package com.willbank.transaction.dto;

import com.willbank.transaction.entity.TransactionStatus;
import com.willbank.transaction.entity.TransactionType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TransactionDto {
    private Long id;
    private String transactionReference;
    private TransactionType transactionType;
    private String fromAccount;
    private String toAccount;
    private BigDecimal amount;
    private String description;
    private TransactionStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime processedAt;
}