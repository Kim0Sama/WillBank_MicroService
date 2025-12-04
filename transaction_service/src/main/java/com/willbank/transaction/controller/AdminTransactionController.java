package com.willbank.transaction.controller;

import com.willbank.transaction.dto.TransactionDto;
import com.willbank.transaction.service.TransactionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/transactions")
@RequiredArgsConstructor
public class AdminTransactionController {
    
    private final TransactionService transactionService;
    
    @GetMapping
    public ResponseEntity<List<TransactionDto>> getAllTransactions(
            @RequestHeader("X-User-Role") String role) {
        if (!"ADMIN".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        List<TransactionDto> transactions = transactionService.getAllTransactions();
        return ResponseEntity.ok(transactions);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<TransactionDto> getTransaction(
            @PathVariable Long id,
            @RequestHeader("X-User-Role") String role) {
        if (!"ADMIN".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        TransactionDto transaction = transactionService.getTransactionById(id);
        return ResponseEntity.ok(transaction);
    }
}
