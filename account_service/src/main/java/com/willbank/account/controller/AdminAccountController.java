package com.willbank.account.controller;

import com.willbank.account.dto.AccountDto;
import com.willbank.account.dto.CreateAccountRequest;
import com.willbank.account.entity.AccountStatus;
import com.willbank.account.service.AccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/admin/accounts")
@RequiredArgsConstructor
public class AdminAccountController {
    
    private final AccountService accountService;
    
    @GetMapping
    public ResponseEntity<List<AccountDto>> getAllAccounts(
            @RequestHeader("X-User-Role") String role) {
        if (!"ADMIN".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        List<AccountDto> accounts = accountService.getAllAccounts();
        return ResponseEntity.ok(accounts);
    }
    
    @GetMapping("/{accountNumber}")
    public ResponseEntity<AccountDto> getAccount(
            @PathVariable String accountNumber,
            @RequestHeader("X-User-Role") String role) {
        if (!"ADMIN".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        AccountDto account = accountService.getAccountByNumber(accountNumber);
        return ResponseEntity.ok(account);
    }
    
    @PostMapping
    public ResponseEntity<AccountDto> createAccount(
            @Valid @RequestBody CreateAccountRequest request,
            @RequestHeader("X-User-Role") String role) {
        if (!"ADMIN".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        AccountDto account = accountService.createAccount(request);
        return new ResponseEntity<>(account, HttpStatus.CREATED);
    }
    
    @PutMapping("/{accountNumber}/status")
    public ResponseEntity<AccountDto> updateAccountStatus(
            @PathVariable String accountNumber,
            @RequestParam AccountStatus status,
            @RequestHeader("X-User-Role") String role) {
        if (!"ADMIN".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        AccountDto account = accountService.updateAccountStatus(accountNumber, status);
        return ResponseEntity.ok(account);
    }
}
