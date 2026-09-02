package com.myserial.domain.service;

import com.myserial.domain.entity.Show;

import java.util.List;

/**
 * Port (outbound interface) for fetching and persisting show data from an external catalog.
 * Implemented in myserial-catalog to avoid the domain depending on catalog details.
 */
public interface ShowSyncPort {
    Show fetchAndPersistShow(int tmdbId);
    List<Show> searchAndSeedShows(String query, int limit);
}
