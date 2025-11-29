package com.willbank.account.service;

import com.willbank.account.dto.AccountDto;
import com.willbank.account.dto.CreateAccountRequest;
import com.willbank.account.dto.UpdateBalanceRequest;
import com.willbank.account.entity.Account;
import com.willbank.account.entity.AccountStatus;
import com.willbank.account.entity.AccountType;
import com.willbank.account.repository.AccountRepository;

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

    
    @Transactional
    public AccountDto createAccount(CreateAccountRequest request) {
        // Validate customer exists (would call client service in real implementation)
        
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