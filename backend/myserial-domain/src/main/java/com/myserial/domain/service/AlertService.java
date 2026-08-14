package com.myserial.domain.service;

import com.myserial.domain.entity.Alert;
import com.myserial.domain.entity.Show;
import com.myserial.domain.entity.User;
import com.myserial.domain.repository.AlertRepository;
import com.myserial.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;

@Service
@RequiredArgsConstructor
public class AlertService {

    private final AlertRepository alertRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public Page<Alert> getAlerts(Long userId, Pageable pageable) {
        return alertRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
    }

    @Transactional
    public void markRead(Long userId, Long alertId) {
        alertRepository.findById(alertId).ifPresent(alert -> {
            if (alert.getUser().getId().equals(userId)) {
                alert.setReadAt(OffsetDateTime.now());
                alertRepository.save(alert);
            }
        });
    }

    @Transactional
    public Alert createAlert(Long userId, Show show, String title, String body) {
        User user = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));
        Alert alert = Alert.builder()
                .user(user)
                .show(show)
                .title(title)
                .body(body)
                .build();
        return alertRepository.save(alert);
    }

    @Transactional(readOnly = true)
    public long countUnread(Long userId) {
        return alertRepository.countByUserIdAndReadAtIsNull(userId);
    }
}
