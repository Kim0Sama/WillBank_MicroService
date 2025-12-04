package com.willbank.client.controller;

import com.willbank.client.dto.ClientDto;
import com.willbank.client.dto.CreateClientRequest;
import com.willbank.client.dto.UpdateClientRequest;
import com.willbank.client.service.ClientService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/admin/clients")
@RequiredArgsConstructor
public class AdminClientController {
    
    private final ClientService clientService;
    
    @GetMapping
    public ResponseEntity<List<ClientDto>> getAllClients(
            @RequestHeader("X-User-Role") String role) {
        if (!"ADMIN".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        List<ClientDto> clients = clientService.getAllClients();
        return ResponseEntity.ok(clients);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ClientDto> getClient(
            @PathVariable Long id,
            @RequestHeader("X-User-Role") String role) {
        if (!"ADMIN".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        ClientDto client = clientService.getClientById(id);
        return ResponseEntity.ok(client);
    }
    
    @PostMapping
    public ResponseEntity<ClientDto> createClient(
            @Valid @RequestBody CreateClientRequest request,
            @RequestHeader("X-User-Role") String role) {
        if (!"ADMIN".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        ClientDto client = clientService.createClient(request);
        return new ResponseEntity<>(client, HttpStatus.CREATED);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ClientDto> updateClient(
            @PathVariable Long id,
            @Valid @RequestBody UpdateClientRequest request,
            @RequestHeader("X-User-Role") String role) {
        if (!"ADMIN".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        ClientDto client = clientService.updateClient(id, request);
        return ResponseEntity.ok(client);
    }
}
