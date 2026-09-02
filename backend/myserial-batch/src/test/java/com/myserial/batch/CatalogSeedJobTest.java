package com.myserial.batch;

import com.myserial.catalog.ShowSyncAdapter;
import com.myserial.catalog.tmdb.TmdbExportClient;
import com.myserial.domain.entity.Show;
import com.myserial.domain.service.ShowService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class CatalogSeedJobTest {

    @Mock
    private TmdbExportClient exportClient;

    @Mock
    private ShowService showService;

    @Mock
    private ShowSyncAdapter showSyncAdapter;

    private CatalogSeedProperties properties;
    private CatalogSeedJob job;

    @BeforeEach
    void setUp() {
        properties = new CatalogSeedProperties();
        properties.setEnabled(true);
        properties.setRosterSize(100);
        properties.setHydratePerRun(100);
        properties.setRefreshPerRun(25);
        properties.setRefreshAfterDays(14);
        properties.setRequestDelayMs(0);

        job = new CatalogSeedJob(exportClient, showService, showSyncAdapter, properties);
    }

    @Test
    void run_executesRosterUpsert_hydration_andRefresh() {
        List<TmdbExportClient.ExportEntry> entries = List.of(
                new TmdbExportClient.ExportEntry(101, "Show A", 90.0),
                new TmdbExportClient.ExportEntry(102, "Show B", 80.0)
        );
        when(exportClient.fetchTopSeries(100)).thenReturn(entries);

        Show show1 = Show.builder().id(1L).tmdbId(101).title("Show A").popularity(BigDecimal.valueOf(90.0)).build();
        Show show2 = Show.builder().id(2L).tmdbId(102).title("Show B").popularity(BigDecimal.valueOf(80.0)).build();
        when(showService.findUnhydrated(100)).thenReturn(List.of(show1, show2));

        Show staleShow = Show.builder().id(3L).tmdbId(103).title("Show C").popularity(BigDecimal.valueOf(70.0)).build();
        when(showService.findHydratedOlderThan(any(OffsetDateTime.class), eq(25))).thenReturn(List.of(staleShow));

        job.run();

        verify(showService, times(1)).upsertRosterEntries(anyList());
        verify(showSyncAdapter, times(1)).fetchAndPersistShow(101);
        verify(showSyncAdapter, times(1)).fetchAndPersistShow(102);
        verify(showSyncAdapter, times(1)).fetchAndPersistShow(103);
    }

    @Test
    void seedFromExport_executesWithCustomCount() {
        List<TmdbExportClient.ExportEntry> entries = List.of(
                new TmdbExportClient.ExportEntry(201, "Show 1", 99.0),
                new TmdbExportClient.ExportEntry(202, "Show 2", 88.0)
        );
        when(exportClient.fetchTopSeries(50)).thenReturn(entries);

        Show show1 = Show.builder().id(1L).tmdbId(201).title("Show 1").popularity(BigDecimal.valueOf(99.0)).build();
        Show show2 = Show.builder().id(2L).tmdbId(202).title("Show 2").popularity(BigDecimal.valueOf(88.0)).build();
        when(showService.findUnhydrated(50)).thenReturn(List.of(show1, show2));

        CatalogSeedJob.SeedResult result = job.seedFromExport(50);

        assertNotNull(result);
        assertEquals(50, result.requestedCount());
        assertEquals(2, result.rosterCount());
        assertEquals(2, result.hydratedCount());

        verify(exportClient, times(1)).fetchTopSeries(50);
        verify(showService, times(1)).upsertRosterEntries(anyList());
        verify(showSyncAdapter, times(1)).fetchAndPersistShow(201);
        verify(showSyncAdapter, times(1)).fetchAndPersistShow(202);
    }

    @Test
    void run_whenDisabled_doesNothing() {
        properties.setEnabled(false);

        job.run();

        verifyNoInteractions(exportClient, showService, showSyncAdapter);
    }
}
