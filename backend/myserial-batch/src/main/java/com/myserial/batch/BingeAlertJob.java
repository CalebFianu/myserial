package com.myserial.batch;

import com.myserial.domain.entity.BingeTrack;
import com.myserial.domain.repository.BingeTrackRepository;
import com.myserial.domain.service.AlertService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class BingeAlertJob {

    private final BingeTrackRepository bingeTrackRepository;
    private final AlertService alertService;

    @Scheduled(cron = "0 30 3 * * *")
    public void run() {
        log.info("BingeAlertJob starting");
        List<BingeTrack> tracks = bingeTrackRepository.findByWrappedTrueAndAlertedFalse();
        log.info("Found {} tracks to alert", tracks.size());

        for (BingeTrack track : tracks) {
            try {
                String showTitle = track.getShow().getTitle();
                alertService.createAlert(
                        track.getUser().getId(),
                        track.getShow(),
                        "\"" + showTitle + "\" has finished!",
                        "The show you were tracking has ended. Time to find your next binge!"
                );
                track.setAlerted(true);
                bingeTrackRepository.save(track);
                log.info("Alerted user {} about show {}", track.getUser().getId(), showTitle);
            } catch (Exception e) {
                log.error("Failed to create alert for binge track {}: {}", track.getId(), e.getMessage(), e);
            }
        }
        log.info("BingeAlertJob completed");
    }
}
