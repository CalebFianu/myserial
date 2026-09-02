package com.myserial.api.controller;

import com.myserial.api.dto.request.UpdateProfileRequest;
import com.myserial.api.dto.response.ProfileResponse;
import com.myserial.api.dto.response.UserResponse;
import com.myserial.domain.entity.User;
import com.myserial.domain.service.ProfileService;
import com.myserial.domain.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/profile")
@RequiredArgsConstructor
public class ProfileController extends BaseController {

    private final ProfileService profileService;
    private final UserService userService;

    @PatchMapping("/me")
    public ResponseEntity<UserResponse> updateProfile(@Valid @RequestBody UpdateProfileRequest request) {
        User updated = userService.updateProfile(
                currentUserId(), request.name(), request.bio(), request.avatarPath());
        return ResponseEntity.ok(DtoMapper.toUserResponse(updated));
    }

    @GetMapping("/me")
    public ResponseEntity<ProfileResponse> getProfile() {
        ProfileService.ProfileData data = profileService.getProfile(currentUserId());

        List<ProfileResponse.UserShowProgress> watchingShows = data.watchingShows().stream()
                .map(s -> new ProfileResponse.UserShowProgress(
                        s.show().getId(), s.show().getTitle(), s.show().getPosterPath(), s.show().getStatus(),
                        s.watchedEpisodes(), s.totalEpisodes(), s.progress()
                ))
                .toList();

        List<ProfileResponse.UserShowProgress> watchedShows = data.watchedShows().stream()
                .map(s -> new ProfileResponse.UserShowProgress(
                        s.show().getId(), s.show().getTitle(), s.show().getPosterPath(), s.show().getStatus(),
                        s.watchedEpisodes(), s.totalEpisodes(), s.progress()
                ))
                .toList();

        List<ProfileResponse.UserListSummary> listSummaries = data.lists().stream()
                .map(l -> new ProfileResponse.UserListSummary(l.getId(), l.getName(),
                        l.getItems() == null ? 0 : l.getItems().size()))
                .toList();

        return ResponseEntity.ok(new ProfileResponse(
                data.user().getId(), data.user().getName(), data.user().getHandle(),
                data.user().getBio(), data.user().getAvatarPath(),
                data.episodeCount(), data.showCount(), data.avgRating(),
                watchingShows, watchedShows, listSummaries, data.watchlistCount(), data.watchlistPosters()
        ));
    }
}
