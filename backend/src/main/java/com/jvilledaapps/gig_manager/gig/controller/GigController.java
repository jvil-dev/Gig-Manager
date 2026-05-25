// REST endpoints for the authenticated user's gigs
package com.jvilledaapps.gig_manager.gig.controller;

import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.jvilledaapps.gig_manager.gig.dto.CreateGigRequest;
import com.jvilledaapps.gig_manager.gig.dto.GigResponse;
import com.jvilledaapps.gig_manager.gig.dto.UpdateGigRequest;
import com.jvilledaapps.gig_manager.gig.service.GigService;

@RestController
@RequestMapping("/api/v1/gigs")
public class GigController {

    private final GigService gigService;

    public GigController(GigService gigService) {
        this.gigService = gigService;
    }

    @PostMapping
    public ResponseEntity<GigResponse> createGig(@AuthenticationPrincipal UUID userId,
            @RequestBody CreateGigRequest request) {
        GigResponse created = gigService.createGig(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping
    public ResponseEntity<List<GigResponse>> getGigs(@AuthenticationPrincipal UUID userId) {
        return ResponseEntity.ok(gigService.getGigs(userId));
    }

    @GetMapping("/event-type-suggestions")
    public ResponseEntity<List<String>> getEventTypeSuggestions(@AuthenticationPrincipal UUID userId) {
        return ResponseEntity.ok(gigService.getTypeSuggestions(userId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<GigResponse> getGig(@AuthenticationPrincipal UUID userId, @PathVariable UUID id) {
        return ResponseEntity.ok(gigService.getGig(userId, id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<GigResponse> updateGig(@AuthenticationPrincipal UUID userId, @PathVariable UUID id,
            @RequestBody UpdateGigRequest request) {
        return ResponseEntity.ok(gigService.updateGig(userId, id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteGig(@AuthenticationPrincipal UUID userId, @PathVariable UUID id) {
        gigService.deleteGig(userId, id);
        return ResponseEntity.noContent().build();
    }
}
