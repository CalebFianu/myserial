package com.myserial.api.controller;

import com.myserial.api.dto.request.AddItemRequest;
import com.myserial.api.dto.request.CollaboratorRequest;
import com.myserial.api.dto.request.CreateListRequest;
import com.myserial.api.dto.request.UpdateListRequest;
import com.myserial.api.dto.response.UserListResponse;
import com.myserial.domain.entity.UserList;
import com.myserial.domain.service.ActivityService;
import com.myserial.domain.service.ListService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/lists")
@RequiredArgsConstructor
public class ListController extends BaseController {

    private final ListService listService;
    private final ActivityService activityService;

    @GetMapping
    public ResponseEntity<List<UserListResponse>> getLists() {
        List<UserList> lists = listService.getLists(currentUserId());
        return ResponseEntity.ok(lists.stream().map(DtoMapper::toUserListResponse).toList());
    }

    @PostMapping
    public ResponseEntity<UserListResponse> createList(@Valid @RequestBody CreateListRequest req) {
        Long userId = currentUserId();
        UserList list = listService.createList(userId, req.name(), req.note());
        return ResponseEntity.status(HttpStatus.CREATED).body(DtoMapper.toUserListResponse(list));
    }

    @GetMapping("/{listId}")
    public ResponseEntity<UserListResponse> getList(@PathVariable Long listId) {
        UserList list = listService.getList(listId);
        return ResponseEntity.ok(DtoMapper.toUserListResponse(list));
    }

    @PutMapping("/{listId}")
    public ResponseEntity<UserListResponse> updateList(@PathVariable Long listId,
                                                       @Valid @RequestBody UpdateListRequest req) {
        UserList list = listService.updateList(currentUserId(), listId, req.name(), req.note());
        return ResponseEntity.ok(DtoMapper.toUserListResponse(list));
    }

    @DeleteMapping("/{listId}")
    public ResponseEntity<Void> deleteList(@PathVariable Long listId) {
        listService.deleteList(currentUserId(), listId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/watchlist")
    public ResponseEntity<UserListResponse> getWatchlist() {
        UserList watchlist = listService.getOrCreateWatchlist(currentUserId());
        UserList loaded = listService.getList(watchlist.getId());
        return ResponseEntity.ok(DtoMapper.toUserListResponse(loaded));
    }

    @PostMapping("/{listId}/items")
    public ResponseEntity<Void> addItem(@PathVariable Long listId, @Valid @RequestBody AddItemRequest req) {
        Long userId = currentUserId();
        listService.addToList(userId, listId, req.showId());
        activityService.log(userId, "LIST_ADD", req.showId(), null, listId, null);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{listId}/items/{showId}")
    public ResponseEntity<Void> removeItem(@PathVariable Long listId, @PathVariable Long showId) {
        listService.removeFromList(currentUserId(), listId, showId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{listId}/collaborators")
    public ResponseEntity<Void> addCollaborator(@PathVariable Long listId, @Valid @RequestBody CollaboratorRequest req) {
        listService.addCollaborator(currentUserId(), listId, req.userId());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/watchlist/{showId}")
    public ResponseEntity<Void> addToWatchlist(@PathVariable Long showId) {
        listService.addToWatchlist(currentUserId(), showId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/watchlist/{showId}")
    public ResponseEntity<Void> removeFromWatchlist(@PathVariable Long showId) {
        listService.removeFromWatchlist(currentUserId(), showId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/watchlist/check/{showId}")
    public ResponseEntity<java.util.Map<String, Boolean>> checkWatchlist(@PathVariable Long showId) {
        boolean inWatchlist = listService.isInWatchlist(currentUserId(), showId);
        return ResponseEntity.ok(java.util.Map.of("inWatchlist", inWatchlist));
    }
}
