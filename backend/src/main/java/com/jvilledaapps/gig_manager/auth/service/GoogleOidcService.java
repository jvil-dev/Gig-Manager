// Verifies Google Sign In ID tokens against Google's public JWKS endpoint
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
public class GoogleOidcService {

    private static final String GOOGLE_JWKS_URL = "https://www.googleapis.com/oauth2/v3/certs";
    private static final String GOOGLE_ISSUER = "https://accounts.google.com";

    private final String clientId;
    private final ConfigurableJWTProcessor<SecurityContext> jwtProcessor;

    public GoogleOidcService(@Value("${app.google.client-id") String clientId) throws Exception {
        this.clientId = clientId;
        JWKSource<SecurityContext> jwkSource = new RemoteJWKSet<>(new URL(GOOGLE_JWKS_URL));
        this.jwtProcessor = new DefaultJWTProcessor<>();
        this.jwtProcessor
                .setJWSKeySelector(new JWSVerificationKeySelector<SecurityContext>(JWSAlgorithm.RS256, jwkSource));
    }

    public OidcUserInfo verify(String idToken) {
        try {
            JWTClaimsSet claims = jwtProcessor.process(idToken, null);
            if (!GOOGLE_ISSUER.equals(claims.getIssuer())) {
                throw new AuthException("Invalid Google token issuer");
            }
            if (!claims.getAudience().contains(clientId)) {
                throw new AuthException("Invalid Google token audience");
            }
            return new OidcUserInfo(
                    claims.getSubject(),
                    claims.getStringClaim("email"),
                    claims.getStringClaim("name"));
        } catch (AuthException e) {
            throw e;
        } catch (Exception e) {
            throw new AuthException("Google token verification failed: " + e.getMessage());
        }
    }
}
