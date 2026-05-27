// Data access for clients
package com.jvilledaapps.gig_manager.client.repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.jvilledaapps.gig_manager.client.model.Client;

public interface ClientRepository extends JpaRepository<Client, UUID> {

    List<Client> findByUserIdOrderByNameAsc(UUID userId);

    Optional<Client> findByIdAndUserId(UUID id, UUID userId);

    void deleteByIdAndUserId(UUID id, UUID userId);
}
