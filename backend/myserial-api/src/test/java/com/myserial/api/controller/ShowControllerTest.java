package com.myserial.api.controller;

import com.myserial.batch.CatalogSeedJob;
import com.myserial.catalog.CatalogProvider;
import com.myserial.catalog.dto.ShowSummary;
import com.myserial.domain.entity.Show;
import com.myserial.domain.repository.ShowRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@Testcontainers
@ActiveProfiles("test")
class ShowControllerTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine")
            .withDatabaseName("myserial_test")
            .withUsername("test")
            .withPassword("test");

    @DynamicPropertySource
    static void overrideProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
        registry.add("spring.flyway.locations", () -> "classpath:db/migration");
        registry.add("tmdb.api-key", () -> "test-key");
        registry.add("jwt.secret", () -> "test-secret-key-at-least-32-chars-long-for-hmac256");
        registry.add("tmdb.seed.enabled", () -> "false");
    }

    @Autowired
    MockMvc mockMvc;

    @Autowired
    ShowRepository showRepository;

    @MockBean
    CatalogProvider catalogProvider;

    @MockBean
    CatalogSeedJob catalogSeedJob;

    @BeforeEach
    void cleanUp() {
        showRepository.deleteAll();
    }

    @Test
    void search_localHit_returnsRealIdAndSkipsRemote() throws Exception {
        Show show = Show.builder()
                .tmdbId(9999)
                .title("Local Hit Show")
                .originalTitle("Local Hit Show")
                .popularity(BigDecimal.valueOf(50.0))
                .lastSyncedAt(OffsetDateTime.now())
                .build();
        Show saved = showRepository.save(show);

        mockMvc.perform(get("/api/v1/shows/search")
                        .param("q", "Local Hit Show")
                        .param("limit", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(saved.getId()))
                .andExpect(jsonPath("$[0].tmdbId").value(9999))
                .andExpect(jsonPath("$[0].title").value("Local Hit Show"));

        verifyNoInteractions(catalogProvider);
    }

    @Test
    void search_noLocalHit_fallsBackToCatalogProvider() throws Exception {
        ShowSummary remoteSummary = new ShowSummary(
                8888, "Remote TMDB Show", "Remote TMDB Show",
                "Remote overview", "/poster.jpg", "/backdrop.jpg",
                LocalDate.parse("2023-01-01"), BigDecimal.valueOf(8.5), BigDecimal.valueOf(40.0), "Returning Series"
        );
        when(catalogProvider.searchShows("Remote TMDB Show", "en-US"))
                .thenReturn(List.of(remoteSummary));

        mockMvc.perform(get("/api/v1/shows/search")
                        .param("q", "Remote TMDB Show"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").isNumber())
                .andExpect(jsonPath("$[0].tmdbId").value(8888))
                .andExpect(jsonPath("$[0].title").value("Remote TMDB Show"));

        verify(catalogProvider, times(1)).searchShows("Remote TMDB Show", "en-US");
    }

    @Test
    void seedCatalog_defaultCount_callsCatalogSeedJobWith100() throws Exception {
        when(catalogSeedJob.seedFromExport(100))
                .thenReturn(new CatalogSeedJob.SeedResult(100, 100, 100, "Seeded 100 roster entries and hydrated 100 shows from export"));

        mockMvc.perform(post("/api/v1/shows/seed"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.requestedCount").value(100))
                .andExpect(jsonPath("$.rosterCount").value(100))
                .andExpect(jsonPath("$.hydratedCount").value(100));

        verify(catalogSeedJob, times(1)).seedFromExport(100);
    }

    @Test
    void seedCatalog_customCount_callsCatalogSeedJobWithCustomCount() throws Exception {
        when(catalogSeedJob.seedFromExport(50))
                .thenReturn(new CatalogSeedJob.SeedResult(50, 50, 50, "Seeded 50 roster entries and hydrated 50 shows from export"));

        mockMvc.perform(post("/api/v1/shows/seed").param("count", "50"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.requestedCount").value(50))
                .andExpect(jsonPath("$.rosterCount").value(50))
                .andExpect(jsonPath("$.hydratedCount").value(50));

        verify(catalogSeedJob, times(1)).seedFromExport(50);
    }
}
