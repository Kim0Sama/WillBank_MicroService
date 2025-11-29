package com.willbank.transaction.client;

import com.willbank.transaction.dto.UpdateBalanceRequest;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@FeignClient(name = "account-service")
public interface AccountServiceClient {
    
    @GetMapping("/api/accounts/{accountNumber}/balance")
    BigDecimal getAccountBalance(@PathVariable String accountNumber);
    
    @PutMapping("/api/accounts/{accountNumber}/balance")
    void updateAccountBalance(@PathVariable String accountNumber, @RequestBody UpdateBalanceRequest request);
}