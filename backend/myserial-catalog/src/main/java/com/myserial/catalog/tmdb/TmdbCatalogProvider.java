package com.myserial.catalog.tmdb;

import com.fasterxml.jackson.databind.JsonNode;
import com.myserial.catalog.CatalogProvider;
import com.myserial.catalog.dto.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class TmdbCatalogProvider implements CatalogProvider {

    private final RestTemplate restTemplate;
    private final TmdbProperties properties;

    @Override
    @Cacheable("tmdb-show")
    public ShowDetail fetchShow(int tmdbId) {
        String url = UriComponentsBuilder
                .fromHttpUrl(properties.getBaseUrl() + "/tv/{id}")
                .queryParam("api_key", properties.getApiKey())
                .buildAndExpand(tmdbId)
                .toUriString();
        JsonNode root = restTemplate.getForObject(url, JsonNode.class);
        return mapShowDetail(root, Collections.emptyList(), Collections.emptyList(), Collections.emptyList(), Collections.emptyList());
    }

    @Override
    @Cacheable("tmdb-show-full")
    public ShowDetail fetchShowWithSeasonsAndCredits(int tmdbId) {
        String url = UriComponentsBuilder
                .fromHttpUrl(properties.getBaseUrl() + "/tv/{id}")
                .queryParam("api_key", properties.getApiKey())
                .queryParam("append_to_response", "credits,watch/providers,external_ids")
                .buildAndExpand(tmdbId)
                .toUriString();
        JsonNode root = restTemplate.getForObject(url, JsonNode.class);

        List<CastMember> cast = parseCast(root);
        List<CrewMember> crew = parseCrew(root);
        List<WatchProviderInfo> providers = parseWatchProviders(root, "US");

        // Fetch seasons
        List<SeasonDetail> seasons = new ArrayList<>();
        if (root != null && root.has("seasons")) {
            for (JsonNode s : root.get("seasons")) {
                int seasonNum = s.path("season_number").asInt();
                if (seasonNum < 1) continue;
                try {
                    SeasonDetail sd = fetchSeasonDetail(tmdbId, seasonNum);
                    seasons.add(sd);
                } catch (Exception e) {
                    log.warn("Failed to fetch season {} for show {}: {}", seasonNum, tmdbId, e.getMessage());
                }
            }
        }

        return mapShowDetail(root, seasons, cast, crew, providers);
    }

    @Override
    @Cacheable("tmdb-search")
    public List<ShowSummary> searchShows(String query, String language) {
        String lang = language != null ? language : "en-US";
        String url = UriComponentsBuilder
                .fromHttpUrl(properties.getBaseUrl() + "/search/tv")
                .queryParam("api_key", properties.getApiKey())
                .queryParam("query", query)
                .queryParam("language", lang)
                .build()
                .toUriString();
        JsonNode root = restTemplate.getForObject(url, JsonNode.class);
        List<ShowSummary> results = new ArrayList<>();
        if (root != null && root.has("results")) {
            for (JsonNode node : root.get("results")) {
                results.add(mapShowSummary(node));
            }
        }
        return results;
    }

    @Override
    public List<WatchProviderInfo> fetchWatchProviders(int tmdbId, String countryCode) {
        String url = UriComponentsBuilder
                .fromHttpUrl(properties.getBaseUrl() + "/tv/{id}/watch/providers")
                .queryParam("api_key", properties.getApiKey())
                .buildAndExpand(tmdbId)
                .toUriString();
        JsonNode root = restTemplate.getForObject(url, JsonNode.class);
        return parseWatchProviders(root, countryCode);
    }

    private SeasonDetail fetchSeasonDetail(int showTmdbId, int seasonNumber) {
        String url = UriComponentsBuilder
                .fromHttpUrl(properties.getBaseUrl() + "/tv/{id}/season/{season}")
                .queryParam("api_key", properties.getApiKey())
                .buildAndExpand(showTmdbId, seasonNumber)
                .toUriString();
        JsonNode root = restTemplate.getForObject(url, JsonNode.class);
        return mapSeasonDetail(root);
    }

    private ShowDetail mapShowDetail(JsonNode root, List<SeasonDetail> seasons, List<CastMember> cast,
                                     List<CrewMember> crew, List<WatchProviderInfo> providers) {
        if (root == null) return null;
        return new ShowDetail(
                root.path("id").asInt(),
                root.path("name").asText(null),
                root.path("original_name").asText(null),
                root.path("overview").asText(null),
                root.path("status").asText(null),
                parseDate(root.path("first_air_date").asText(null)),
                parseDate(root.path("last_air_date").asText(null)),
                root.path("poster_path").asText(null),
                root.path("backdrop_path").asText(null),
                genresToJson(root.path("genres")),
                extractNetwork(root),
                extractEpisodeRuntime(root),
                parseDecimal(root.path("vote_average").asText(null)),
                root.path("vote_count").asInt(0),
                parseDecimal(root.path("popularity").asText(null)),
                seasons,
                cast,
                crew,
                providers
        );
    }

    private ShowSummary mapShowSummary(JsonNode node) {
        return new ShowSummary(
                node.path("id").asInt(),
                node.path("name").asText(null),
                node.path("original_name").asText(null),
                node.path("overview").asText(null),
                node.path("poster_path").asText(null),
                node.path("backdrop_path").asText(null),
                parseDate(node.path("first_air_date").asText(null)),
                parseDecimal(node.path("vote_average").asText(null)),
                parseDecimal(node.path("popularity").asText(null)),
                null
        );
    }

    private SeasonDetail mapSeasonDetail(JsonNode root) {
        if (root == null) return null;
        List<EpisodeDetail> episodes = new ArrayList<>();
        if (root.has("episodes")) {
            for (JsonNode ep : root.get("episodes")) {
                episodes.add(new EpisodeDetail(
                        ep.path("id").asInt(),
                        ep.path("season_number").asInt(),
                        ep.path("episode_number").asInt(),
                        ep.path("name").asText(null),
                        ep.path("overview").asText(null),
                        parseDate(ep.path("air_date").asText(null)),
                        ep.path("still_path").asText(null),
                        ep.has("runtime") && !ep.path("runtime").isNull() ? ep.path("runtime").asInt() : null,
                        parseDecimal(ep.path("vote_average").asText(null))
                ));
            }
        }
        return new SeasonDetail(
                root.path("id").asInt(),
                root.path("season_number").asInt(),
                root.path("name").asText(null),
                root.path("overview").asText(null),
                root.path("poster_path").asText(null),
                parseDate(root.path("air_date").asText(null)),
                episodes
        );
    }

    private List<CastMember> parseCast(JsonNode root) {
        List<CastMember> cast = new ArrayList<>();
        if (root == null || !root.has("credits")) return cast;
        JsonNode credits = root.get("credits");
        if (credits.has("cast")) {
            for (JsonNode c : credits.get("cast")) {
                cast.add(new CastMember(
                        c.path("id").asInt(),
                        c.path("name").asText(null),
                        c.path("character").asText(null),
                        c.path("profile_path").asText(null),
                        c.path("order").asInt(999)
                ));
            }
        }
        return cast;
    }

    private List<CrewMember> parseCrew(JsonNode root) {
        List<CrewMember> crew = new ArrayList<>();
        if (root == null || !root.has("credits")) return crew;
        JsonNode credits = root.get("credits");
        if (credits.has("crew")) {
            for (JsonNode c : credits.get("crew")) {
                crew.add(new CrewMember(
                        c.path("id").asInt(),
                        c.path("name").asText(null),
                        c.path("department").asText(null),
                        c.path("job").asText(null),
                        c.path("profile_path").asText(null)
                ));
            }
        }
        return crew;
    }

    private List<WatchProviderInfo> parseWatchProviders(JsonNode root, String countryCode) {
        List<WatchProviderInfo> providers = new ArrayList<>();
        if (root == null) return providers;
        JsonNode results = root.path("results");
        if (results.isMissingNode()) {
            // Root itself might be the response from the show append_to_response
            results = root.path("watch/providers").path("results");
        }
        if (results.isMissingNode() || !results.has(countryCode)) return providers;
        JsonNode country = results.get(countryCode);
        String link = country.path("link").asText(null);
        String[] offerTypes = {"flatrate", "rent", "buy", "free"};
        for (String offerType : offerTypes) {
            if (country.has(offerType)) {
                for (JsonNode p : country.get(offerType)) {
                    providers.add(new WatchProviderInfo(
                            p.path("provider_id").asInt(),
                            p.path("provider_name").asText(null),
                            p.path("logo_path").asText(null),
                            offerType,
                            countryCode,
                            link
                    ));
                }
            }
        }
        return providers;
    }

    private String genresToJson(JsonNode genres) {
        if (genres == null || genres.isNull() || genres.isMissingNode()) return "[]";
        return genres.toString();
    }

    private String extractNetwork(JsonNode root) {
        if (root == null || !root.has("networks")) return null;
        JsonNode networks = root.get("networks");
        if (networks.isEmpty()) return null;
        return networks.get(0).path("name").asText(null);
    }

    private Integer extractEpisodeRuntime(JsonNode root) {
        if (root == null || !root.has("episode_run_time")) return null;
        JsonNode runtimes = root.get("episode_run_time");
        if (runtimes.isEmpty()) return null;
        return runtimes.get(0).asInt();
    }

    private LocalDate parseDate(String text) {
        if (text == null || text.isBlank()) return null;
        try {
            return LocalDate.parse(text);
        } catch (Exception e) {
            return null;
        }
    }

    private BigDecimal parseDecimal(String text) {
        if (text == null || text.isBlank() || text.equals("null")) return null;
        try {
            return new BigDecimal(text);
        } catch (Exception e) {
            return null;
        }
    }
}
