// Input for creating a new client
package com.jvilledaapps.gig_manager.client.dto;

public record CreateClientRequest(
        String name,
        String email,
        String phone,
        String company,
        String notes) {
}
