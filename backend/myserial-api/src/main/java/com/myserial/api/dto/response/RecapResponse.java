package com.myserial.api.dto.response;

import java.util.List;

public record RecapResponse(
        List<RecapChapter> chapters,
        long watchedCount
) {
    public record RecapChapter(
            String range,
            String title,
            String body,
            int unlockAfterEpisode
    ) {}
}
