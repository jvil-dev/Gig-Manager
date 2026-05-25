// Business logic for gig CRUD - all operations scoped to the authenticated user
package com.jvilledaapps.gig_manager.gig.service;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.jvilledaapps.gig_manager.gig.dto.CreateGigRequest;
import com.jvilledaapps.gig_manager.gig.dto.GigResponse;
import com.jvilledaapps.gig_manager.gig.dto.UpdateGigRequest;
import com.jvilledaapps.gig_manager.gig.exception.GigNotFoundException;
import com.jvilledaapps.gig_manager.gig.model.Gig;
import com.jvilledaapps.gig_manager.gig.repository.GigRepository;

@Service
public class GigService {

    private final GigRepository gigRepository;

    public GigService(GigRepository gigRepository) {
        this.gigRepository = gigRepository;
    }

    public GigResponse createGig(UUID userId, CreateGigRequest request) {
        Gig gig = new Gig();
        gig.setUserId(userId);
        gig.setName(request.name());
        gig.setLocation(request.location());
        gig.setDate(request.date());
        gig.setStartTime(request.startTime());
        gig.setEndTime(request.endTime());
        gig.setType(request.type());
        gig.setPaymentAmount(request.paymentAmount());
        gig.setNotes(request.notes());

        return toResponse(gigRepository.save(gig));
    }

    public List<GigResponse> getGigs(UUID userId) {
        return gigRepository.findByUserIdOrderByDateDesc(userId).stream()
                .map(this::toResponse)
                .toList();
    }

    public GigResponse getGig(UUID userId, UUID gigId) {
        return toResponse(findOwnedGig(userId, gigId));
    }

    @Transactional
    public GigResponse updateGig(UUID userId, UUID gigId, UpdateGigRequest request) {
        Gig gig = findOwnedGig(userId, gigId);

        if (request.name() != null)
            gig.setName(request.name());
        if (request.location() != null)
            gig.setLocation(request.location());
        if (request.date() != null)
            gig.setDate(request.date());
        if (request.startTime() != null)
            gig.setStartTime(request.startTime());
        if (request.endTime() != null)
            gig.setEndTime(request.endTime());
        if (request.type() != null)
            gig.setType(request.type());
        if (request.paymentAmount() != null)
            gig.setPaymentAmount(request.paymentAmount());
        if (request.notes() != null)
            gig.setNotes(request.notes());

        return toResponse(gig);
    }

    @Transactional
    public void deleteGig(UUID userId, UUID gigId) {
        findOwnedGig(userId, gigId);
        gigRepository.deleteByIdAndUserId(gigId, userId);
    }

    public List<String> getTypeSuggestions(UUID userId) {
        return gigRepository.findDistinctTypesByUserId(userId);
    }

    private Gig findOwnedGig(UUID userId, UUID gigId) {
        return gigRepository.findByIdAndUserId(gigId, userId)
                .orElseThrow(() -> new GigNotFoundException("Gig not found: " + gigId));
    }

    private GigResponse toResponse(Gig gig) {
        return new GigResponse(
                gig.getId(),
                gig.getName(),
                gig.getLocation(),
                gig.getDate(),
                gig.getStartTime(),
                gig.getEndTime(),
                gig.getType(),
                gig.getPaymentAmount(),
                gig.getPaymentStatus(),
                gig.getNotes(),
                gig.getCreatedAt(),
                gig.getUpdatedAt());
    }
}
