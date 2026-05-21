package com.jvilledaapps.gig_manager.auth.dto;

public record SocialAuthRequest(String provider, String idToken, String displayName) {
}
