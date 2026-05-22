// Auth endpoints - delegates entirely to AuthService
package com.jvilledaapps.gig_manager.auth.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.jvilledaapps.gig_manager.auth.dto.AuthResponse;
import com.jvilledaapps.gig_manager.auth.dto.LoginRequest;
import com.jvilledaapps.gig_manager.auth.dto.LogoutRequest;
import com.jvilledaapps.gig_manager.auth.dto.RefreshRequest;
import com.jvilledaapps.gig_manager.auth.dto.RegisterRequest;
import com.jvilledaapps.gig_manager.auth.dto.SocialAuthRequest;
import com.jvilledaapps.gig_manager.auth.service.AuthService;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@RequestBody RegisterRequest request) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/social")
    public ResponseEntity<AuthResponse> social(@RequestBody SocialAuthRequest request) {
        return ResponseEntity.ok(authService.socialAuth(request));
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refresh(@RequestBody RefreshRequest request) {
        return ResponseEntity.ok(authService.refresh(request));
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(@RequestBody LogoutRequest request) {
        authService.logout(request);
        return ResponseEntity.noContent().build();
    }
}
