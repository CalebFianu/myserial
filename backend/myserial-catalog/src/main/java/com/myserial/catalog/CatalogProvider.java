package com.myserial.catalog;

import com.myserial.catalog.dto.*;

import java.util.List;

public interface CatalogProvider {
    ShowDetail fetchShow(int tmdbId);
    List<ShowSummary> searchShows(String query, String language);
    List<WatchProviderInfo> fetchWatchProviders(int tmdbId, String countryCode);
    ShowDetail fetchShowWithSeasonsAndCredits(int tmdbId);
}
