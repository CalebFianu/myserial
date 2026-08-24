package com.myserial.catalog;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.myserial.catalog.dto.ShowDetail;
import com.myserial.catalog.dto.ShowSummary;
import com.myserial.catalog.tmdb.TmdbCatalogProvider;
import com.myserial.catalog.tmdb.TmdbProperties;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestTemplate;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

class TmdbCatalogProviderTest {

    private TmdbCatalogProvider provider;
    private MockRestServiceServer mockServer;

    @BeforeEach
    void setUp() {
        RestTemplate restTemplate = new RestTemplate();
        mockServer = MockRestServiceServer.createServer(restTemplate);
        TmdbProperties properties = new TmdbProperties();
        properties.setApiKey("test-key");
        properties.setBaseUrl("https://api.themoviedb.org/3");
        properties.setImageBaseUrl("https://image.tmdb.org/t/p");
        provider = new TmdbCatalogProvider(restTemplate, properties);
    }

    @Test
    void fetchShow_mapsCorrectly() throws Exception {
        String json = loadFixture("tmdb_show_1396.json");
        mockServer.expect(requestTo(containsString("/tv/1396")))
                .andExpect(method(HttpMethod.GET))
                .andRespond(withSuccess(json, MediaType.APPLICATION_JSON));

        ShowDetail detail = provider.fetchShow(1396);

        assertThat(detail).isNotNull();
        assertThat(detail.tmdbId()).isEqualTo(1396);
        assertThat(detail.title()).isEqualTo("Breaking Bad");
        assertThat(detail.status()).isEqualTo("Ended");
        assertThat(detail.network()).isEqualTo("AMC");
        mockServer.verify();
    }

    @Test
    void searchShows_returnsList() throws Exception {
        String json = loadFixture("tmdb_search_breaking.json");
        mockServer.expect(requestTo(containsString("/search/tv")))
                .andExpect(method(HttpMethod.GET))
                .andRespond(withSuccess(json, MediaType.APPLICATION_JSON));

        List<ShowSummary> results = provider.searchShows("breaking bad", "en-US");

        assertThat(results).isNotEmpty();
        assertThat(results.get(0).title()).isEqualTo("Breaking Bad");
        mockServer.verify();
    }

    private String loadFixture(String filename) throws Exception {
        try (InputStream is = getClass().getResourceAsStream("/fixtures/" + filename)) {
            assertThat(is).isNotNull();
            return new String(is.readAllBytes(), StandardCharsets.UTF_8);
        }
    }
}
