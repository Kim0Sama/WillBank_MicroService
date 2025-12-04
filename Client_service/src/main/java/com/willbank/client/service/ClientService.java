package com.willbank.client.service;

import com.willbank.client.dto.ClientDto;
import com.willbank.client.dto.CreateClientRequest;
import com.willbank.client.dto.KycUpdateRequest;
import com.willbank.client.dto.UpdateClientRequest;
import com.willbank.client.entity.Client;
import com.willbank.client.entity.ClientStatus;
import com.willbank.client.entity.KycStatus;
import com.willbank.client.exception.ClientAlreadyExistsException;
import com.willbank.client.exception.ClientNotFoundException;
import com.willbank.client.repository.ClientRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ClientService {
    
    private final ClientRepository clientRepository;
    
    @Transactional
    public ClientDto createClient(CreateClientRequest request) {
        log.info("Creating new client with email: {}", request.getEmail());
        
        if (clientRepository.existsByEmail(request.getEmail())) {
            throw new ClientAlreadyExistsException("Client with email " + request.getEmail() + " already exists");
        }
        
        if (clientRepository.existsByNationalId(request.getNationalId())) {
            throw new ClientAlreadyExistsException("Client with national ID " + request.getNationalId() + " already exists");
        }
        
        Client client = new Client();
        client.setFirstName(request.getFirstName());
        client.setLastName(request.getLastName());
        client.setEmail(request.getEmail());
        client.setPhoneNumber(request.getPhoneNumber());
        client.setAddress(request.getAddress());
        client.setCity(request.getCity());
        client.setPostalCode(request.getPostalCode());
        client.setCountry(request.getCountry());
        client.setDateOfBirth(request.getDateOfBirth());
        client.setNationalId(request.getNationalId());
        client.setStatus(ClientStatus.PENDING);
        client.setKycStatus(KycStatus.PENDING_VERIFICATION);
        
        Client savedClient = clientRepository.save(client);
        log.info("Client created successfully with ID: {}", savedClient.getId());
        
        return mapToDto(savedClient);
    }
    
    @Transactional(readOnly = true)
    public ClientDto getClientById(Long id) {
        log.info("Fetching client with ID: {}", id);
        Client client = clientRepository.findById(id)
                .orElseThrow(() -> new ClientNotFoundException("Client not found with ID: " + id));
        return mapToDto(client);
    }
    
    @Transactional(readOnly = true)
    public ClientDto getClientByEmail(String email) {
        log.info("Fetching client with email: {}", email);
        Client client = clientRepository.findByEmail(email)
                .orElseThrow(() -> new ClientNotFoundException("Client not found with email: " + email));
        return mapToDto(client);
    }
    
    @Transactional(readOnly = true)
    public List<ClientDto> getAllClients() {
        log.info("Fetching all clients");
        return clientRepository.findAll().stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<ClientDto> getClientsByStatus(ClientStatus status) {
        log.info("Fetching clients with status: {}", status);
        return clientRepository.findByStatus(status).stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }
    
    @Transactional(readOnly = true)
    public List<ClientDto> getClientsByKycStatus(KycStatus kycStatus) {
        log.info("Fetching clients with KYC status: {}", kycStatus);
        return clientRepository.findByKycStatus(kycStatus).stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }
    
    @Transactional
    public ClientDto updateClient(Long id, UpdateClientRequest request) {
        log.info("Updating client with ID: {}", id);
        
        Client client = clientRepository.findById(id)
                .orElseThrow(() -> new ClientNotFoundException("Client not found with ID: " + id));
        
        if (request.getFirstName() != null) {
            client.setFirstName(request.getFirstName());
        }
        if (request.getLastName() != null) {
            client.setLastName(request.getLastName());
        }
        if (request.getEmail() != null && !request.getEmail().equals(client.getEmail())) {
            if (clientRepository.existsByEmail(request.getEmail())) {
                throw new ClientAlreadyExistsException("Email already in use");
            }
            client.setEmail(request.getEmail());
        }
        if (request.getPhoneNumber() != null) {
            client.setPhoneNumber(request.getPhoneNumber());
        }
        if (request.getAddress() != null) {
            client.setAddress(request.getAddress());
        }
        if (request.getCity() != null) {
            client.setCity(request.getCity());
        }
        if (request.getPostalCode() != null) {
            client.setPostalCode(request.getPostalCode());
        }
        if (request.getCountry() != null) {
            client.setCountry(request.getCountry());
        }
        
        Client updatedClient = clientRepository.save(client);
        log.info("Client updated successfully with ID: {}", updatedClient.getId());
        
        return mapToDto(updatedClient);
    }
    
    @Transactional
    public ClientDto updateClientStatus(Long id, ClientStatus status) {
        log.info("Updating client status to {} for ID: {}", status, id);
        
        Client client = clientRepository.findById(id)
                .orElseThrow(() -> new ClientNotFoundException("Client not found with ID: " + id));
        
        client.setStatus(status);
        Client updatedClient = clientRepository.save(client);
        
        log.info("Client status updated successfully");
        return mapToDto(updatedClient);
    }
    
    @Transactional
    public ClientDto updateKycStatus(Long id, KycUpdateRequest request) {
        log.info("Updating KYC status to {} for client ID: {}", request.getKycStatus(), id);
        
        Client client = clientRepository.findById(id)
                .orElseThrow(() -> new ClientNotFoundException("Client not found with ID: " + id));
        
        client.setKycStatus(request.getKycStatus());
        
        if (request.getKycStatus() == KycStatus.VERIFIED && client.getStatus() == ClientStatus.PENDING) {
            client.setStatus(ClientStatus.ACTIVE);
        }
        
        Client updatedClient = clientRepository.save(client);
        log.info("KYC status updated successfully");
        
        return mapToDto(updatedClient);
    }
    
    @Transactional
    public void deleteClient(Long id) {
        log.info("Deleting client with ID: {}", id);
        
        if (!clientRepository.existsById(id)) {
            throw new ClientNotFoundException("Client not found with ID: " + id);
        }
        
        clientRepository.deleteById(id);
        log.info("Client deleted successfully");
    }
    
    private ClientDto mapToDto(Client client) {
        ClientDto dto = new ClientDto();
        dto.setId(client.getId());
        dto.setFirstName(client.getFirstName());
        dto.setLastName(client.getLastName());
        dto.setEmail(client.getEmail());
        dto.setPhoneNumber(client.getPhoneNumber());
        dto.setAddress(client.getAddress());
        dto.setCity(client.getCity());
        dto.setPostalCode(client.getPostalCode());
        dto.setCountry(client.getCountry());
        dto.setDateOfBirth(client.getDateOfBirth());
        dto.setNationalId(client.getNationalId());
        dto.setStatus(client.getStatus());
        dto.setKycStatus(client.getKycStatus());
        dto.setCreatedAt(client.getCreatedAt());
        dto.setUpdatedAt(client.getUpdatedAt());
        return dto;
    }
}