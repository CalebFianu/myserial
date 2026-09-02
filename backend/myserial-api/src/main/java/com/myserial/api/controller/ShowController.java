package com.myserial.api.controller;

import com.myserial.api.dto.response.*;
import com.myserial.batch.CatalogSeedJob;
import com.myserial.domain.entity.*;
import com.myserial.domain.repository.BingeTrackRepository;
import com.myserial.domain.repository.WatchedEpisodeRepository;
import com.myserial.domain.service.ListService;
import com.myserial.domain.service.ShowService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/shows")
@RequiredArgsConstructor
public class ShowController extends BaseController {

    private final ShowService showService;
    private final ListService listService;
    private final WatchedEpisodeRepository watchedEpisodeRepository;
    private final BingeTrackRepository bingeTrackRepository;
    private final CatalogSeedJob catalogSeedJob;

    @GetMapping("/search")
    public ResponseEntity<List<ShowSummaryResponse>> search(
            @RequestParam String q,
            @RequestParam(defaultValue = "20") int limit) {
        List<Show> results = showService.search(q, limit);
        return ResponseEntity.ok(results.stream().map(DtoMapper::toShowSummaryResponse).toList());
    }

    @PostMapping("/seed")
    public ResponseEntity<CatalogSeedJob.SeedResult> seedCatalog(
            @RequestParam(defaultValue = "100") int count) {
        CatalogSeedJob.SeedResult result = catalogSeedJob.seedFromExport(count);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ShowDetailResponse> getShow(@PathVariable Long id) {
        Show show = showService.findById(id);
        Long showId = show.getId();

        List<Season> seasons = showService.getSeasons(showId);
        List<Credit> credits = showService.getCredits(showId);
        List<StreamingAvailability> streaming = showService.getStreamingAvailability(showId, null);

        List<SeasonResponse> seasonResponses = seasons.stream()
                .map(s -> DtoMapper.toSeasonResponse(s, null))
                .toList();

        List<CastMemberResponse> castPreview = credits.stream()
                .filter(c -> "CAST".equals(c.getCreditType()))
                .sorted(java.util.Comparator.comparingInt(c -> c.getDisplayOrder() != null ? c.getDisplayOrder() : 999))
                .limit(10)
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

        Long userId = optionalCurrentUserId();
        boolean inWatchlist = userId != null && listService.isInWatchlist(userId, showId);
        long watchedCount = userId != null ? watchedEpisodeRepository.countByUserIdAndEpisodeShowId(userId, showId) : 0;
        boolean isTracked = userId != null && bingeTrackRepository.existsByUserIdAndShowId(userId, showId);

        ShowDetailResponse response = new ShowDetailResponse(
                show.getId(), show.getTmdbId(), show.getTitle(), show.getOriginalTitle(),
                show.getOverview(), show.getStatus(), show.getFirstAirDate(), show.getLastAirDate(),
                show.getPosterPath(), show.getBackdropPath(), show.getGenres(), show.getNetwork(),
                show.getEpisodeRunTime(), show.getVoteAverage(), show.getVoteCount(), show.getPopularity(),
                seasonResponses, castPreview, crewPreview, streamingResponses,
                inWatchlist, watchedCount, isTracked
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}/seasons/{seasonNumber}")
    public ResponseEntity<SeasonResponse> getSeason(@PathVariable Long id, @PathVariable int seasonNumber) {
        Season season = showService.getSeasonWithEpisodes(id, seasonNumber)
                .orElseThrow(() -> new com.myserial.api.exception.NotFoundException("Season not found: S" + seasonNumber));
        List<Episode> eps = showService.getSeasonEpisodes(id, seasonNumber);

        Long userId = optionalCurrentUserId();
        java.util.Set<Long> watchedEpisodeIds = userId != null
                ? watchedEpisodeRepository.findEpisodeIdsByUserIdAndShowId(userId, id)
                : java.util.Collections.emptySet();

        return ResponseEntity.ok(DtoMapper.toSeasonResponse(season, eps, watchedEpisodeIds));
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

    @GetMapping("/popular")
    public ResponseEntity<List<ShowSummaryResponse>> getPopular() {
        List<Show> shows = showService.getPopular(20);
        return ResponseEntity.ok(shows.stream().map(DtoMapper::toShowSummaryResponse).toList());
    }

    @GetMapping("/{id}/recap")
    public ResponseEntity<RecapResponse> getRecap(
            @PathVariable Long id,
            @RequestParam(defaultValue = "1") int chunkSize) {
        Long userId = optionalCurrentUserId();
        ShowService.RecapResult result = showService.getRecap(id, userId, chunkSize);
        List<RecapResponse.RecapChapter> chapters = result.chapters().stream()
                .map(c -> new RecapResponse.RecapChapter(c.range(), c.title(), c.body(), c.unlockAfterEpisode()))
                .toList();
        return ResponseEntity.ok(new RecapResponse(
                chapters,
                result.watchedCount()
        ));
    }
}
