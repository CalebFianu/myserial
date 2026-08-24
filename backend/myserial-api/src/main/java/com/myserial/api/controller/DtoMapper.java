package com.myserial.api.controller;

import com.myserial.api.dto.response.*;
import com.myserial.domain.entity.*;

import java.util.Collections;
import java.util.List;

/**
 * Utility class for mapping domain entities to response DTOs.
 */
public final class DtoMapper {

    private DtoMapper() {}

    public static UserResponse toUserResponse(User user) {
        return new UserResponse(user.getId(), user.getName(), user.getEmail(),
                user.getHandle(), user.getBio(), user.getAvatarPath(),
                user.getOnboardingCompleted(), user.getCreatedAt());
    }

    public static ShowSummaryResponse toShowSummaryResponse(Show show) {
        return new ShowSummaryResponse(show.getId(), show.getTmdbId(), show.getTitle(),
                show.getOriginalTitle(), show.getOverview(), show.getPosterPath(),
                show.getBackdropPath(), show.getFirstAirDate(), show.getVoteAverage(),
                show.getPopularity(), show.getStatus(), show.getNetwork());
    }

    public static EpisodeResponse toEpisodeResponse(Episode episode) {
        return new EpisodeResponse(episode.getId(), episode.getTmdbId(),
                episode.getSeasonNumber(), episode.getEpisodeNumber(), episode.getName(),
                episode.getOverview(), episode.getAirDate(), episode.getStillPath(),
                episode.getRuntime(), episode.getVoteAverage());
    }

    public static SeasonResponse toSeasonResponse(Season season, List<Episode> episodes) {
        List<EpisodeResponse> episodeResponses = episodes == null ? Collections.emptyList()
                : episodes.stream().map(DtoMapper::toEpisodeResponse).toList();
        return new SeasonResponse(season.getId(), season.getTmdbId(), season.getSeasonNumber(),
                season.getName(), season.getOverview(), season.getPosterPath(),
                season.getAirDate(), season.getEpisodeCount(), episodeResponses);
    }

    public static CastMemberResponse toCastMemberResponse(Credit credit) {
        Person person = credit.getPerson();
        return new CastMemberResponse(person.getId(), person.getTmdbId(), person.getName(),
                credit.getCharacterName(), person.getProfilePath(), credit.getDisplayOrder());
    }

    public static CrewMemberResponse toCrewMemberResponse(Credit credit) {
        Person person = credit.getPerson();
        return new CrewMemberResponse(person.getId(), person.getTmdbId(), person.getName(),
                credit.getDepartment(), credit.getJob(), person.getProfilePath());
    }

    public static StreamingProviderResponse toStreamingProviderResponse(StreamingAvailability sa) {
        return new StreamingProviderResponse(sa.getProviderId(), sa.getProviderName(),
                sa.getProviderLogoPath(), sa.getOfferType(), sa.getCountryCode(), sa.getLink());
    }

    public static EpisodeRatingResponse toEpisodeRatingResponse(EpisodeRating rating) {
        Episode ep = rating.getEpisode();
        return new EpisodeRatingResponse(rating.getId(), ep.getId(), ep.getSeasonNumber(),
                ep.getEpisodeNumber(), ep.getName(), rating.getScore(), rating.getReview(),
                rating.getCreatedAt(), rating.getUpdatedAt());
    }

    public static UserListResponse toUserListResponse(UserList list) {
        List<ShowSummaryResponse> shows = list.getItems() == null ? Collections.emptyList()
                : list.getItems().stream().map(item -> toShowSummaryResponse(item.getShow())).toList();
        return new UserListResponse(list.getId(), list.getName(), list.getNote(),
                list.getIsWatchlist(), list.getCreatedAt(), shows);
    }

    public static BingeTrackResponse toBingeTrackResponse(BingeTrack track) {
        return new BingeTrackResponse(track.getId(), toShowSummaryResponse(track.getShow()),
                track.getWrapped(), track.getAlerted(), track.getCreatedAt(), track.getWrappedAt());
    }

    public static AlertResponse toAlertResponse(Alert alert) {
        Long showId = alert.getShow() != null ? alert.getShow().getId() : null;
        String showTitle = alert.getShow() != null ? alert.getShow().getTitle() : null;
        return new AlertResponse(alert.getId(), showId, showTitle, alert.getTitle(),
                alert.getBody(), alert.getCreatedAt(), alert.getReadAt());
    }

    public static ActivityEventResponse toActivityEventResponse(ActivityEvent event) {
        Long showId = event.getShow() != null ? event.getShow().getId() : null;
        String showTitle = event.getShow() != null ? event.getShow().getTitle() : null;
        Long episodeId = event.getEpisode() != null ? event.getEpisode().getId() : null;
        Long listId = event.getList() != null ? event.getList().getId() : null;
        return new ActivityEventResponse(event.getId(), event.getUser().getId(),
                event.getUser().getHandle(), event.getEventType(), showId, showTitle,
                episodeId, listId, event.getMetadata(), event.getCreatedAt());
    }

    public static DiaryEntryResponse toDiaryEntryResponse(WatchedEpisode we) {
        Show show = we.getEpisode().getShow();
        return new DiaryEntryResponse(we.getId(), show.getId(), show.getTitle(),
                show.getPosterPath(), toEpisodeResponse(we.getEpisode()), we.getWatchedAt());
    }

    public static UpNextResponse toUpNextResponse(com.myserial.domain.service.WatchService.UpNextResult result) {
        return new UpNextResponse(toShowSummaryResponse(result.show()), toEpisodeResponse(result.nextEpisode()));
    }
}
