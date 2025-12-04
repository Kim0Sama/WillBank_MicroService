package com.willbank.client.repository;

import com.willbank.client.entity.Client;
import com.willbank.client.entity.ClientStatus;
import com.willbank.client.entity.KycStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ClientRepository extends JpaRepository<Client, Long> {
    
    Optional<Client> findByEmail(String email);
    
    boolean existsByEmail(String email);
    
    boolean existsByNationalId(String nationalId);
    
    List<Client> findByStatus(ClientStatus status);
    
    List<Client> findByKycStatus(KycStatus kycStatus);
}
