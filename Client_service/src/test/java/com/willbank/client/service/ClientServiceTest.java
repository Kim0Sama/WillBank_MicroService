package com.willbank.client.service;

import com.willbank.client.dto.ClientDto;
import com.willbank.client.dto.CreateClientRequest;
import com.willbank.client.entity.Client;
import com.willbank.client.entity.ClientStatus;
import com.willbank.client.entity.KycStatus;
import com.willbank.client.exception.ClientAlreadyExistsException;
import com.willbank.client.exception.ClientNotFoundException;
import com.willbank.client.repository.ClientRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ClientServiceTest {
    
    @Mock
    private ClientRepository clientRepository;
    
    @InjectMocks
    private ClientService clientService;
    
    private CreateClientRequest createRequest;
    private Client client;
    
    @BeforeEach
    void setUp() {
        createRequest = new CreateClientRequest();
        createRequest.setFirstName("John");
        createRequest.setLastName("Doe");
        createRequest.setEmail("john.doe@example.com");
        createRequest.setPhoneNumber("+33612345678");
        createRequest.setAddress("123 Test Street");
        createRequest.setCity("Paris");
        createRequest.setPostalCode("75001");
        createRequest.setCountry("France");
        createRequest.setDateOfBirth(LocalDate.of(1990, 1, 1));
        createRequest.setNationalId("1234567890123");
        
        client = new Client();
        client.setId(1L);
        client.setFirstName("John");
        client.setLastName("Doe");
        client.setEmail("john.doe@example.com");
        client.setPhoneNumber("+33612345678");
        client.setStatus(ClientStatus.PENDING);
        client.setKycStatus(KycStatus.PENDING_VERIFICATION);
    }
    
    @Test
    void createClient_Success() {
        when(clientRepository.existsByEmail(anyString())).thenReturn(false);
        when(clientRepository.existsByNationalId(anyString())).thenReturn(false);
        when(clientRepository.save(any(Client.class))).thenReturn(client);
        
        ClientDto result = clientService.createClient(createRequest);
        
        assertNotNull(result);
        assertEquals("John", result.getFirstName());
        assertEquals("Doe", result.getLastName());
        assertEquals("john.doe@example.com", result.getEmail());
        
        verify(clientRepository, times(1)).save(any(Client.class));
    }
    
    @Test
    void createClient_EmailAlreadyExists() {
        when(clientRepository.existsByEmail(anyString())).thenReturn(true);
        
        assertThrows(ClientAlreadyExistsException.class, () -> {
            clientService.createClient(createRequest);
        });
        
        verify(clientRepository, never()).save(any(Client.class));
    }
    
    @Test
    void getClientById_Success() {
        when(clientRepository.findById(1L)).thenReturn(Optional.of(client));
        
        ClientDto result = clientService.getClientById(1L);
        
        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertEquals("John", result.getFirstName());
    }
    
    @Test
    void getClientById_NotFound() {
        when(clientRepository.findById(1L)).thenReturn(Optional.empty());
        
        assertThrows(ClientNotFoundException.class, () -> {
            clientService.getClientById(1L);
        });
    }
    
    @Test
    void updateClientStatus_Success() {
        when(clientRepository.findById(1L)).thenReturn(Optional.of(client));
        when(clientRepository.save(any(Client.class))).thenReturn(client);
        
        ClientDto result = clientService.updateClientStatus(1L, ClientStatus.ACTIVE);
        
        assertNotNull(result);
        verify(clientRepository, times(1)).save(any(Client.class));
    }
}
