package com.myserial.catalog.tmdb;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.PriorityQueue;
import java.util.zip.GZIPInputStream;

@Slf4j
@Component
@RequiredArgsConstructor
public class TmdbExportClient {

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("MM_dd_yyyy");

    @Value("${tmdb.seed.export-base-url:http://files.tmdb.org/p/exports}")
    private String exportBaseUrl = "http://files.tmdb.org/p/exports";

    @Value("${tmdb.seed.export-lookback-days:3}")
    private int exportLookbackDays = 3;

    private final ObjectMapper objectMapper;

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record ExportEntry(
            @JsonProperty("id") int id,
            @JsonProperty("original_name") String originalName,
            @JsonProperty("popularity") double popularity
    ) {}

    public List<ExportEntry> fetchTopSeries(int limit) {
        HttpClient client = HttpClient.newBuilder()
                .followRedirects(HttpClient.Redirect.NORMAL)
                .connectTimeout(Duration.ofSeconds(10))
                .build();

        LocalDate date = LocalDate.now(ZoneOffset.UTC);
        for (int i = 0; i <= exportLookbackDays; i++) {
            String dateStr = date.minusDays(i).format(DATE_FORMATTER);
            String url = String.format("%s/tv_series_ids_%s.json.gz", exportBaseUrl, dateStr);
            log.info("Attempting to fetch TMDB daily export from: {}", url);

            try {
                HttpRequest request = HttpRequest.newBuilder()
                        .uri(URI.create(url))
                        .timeout(Duration.ofSeconds(60))
                        .GET()
                        .build();

                HttpResponse<InputStream> response = client.send(request, HttpResponse.BodyHandlers.ofInputStream());
                if (response.statusCode() == 200) {
                    log.info("Successfully connected to TMDB daily export at {}", url);
                    try (InputStream body = response.body();
                         GZIPInputStream gzipStream = new GZIPInputStream(body)) {
                        return parseExportStream(gzipStream, limit);
                    }
                } else if (response.statusCode() == 404) {
                    log.warn("TMDB export not found for date {} (HTTP 404), trying previous day...", dateStr);
                } else {
                    log.warn("Unexpected status code {} fetching TMDB export from {}", response.statusCode(), url);
                }
            } catch (Exception e) {
                log.warn("Failed to fetch TMDB export from {}: {}", url, e.getMessage());
            }
        }

        log.error("Unable to download TMDB daily export within lookback window of {} days", exportLookbackDays);
        return List.of();
    }

    public List<ExportEntry> parseExportStream(InputStream inputStream, int limit) {
        PriorityQueue<ExportEntry> minHeap = new PriorityQueue<>(
                Comparator.comparingDouble(ExportEntry::popularity)
        );

        try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.isBlank()) continue;
                try {
                    ExportEntry entry = objectMapper.readValue(line, ExportEntry.class);
                    if (entry.id() > 0 && entry.originalName() != null && !entry.originalName().isBlank()) {
                        if (minHeap.size() < limit) {
                            minHeap.offer(entry);
                        } else if (entry.popularity() > minHeap.peek().popularity()) {
                            minHeap.poll();
                            minHeap.offer(entry);
                        }
                    }
                } catch (Exception ex) {
                    log.trace("Skipping unparseable line: {}", line);
                }
            }
        } catch (Exception e) {
            log.error("Error reading export stream: {}", e.getMessage(), e);
        }

        List<ExportEntry> result = new ArrayList<>(minHeap);
        result.sort(Comparator.comparingDouble(ExportEntry::popularity).reversed());
        return result;
    }
}
