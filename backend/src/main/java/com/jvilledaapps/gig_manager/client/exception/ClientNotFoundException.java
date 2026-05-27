// Thrown when a client is not found or does not belong to the requesting user
package com.jvilledaapps.gig_manager.client.exception;

public class ClientNotFoundException extends RuntimeException {

    public ClientNotFoundException(String message) {
        super(message);
    }

}
