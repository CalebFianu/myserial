package com.myserial.domain.repository;

import com.myserial.domain.entity.Show;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.time.OffsetDateTime;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest(
    properties = {
        "spring.flyway.enabled=true",
        "spring.flyway.locations=classpath:db/migration",
        "spring.jpa.hibernate.ddl-auto=validate"
    }
)
@Testcontainers
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
class ShowRepositoryTest {

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
    }

    @Autowired
    private ShowRepository showRepository;

    @Test
    void saveAndFindByTmdbId() {
        Show show = Show.builder()
                .tmdbId(1396)
                .title("Breaking Bad")
                .status("Ended")
                .build();
        showRepository.save(show);

        Optional<Show> found = showRepository.findByTmdbId(1396);
        assertThat(found).isPresent();
        assertThat(found.get().getTitle()).isEqualTo("Breaking Bad");
    }

    @Test
    void findByStatusAndLastSyncedAtBefore_returnsMatchingShows() {
        Show show = Show.builder()
                .tmdbId(9999)
                .title("Some Show")
                .status("Returning Series")
                .lastSyncedAt(OffsetDateTime.now().minusHours(25))
                .build();
        showRepository.save(show);

        var results = showRepository.findByStatusAndLastSyncedAtBefore(
                "Returning Series", OffsetDateTime.now().minusHours(23));
        assertThat(results).isNotEmpty();
        assertThat(results.stream().anyMatch(s -> s.getTmdbId() == 9999)).isTrue();
    }

    @Test
    void findByStatusAndLastSyncedAtBefore_excludesRecentlySynced() {
        Show show = Show.builder()
                .tmdbId(8888)
                .title("Fresh Show")
                .status("Returning Series")
                .lastSyncedAt(OffsetDateTime.now().minusHours(1))
                .build();
        showRepository.save(show);

        var results = showRepository.findByStatusAndLastSyncedAtBefore(
                "Returning Series", OffsetDateTime.now().minusHours(23));
        assertThat(results.stream().anyMatch(s -> s.getTmdbId() == 8888)).isFalse();
    }
}
