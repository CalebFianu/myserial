package com.myserial.api.controller;

import com.myserial.api.dto.response.ActivityEventResponse;
import com.myserial.domain.entity.ActivityEvent;
import com.myserial.domain.service.ActivityService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/activity")
@RequiredArgsConstructor
public class ActivityController extends BaseController {

    private final ActivityService activityService;

    @GetMapping
    public ResponseEntity<Page<ActivityEventResponse>> getFeed(Pageable pageable) {
        Page<ActivityEvent> page = activityService.getFeed(currentUserId(), pageable);
        return ResponseEntity.ok(page.map(DtoMapper::toActivityEventResponse));
    }
}
