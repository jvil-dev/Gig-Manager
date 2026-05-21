package com.jvilledaapps.gig_manager.auth.dto;

public record OidcUserInfo(String providerUserId, String email, String displayName) {
}
