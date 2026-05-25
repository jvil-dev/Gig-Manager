// Input for updating a gig
package com.jvilledaapps.gig_manager.gig.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;

public record UpdateGigRequest(String name, String location, LocalDate date, LocalTime startTime, LocalTime endTime,
        String type, BigDecimal paymentAmount, String notes) {

}
