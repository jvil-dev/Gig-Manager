// Read-side operations for the authenticated user's own profile
package com.jvilledaapps.gig_manager.user.service;

import java.util.UUID;

import org.springframework.stereotype.Service;

import com.jvilledaapps.gig_manager.auth.model.User;
import com.jvilledaapps.gig_manager.auth.repository.UserRepository;
import com.jvilledaapps.gig_manager.user.dto.UserProfileResponse;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public UserProfileResponse getProfile(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalStateException("User not found for authenticated principal: " + userId));

        return new UserProfileResponse(user.getId(), user.getEmail(), user.getDisplayName(), user.getCreatedAt());
    }
}
