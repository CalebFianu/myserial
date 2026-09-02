package com.myserial.domain.service;

import com.myserial.domain.entity.RefreshToken;
import com.myserial.domain.entity.User;
import com.myserial.domain.entity.UserList;
import com.myserial.domain.repository.RefreshTokenRepository;
import com.myserial.domain.repository.UserListRepository;
import com.myserial.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final RefreshTokenRepository refreshTokenRepository;
    private final UserListRepository userListRepository;

    @Transactional
    public User register(String name, String email, String rawPassword, String handle) {
        if (userRepository.existsByEmail(email)) {
            throw new IllegalStateException("Email already in use: " + email);
        }

        String resolvedHandle = handle;
        if (resolvedHandle == null || resolvedHandle.isBlank()) {
            resolvedHandle = email.split("@")[0].replaceAll("[^a-zA-Z0-9_]", "");
            if (resolvedHandle.length() < 2) {
                resolvedHandle = "user_" + resolvedHandle;
            }
        }
        if (userRepository.existsByHandle(resolvedHandle)) {
            int suffix = 1;
            while (userRepository.existsByHandle(resolvedHandle + suffix)) {
                suffix++;
            }
            resolvedHandle = resolvedHandle + suffix;
        }

        User user = User.builder()
                .name(name)
                .email(email)
                .passwordHash(rawPassword != null ? passwordEncoder.encode(rawPassword) : null)
                .handle(resolvedHandle)
                .build();
        user = userRepository.save(user);

        // Auto-create the user's watchlist
        UserList watchlist = UserList.builder()
                .user(user)
                .name("Watchlist")
                .isWatchlist(true)
                .build();
        userListRepository.save(watchlist);

        return user;
    }

    @Transactional(readOnly = true)
    public User loadByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + email));
    }

    @Transactional(readOnly = true)
    public User loadById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + id));
    }

    @Transactional(readOnly = true)
    public User loadByHandle(String handle) {
        return userRepository.findByHandle(handle)
                .orElseThrow(() -> new IllegalArgumentException("User not found with handle: " + handle));
    }

    @Transactional(readOnly = true)
    public boolean existsByHandle(String handle) {
        return userRepository.existsByHandle(handle);
    }

    @Transactional
    public User completeOnboarding(Long userId) {
        User user = loadById(userId);
        user.setOnboardingCompleted(true);
        return userRepository.save(user);
    }

    @Transactional
    public User updateProfile(Long userId, String name, String bio, String avatarPath) {
        User user = loadById(userId);
        if (name != null) user.setName(name);
        if (bio != null) user.setBio(bio);
        if (avatarPath != null) user.setAvatarPath(avatarPath);
        return userRepository.save(user);
    }

    @Transactional
    public RefreshToken saveRefreshToken(User user, String token, OffsetDateTime expiresAt) {
        RefreshToken refreshToken = RefreshToken.builder()
                .user(user)
                .token(token)
                .expiresAt(expiresAt)
                .build();
        return refreshTokenRepository.save(refreshToken);
    }

    @Transactional(readOnly = true)
    public Optional<RefreshToken> findRefreshToken(String token) {
        return refreshTokenRepository.findByToken(token);
    }

    @Transactional
    public void deleteRefreshToken(RefreshToken token) {
        refreshTokenRepository.delete(token);
    }

    @Transactional
    public void deleteRefreshTokenByRawToken(String token) {
        refreshTokenRepository.deleteByToken(token);
    }
}
