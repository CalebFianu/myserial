package com.myserial.domain.repository;

import com.myserial.domain.entity.UserList;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserListRepository extends JpaRepository<UserList, Long> {

    @Query("SELECT DISTINCT ul FROM UserList ul LEFT JOIN FETCH ul.items i LEFT JOIN FETCH i.show WHERE ul.user.id = :userId ORDER BY ul.createdAt DESC")
    List<UserList> findByUserIdOrderByCreatedAtDesc(@Param("userId") Long userId);

    @Query("SELECT DISTINCT ul FROM UserList ul LEFT JOIN FETCH ul.items i LEFT JOIN FETCH i.show WHERE ul.id = :id")
    Optional<UserList> findByIdWithItems(@Param("id") Long id);

    @Query("SELECT DISTINCT ul FROM UserList ul LEFT JOIN FETCH ul.items i LEFT JOIN FETCH i.show WHERE ul.user.id = :userId AND ul.isWatchlist = true")
    Optional<UserList> findWatchlistWithItemsByUserId(@Param("userId") Long userId);

    Optional<UserList> findByUserIdAndIsWatchlistTrue(Long userId);

    @Query("SELECT DISTINCT ul FROM UserList ul LEFT JOIN FETCH ul.items i LEFT JOIN FETCH i.show WHERE ul.user.id = :userId AND ul.isWatchlist = false ORDER BY ul.createdAt DESC")
    List<UserList> findCustomListsWithItemsByUserId(@Param("userId") Long userId);

    List<UserList> findByUserIdAndIsWatchlistFalseOrderByCreatedAtDesc(Long userId);
}
