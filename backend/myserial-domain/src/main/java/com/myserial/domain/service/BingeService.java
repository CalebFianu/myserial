package com.myserial.domain.service;

import com.myserial.domain.entity.BingeTrack;
import com.myserial.domain.entity.Show;
import com.myserial.domain.entity.User;
import com.myserial.domain.repository.BingeTrackRepository;
import com.myserial.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class BingeService {

    private final BingeTrackRepository bingeTrackRepository;
    private final UserRepository userRepository;
    private final ShowService showService;

    @Transactional
    public BingeTrack trackShow(Long userId, Long showId) {
        Show show = showService.findById(showId);
        Long resolvedShowId = show.getId();
        if (bingeTrackRepository.existsByUserIdAndShowId(userId, resolvedShowId)) {
            return bingeTrackRepository.findByUserIdAndShowId(userId, resolvedShowId).orElseThrow();
        }
        User user = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));
        BingeTrack track = BingeTrack.builder()
                .user(user)
                .show(show)
                .build();
        return bingeTrackRepository.save(track);
    }

    @Transactional
    public void untrackShow(Long userId, Long showId) {
        bingeTrackRepository.findByUserIdAndShowId(userId, showId)
                .ifPresent(bingeTrackRepository::delete);
    }

    @Transactional(readOnly = true)
    public List<BingeTrack> getTrackedShows(Long userId) {
        return bingeTrackRepository.findByUserId(userId);
    }

    @Transactional
    public void markWrapped(Long userId, Long showId) {
        bingeTrackRepository.findByUserIdAndShowId(userId, showId).ifPresent(track -> {
            track.setWrapped(true);
            track.setWrappedAt(OffsetDateTime.now());
            bingeTrackRepository.save(track);
        });
    }

    @Transactional(readOnly = true)
    public List<BingeTrack> getUnwrappedTracks() {
        return bingeTrackRepository.findByWrappedFalse();
    }

    @Transactional(readOnly = true)
    public List<BingeTrack> getWrappedUnalertedTracks() {
        return bingeTrackRepository.findByWrappedTrueAndAlertedFalse();
    }
}
