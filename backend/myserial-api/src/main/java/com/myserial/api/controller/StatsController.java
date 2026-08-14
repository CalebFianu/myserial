package com.myserial.api.controller;

import com.myserial.api.dto.response.StatsResponse;
import com.myserial.domain.service.StatsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/stats")
@RequiredArgsConstructor
public class StatsController extends BaseController {

    private final StatsService statsService;

    @GetMapping
    public ResponseEntity<StatsResponse> getStats() {
        StatsService.Stats stats = statsService.getStats(currentUserId());
        return ResponseEntity.ok(new StatsResponse(
                stats.episodesWatched(),
                stats.totalMinutes(),
                stats.ratingsHistogram()
        ));
    }
}
