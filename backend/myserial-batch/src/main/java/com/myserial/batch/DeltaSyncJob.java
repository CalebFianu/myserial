package com.myserial.batch;

import com.myserial.catalog.ShowSyncAdapter;
import com.myserial.domain.entity.BingeTrack;
import com.myserial.domain.entity.Show;
import com.myserial.domain.service.BingeService;
import com.myserial.domain.service.ShowService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Set;

@Slf4j
@Component
@RequiredArgsConstructor
public class DeltaSyncJob {

    private static final String RETURNING_SERIES = "Returning Series";
    private static final Set<String> TERMINAL_STATUSES = Set.of("Ended", "Canceled");

    private final ShowService showService;
    private final ShowSyncAdapter showSyncAdapter;
    private final BingeService bingeService;

    @Scheduled(cron = "0 0 3 * * *")
    public void run() {
        log.info("DeltaSyncJob starting");
        OffsetDateTime threshold = OffsetDateTime.now().minusHours(23);
        List<Show> showsToSync = showService.findByStatusAndLastSyncedBefore(RETURNING_SERIES, threshold);
        log.info("Found {} shows to sync", showsToSync.size());

        for (Show show : showsToSync) {
            try {
                syncShow(show);
            } catch (Exception e) {
                log.error("Failed to sync show {} (tmdbId={}): {}", show.getId(), show.getTmdbId(), e.getMessage(), e);
            }
        }
        log.info("DeltaSyncJob completed");
    }

    private void syncShow(Show show) {
        String previousStatus = show.getStatus();
        Show updated = showSyncAdapter.fetchAndPersistShow(show.getTmdbId());
        String newStatus = updated.getStatus();

        boolean justFinished = RETURNING_SERIES.equals(previousStatus) && TERMINAL_STATUSES.contains(newStatus);
        if (justFinished) {
            log.info("Show {} (tmdbId={}) has ended/been canceled. Marking binge tracks as wrapped.", updated.getId(), updated.getTmdbId());
            List<BingeTrack> tracks = bingeService.getUnwrappedTracks().stream()
                    .filter(t -> t.getShow().getId().equals(updated.getId()))
                    .toList();
            for (BingeTrack track : tracks) {
                bingeService.markWrapped(track.getUser().getId(), updated.getId());
            }
        }
    }
}
