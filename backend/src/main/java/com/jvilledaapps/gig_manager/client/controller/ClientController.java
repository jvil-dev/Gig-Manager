// REST endpoints for the authenticated user's clients
package com.jvilledaapps.gig_manager.client.controller;

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

import com.jvilledaapps.gig_manager.client.dto.ClientResponse;
import com.jvilledaapps.gig_manager.client.dto.CreateClientRequest;
import com.jvilledaapps.gig_manager.client.dto.UpdateClientRequest;
import com.jvilledaapps.gig_manager.client.service.ClientService;

@RestController
@RequestMapping("/api/v1/clients")
public class ClientController {

    private final ClientService clientService;

    public ClientController(ClientService clientService) {
        this.clientService = clientService;
    }

    @PostMapping
    public ResponseEntity<ClientResponse> createClient(@AuthenticationPrincipal UUID userId,
            @RequestBody CreateClientRequest request) {
        ClientResponse created = clientService.createClient(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    @GetMapping
    public ResponseEntity<List<ClientResponse>> getClients(@AuthenticationPrincipal UUID userId) {
        return ResponseEntity.ok(clientService.getClients(userId));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ClientResponse> getClient(@AuthenticationPrincipal UUID userId, @PathVariable UUID id) {
        return ResponseEntity.ok(clientService.getClient(userId, id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ClientResponse> updateClient(@AuthenticationPrincipal UUID userId, @PathVariable UUID id,
            @RequestBody UpdateClientRequest request) {
        return ResponseEntity.ok(clientService.updateClient(userId, id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteClient(@AuthenticationPrincipal UUID userId, @PathVariable UUID id) {
        clientService.deleteClient(userId, id);
        return ResponseEntity.noContent().build();
    }
}
