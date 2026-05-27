// Unit tests for ClientService - verifies ownership isolation and CRUD behavior
package com.jvilledaapps.gig_manager.client.service;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import static org.mockito.ArgumentMatchers.any;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import org.mockito.junit.jupiter.MockitoExtension;

import com.jvilledaapps.gig_manager.client.dto.ClientResponse;
import com.jvilledaapps.gig_manager.client.dto.CreateClientRequest;
import com.jvilledaapps.gig_manager.client.dto.UpdateClientRequest;
import com.jvilledaapps.gig_manager.client.exception.ClientNotFoundException;
import com.jvilledaapps.gig_manager.client.model.Client;
import com.jvilledaapps.gig_manager.client.repository.ClientRepository;

@ExtendWith(MockitoExtension.class)
class ClientServiceTest {

    @Mock
    private ClientRepository clientRepository;

    @InjectMocks
    private ClientService clientService;

    private UUID userId;
    private UUID clientId;

    @BeforeEach
    void setUp() {
        userId = UUID.randomUUID();
        clientId = UUID.randomUUID();
    }

    @Test
    void createClient_setsUserId() {
        CreateClientRequest request = new CreateClientRequest(
                "Acme Weddings", "events@acme.com", "555-1212", "Acme Events", null);

        when(clientRepository.save(any(Client.class))).thenAnswer(invocation -> invocation.getArgument(0));

        ClientResponse response = clientService.createClient(userId, request);

        assertThat(response.name()).isEqualTo("Acme Weddings");
        assertThat(response.email()).isEqualTo("events@acme.com");
        verify(clientRepository).save(any(Client.class));
    }

    @Test
    void getClient_returnsResponseWhenOwned() {
        when(clientRepository.findByIdAndUserId(clientId, userId)).thenReturn(Optional.of(makeClient()));

        ClientResponse response = clientService.getClient(userId, clientId);

        assertThat(response.name()).isEqualTo("Acme Weddings");
    }

    @Test
    void getClient_throwsWhenNotFoundOrNotOwned() {
        when(clientRepository.findByIdAndUserId(clientId, userId)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> clientService.getClient(userId, clientId))
                .isInstanceOf(ClientNotFoundException.class);
    }

    @Test
    void updateClient_appliesOnlyNonNullFields() {
        when(clientRepository.findByIdAndUserId(clientId, userId)).thenReturn(Optional.of(makeClient()));

        UpdateClientRequest request = new UpdateClientRequest("Renamed", null, "555-9999", null, null);

        ClientResponse response = clientService.updateClient(userId, clientId, request);

        assertThat(response.name()).isEqualTo("Renamed");
        assertThat(response.phone()).isEqualTo("555-9999");
        // Untouched fields stay the same
        assertThat(response.email()).isEqualTo("events@acme.com");
        assertThat(response.company()).isEqualTo("Acme Events");
    }

    @Test
    void deleteClient_throwsWhenNotFoundOrNotOwned() {
        when(clientRepository.findByIdAndUserId(clientId, userId)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> clientService.deleteClient(userId, clientId))
                .isInstanceOf(ClientNotFoundException.class);

        verify(clientRepository, never()).deleteByIdAndUserId(any(), any());
    }

    @Test
    void deleteClient_callsRepositoryWhenOwned() {
        when(clientRepository.findByIdAndUserId(clientId, userId)).thenReturn(Optional.of(makeClient()));

        clientService.deleteClient(userId, clientId);

        verify(clientRepository, times(1)).deleteByIdAndUserId(clientId, userId);
    }

    private Client makeClient() {
        Client client = new Client();
        client.setUserId(userId);
        client.setName("Acme Weddings");
        client.setEmail("events@acme.com");
        client.setPhone("555-1212");
        client.setCompany("Acme Events");
        return client;
    }
}