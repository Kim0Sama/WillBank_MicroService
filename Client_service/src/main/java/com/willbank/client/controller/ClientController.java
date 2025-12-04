package com.willbank.client.controller;

import com.willbank.client.dto.ClientDto;
import com.willbank.client.dto.CreateClientRequest;
import com.willbank.client.dto.KycUpdateRequest;
import com.willbank.client.dto.UpdateClientRequest;
import com.willbank.client.entity.ClientStatus;
import com.willbank.client.entity.KycStatus;
import com.willbank.client.service.ClientService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/clients")
@RequiredArgsConstructor
@Slf4j
public class ClientController {
    
    private final ClientService clientService;
    
    @PostMapping
    public ResponseEntity<ClientDto> createClient(@Valid @RequestBody CreateClientRequest request) {
        log.info("REST request to create client: {}", request.getEmail());
        ClientDto client = clientService.createClient(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(client);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ClientDto> getClientById(@PathVariable Long id) {
        log.info("REST request to get client by ID: {}", id);
        ClientDto client = clientService.getClientById(id);
        return ResponseEntity.ok(client);
    }
    
    @GetMapping("/email/{email}")
    public ResponseEntity<ClientDto> getClientByEmail(@PathVariable String email) {
        log.info("REST request to get client by email: {}", email);
        ClientDto client = clientService.getClientByEmail(email);
        return ResponseEntity.ok(client);
    }
    
    @GetMapping
    public ResponseEntity<List<ClientDto>> getAllClients() {
        log.info("REST request to get all clients");
        List<ClientDto> clients = clientService.getAllClients();
        return ResponseEntity.ok(clients);
    }
    
    @GetMapping("/status/{status}")
    public ResponseEntity<List<ClientDto>> getClientsByStatus(@PathVariable ClientStatus status) {
        log.info("REST request to get clients by status: {}", status);
        List<ClientDto> clients = clientService.getClientsByStatus(status);
        return ResponseEntity.ok(clients);
    }
    
    @GetMapping("/kyc-status/{kycStatus}")
    public ResponseEntity<List<ClientDto>> getClientsByKycStatus(@PathVariable KycStatus kycStatus) {
        log.info("REST request to get clients by KYC status: {}", kycStatus);
        List<ClientDto> clients = clientService.getClientsByKycStatus(kycStatus);
        return ResponseEntity.ok(clients);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ClientDto> updateClient(
            @PathVariable Long id,
            @Valid @RequestBody UpdateClientRequest request) {
        log.info("REST request to update client: {}", id);
        ClientDto client = clientService.updateClient(id, request);
        return ResponseEntity.ok(client);
    }
    
    @PatchMapping("/{id}/status")
    public ResponseEntity<ClientDto> updateClientStatus(
            @PathVariable Long id,
            @RequestParam ClientStatus status) {
        log.info("REST request to update client status: {} to {}", id, status);
        ClientDto client = clientService.updateClientStatus(id, status);
        return ResponseEntity.ok(client);
    }
    
    @PatchMapping("/{id}/kyc")
    public ResponseEntity<ClientDto> updateKycStatus(
            @PathVariable Long id,
            @Valid @RequestBody KycUpdateRequest request) {
        log.info("REST request to update KYC status for client: {}", id);
        ClientDto client = clientService.updateKycStatus(id, request);
        return ResponseEntity.ok(client);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteClient(@PathVariable Long id) {
        log.info("REST request to delete client: {}", id);
        clientService.deleteClient(id);
        return ResponseEntity.noContent().build();
    }
}
