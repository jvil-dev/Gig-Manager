// Unit tests for JWT generation and validation
package com.jvilledaapps.gig_manager.auth.service;

import java.util.Base64;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;

class JwtServiceTest {

    private JwtService jwtService;
    private final UUID userId = UUID.randomUUID();
    private final String email = "test@example.com";

    @BeforeEach
    void setUp() {
        // 32 zero-bytes encoded as Base64 - valid 256-bit key for tests only
        String secret = Base64.getEncoder().encodeToString(new byte[32]);
        jwtService = new JwtService(secret, 900_000L);
    }

    @Test
    void generatedTokenContainsExpectedClaims() {
        String token = jwtService.generateAccessToken(userId, email);
        Claims claims = jwtService.validateToken(token);
        assertThat(claims.getSubject()).isEqualTo(userId.toString());
        assertThat(claims.get("email", String.class)).isEqualTo(email);
    }

    @Test
    void expiredTokenThrows() {
        JwtService shortLived = new JwtService(
                Base64.getEncoder().encodeToString(new byte[32]), -1L);
        String token = shortLived.generateAccessToken(userId, email);
        assertThatThrownBy(() -> jwtService.validateToken(token))
                .isInstanceOf(ExpiredJwtException.class);
    }

    @Test
    void tamperedTokenThrows() {
        String token = jwtService.generateAccessToken(userId, email);
        String tampered = token.substring(0, token.length() - 4) + "XXXX";
        assertThatThrownBy(() -> jwtService.validateToken(tampered))
                .isInstanceOf(Exception.class);
    }
}
