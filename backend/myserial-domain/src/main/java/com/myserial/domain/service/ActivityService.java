package com.myserial.domain.service;

import com.myserial.domain.entity.*;
import com.myserial.domain.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ActivityService {

    private final ActivityEventRepository activityEventRepository;
    private final UserRepository userRepository;
    private final ShowRepository showRepository;
    private final EpisodeRepository episodeRepository;
    private final UserListRepository listRepository;
    private final FriendshipRepository friendshipRepository;

    @Transactional
    public ActivityEvent log(Long userId, String eventType, Long showId, Long episodeId, Long listId, String metadata) {
        User user = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));
        Show show = showId != null ? showRepository.findById(showId).orElse(null) : null;
        Episode episode = episodeId != null ? episodeRepository.findById(episodeId).orElse(null) : null;
        UserList list = listId != null ? listRepository.findById(listId).orElse(null) : null;

        ActivityEvent event = ActivityEvent.builder()
                .user(user)
                .eventType(eventType)
                .show(show)
                .episode(episode)
                .list(list)
                .metadata(metadata)
                .build();
        return activityEventRepository.save(event);
    }

    @Transactional(readOnly = true)
    public Page<ActivityEvent> getFeed(Long userId, Pageable pageable) {
        return activityEventRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
    }

    @Transactional(readOnly = true)
    public Page<ActivityEvent> getFriendsFeed(Long userId, Pageable pageable) {
        List<Long> friendIds = friendshipRepository.findByUserId(userId).stream()
                .map(f -> f.getFriend().getId())
                .toList();
        if (friendIds.isEmpty()) {
            return Page.empty(pageable);
        }
        return activityEventRepository.findByUserIdInOrderByCreatedAtDesc(friendIds, pageable);
    }
}
