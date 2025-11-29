package com.willbank.transaction.service;

import com.willbank.transaction.client.AccountServiceClient;
import com.willbank.transaction.dto.DepositRequest;
import com.willbank.transaction.dto.TransactionDto;
import com.willbank.transaction.dto.UpdateBalanceRequest;
import com.willbank.transaction.dto.WithdrawalRequest;
import com.willbank.transaction.entity.Transaction;
import com.willbank.transaction.entity.TransactionStatus;
import com.willbank.transaction.entity.TransactionType;
import com.willbank.transaction.repository.TransactionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class TransactionService {
    
    private final TransactionRepository transactionRepository;
    private final AccountServiceClient accountServiceClient;
    
    @Transactional
    public TransactionDto processDeposit(DepositRequest request) {
        log.info("Processing deposit for account: {} amount: {}", request.getAccountNumber(), request.getAmount());
        
        try {
            // Validate account exists by checking balance
            accountServiceClient.getAccountBalance(request.getAccountNumber());
            
            // Create transaction record
            Transaction transaction = new Transaction();
            transaction.setTransactionReference(generateTransactionReference());
            transaction.setTransactionType(TransactionType.DEPOSIT);
            transaction.setFromAccount(request.getAccountNumber());
            transaction.setAmount(request.getAmount());
            transaction.setDescription(request.getDescription() != null ? request.getDescription() : "Deposit");
            transaction.setStatus(TransactionStatus.PENDING);
            
            Transaction savedTransaction = transactionRepository.save(transaction);
            
            // Update account balance
            UpdateBalanceRequest balanceRequest = 
                new UpdateBalanceRequest(
                    request.getAmount(), 
                    UpdateBalanceRequest.OperationType.CREDIT
                );
            
            accountServiceClient.updateAccountBalance(request.getAccountNumber(), balanceRequest);
            
            // Mark transaction as completed
            savedTransaction.setStatus(TransactionStatus.COMPLETED);
            savedTransaction.setProcessedAt(LocalDateTime.now());
            savedTransaction = transactionRepository.save(savedTransaction);
            
            // Generate TransactionCompleted event (mock/log)
            log.info("TransactionCompleted Event: Reference={}, Type={}, Amount={}, Account={}", 
                savedTransaction.getTransactionReference(),
                savedTransaction.getTransactionType(),
                savedTransaction.getAmount(),
                savedTransaction.getFromAccount());
            
            log.info("Deposit completed successfully: {}", savedTransaction.getTransactionReference());
            return mapToDto(savedTransaction);
            
        } catch (Exception e) {
            log.error("Deposit failed for account: {}", request.getAccountNumber(), e);
            throw new RuntimeException("Deposit failed: " + e.getMessage());
        }
    }
    
    @Transactional
    public TransactionDto processWithdrawal(WithdrawalRequest request) {
        log.info("Processing withdrawal for account: {} amount: {}", request.getAccountNumber(), request.getAmount());
        
        try {
            // Validate account balance
            BigDecimal currentBalance = accountServiceClient.getAccountBalance(request.getAccountNumber());
            
            if (currentBalance.compareTo(request.getAmount()) < 0) {
                throw new RuntimeException("Insufficient funds. Current balance: " + currentBalance);
            }
            
            // Create transaction record
            Transaction transaction = new Transaction();
            transaction.setTransactionReference(generateTransactionReference());
            transaction.setTransactionType(TransactionType.WITHDRAWAL);
            transaction.setFromAccount(request.getAccountNumber());
            transaction.setAmount(request.getAmount());
            transaction.setDescription(request.getDescription() != null ? request.getDescription() : "Withdrawal");
            transaction.setStatus(TransactionStatus.PENDING);
            
            Transaction savedTransaction = transactionRepository.save(transaction);
            
            // Update account balance
            UpdateBalanceRequest balanceRequest = 
                new UpdateBalanceRequest(
                    request.getAmount(), 
                    UpdateBalanceRequest.OperationType.DEBIT
                );
            
            accountServiceClient.updateAccountBalance(request.getAccountNumber(), balanceRequest);
            
            // Mark transaction as completed
            savedTransaction.setStatus(TransactionStatus.COMPLETED);
            savedTransaction.setProcessedAt(LocalDateTime.now());
            savedTransaction = transactionRepository.save(savedTransaction);
            
            // Generate TransactionCompleted event (mock/log)
            log.info("TransactionCompleted Event: Reference={}, Type={}, Amount={}, Account={}", 
                savedTransaction.getTransactionReference(),
                savedTransaction.getTransactionType(),
                savedTransaction.getAmount(),
                savedTransaction.getFromAccount());
            
            log.info("Withdrawal completed successfully: {}", savedTransaction.getTransactionReference());
            return mapToDto(savedTransaction);
            
        } catch (Exception e) {
            log.error("Withdrawal failed for account: {}", request.getAccountNumber(), e);
            throw new RuntimeException("Withdrawal failed: " + e.getMessage());
        }
    }
    
    public List<TransactionDto> getTransactionsByAccount(String accountNumber) {
        return transactionRepository.findByFromAccountOrToAccountOrderByCreatedAtDesc(accountNumber, accountNumber)
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }
    
    public TransactionDto getTransactionByReference(String transactionReference) {
        Transaction transaction = transactionRepository.findByTransactionReference(transactionReference)
                .orElseThrow(() -> new RuntimeException("Transaction not found: " + transactionReference));
        return mapToDto(transaction);
    }
    
    private String generateTransactionReference() {
        return "TXN-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }
    
    private TransactionDto mapToDto(Transaction transaction) {
        return new TransactionDto(
                transaction.getId(),
                transaction.getTransactionReference(),
                transaction.getTransactionType(),
                transaction.getFromAccount(),
                transaction.getToAccount(),
                transaction.getAmount(),
                transaction.getDescription(),
                transaction.getStatus(),
                transaction.getCreatedAt(),
                transaction.getProcessedAt()
        );
    }
}