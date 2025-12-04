package com.willbank.account.service;

import com.willbank.account.client.ClientServiceClient;
import com.willbank.account.dto.AccountDto;
import com.willbank.account.dto.ClientDto;
import com.willbank.account.dto.CreateAccountRequest;
import com.willbank.account.dto.UpdateBalanceRequest;
import com.willbank.account.entity.Account;
import com.willbank.account.entity.AccountStatus;
import com.willbank.account.exception.ClientNotFoundException;
import com.willbank.account.repository.AccountRepository;

import feign.FeignException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class AccountService {
    
    private final AccountRepository accountRepository;
    private final ClientServiceClient clientServiceClient;

    
    @Transactional
    public AccountDto createAccount(CreateAccountRequest request) {
        // Valider que le client existe dans le Client Service
        log.info("Validating client with ID: {}", request.getCustomerId());
        ClientDto client = validateClientExists(request.getCustomerId());
        
        // Vérifier que le client est actif et vérifié
        if (!"ACTIVE".equals(client.getStatus())) {
            throw new RuntimeException("Client is not active. Current status: " + client.getStatus());
        }
        
        if (!"VERIFIED".equals(client.getKycStatus())) {
            throw new RuntimeException("Client KYC is not verified. Current status: " + client.getKycStatus());
        }
        
        log.info("Client validated: {} {}", client.getFirstName(), client.getLastName());
        
        Account account = new Account();
        account.setAccountNumber(generateAccountNumber());
        account.setCustomerId(request.getCustomerId());
        account.setAccountType(request.getAccountType());
        account.setBalance(request.getInitialBalance());
        account.setStatus(AccountStatus.ACTIVE);
        
        Account savedAccount = accountRepository.save(account);
        
        // Publish account created event (disabled for testing)
        // eventPublisher.publishAccountCreated(savedAccount);
        
        log.info("Account created: {}", savedAccount.getAccountNumber());
        return mapToDto(savedAccount);
    }
    
    public AccountDto getAccountByNumber(String accountNumber) {
        Account account = accountRepository.findByAccountNumber(accountNumber)
                .orElseThrow(() -> new RuntimeException("Account not found: " + accountNumber));
        return mapToDto(account);
    }
    
    public List<AccountDto> getAccountsByCustomerId(Long customerId) {
        return accountRepository.findByCustomerId(customerId)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }
    
    @Transactional
    public AccountDto updateBalance(String accountNumber, UpdateBalanceRequest request) {
        Account account = accountRepository.findByAccountNumber(accountNumber)
                .orElseThrow(() -> new RuntimeException("Account not found: " + accountNumber));
        
        if (account.getStatus() != AccountStatus.ACTIVE) {
            throw new RuntimeException("Account is not active: " + accountNumber);
        }
        
        BigDecimal newBalance;
        if (request.getOperationType() == UpdateBalanceRequest.OperationType.CREDIT) {
            newBalance = account.getBalance().add(request.getAmount());
        } else {
            newBalance = account.getBalance().subtract(request.getAmount());
            if (newBalance.compareTo(BigDecimal.ZERO) < 0) {
                throw new RuntimeException("Insufficient funds");
            }
        }
        
        account.setBalance(newBalance);
        Account savedAccount = accountRepository.save(account);
        
        log.info("Balance updated for account {}: {}", accountNumber, newBalance);
        return mapToDto(savedAccount);
    }
    
    @Transactional
    public AccountDto updateAccountStatus(String accountNumber, AccountStatus status) {
        Account account = accountRepository.findByAccountNumber(accountNumber)
                .orElseThrow(() -> new RuntimeException("Account not found: " + accountNumber));
        
        AccountStatus oldStatus = account.getStatus();
        account.setStatus(status);
        Account savedAccount = accountRepository.save(account);
        
        // Publish status change event (disabled for testing)
        // eventPublisher.publishAccountStatusChanged(savedAccount, oldStatus);
        
        log.info("Account status updated: {} -> {}", oldStatus, status);
        return mapToDto(savedAccount);
    }
    
    public BigDecimal getAccountBalance(String accountNumber) {
        Account account = accountRepository.findByAccountNumber(accountNumber)
                .orElseThrow(() -> new RuntimeException("Account not found: " + accountNumber));
        return account.getBalance();
    }
    
    private String generateAccountNumber() {
        String prefix = "WB";
        Random random = new Random();
        long number = 100000000L + random.nextLong(900000000L);
        return prefix + number;
    }
    
    /**
     * Valide que le client existe dans le Client Service
     */
    private ClientDto validateClientExists(Long customerId) {
        try {
            ClientDto client = clientServiceClient.getClientById(customerId);
            if (client == null) {
                throw new ClientNotFoundException(customerId);
            }
            return client;
        } catch (FeignException.NotFound e) {
            log.error("Client not found with ID: {}", customerId);
            throw new ClientNotFoundException(customerId);
        } catch (FeignException e) {
            log.error("Error communicating with Client Service: {}", e.getMessage());
            throw new RuntimeException("Unable to validate client. Client Service may be unavailable.");
        }
    }
    
    private AccountDto mapToDto(Account account) {
        return new AccountDto(
                account.getId(),
                account.getAccountNumber(),
                account.getCustomerId(),
                account.getAccountType(),
                account.getBalance(),
                account.getStatus(),
                account.getCreatedAt(),
                account.getUpdatedAt()
        );
    }
}