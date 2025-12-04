package com.willbank.account.client;

import com.willbank.account.dto.ClientDto;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * Fallback pour le Client Service en cas d'indisponibilité
 */
@Component
@Slf4j
public class ClientServiceClientFallback implements ClientServiceClient {
    
    @Override
    public ClientDto getClientById(Long id) {
        log.error("Client Service is unavailable. Fallback triggered for client ID: {}", id);
        throw new RuntimeException("Client Service is currently unavailable. Please try again later.");
    }
}
