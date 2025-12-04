package com.willbank.account.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * DTO pour représenter un client du Client Service
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ClientDto {
    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private String phoneNumber;
    private String address;
    private String city;
    private String postalCode;
    private String country;
    private LocalDate dateOfBirth;
    private String nationalId;
    private String status;
    private String kycStatus;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
