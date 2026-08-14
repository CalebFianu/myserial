package com.myserial.domain.service;

import com.myserial.domain.entity.Show;

/**
 * Port (outbound interface) for fetching and persisting show data from an external catalog.
 * Implemented in myserial-catalog to avoid the domain depending on catalog details.
 */
public interface ShowSyncPort {
    Show fetchAndPersistShow(int tmdbId);
}
