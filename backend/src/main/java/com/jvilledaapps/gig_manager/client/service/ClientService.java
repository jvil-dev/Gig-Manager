// Business logic for client CRUD
package com.jvilledaapps.gig_manager.client.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.jvilledaapps.gig_manager.client.dto.ClientResponse;
import com.jvilledaapps.gig_manager.client.dto.CreateClientRequest;
import com.jvilledaapps.gig_manager.client.dto.UpdateClientRequest;
import com.jvilledaapps.gig_manager.client.exception.ClientNotFoundException;
import com.jvilledaapps.gig_manager.client.model.Client;
import com.jvilledaapps.gig_manager.client.repository.ClientRepository;

@Service
public class ClientService {

    private final ClientRepository clientRepository;

    public ClientService(ClientRepository clientRepository) {
        this.clientRepository = clientRepository;
    }

    public ClientResponse createClient(UUID userId, CreateClientRequest request) {
        Client client = new Client();
        client.setUserId(userId);
        client.setName(request.name());
        client.setEmail(request.email());
        client.setPhone(request.phone());
        client.setCompany(request.company());
        client.setNotes(request.notes());

        return toResponse(clientRepository.save(client));
    }

    public List<ClientResponse> getClients(UUID userId) {
        return clientRepository.findByUserIdOrderByNameAsc(userId).stream()
                .map(this::toResponse)
                .toList();
    }

    public ClientResponse getClient(UUID userId, UUID clientId) {
        return toResponse(findOwnedClient(userId, clientId));
    }

    @Transactional
    public ClientResponse updateClient(UUID userId, UUID clientId, UpdateClientRequest request) {
        Client client = findOwnedClient(userId, clientId);

        if (request.name() != null)
            client.setName(request.name());
        if (request.email() != null)
            client.setEmail(request.email());
        if (request.phone() != null)
            client.setPhone(request.phone());
        if (request.company() != null)
            client.setCompany(request.company());
        if (request.notes() != null)
            client.setNotes(request.notes());

        return toResponse(client);
    }

    @Transactional
    public void deleteClient(UUID userId, UUID clientId) {
        findOwnedClient(userId, clientId);
        clientRepository.deleteByIdAndUserId(clientId, userId);
    }

    private Client findOwnedClient(UUID userId, UUID clientId) {
        return clientRepository.findByIdAndUserId(clientId, userId)
                .orElseThrow(() -> new ClientNotFoundException("Client not found: " + clientId));
    }

    private ClientResponse toResponse(Client client) {
        return new ClientResponse(
                client.getId(),
                client.getName(),
                client.getEmail(),
                client.getPhone(),
                client.getCompany(),
                client.getNotes(),
                client.getCreatedAt(),
                client.getUpdatedAt());
    }
}
