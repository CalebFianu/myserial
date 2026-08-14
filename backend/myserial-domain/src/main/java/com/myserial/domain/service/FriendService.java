package com.myserial.domain.service;

import com.myserial.domain.entity.Friendship;
import com.myserial.domain.entity.User;
import com.myserial.domain.repository.FriendshipRepository;
import com.myserial.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class FriendService {

    private final FriendshipRepository friendshipRepository;
    private final UserRepository userRepository;

    @Transactional
    public Friendship addFriend(Long userId, String friendHandle) {
        User user = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));
        User friend = userRepository.findByHandle(friendHandle).orElseThrow(() -> new IllegalArgumentException("User not found with handle: " + friendHandle));
        if (userId.equals(friend.getId())) {
            throw new IllegalArgumentException("Cannot add yourself as a friend");
        }
        if (friendshipRepository.existsByUserIdAndFriendId(userId, friend.getId())) {
            throw new IllegalStateException("Friendship already exists");
        }
        Friendship friendship = Friendship.builder()
                .user(user)
                .friend(friend)
                .build();
        // Create bidirectional friendship
        Friendship reverse = Friendship.builder()
                .user(friend)
                .friend(user)
                .build();
        friendshipRepository.save(reverse);
        return friendshipRepository.save(friendship);
    }

    @Transactional(readOnly = true)
    public List<Friendship> getFriends(Long userId) {
        return friendshipRepository.findByUserId(userId);
    }

    @Transactional(readOnly = true)
    public List<Long> getFriendIds(Long userId) {
        return getFriends(userId).stream()
                .map(f -> f.getFriend().getId())
                .toList();
    }
}
