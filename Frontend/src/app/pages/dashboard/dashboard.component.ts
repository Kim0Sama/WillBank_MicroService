import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Account } from '../../models/account.model';
import { Transaction } from '../../models/transaction.model';
import { AccountService } from '../../services/account.service';
import { TransactionService } from '../../services/transaction.service';
import { AuthService, User } from '../../services/auth.service';
import { ClientService } from '../../services/client.service';
import { Client } from '../../models/client.model';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent implements OnInit {
  accounts: Account[] = [];
  recentTransactions: Transaction[] = [];
  selectedAccount: Account | null = null;
  currentUser: User | null = null;
  clientDetails: Client | null = null;
  loading = true;
  error: string | null = null;

  constructor(
    private accountService: AccountService,
    private transactionService: TransactionService,
    private authService: AuthService,
    private clientService: ClientService
  ) {}

  get customerId(): number {
    return this.authService.getUserId() || 0;
  }

  ngOnInit(): void {
    this.currentUser = this.authService.getCurrentUser();
    if (this.customerId) {
      this.loadClientDetails();
      this.loadAccounts();
    } else {
      this.error = 'User not authenticated';
      this.loading = false;
    }
  }

  loadClientDetails(): void {
    this.clientService.getClientById(this.customerId).subscribe({
      next: (client) => {
        this.clientDetails = client;
      },
      error: (error) => {
        console.error('Error loading client details:', error);
        this.error = 'Failed to load client details';
      }
    });
  }

  loadAccounts(): void {
    this.accountService.getAccountsByCustomerId(this.customerId).subscribe({
      next: (accounts) => {
        this.accounts = accounts;
        if (accounts.length > 0) {
          this.selectedAccount = accounts[0];
          this.loadTransactions(accounts[0].accountNumber);
        } else {
          console.log('No accounts found for customer:', this.customerId);
        }
        this.loading = false;
      },
      error: (error) => {
        console.error('Error loading accounts:', error);
        this.error = 'Failed to load accounts';
        this.loading = false;
      }
    });
  }

  loadTransactions(accountNumber: string): void {
    this.transactionService.getTransactionsByAccount(accountNumber).subscribe({
      next: (transactions) => {
        // Filter transactions for the selected account
        this.recentTransactions = transactions
          .filter(t => t.fromAccount === accountNumber || t.toAccount === accountNumber)
          .slice(0, 5);
      },
      error: (error) => console.error('Error loading transactions:', error)
    });
  }

  selectAccount(account: Account): void {
    this.selectedAccount = account;
    this.loadTransactions(account.accountNumber);
  }

  formatCardNumber(accountNumber: string): string {
    const last4 = accountNumber.slice(-4);
    return `${accountNumber.slice(0, 4)} **** **** ${last4}`;
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
