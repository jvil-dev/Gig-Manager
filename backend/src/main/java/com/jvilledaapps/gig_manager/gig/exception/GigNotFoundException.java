package com.jvilledaapps.gig_manager.gig.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.NOT_FOUND)
public class GigNotFoundException extends RuntimeException {

    public GigNotFoundException (String message) {
        super(message);
    }
}
