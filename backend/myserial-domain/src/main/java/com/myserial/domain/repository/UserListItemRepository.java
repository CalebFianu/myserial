package com.myserial.domain.repository;

import com.myserial.domain.entity.UserListItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserListItemRepository extends JpaRepository<UserListItem, Long> {
    List<UserListItem> findByListId(Long listId);
    Optional<UserListItem> findByListIdAndShowId(Long listId, Long showId);
    @org.springframework.transaction.annotation.Transactional
    void deleteByListIdAndShowId(Long listId, Long showId);
    boolean existsByListIdAndShowId(Long listId, Long showId);
}
