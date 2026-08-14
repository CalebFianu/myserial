package com.myserial.api.security;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.interfaces.DecodedJWT;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.Date;
import java.util.UUID;

@Slf4j
@Component
public class JwtUtil {

    private final Algorithm algorithm;
    private final long accessTokenExpiry;
    private final long refreshTokenExpiry;
    private static final String ISSUER = "myserial";
    private static final String CLAIM_USER_ID = "userId";

    public JwtUtil(
            @Value("${jwt.secret}") String secret,
            @Value("${jwt.access-token-expiry:900}") long accessTokenExpiry,
            @Value("${jwt.refresh-token-expiry:2592000}") long refreshTokenExpiry) {
        this.algorithm = Algorithm.HMAC256(secret);
        this.accessTokenExpiry = accessTokenExpiry;
        this.refreshTokenExpiry = refreshTokenExpiry;
    }

    public String createAccessToken(Long userId, String email) {
        Instant now = Instant.now();
        return JWT.create()
                .withIssuer(ISSUER)
                .withSubject(email)
                .withClaim(CLAIM_USER_ID, userId)
                .withIssuedAt(Date.from(now))
                .withExpiresAt(Date.from(now.plusSeconds(accessTokenExpiry)))
                .sign(algorithm);
    }

    public String createRefreshToken(Long userId, String email) {
        Instant now = Instant.now();
        return JWT.create()
                .withIssuer(ISSUER)
                .withSubject(email)
                .withClaim(CLAIM_USER_ID, userId)
                .withJWTId(UUID.randomUUID().toString())
                .withIssuedAt(Date.from(now))
                .withExpiresAt(Date.from(now.plusSeconds(refreshTokenExpiry)))
                .sign(algorithm);
    }

    public DecodedJWT verify(String token) throws JWTVerificationException {
        return JWT.require(algorithm)
                .withIssuer(ISSUER)
                .build()
                .verify(token);
    }

    public String extractEmail(String token) {
        return verify(token).getSubject();
    }

    public Long extractUserId(String token) {
        return verify(token).getClaim(CLAIM_USER_ID).asLong();
    }

    public boolean isValid(String token) {
        try {
            verify(token);
            return true;
        } catch (JWTVerificationException e) {
            log.debug("Invalid JWT token: {}", e.getMessage());
            return false;
        }
    }

    public long getRefreshTokenExpiry() {
        return refreshTokenExpiry;
    }
}
