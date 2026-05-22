// Handles all authentication flows: email/password, social (Apple/Google), token refresh, and logout
package com.jvilledaapps.gig_manager.auth.service;

import com.jvilledaapps.gig_manager.auth.dto.*;
import com.jvilledaapps.gig_manager.auth.exception.AuthException;
import com.jvilledaapps.gig_manager.auth.model.*;
import com.jvilledaapps.gig_manager.auth.repository.*;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDateTime;
import java.util.HexFormat;
import java.util.UUID;

@Service
@Transactional
public class AuthService {

    private final UserRepository userRepository;
    private final AuthProviderRepository authProviderRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtService jwtService;
    private final AppleOidcService appleOidcService;
    private final GoogleOidcService googleOidcService;
    private final PasswordEncoder passwordEncoder;

    public AuthService(
            UserRepository userRepository,
            AuthProviderRepository authProviderRepository,
            RefreshTokenRepository refreshTokenRepository,
            JwtService jwtService,
            AppleOidcService appleOidcService,
            GoogleOidcService googleOidcService,
            PasswordEncoder passwordEncoder
    ) {
        this.userRepository = userRepository;
        this.authProviderRepository = authProviderRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.jwtService = jwtService;
        this.appleOidcService = appleOidcService;
        this.googleOidcService = googleOidcService;
        this.passwordEncoder = passwordEncoder;
    }

    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new AuthException("Email already registered");
        }
        User user = new User();
        user.setEmail(request.email());
        user.setDisplayName(request.displayName());
        userRepository.save(user);

        AuthProvider credential = new AuthProvider();
        credential.setUser(user);
        credential.setProvider(Provider.EMAIL);
        credential.setPasswordHash(passwordEncoder.encode(request.password()));
        authProviderRepository.save(credential);

        return issueTokens(user);
    }

    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new AuthException("Invalid email or password"));
        AuthProvider credential = authProviderRepository.findByUserAndProvider(user, Provider.EMAIL)
                .orElseThrow(() -> new AuthException("Invalid email or password"));

        if (!passwordEncoder.matches(request.password(), credential.getPasswordHash())) {
            throw new AuthException("Invalid email or password");
        }
        return issueTokens(user);
    }

    public AuthResponse socialAuth(SocialAuthRequest request) {
        Provider provider = switch (request.provider().toUpperCase()) {
            case "APPLE" -> Provider.APPLE;
            case "GOOGLE" -> Provider.GOOGLE;
            default -> throw new AuthException("Unsupported provider: " + request.provider());
        };

        OidcUserInfo info = switch (provider) {
            case APPLE -> appleOidcService.verify(request.idToken());
            case GOOGLE -> googleOidcService.verify(request.idToken());
            default -> throw new AuthException("Unsupported provider");
        };

        return authProviderRepository.findByProviderAndProviderUserId(provider, info.providerUserId())
                .map(ap -> issueTokens(ap.getUser()))
                .orElseGet(() -> {
                    User user = userRepository.findByEmail(info.email()).orElseGet(() -> {
                        // Apple sends displayName only on first auth — passed explicitly in the request body
                        String name = request.displayName() != null ? request.displayName() : info.displayName();
                        User newUser = new User();
                        newUser.setEmail(info.email());
                        newUser.setDisplayName(name);
                        return userRepository.save(newUser);
                    });

                    AuthProvider ap = new AuthProvider();
                    ap.setUser(user);
                    ap.setProvider(provider);
                    ap.setProviderUserId(info.providerUserId());
                    authProviderRepository.save(ap);

                    return issueTokens(user);
                });
    }

    public AuthResponse refresh(RefreshRequest request) {
        String hash = sha256(request.refreshToken());
        RefreshToken token = refreshTokenRepository.findByTokenHash(hash)
                .orElseThrow(() -> new AuthException("Invalid refresh token"));
        if (token.isRevoked() || token.getExpiresAt().isBefore(LocalDateTime.now())) {
            throw new AuthException("Refresh token expired or revoked");
        }
        String accessToken = jwtService.generateAccessToken(
                token.getUser().getId(), token.getUser().getEmail());
        return new AuthResponse(accessToken, request.refreshToken(), toUserDto(token.getUser()));
    }

    public void logout(LogoutRequest request) {
        String hash = sha256(request.refreshToken());
        refreshTokenRepository.findByTokenHash(hash).ifPresent(token -> {
            token.setRevoked(true);
            refreshTokenRepository.save(token);
        });
    }

    private AuthResponse issueTokens(User user) {
        String rawRefreshToken = UUID.randomUUID().toString();
        RefreshToken token = new RefreshToken();
        token.setUser(user);
        token.setTokenHash(sha256(rawRefreshToken));
        token.setExpiresAt(LocalDateTime.now().plusDays(30));
        refreshTokenRepository.save(token);

        String accessToken = jwtService.generateAccessToken(user.getId(), user.getEmail());
        return new AuthResponse(accessToken, rawRefreshToken, toUserDto(user));
    }

    private AuthResponse.UserDto toUserDto(User user) {
        return new AuthResponse.UserDto(user.getId(), user.getEmail(), user.getDisplayName());
    }

    private static String sha256(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (Exception e) {
            throw new RuntimeException("SHA-256 unavailable", e);
        }
    }
}
