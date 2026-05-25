// Input for creating a new gig
package com.jvilledaapps.gig_manager.gig.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;

public record CreateGigRequest(String name, String location, LocalDate date, LocalTime startTime, LocalTime endTime,
        String type, BigDecimal paymentAmount, String notes) {

}
