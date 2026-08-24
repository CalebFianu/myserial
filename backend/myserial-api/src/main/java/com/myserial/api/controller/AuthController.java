package com.myserial.api.controller;

import com.myserial.api.dto.request.LoginRequest;
import com.myserial.api.dto.request.RefreshRequest;
import com.myserial.api.dto.request.RegisterRequest;
import com.myserial.api.dto.response.TokenResponse;
import com.myserial.api.dto.response.UserResponse;
import com.myserial.api.exception.ConflictException;
import com.myserial.api.exception.UnauthorizedException;
import com.myserial.api.security.JwtUtil;
import com.myserial.domain.entity.RefreshToken;
import com.myserial.domain.entity.User;
import com.myserial.domain.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.OffsetDateTime;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController extends BaseController {

    private final UserService userService;
    private final JwtUtil jwtUtil;
    private final BCryptPasswordEncoder passwordEncoder;

    @PostMapping("/register")
    public ResponseEntity<TokenResponse> register(@Valid @RequestBody RegisterRequest req) {
        try {
            User user = userService.register(req.name(), req.email(), req.password(), req.handle());
            return ResponseEntity.status(HttpStatus.CREATED).body(buildTokenResponse(user));
        } catch (IllegalStateException e) {
            throw new ConflictException(e.getMessage());
        }
    }

    @PostMapping("/login")
    public ResponseEntity<TokenResponse> login(@Valid @RequestBody LoginRequest req) {
        User user;
        try {
            user = userService.loadByEmail(req.email());
        } catch (IllegalArgumentException e) {
            throw new UnauthorizedException("Invalid credentials");
        }
        if (!passwordEncoder.matches(req.password(), user.getPasswordHash())) {
            throw new UnauthorizedException("Invalid credentials");
        }
        return ResponseEntity.ok(buildTokenResponse(user));
    }

    @PostMapping("/refresh")
    public ResponseEntity<TokenResponse> refresh(@Valid @RequestBody RefreshRequest req) {
        RefreshToken stored = userService.findRefreshToken(req.refreshToken())
                .orElseThrow(() -> new UnauthorizedException("Invalid refresh token"));
        if (stored.getExpiresAt().isBefore(OffsetDateTime.now())) {
            userService.deleteRefreshToken(stored);
            throw new UnauthorizedException("Refresh token expired");
        }
        User user = stored.getUser();
        userService.deleteRefreshToken(stored);
        return ResponseEntity.ok(buildTokenResponse(user));
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(@Valid @RequestBody RefreshRequest req) {
        userService.deleteRefreshTokenByRawToken(req.refreshToken());
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/me")
    public ResponseEntity<UserResponse> me() {
        return ResponseEntity.ok(DtoMapper.toUserResponse(currentUser()));
    }

    @PostMapping("/onboarding-complete")
    public ResponseEntity<UserResponse> completeOnboarding() {
        User user = userService.completeOnboarding(currentUserId());
        return ResponseEntity.ok(DtoMapper.toUserResponse(user));
    }

    private TokenResponse buildTokenResponse(User user) {
        String accessToken = jwtUtil.createAccessToken(user.getId(), user.getEmail());
        String rawRefreshToken = jwtUtil.createRefreshToken(user.getId(), user.getEmail());
        userService.saveRefreshToken(user, rawRefreshToken,
                OffsetDateTime.now().plusSeconds(jwtUtil.getRefreshTokenExpiry()));
        return new TokenResponse(accessToken, rawRefreshToken, DtoMapper.toUserResponse(user));
    }
}
