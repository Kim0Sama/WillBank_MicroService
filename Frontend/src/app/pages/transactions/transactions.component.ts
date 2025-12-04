import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Account } from '../../models/account.model';
import { Transaction, DepositRequest, WithdrawalRequest, TransferRequest } from '../../models/transaction.model';
import { AccountService } from '../../services/account.service';
import { TransactionService } from '../../services/transaction.service';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-transactions',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './transactions.component.html',
  styleUrls: ['./transactions.component.scss']
})
export class TransactionsComponent implements OnInit {
  accounts: Account[] = [];
  transactions: Transaction[] = [];
  selectedAccount: string = '';
  activeTab: 'deposit' | 'withdrawal' | 'transfer' = 'deposit';

  depositForm = {
    accountNumber: '',
    amount: 0,
    description: ''
  };

  withdrawalForm = {
    accountNumber: '',
    amount: 0,
    description: ''
  };

  transferForm = {
    fromAccountNumber: '',
    toAccountNumber: '',
    amount: 0,
    description: ''
  };

  constructor(
    private accountService: AccountService,
    private transactionService: TransactionService,
    private authService: AuthService
  ) {}

  get customerId(): number {
    return this.authService.getUserId() || 1;
  }

  ngOnInit(): void {
    this.loadAccounts();
  }

  loadAccounts(): void {
    this.accountService.getAccountsByCustomerId(this.customerId).subscribe({
      next: (accounts) => {
        this.accounts = accounts;
        if (accounts.length > 0) {
          this.selectedAccount = accounts[0].accountNumber;
          this.depositForm.accountNumber = accounts[0].accountNumber;
          this.withdrawalForm.accountNumber = accounts[0].accountNumber;
          this.transferForm.fromAccountNumber = accounts[0].accountNumber;
          this.loadTransactions(accounts[0].accountNumber);
        }
      },
      error: (error) => console.error('Error loading accounts:', error)
    });
  }

  loadTransactions(accountNumber: string): void {
    this.transactionService.getTransactionsByAccount(accountNumber).subscribe({
      next: (transactions) => {
        // Filter transactions for the selected account
        this.transactions = transactions.filter(t => 
          t.fromAccount === accountNumber || t.toAccount === accountNumber
        );
      },
      error: (error) => console.error('Error loading transactions:', error)
    });
  }

  onAccountChange(): void {
    this.loadTransactions(this.selectedAccount);
  }

  setActiveTab(tab: 'deposit' | 'withdrawal' | 'transfer'): void {
    this.activeTab = tab;
  }

  onDeposit(): void {
    if (this.depositForm.amount <= 0) {
      alert('Please enter a valid amount');
      return;
    }

    this.transactionService.deposit(this.depositForm).subscribe({
      next: () => {
        alert('Deposit successful!');
        this.depositForm.amount = 0;
        this.depositForm.description = '';
        this.loadAccounts();
        this.loadTransactions(this.depositForm.accountNumber);
      },
      error: (error) => {
        alert('Deposit failed: ' + (error.error?.message || 'Unknown error'));
      }
    });
  }

  onWithdrawal(): void {
    if (this.withdrawalForm.amount <= 0) {
      alert('Please enter a valid amount');
      return;
    }

    this.transactionService.withdrawal(this.withdrawalForm).subscribe({
      next: () => {
        alert('Withdrawal successful!');
        this.withdrawalForm.amount = 0;
        this.withdrawalForm.description = '';
        this.loadAccounts();
        this.loadTransactions(this.withdrawalForm.accountNumber);
      },
      error: (error) => {
        alert('Withdrawal failed: ' + (error.error?.message || 'Unknown error'));
      }
    });
  }

  onTransfer(): void {
    if (this.transferForm.amount <= 0) {
      alert('Please enter a valid amount');
      return;
    }

    if (this.transferForm.fromAccountNumber === this.transferForm.toAccountNumber) {
      alert('Cannot transfer to the same account');
      return;
    }

    this.transactionService.transfer(this.transferForm).subscribe({
      next: () => {
        alert('Transfer successful!');
        this.transferForm.amount = 0;
        this.transferForm.description = '';
        this.transferForm.toAccountNumber = '';
        this.loadAccounts();
        this.loadTransactions(this.transferForm.fromAccountNumber);
      },
      error: (error) => {
        alert('Transfer failed: ' + (error.error?.message || 'Unknown error'));
      }
    });
  }

  getTransactionIcon(type: string): string {
    switch (type) {
      case 'DEPOSIT': return '💰';
      case 'WITHDRAWAL': return '💸';
      case 'TRANSFER': return '🔄';
      default: return '💳';
    }
  }

  getTransactionColor(type: string): string {
    switch (type) {
      case 'DEPOSIT': return 'positive';
      case 'WITHDRAWAL': return 'negative';
      case 'TRANSFER': return 'neutral';
      default: return '';
    }
  }
}
