package com.myserial.api.controller;

import com.myserial.api.dto.request.BulkWatchEpisodesRequest;
import com.myserial.api.dto.request.BulkWatchProgressRequest;
import com.myserial.api.dto.request.BulkWatchRequest;
import com.myserial.api.dto.response.DiaryEntryResponse;
import com.myserial.api.dto.response.UpNextResponse;
import com.myserial.domain.entity.WatchedEpisode;
import com.myserial.domain.service.ActivityService;
import com.myserial.domain.service.WatchService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/watch")
@RequiredArgsConstructor
public class WatchController extends BaseController {

    private final WatchService watchService;
    private final ActivityService activityService;

    @PostMapping("/{episodeId}")
    public ResponseEntity<Void> markWatched(@PathVariable Long episodeId) {
        Long userId = currentUserId();
        WatchedEpisode we = watchService.markWatched(userId, episodeId);
        activityService.log(userId, "EPISODE_WATCHED",
                we.getEpisode().getShow().getId(), episodeId, null, null);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{episodeId}")
    public ResponseEntity<Void> markUnwatched(@PathVariable Long episodeId) {
        watchService.markUnwatched(currentUserId(), episodeId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/batch")
    public ResponseEntity<Void> markBatchWatched(@Valid @RequestBody BulkWatchEpisodesRequest req) {
        Long userId = currentUserId();
        List<WatchedEpisode> created = watchService.markWatchedBatch(userId, req.episodeIds());
        logBatchWatchActivity(userId, req.showId(), created);
        return ResponseEntity.ok().build();
    }

    /**
     * Records activity for a batch log, grouped by season: a single episode
     * becomes an EPISODE_WATCHED event linked to that episode; two or more in the
     * same season become one EPISODES_WATCHED event carrying the season number
     * and count in its metadata.
     */
    private void logBatchWatchActivity(Long userId, Long showId, List<WatchedEpisode> created) {
        if (created.isEmpty()) {
            return;
        }
        Map<Integer, List<WatchedEpisode>> bySeason = created.stream()
                .collect(Collectors.groupingBy(
                        we -> we.getEpisode().getSeasonNumber(),
                        LinkedHashMap::new,
                        Collectors.toList()));

        bySeason.forEach((seasonNumber, episodes) -> {
            if (episodes.size() == 1) {
                WatchedEpisode we = episodes.get(0);
                activityService.log(userId, "EPISODE_WATCHED", showId,
                        we.getEpisode().getId(), null, null);
            } else {
                String metadata = String.format(
                        "{\"seasonNumber\":%d,\"episodeCount\":%d}",
                        seasonNumber, episodes.size());
                activityService.log(userId, "EPISODES_WATCHED", showId, null, null, metadata);
            }
        });
    }

    @PostMapping("/season")
    public ResponseEntity<Void> bulkMarkSeason(@Valid @RequestBody BulkWatchRequest req) {
        Long userId = currentUserId();
        watchService.bulkMarkSeasonWatched(userId, req.showId(), req.seasonNumber());
        activityService.log(userId, "SEASON_WATCHED", req.showId(), null, null,
                "{\"seasonNumber\":" + req.seasonNumber() + "}");
        return ResponseEntity.ok().build();
    }

    @PostMapping("/progress")
    public ResponseEntity<Void> bulkMarkProgress(@Valid @RequestBody BulkWatchProgressRequest req) {
        Long userId = currentUserId();
        watchService.bulkMarkUpToEpisode(userId, req.showId(), req.seasonNumber(), req.episodeNumber());
        activityService.log(userId, "SEASON_WATCHED", req.showId(), null, null,
                "{\"seasonNumber\":" + req.seasonNumber() + ",\"episodeNumber\":" + req.episodeNumber() + "}");
        return ResponseEntity.ok().build();
    }

    @PostMapping("/show/{showId}")
    public ResponseEntity<Void> bulkMarkEntireShow(@PathVariable Long showId) {
        Long userId = currentUserId();
        watchService.bulkMarkEntireShowWatched(userId, showId);
        activityService.log(userId, "SERIES_WATCHED", showId, null, null, null);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/up-next")
    public ResponseEntity<List<UpNextResponse>> getUpNext() {
        List<WatchService.UpNextResult> results = watchService.getUpNext(currentUserId());
        return ResponseEntity.ok(results.stream().map(DtoMapper::toUpNextResponse).toList());
    }

    @GetMapping("/diary")
    public ResponseEntity<Page<DiaryEntryResponse>> getDiary(Pageable pageable) {
        Page<WatchedEpisode> page = watchService.getDiary(currentUserId(), pageable);
        return ResponseEntity.ok(page.map(DtoMapper::toDiaryEntryResponse));
    }
}
