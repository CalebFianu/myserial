package com.myserial.catalog.tmdb;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class TmdbExportClientTest {

    private TmdbExportClient client;

    @BeforeEach
    void setUp() {
        client = new TmdbExportClient(new ObjectMapper());
    }

    @Test
    void parseExportStream_returnsTopEntriesInDescendingPopularity() {
        String jsonLines = """
                {"id":101,"original_name":"Show Low","popularity":5.2}
                {"id":102,"original_name":"Show Med","popularity":45.8}
                {"id":103,"original_name":"Show Highest","popularity":99.4}
                {"id":104,"original_name":"Show High","popularity":82.1}
                {"id":105,"original_name":"Show Lowest","popularity":1.0}
                """;

        ByteArrayInputStream is = new ByteArrayInputStream(jsonLines.getBytes(StandardCharsets.UTF_8));
        List<TmdbExportClient.ExportEntry> top3 = client.parseExportStream(is, 3);

        assertThat(top3).hasSize(3);
        assertThat(top3.get(0).id()).isEqualTo(103);
        assertThat(top3.get(0).originalName()).isEqualTo("Show Highest");
        assertThat(top3.get(0).popularity()).isEqualTo(99.4);

        assertThat(top3.get(1).id()).isEqualTo(104);
        assertThat(top3.get(1).originalName()).isEqualTo("Show High");
        assertThat(top3.get(1).popularity()).isEqualTo(82.1);

        assertThat(top3.get(2).id()).isEqualTo(102);
        assertThat(top3.get(2).originalName()).isEqualTo("Show Med");
        assertThat(top3.get(2).popularity()).isEqualTo(45.8);
    }
}
