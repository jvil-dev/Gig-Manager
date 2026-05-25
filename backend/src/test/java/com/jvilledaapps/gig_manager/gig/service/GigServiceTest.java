package com.jvilledaapps.gig_manager.gig.service;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.jvilledaapps.gig_manager.gig.dto.CreateGigRequest;
import com.jvilledaapps.gig_manager.gig.dto.GigResponse;
import com.jvilledaapps.gig_manager.gig.dto.UpdateGigRequest;
import com.jvilledaapps.gig_manager.gig.exception.GigNotFoundException;
import com.jvilledaapps.gig_manager.gig.model.Gig;
import com.jvilledaapps.gig_manager.gig.model.PaymentStatus;
import com.jvilledaapps.gig_manager.gig.repository.GigRepository;

@ExtendWith(MockitoExtension.class)
class GigServiceTest {

    @Mock
    private GigRepository gigRepository;

    @InjectMocks
    private GigService gigService;

    private UUID userId;
    private UUID gigId;

    @BeforeEach
    void setUp() {
        userId = UUID.randomUUID();
        gigId = UUID.randomUUID();
    }

    @Test
    void createGig_setsUserIdAndDefaultsPaymentStatusToUnpaid() {
        CreateGigRequest request = new CreateGigRequest(
                "Smith Wedding", "Grand Ballroom", LocalDate.of(2026, 6, 15),
                null, null, "wedding", new BigDecimal("1200.00"), null);

        when(gigRepository.save(any(Gig.class))).thenAnswer(invocation -> invocation.getArgument(0));

        GigResponse response = gigService.createGig(userId, request);

        assertThat(response.name()).isEqualTo("Smith Wedding");
        assertThat(response.paymentStatus()).isEqualTo(PaymentStatus.UNPAID);
        verify(gigRepository).save(any(Gig.class));
    }

    @Test
    void getGig_returnsResponseWhenOwned() {
        Gig gig = makeGig();
        when(gigRepository.findByIdAndUserId(gigId, userId)).thenReturn(Optional.of(gig));

        GigResponse response = gigService.getGig(userId, gigId);

        assertThat(response.name()).isEqualTo("Smith Wedding");
    }

    @Test
    void getGig_throwsWhenNotFoundOrNotOwned() {
        when(gigRepository.findByIdAndUserId(gigId, userId)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> gigService.getGig(userId, gigId))
                .isInstanceOf(GigNotFoundException.class);
    }

    @Test
    void updateGig_appliesOnlyNonNullFields() {
        Gig gig = makeGig();
        when(gigRepository.findByIdAndUserId(gigId, userId)).thenReturn(Optional.of(gig));

        UpdateGigRequest request = new UpdateGigRequest(
                "Renamed", null, null, null, null, null, new BigDecimal("1500.00"), null);

        GigResponse response = gigService.updateGig(userId, gigId, request);

        assertThat(response.name()).isEqualTo("Renamed");
        assertThat(response.paymentAmount()).isEqualByComparingTo("1500.00");
        // Untouched field stays the same
        assertThat(response.location()).isEqualTo("Grand Ballroom");
    }

    @Test
    void deleteGig_throwsWhenNotFoundOrNotOwned() {
        when(gigRepository.findByIdAndUserId(gigId, userId)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> gigService.deleteGig(userId, gigId))
                .isInstanceOf(GigNotFoundException.class);

        verify(gigRepository, never()).deleteByIdAndUserId(any(), any());
    }

    @Test
    void deleteGig_callsRepositoryWhenOwned() {
        when(gigRepository.findByIdAndUserId(gigId, userId)).thenReturn(Optional.of(makeGig()));

        gigService.deleteGig(userId, gigId);

        verify(gigRepository, times(1)).deleteByIdAndUserId(gigId, userId);
    }

    @Test
    void getTypeSuggestions_returnsRepositoryResult() {
        when(gigRepository.findDistinctTypesByUserId(userId))
                .thenReturn(List.of("wedding", "grad party"));

        List<String> result = gigService.getTypeSuggestions(userId);

        assertThat(result).containsExactly("wedding", "grad party");
    }

    private Gig makeGig() {
        Gig gig = new Gig();
        gig.setUserId(userId);
        gig.setName("Smith Wedding");
        gig.setLocation("Grand Ballroom");
        gig.setDate(LocalDate.of(2026, 6, 15));
        gig.setType("wedding");
        gig.setPaymentAmount(new BigDecimal("1200.00"));
        gig.setPaymentStatus(PaymentStatus.UNPAID);
        return gig;
    }
}
