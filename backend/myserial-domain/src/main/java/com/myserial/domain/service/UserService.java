package com.myserial.domain.service;

import com.myserial.domain.entity.User;
import com.myserial.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    @Transactional
    public User register(String name, String email, String rawPassword, String handle) {
        if (userRepository.existsByEmail(email)) {
            throw new IllegalStateException("Email already in use: " + email);
        }
        if (userRepository.existsByHandle(handle)) {
            throw new IllegalStateException("Handle already taken: " + handle);
        }
        User user = User.builder()
                .name(name)
                .email(email)
                .passwordHash(rawPassword != null ? passwordEncoder.encode(rawPassword) : null)
                .handle(handle)
                .build();
        return userRepository.save(user);
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

    @Transactional
    public User updateProfile(Long userId, String name, String bio, String avatarPath) {
        User user = loadById(userId);
        if (name != null) user.setName(name);
        if (bio != null) user.setBio(bio);
        if (avatarPath != null) user.setAvatarPath(avatarPath);
        return userRepository.save(user);
    }
}
