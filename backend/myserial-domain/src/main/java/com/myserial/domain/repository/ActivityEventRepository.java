package com.myserial.domain.repository;

import com.myserial.domain.entity.ActivityEvent;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ActivityEventRepository extends JpaRepository<ActivityEvent, Long> {
    @Query("SELECT ae FROM ActivityEvent ae JOIN FETCH ae.user LEFT JOIN FETCH ae.show LEFT JOIN FETCH ae.episode WHERE ae.user.id = :userId ORDER BY ae.createdAt DESC")
    Page<ActivityEvent> findByUserIdOrderByCreatedAtDesc(@Param("userId") Long userId, Pageable pageable);

    @Query("SELECT ae FROM ActivityEvent ae JOIN FETCH ae.user LEFT JOIN FETCH ae.show LEFT JOIN FETCH ae.episode WHERE ae.user.id IN :friendIds ORDER BY ae.createdAt DESC")
    Page<ActivityEvent> findByUserIdInOrderByCreatedAtDesc(@Param("friendIds") List<Long> friendIds, Pageable pageable);
}
