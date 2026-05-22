// Data access for refresh token revocation
package com.jvilledaapps.gig_manager.auth.repository;

import com.jvilledaapps.gig_manager.auth.model.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {
    Optional<RefreshToken> findByTokenHash(String tokenHash);
}
