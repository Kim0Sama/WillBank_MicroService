package com.willbank.transaction.repository;

import com.willbank.transaction.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    
    Optional<Transaction> findByTransactionReference(String transactionReference);
    
    List<Transaction> findByFromAccountOrderByCreatedAtDesc(String fromAccount);
    
    List<Transaction> findByFromAccountOrToAccountOrderByCreatedAtDesc(String fromAccount, String toAccount);
}