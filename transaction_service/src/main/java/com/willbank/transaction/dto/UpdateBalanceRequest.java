package com.willbank.transaction.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateBalanceRequest {
    
    private BigDecimal amount;
    private OperationType operationType;
    
    public enum OperationType {
        CREDIT, DEBIT
    }
}