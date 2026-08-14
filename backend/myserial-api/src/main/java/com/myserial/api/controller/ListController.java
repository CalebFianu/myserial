package com.myserial.api.controller;

import com.myserial.api.dto.request.AddItemRequest;
import com.myserial.api.dto.request.CollaboratorRequest;
import com.myserial.api.dto.request.CreateListRequest;
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
}
