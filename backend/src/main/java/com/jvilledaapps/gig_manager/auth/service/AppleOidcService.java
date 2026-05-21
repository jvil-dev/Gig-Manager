// Verifies Apple Sign In ID tokens against Apple's public JWKS endpoint
package com.jvilledaapps.gig_manager.auth.service;

import java.net.URL;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.jvilledaapps.gig_manager.auth.dto.OidcUserInfo;
import com.jvilledaapps.gig_manager.auth.exception.AuthException;
import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.jwk.source.JWKSource;
import com.nimbusds.jose.jwk.source.RemoteJWKSet;
import com.nimbusds.jose.proc.JWSVerificationKeySelector;
import com.nimbusds.jose.proc.SecurityContext;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.proc.ConfigurableJWTProcessor;
import com.nimbusds.jwt.proc.DefaultJWTProcessor;

@Service
public class AppleOidcService {

    private static final String APPLE_JWKS_URL = "https://appleid.apple.com/auth/keys";
    private static final String APPLE_ISSUER = "https://appleid.apple.com";

    private final String bundleId;
    private final ConfigurableJWTProcessor<SecurityContext> jwtProcessor;

    public AppleOidcService(@Value("${app.apple.bundle-id}") String bundleId) throws Exception {
        this.bundleId = bundleId;
        JWKSource<SecurityContext> jwkSource = new RemoteJWKSet<>(new URL(APPLE_JWKS_URL));
        this.jwtProcessor = new DefaultJWTProcessor<>();
        this.jwtProcessor
                .setJWSKeySelector(new JWSVerificationKeySelector<SecurityContext>(JWSAlgorithm.RS256, jwkSource));
    }

    public OidcUserInfo verify(String idToken) {
        try {
            JWTClaimsSet claims = jwtProcessor.process(idToken, null);
            if (!APPLE_ISSUER.equals(claims.getIssuer())) {
                throw new AuthException("Invalid Apple token issuer");
            }
            if (!claims.getAudience().contains(bundleId)) {
                throw new AuthException("Invalid Apple token audience");
            }
            return new OidcUserInfo(claims.getSubject(), claims.getStringClaim("email"), null);
        } catch (AuthException e) {
            throw e;
        } catch (Exception e) {
            throw new AuthException("Apple token verification failed: " + e.getMessage());
        }
    }
}
