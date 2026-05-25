// Response payload for a single gig
package com.jvilledaapps.gig_manager.gig.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

import com.jvilledaapps.gig_manager.gig.model.PaymentStatus;

public record GigResponse(UUID id, String name, String location, LocalDate date, LocalTime startTime, LocalTime endTime,
        String type, BigDecimal paymentAmount, PaymentStatus paymentStatus, String notes, LocalDateTime createdAt,
        LocalDateTime updatedAt) {
}
