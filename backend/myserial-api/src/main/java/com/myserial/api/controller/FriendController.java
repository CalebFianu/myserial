package com.myserial.api.controller;

import com.myserial.api.dto.request.AddFriendRequest;
import com.myserial.api.dto.response.FriendResponse;
import com.myserial.api.dto.response.FriendReviewResponse;
import com.myserial.domain.entity.*;
import com.myserial.domain.repository.EpisodeRatingRepository;
import com.myserial.domain.service.ActivityService;
import com.myserial.domain.service.FriendService;
import com.myserial.domain.service.WatchService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/v1/friends")
@RequiredArgsConstructor
public class FriendController extends BaseController {

    private final FriendService friendService;
    private final WatchService watchService;
    private final ActivityService activityService;
    private final EpisodeRatingRepository episodeRatingRepository;

    @GetMapping
    public ResponseEntity<List<FriendResponse>> getFriends() {
        Long userId = currentUserId();
        List<Friendship> friendships = friendService.getFriends(userId);
        List<FriendResponse> responses = friendships.stream().map(f -> {
            User friend = f.getFriend();
            List<WatchService.UpNextResult> upNext = watchService.getUpNext(friend.getId());
            WatchService.UpNextResult currentResult = upNext.isEmpty() ? null : upNext.get(0);
            return new FriendResponse(
                    friend.getId(), friend.getName(), friend.getHandle(), friend.getAvatarPath(),
                    f.getCreatedAt(),
                    currentResult != null ? DtoMapper.toEpisodeResponse(currentResult.nextEpisode()) : null,
                    currentResult != null ? DtoMapper.toShowSummaryResponse(currentResult.show()) : null
            );
        }).toList();
        return ResponseEntity.ok(responses);
    }

    @PostMapping
    public ResponseEntity<FriendResponse> addFriend(@Valid @RequestBody AddFriendRequest req) {
        Long userId = currentUserId();
        Friendship friendship = friendService.addFriend(userId, req.handle());
        User friend = friendship.getFriend();
        return ResponseEntity.ok(new FriendResponse(
                friend.getId(), friend.getName(), friend.getHandle(), friend.getAvatarPath(),
                friendship.getCreatedAt(), null, null
        ));
    }

    @GetMapping("/reviews")
    public ResponseEntity<Page<FriendReviewResponse>> getFriendReviews(Pageable pageable) {
        Long userId = currentUserId();
        List<Long> friendIds = friendService.getFriendIds(userId);
        if (friendIds.isEmpty()) {
            return ResponseEntity.ok(Page.empty(pageable));
        }
        List<FriendReviewResponse> reviews = new ArrayList<>();
        for (Long friendId : friendIds) {
            List<EpisodeRating> ratings = episodeRatingRepository.findByUserId(friendId);
            for (EpisodeRating rating : ratings) {
                User friend = rating.getUser();
                Episode ep = rating.getEpisode();
                Show show = ep.getShow();
                reviews.add(new FriendReviewResponse(
                        rating.getId(), DtoMapper.toUserResponse(friend),
                        show.getId(), show.getTitle(), ep.getId(),
                        ep.getSeasonNumber(), ep.getEpisodeNumber(), ep.getName(),
                        rating.getScore(), rating.getReview(), rating.getUpdatedAt()
                ));
            }
        }
        reviews.sort((a, b) -> b.ratedAt().compareTo(a.ratedAt()));
        int start = (int) pageable.getOffset();
        int end = Math.min(start + pageable.getPageSize(), reviews.size());
        List<FriendReviewResponse> pageContent = start >= reviews.size() ? List.of() : reviews.subList(start, end);
        return ResponseEntity.ok(new PageImpl<>(pageContent, pageable, reviews.size()));
    }
}
