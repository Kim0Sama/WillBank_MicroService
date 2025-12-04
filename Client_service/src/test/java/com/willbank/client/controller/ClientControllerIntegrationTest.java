package com.willbank.client.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.willbank.client.dto.CreateClientRequest;
import com.willbank.client.dto.UpdateClientRequest;
import com.willbank.client.entity.ClientStatus;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class ClientControllerIntegrationTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @Test
    void getAllClients_Success() throws Exception {
        mockMvc.perform(get("/api/clients"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON));
    }
    
    @Test
    void getClientById_Success() throws Exception {
        mockMvc.perform(get("/api/clients/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.firstName").value("Jean"))
                .andExpect(jsonPath("$.email").value("jean.dupont@example.com"));
    }
    
    @Test
    void getClientById_NotFound() throws Exception {
        mockMvc.perform(get("/api/clients/999"))
                .andExpect(status().isNotFound());
    }
    
    @Test
    void createClient_Success() throws Exception {
        CreateClientRequest request = new CreateClientRequest();
        request.setFirstName("Test");
        request.setLastName("User");
        request.setEmail("test.user@example.com");
        request.setPhoneNumber("+33612345678");
        request.setAddress("123 Test Street");
        request.setCity("Paris");
        request.setPostalCode("75001");
        request.setCountry("France");
        request.setDateOfBirth(LocalDate.of(1990, 1, 1));
        request.setNationalId("9999999999999");
        
        mockMvc.perform(post("/api/clients")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.firstName").value("Test"))
                .andExpect(jsonPath("$.email").value("test.user@example.com"));
    }
    
    @Test
    void updateClient_Success() throws Exception {
        UpdateClientRequest request = new UpdateClientRequest();
        request.setPhoneNumber("+33699999999");
        request.setCity("Lyon");
        
        mockMvc.perform(put("/api/clients/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1));
    }
    
    @Test
    void updateClientStatus_Success() throws Exception {
        mockMvc.perform(patch("/api/clients/1/status")
                .param("status", ClientStatus.ACTIVE.name()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("ACTIVE"));
    }
}
