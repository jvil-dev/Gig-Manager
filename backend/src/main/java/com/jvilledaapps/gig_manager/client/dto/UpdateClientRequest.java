// Input for updating a client
package com.jvilledaapps.gig_manager.client.dto;

public record UpdateClientRequest(
        String name,
        String email,
        String phone,
        String company,
        String notes) {

}
