package com.willbank.client.dto;

import com.willbank.client.entity.ClientStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.NotNull;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ClientStatusUpdateRequest {
    
    @NotNull(message = "Client status is required")
    private ClientStatus status;
    
    private String reason;
}
