package com.myserial.api.controller;

import com.myserial.api.dto.response.AlertResponse;
import com.myserial.domain.entity.Alert;
import com.myserial.domain.service.AlertService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/alerts")
@RequiredArgsConstructor
public class AlertController extends BaseController {

    private final AlertService alertService;

    @GetMapping
    public ResponseEntity<Page<AlertResponse>> getAlerts(Pageable pageable) {
        Page<Alert> alerts = alertService.getAlerts(currentUserId(), pageable);
        return ResponseEntity.ok(alerts.map(DtoMapper::toAlertResponse));
    }

    @PostMapping("/{id}/read")
    public ResponseEntity<Void> markRead(@PathVariable Long id) {
        alertService.markRead(currentUserId(), id);
        return ResponseEntity.ok().build();
    }
}
