package com.myserial.api.controller;

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

import java.util.List;

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
