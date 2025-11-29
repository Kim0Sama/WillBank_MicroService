package com.willbank.transaction.entity;

import javax.persistence.*;
import javax.validation.constraints.DecimalMin;
import javax.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "transactions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Transaction {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotNull
    @Column(unique = true)
    private String transactionReference;
    
    @NotNull
    @Enumerated(EnumType.STRING)
    private TransactionType transactionType;
    
    @NotNull
    private String fromAccount;
    
    private String toAccount; // Null for deposits/withdrawals
    
    @NotNull
    @DecimalMin(value = "0.01")
    private BigDecimal amount;
    
    private String description;
    
    @NotNull
    @Enumerated(EnumType.STRING)
    private TransactionStatus status;
    
    @Column(updatable = false)
    private LocalDateTime createdAt;
    
    private LocalDateTime processedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }
}