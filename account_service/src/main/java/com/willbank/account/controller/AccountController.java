package com.willbank.account.controller;

import com.willbank.account.dto.AccountDto;
import com.willbank.account.dto.CreateAccountRequest;
import com.willbank.account.dto.UpdateBalanceRequest;
import com.willbank.account.entity.AccountStatus;
import com.willbank.account.service.AccountService;
import javax.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/accounts")
@RequiredArgsConstructor
public class AccountController {
    
    private final AccountService accountService;
    
    @PostMapping
    public ResponseEntity<AccountDto> createAccount(@Valid @RequestBody CreateAccountRequest request) {
        AccountDto account = accountService.createAccount(request);
        return new ResponseEntity<>(account, HttpStatus.CREATED);
    }
    
    @GetMapping("/{accountNumber}")
    public ResponseEntity<AccountDto> getAccount(@PathVariable String accountNumber) {
        AccountDto account = accountService.getAccountByNumber(accountNumber);
        return ResponseEntity.ok(account);
    }
    
    @GetMapping("/customer/{customerId}")
    public ResponseEntity<List<AccountDto>> getAccountsByCustomer(@PathVariable Long customerId) {
        List<AccountDto> accounts = accountService.getAccountsByCustomerId(customerId);
        return ResponseEntity.ok(accounts);
    }
    
    @PutMapping("/{accountNumber}/balance")
    public ResponseEntity<AccountDto> updateBalance(
            @PathVariable String accountNumber,
            @Valid @RequestBody UpdateBalanceRequest request) {
        AccountDto account = accountService.updateBalance(accountNumber, request);
        return ResponseEntity.ok(account);
    }
    
    @PutMapping("/{accountNumber}/status")
    public ResponseEntity<AccountDto> updateStatus(
            @PathVariable String accountNumber,
            @RequestParam AccountStatus status) {
        AccountDto account = accountService.updateAccountStatus(accountNumber, status);
        return ResponseEntity.ok(account);
    }
    
    @GetMapping("/{accountNumber}/balance")
    public ResponseEntity<BigDecimal> getBalance(@PathVariable String accountNumber) {
        BigDecimal balance = accountService.getAccountBalance(accountNumber);
        return ResponseEntity.ok(balance);
    }
}