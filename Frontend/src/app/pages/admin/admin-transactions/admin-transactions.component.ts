import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Transaction } from '../../../models/transaction.model';
import { TransactionService } from '../../../services/transaction.service';
import { AccountService } from '../../../services/account.service';
import { ClientService } from '../../../services/client.service';

@Component({
  selector: 'app-admin-transactions',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './admin-transactions.component.html',
  styleUrls: ['./admin-transactions.component.scss']
})
export class AdminTransactionsComponent implements OnInit {
  transactions: Transaction[] = [];
  filteredTransactions: Transaction[] = [];
  accounts: any[] = [];
  searchTerm = '';
  filterType = 'ALL';
  filterStatus = 'ALL';

  constructor(
    private transactionService: TransactionService,
    private accountService: AccountService,
    private clientService: ClientService
  ) {}

  ngOnInit(): void {
    this.loadData();
  }

  loadData(): void {
    this.clientService.getAllClients().subscribe({
      next: (clients) => {
        this.loadAllTransactions(clients);
      },
      error: (error) => console.error('Error loading clients:', error)
    });
  }

  loadAllTransactions(clients: any[]): void {
    let allTransactions: Transaction[] = [];
    let processed = 0;

    clients.forEach(client => {
      this.accountService.getAccountsByCustomerId(client.id).subscribe({
        next: (accounts) => {
          this.accounts = [...this.accounts, ...accounts];
          
          accounts.forEach(account => {
            this.transactionService.getTransactionsByAccount(account.accountNumber).subscribe({
              next: (transactions) => {
                allTransactions = [...allTransactions, ...transactions];
              }
            });
          });

          processed++;
          if (processed === clients.length) {
            setTimeout(() => {
              this.transactions = allTransactions.sort((a, b) => 
                new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
              );
              this.applyFilters();
            }, 1000);
          }
        },
        error: () => processed++
      });
    });
  }

  applyFilters(): void {
    this.filteredTransactions = this.transactions.filter(transaction => {
      const matchesSearch = !this.searchTerm || 
        transaction.transactionReference.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
        transaction.fromAccount.toLowerCase().includes(this.searchTerm.toLowerCase());

      const matchesType = this.filterType === 'ALL' || transaction.transactionType === this.filterType;
      const matchesStatus = this.filterStatus === 'ALL' || transaction.status === this.filterStatus;

      return matchesSearch && matchesType && matchesStatus;
    });
  }

  getTotalAmount(): number {
    return this.filteredTransactions.reduce((sum, t) => sum + t.amount, 0);
  }

  getTransactionIcon(type: string): string {
    switch (type) {
      case 'DEPOSIT': return '💰';
      case 'WITHDRAWAL': return '💸';
      case 'TRANSFER': return '🔄';
      default: return '💳';
    }
  }
}
