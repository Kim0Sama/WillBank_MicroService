package com.willbank.client.dto;

import com.willbank.client.entity.KycStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.NotNull;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class KycUpdateRequest {
    
    @NotNull(message = "KYC status is required")
    private KycStatus kycStatus;
    
    private String notes;
}
