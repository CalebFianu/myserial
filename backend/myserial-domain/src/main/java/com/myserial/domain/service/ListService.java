package com.myserial.domain.service;

import com.myserial.domain.entity.*;
import com.myserial.domain.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ListService {

    private final UserListRepository listRepository;
    private final UserListItemRepository listItemRepository;
    private final ListCollaboratorRepository collaboratorRepository;
    private final UserRepository userRepository;
    private final ShowService showService;

    @Transactional
    public UserList createList(Long userId, String name, String note) {
        User user = userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));
        UserList list = UserList.builder()
                .user(user)
                .name(name)
                .note(note)
                .build();
        return listRepository.save(list);
    }

    @Transactional
    public UserListItem addToList(Long userId, Long listId, Long showId) {
        UserList list = listRepository.findById(listId).orElseThrow(() -> new IllegalArgumentException("List not found"));
        if (!list.getUser().getId().equals(userId) && !collaboratorRepository.existsByListIdAndUserId(listId, userId)) {
            throw new IllegalStateException("Not authorized to modify this list");
        }
        Show show = showService.findById(showId);
        Long resolvedShowId = show.getId();
        if (listItemRepository.existsByListIdAndShowId(listId, resolvedShowId)) {
            return listItemRepository.findByListIdAndShowId(listId, resolvedShowId).orElseThrow();
        }
        UserListItem item = UserListItem.builder()
                .list(list)
                .show(show)
                .build();
        return listItemRepository.save(item);
    }

    @Transactional
    public void removeFromList(Long userId, Long listId, Long showId) {
        UserList list = listRepository.findById(listId).orElseThrow(() -> new IllegalArgumentException("List not found"));
        if (!list.getUser().getId().equals(userId) && !collaboratorRepository.existsByListIdAndUserId(listId, userId)) {
            throw new IllegalStateException("Not authorized to modify this list");
        }
        listItemRepository.deleteByListIdAndShowId(listId, showId);
    }

    @Transactional(readOnly = true)
    public List<UserList> getLists(Long userId) {
        return listRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    @Transactional(readOnly = true)
    public UserList getList(Long listId) {
        return listRepository.findByIdWithItems(listId).orElseThrow(() -> new IllegalArgumentException("List not found"));
    }

    @Transactional
    public UserList updateList(Long userId, Long listId, String name, String note) {
        UserList list = listRepository.findById(listId)
                .orElseThrow(() -> new IllegalArgumentException("List not found"));
        if (!list.getUser().getId().equals(userId)) {
            throw new IllegalStateException("Only the list owner can update this list");
        }
        if (name != null && !name.isBlank()) {
            list.setName(name);
        }
        if (note != null) {
            list.setNote(note);
        }
        return listRepository.save(list);
    }

    @Transactional
    public void deleteList(Long userId, Long listId) {
        UserList list = listRepository.findById(listId)
                .orElseThrow(() -> new IllegalArgumentException("List not found"));
        if (!list.getUser().getId().equals(userId)) {
            throw new IllegalStateException("Only the list owner can delete this list");
        }
        if (Boolean.TRUE.equals(list.getIsWatchlist())) {
            throw new IllegalStateException("Cannot delete the watchlist");
        }
        listRepository.delete(list);
    }

    @Transactional
    public UserList getOrCreateWatchlist(Long userId) {
        return listRepository.findByUserIdAndIsWatchlistTrue(userId)
                .orElseGet(() -> {
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new IllegalArgumentException("User not found"));
                    UserList watchlist = UserList.builder()
                            .user(user)
                            .name("Watchlist")
                            .isWatchlist(true)
                            .build();
                    return listRepository.save(watchlist);
                });
    }

    @Transactional
    public void addToWatchlist(Long userId, Long showId) {
        UserList watchlist = getOrCreateWatchlist(userId);
        addToList(userId, watchlist.getId(), showId);
    }

    @Transactional
    public void removeFromWatchlist(Long userId, Long showId) {
        listRepository.findByUserIdAndIsWatchlistTrue(userId)
                .ifPresent(watchlist -> removeFromList(userId, watchlist.getId(), showId));
    }

    @Transactional(readOnly = true)
    public boolean isInWatchlist(Long userId, Long showId) {
        return listRepository.findByUserIdAndIsWatchlistTrue(userId)
                .map(watchlist -> listItemRepository.existsByListIdAndShowId(watchlist.getId(), showId))
                .orElse(false);
    }

    @Transactional
    public ListCollaborator addCollaborator(Long ownerId, Long listId, Long collaboratorUserId) {
        UserList list = listRepository.findById(listId).orElseThrow(() -> new IllegalArgumentException("List not found"));
        if (!list.getUser().getId().equals(ownerId)) {
            throw new IllegalStateException("Only the list owner can add collaborators");
        }
        if (collaboratorRepository.existsByListIdAndUserId(listId, collaboratorUserId)) {
            throw new IllegalStateException("User is already a collaborator");
        }
        User collaborator = userRepository.findById(collaboratorUserId).orElseThrow(() -> new IllegalArgumentException("User not found"));
        ListCollaborator lc = ListCollaborator.builder()
                .list(list)
                .user(collaborator)
                .build();
        return collaboratorRepository.save(lc);
    }
}
