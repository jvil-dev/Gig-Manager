// Response payload for the authenticated user's own profile
package com.jvilledaapps.gig_manager.user.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record UserProfileResponse(UUID id, String email, String displayName, LocalDateTime createdAt) {
}
