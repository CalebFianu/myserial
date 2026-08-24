package com.myserial.api.controller;

import com.myserial.api.dto.response.HomeResponse;
import com.myserial.domain.service.HomeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/home")
@RequiredArgsConstructor
public class HomeController extends BaseController {

    private final HomeService homeService;

    @GetMapping
    public ResponseEntity<HomeResponse> getHome() {
        HomeService.HomeData data = homeService.getHomeData(currentUserId());

        HomeResponse.ContinueWatchingItem continueWatching = null;
        if (data.continueWatching() != null) {
            HomeService.ContinueWatching cw = data.continueWatching();
            continueWatching = new HomeResponse.ContinueWatchingItem(
                    cw.show().getId(), cw.show().getTitle(), cw.show().getPosterPath(),
                    DtoMapper.toEpisodeResponse(cw.nextEpisode()),
                    cw.watched(), cw.total(), cw.progress()
            );
        }

        List<HomeResponse.MyShowItem> myShows = data.myShows().stream()
                .map(s -> new HomeResponse.MyShowItem(s.show().getId(), s.show().getTitle(), s.show().getPosterPath()))
                .toList();

        List<HomeResponse.BingeReadyItem> bingeReady = data.bingeReady().stream()
                .map(b -> new HomeResponse.BingeReadyItem(
                        b.show().getId(), b.show().getTitle(), b.show().getPosterPath(),
                        b.unwatchedCount() + " episodes available to watch",
                        (int) b.unwatchedCount()
                ))
                .toList();

        List<HomeResponse.FriendActivityItem> friendActivity = data.friendActivity().stream()
                .map(f -> new HomeResponse.FriendActivityItem(
                        f.friendName(), f.friendAvatarPath(),
                        f.show().getTitle(), f.show().getPosterPath()
                ))
                .toList();

        return ResponseEntity.ok(new HomeResponse(
                continueWatching, myShows, bingeReady, friendActivity,
                data.upNextCount(), data.diaryCount()
        ));
    }
}
