package com.myserial.domain.repository;

import com.myserial.domain.entity.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, Long> {
    Optional<RefreshToken> findByToken(String token);
    @org.springframework.transaction.annotation.Transactional
    void deleteByToken(String token);
    @org.springframework.transaction.annotation.Transactional
    void deleteByUserId(Long userId);
    List<RefreshToken> findByUserIdAndExpiresAtAfter(Long userId, OffsetDateTime now);
}
