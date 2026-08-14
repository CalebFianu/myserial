package com.myserial.api.controller;

import com.myserial.api.dto.response.*;
import com.myserial.api.exception.NotFoundException;
import com.myserial.catalog.CatalogProvider;
import com.myserial.catalog.dto.ShowSummary;
import com.myserial.domain.entity.*;
import com.myserial.domain.service.ShowService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/shows")
@RequiredArgsConstructor
public class ShowController extends BaseController {

    private final ShowService showService;
    private final CatalogProvider catalogProvider;

    @GetMapping("/search")
    public ResponseEntity<Page<ShowSummaryResponse>> search(
            @RequestParam String q,
            @RequestParam(defaultValue = "en-US") String language,
            Pageable pageable) {
        List<ShowSummary> results = catalogProvider.searchShows(q, language);
        List<ShowSummaryResponse> mapped = results.stream().map(s -> new ShowSummaryResponse(
                null, s.tmdbId(), s.title(), s.originalTitle(), s.overview(),
                s.posterPath(), s.backdropPath(), s.firstAirDate(), s.voteAverage(),
                s.popularity(), s.status(), null
        )).toList();
        int start = (int) pageable.getOffset();
        int end = Math.min(start + pageable.getPageSize(), mapped.size());
        List<ShowSummaryResponse> page = start >= mapped.size() ? List.of() : mapped.subList(start, end);
        return ResponseEntity.ok(new PageImpl<>(page, pageable, mapped.size()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ShowDetailResponse> getShow(
            @PathVariable Long id,
            @RequestParam(defaultValue = "US") String country) {
        Show show = showService.findById(id);
        List<Season> seasons = showService.getSeasons(id);
        List<Credit> credits = showService.getCredits(id);
        List<StreamingAvailability> streaming = showService.getStreamingAvailability(id, country);

        List<SeasonResponse> seasonResponses = seasons.stream().map(s -> {
            List<Episode> eps = showService.getSeasonEpisodes(id, s.getSeasonNumber());
            return DtoMapper.toSeasonResponse(s, eps);
        }).toList();

        List<CastMemberResponse> castPreview = credits.stream()
                .filter(c -> "CAST".equals(c.getCreditType()))
                .sorted(java.util.Comparator.comparingInt(c -> c.getDisplayOrder() != null ? c.getDisplayOrder() : 999))
                .limit(4)
                .map(DtoMapper::toCastMemberResponse)
                .toList();

        List<CrewMemberResponse> crewPreview = credits.stream()
                .filter(c -> "CREW".equals(c.getCreditType()))
                .limit(3)
                .map(DtoMapper::toCrewMemberResponse)
                .toList();

        List<StreamingProviderResponse> streamingResponses = streaming.stream()
                .map(DtoMapper::toStreamingProviderResponse)
                .toList();

        ShowDetailResponse response = new ShowDetailResponse(
                show.getId(), show.getTmdbId(), show.getTitle(), show.getOriginalTitle(),
                show.getOverview(), show.getStatus(), show.getFirstAirDate(), show.getLastAirDate(),
                show.getPosterPath(), show.getBackdropPath(), show.getGenres(), show.getNetwork(),
                show.getEpisodeRunTime(), show.getVoteAverage(), show.getVoteCount(), show.getPopularity(),
                seasonResponses, castPreview, crewPreview, streamingResponses
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}/seasons/{seasonNumber}")
    public ResponseEntity<SeasonResponse> getSeason(@PathVariable Long id, @PathVariable int seasonNumber) {
        Season season = showService.getSeasonWithEpisodes(id, seasonNumber)
                .orElseThrow(() -> new NotFoundException("Season not found: S" + seasonNumber));
        List<Episode> eps = showService.getSeasonEpisodes(id, seasonNumber);
        return ResponseEntity.ok(DtoMapper.toSeasonResponse(season, eps));
    }

    @GetMapping("/{id}/cast")
    public ResponseEntity<CastResponse> getCast(@PathVariable Long id, @RequestParam(required = false) String q) {
        List<Credit> credits = showService.getCredits(id);
        List<CastMemberResponse> cast = credits.stream()
                .filter(c -> "CAST".equals(c.getCreditType()))
                .filter(c -> q == null || c.getPerson().getName().toLowerCase().contains(q.toLowerCase()))
                .sorted(java.util.Comparator.comparingInt(c -> c.getDisplayOrder() != null ? c.getDisplayOrder() : 999))
                .map(DtoMapper::toCastMemberResponse)
                .toList();
        List<CrewMemberResponse> crew = credits.stream()
                .filter(c -> "CREW".equals(c.getCreditType()))
                .filter(c -> q == null || c.getPerson().getName().toLowerCase().contains(q.toLowerCase()))
                .map(DtoMapper::toCrewMemberResponse)
                .toList();
        return ResponseEntity.ok(new CastResponse(cast, crew));
    }
}
