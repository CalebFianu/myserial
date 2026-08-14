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
    private final ShowRepository showRepository;

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
        if (listItemRepository.existsByListIdAndShowId(listId, showId)) {
            return listItemRepository.findByListIdAndShowId(listId, showId).orElseThrow();
        }
        Show show = showRepository.findById(showId).orElseThrow(() -> new IllegalArgumentException("Show not found"));
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
