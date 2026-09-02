package com.myserial.batch;

import com.myserial.catalog.ShowSyncAdapter;
import com.myserial.catalog.tmdb.TmdbExportClient;
import com.myserial.domain.entity.Show;
import com.myserial.domain.service.ShowService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.OffsetDateTime;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class CatalogSeedJob {

    private final TmdbExportClient exportClient;
    private final ShowService showService;
    private final ShowSyncAdapter showSyncAdapter;
    private final CatalogSeedProperties props;

    public record SeedResult(int requestedCount, int rosterCount, int hydratedCount, String message) {}

    @EventListener(ApplicationReadyEvent.class)
    public void onApplicationReady() {
        if (props.isEnabled() && props.isRunOnStartup()) {
            log.info("Running CatalogSeedJob on startup as configured");
            run();
        }
    }

    @Scheduled(cron = "${tmdb.seed.cron:0 0 4 * * *}")
    public void run() {
        if (!props.isEnabled()) {
            log.info("CatalogSeedJob is disabled; skipping");
            return;
        }

        log.info("CatalogSeedJob starting with rosterSize={}, hydratePerRun={}, refreshPerRun={}",
                props.getRosterSize(), props.getHydratePerRun(), props.getRefreshPerRun());

        seedFromExport(props.getRosterSize());

        // Pass 3: Refresh pass
        try {
            OffsetDateTime cutoff = OffsetDateTime.now().minusDays(props.getRefreshAfterDays());
            List<Show> stale = showService.findHydratedOlderThan(cutoff, props.getRefreshPerRun());
            log.info("Found {} stale hydrated shows to refresh (older than {} days)", stale.size(), props.getRefreshAfterDays());
            for (Show show : stale) {
                try {
                    showSyncAdapter.fetchAndPersistShow(show.getTmdbId());
                    log.debug("Successfully refreshed show {} (tmdbId={})", show.getTitle(), show.getTmdbId());
                    if (props.getRequestDelayMs() > 0) {
                        Thread.sleep(props.getRequestDelayMs());
                    }
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    log.warn("CatalogSeedJob refresh interrupted");
                    break;
                } catch (Exception e) {
                    log.error("Failed to refresh show {} (tmdbId={}): {}", show.getId(), show.getTmdbId(), e.getMessage(), e);
                }
            }
        } catch (Exception e) {
            log.error("Failed during CatalogSeedJob refresh pass: {}", e.getMessage(), e);
        }

        log.info("CatalogSeedJob finished");
    }

    /**
     * Seeds the top shows from the TMDB export file sorted by popularity,
     * and hydrates the stub show entities.
     *
     * @param count The number of shows to seed from the export.
     * @return SeedResult containing details on the number of roster and hydrated items.
     */
    public SeedResult seedFromExport(int count) {
        int targetCount = count > 0 ? count : props.getRosterSize();
        log.info("Starting seedFromExport with count={}", targetCount);

        int rosterCount = 0;
        int hydratedCount = 0;

        // Pass 1: Roster upsert
        try {
            List<TmdbExportClient.ExportEntry> entries = exportClient.fetchTopSeries(targetCount);
            if (entries != null && !entries.isEmpty()) {
                List<ShowService.RosterEntry> rosterEntries = entries.stream()
                        .map(e -> new ShowService.RosterEntry(e.id(), e.originalName(), e.popularity()))
                        .toList();
                showService.upsertRosterEntries(rosterEntries);
                rosterCount = rosterEntries.size();
                log.info("Upserted {} roster entries from TMDB export", rosterCount);
            } else {
                log.warn("No export entries retrieved from TMDB export");
            }
        } catch (Exception e) {
            log.error("Failed during CatalogSeedJob roster upsert pass: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to fetch or upsert TMDB export roster: " + e.getMessage(), e);
        }

        // Pass 2: Hydration pass
        try {
            List<Show> unhydrated = showService.findUnhydrated(targetCount);
            log.info("Found {} unhydrated shows to hydrate", unhydrated.size());
            for (Show show : unhydrated) {
                try {
                    showSyncAdapter.fetchAndPersistShow(show.getTmdbId());
                    hydratedCount++;
                    log.debug("Successfully hydrated show {} (tmdbId={})", show.getTitle(), show.getTmdbId());
                    if (props.getRequestDelayMs() > 0) {
                        Thread.sleep(props.getRequestDelayMs());
                    }
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    log.warn("CatalogSeedJob hydration interrupted");
                    break;
                } catch (Exception e) {
                    log.error("Failed to hydrate show {} (tmdbId={}): {}", show.getId(), show.getTmdbId(), e.getMessage(), e);
                }
            }
        } catch (Exception e) {
            log.error("Failed during CatalogSeedJob hydration pass: {}", e.getMessage(), e);
        }

        String msg = String.format("Seeded %d roster entries and hydrated %d shows from export", rosterCount, hydratedCount);
        log.info("Finished seedFromExport: {}", msg);
        return new SeedResult(targetCount, rosterCount, hydratedCount, msg);
    }
}
