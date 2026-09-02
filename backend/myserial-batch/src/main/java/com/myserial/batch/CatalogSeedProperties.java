package com.myserial.batch;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "tmdb.seed")
public class CatalogSeedProperties {
    private boolean enabled = true;
    private String cron = "0 0 4 * * *";
    private String exportBaseUrl = "http://files.tmdb.org/p/exports";
    private int exportLookbackDays = 3;
    private int rosterSize = 100;
    private int hydratePerRun = 100;
    private int refreshPerRun = 25;
    private int refreshAfterDays = 14;
    private long requestDelayMs = 300;
    private boolean runOnStartup = false;
}
