// Data access for user accounts
package com.jvilledaapps.gig_manager.auth.repository;

import com.jvilledaapps.gig_manager.auth.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
}
