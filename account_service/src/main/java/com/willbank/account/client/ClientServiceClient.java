package com.willbank.account.client;

import com.willbank.account.dto.ClientDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

/**
 * Feign Client pour communiquer avec le Client Service
 */
@FeignClient(name = "client-service", fallback = ClientServiceClientFallback.class)
public interface ClientServiceClient {
    
    @GetMapping("/api/clients/{id}")
    ClientDto getClientById(@PathVariable("id") Long id);
}
