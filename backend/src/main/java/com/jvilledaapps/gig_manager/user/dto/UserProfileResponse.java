// Response payload for the authenticated user's own profile
package com.jvilledaapps.gig_manager.user.dto;

import java.time.Instant;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonFormat;

public record UserProfileResponse(
        UUID id,
        String email,
        String displayName,
        @JsonFormat(shape = JsonFormat.Shape.STRING) Instant createdAt) {
}
