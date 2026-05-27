// Response payload for a single client
package com.jvilledaapps.gig_manager.client.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record ClientResponse(
        UUID id,
        String name,
        String email,
        String phone,
        String company,
        String notes,
        LocalDateTime createdAt,
        LocalDateTime updatedAt) {

}
