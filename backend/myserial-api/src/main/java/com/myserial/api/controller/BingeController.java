package com.myserial.api.controller;

import com.myserial.api.dto.response.BingeTrackResponse;
import com.myserial.domain.entity.BingeTrack;
import com.myserial.domain.service.ActivityService;
import com.myserial.domain.service.BingeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/binge")
@RequiredArgsConstructor
public class BingeController extends BaseController {

    private final BingeService bingeService;
    private final ActivityService activityService;

    @GetMapping
    public ResponseEntity<List<BingeTrackResponse>> getTrackedShows() {
        List<BingeTrack> tracks = bingeService.getTrackedShows(currentUserId());
        return ResponseEntity.ok(tracks.stream().map(DtoMapper::toBingeTrackResponse).toList());
    }

    @PostMapping("/{showId}")
    public ResponseEntity<BingeTrackResponse> trackShow(@PathVariable Long showId) {
        Long userId = currentUserId();
        BingeTrack track = bingeService.trackShow(userId, showId);
        activityService.log(userId, "BINGE_STARTED", showId, null, null, null);
        return ResponseEntity.ok(DtoMapper.toBingeTrackResponse(track));
    }

    @DeleteMapping("/{showId}")
    public ResponseEntity<Void> untrackShow(@PathVariable Long showId) {
        bingeService.untrackShow(currentUserId(), showId);
        return ResponseEntity.noContent().build();
    }
}
