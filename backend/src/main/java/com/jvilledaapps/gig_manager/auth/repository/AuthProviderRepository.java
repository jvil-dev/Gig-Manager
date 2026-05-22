// Data access for per-provider sign-in credentials
package com.jvilledaapps.gig_manager.auth.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.jvilledaapps.gig_manager.auth.model.AuthProvider;
import com.jvilledaapps.gig_manager.auth.model.Provider;
import com.jvilledaapps.gig_manager.auth.model.User;

public interface AuthProviderRepository extends JpaRepository<AuthProvider, UUID> {

    @Query("SELECT ap FROM AuthProvider ap WHERE ap.user = :user AND ap.provider = :provider")
    Optional<AuthProvider> findByUserAndProvider(@Param("user") User user, @Param("provider") Provider provider);

    Optional<AuthProvider> findByProviderAndProviderUserId(Provider provider, String providerUserId);
}
