package com.willbank.transaction.controller;

import com.willbank.transaction.dto.DepositRequest;
import com.willbank.transaction.dto.TransactionDto;
import com.willbank.transaction.dto.WithdrawalRequest;
import com.willbank.transaction.service.TransactionService;
import javax.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/transactions")
@RequiredArgsConstructor
public class TransactionController {
    
    private final TransactionService transactionService;
    
    @PostMapping("/deposit")
    public ResponseEntity<TransactionDto> processDeposit(@Valid @RequestBody DepositRequest request) {
        TransactionDto transaction = transactionService.processDeposit(request);
        return new ResponseEntity<>(transaction, HttpStatus.CREATED);
    }
    
    @PostMapping("/withdrawal")
    public ResponseEntity<TransactionDto> processWithdrawal(@Valid @RequestBody WithdrawalRequest request) {
        TransactionDto transaction = transactionService.processWithdrawal(request);
        return new ResponseEntity<>(transaction, HttpStatus.CREATED);
    }
    
    @GetMapping("/account/{accountNumber}")
    public ResponseEntity<List<TransactionDto>> getTransactionsByAccount(@PathVariable String accountNumber) {
        List<TransactionDto> transactions = transactionService.getTransactionsByAccount(accountNumber);
        return ResponseEntity.ok(transactions);
    }
    
    @GetMapping("/{transactionReference}")
    public ResponseEntity<TransactionDto> getTransaction(@PathVariable String transactionReference) {
        TransactionDto transaction = transactionService.getTransactionByReference(transactionReference);
        return ResponseEntity.ok(transaction);
    }
}