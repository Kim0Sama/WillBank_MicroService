import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ClientService } from '../../../services/client.service';
import { AccountService } from '../../../services/account.service';
import { TransactionService } from '../../../services/transaction.service';

@Component({
  selector: 'app-admin-dashboard',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './admin-dashboard.component.html',
  styleUrls: ['./admin-dashboard.component.scss']
})
export class AdminDashboardComponent implements OnInit {
  stats = {
    totalClients: 0,
    activeClients: 0,
    totalAccounts: 0,
    totalBalance: 0,
    totalTransactions: 0,
    pendingKyc: 0
  };

  recentClients: any[] = [];
  recentTransactions: any[] = [];

  constructor(
    private clientService: ClientService,
    private accountService: AccountService,
    private transactionService: TransactionService
  ) {}

  ngOnInit(): void {
    this.loadStats();
  }

  loadStats(): void {
    this.clientService.getAllClients().subscribe({
      next: (clients) => {
        this.stats.totalClients = clients.length;
        this.stats.activeClients = clients.filter(c => c.status === 'ACTIVE').length;
        this.stats.pendingKyc = clients.filter(c => c.kycStatus === 'PENDING_VERIFICATION').length;
        this.recentClients = clients.slice(0, 5);
        
        // Load accounts for all clients
        this.loadAllAccounts(clients);
      },
      error: (error) => console.error('Error loading clients:', error)
    });
  }

  loadAllAccounts(clients: any[]): void {
    let allAccounts: any[] = [];
    let processed = 0;

    clients.forEach(client => {
      this.accountService.getAccountsByCustomerId(client.id).subscribe({
        next: (accounts) => {
          allAccounts = [...allAccounts, ...accounts];
          processed++;

          if (processed === clients.length) {
            this.stats.totalAccounts = allAccounts.length;
            this.stats.totalBalance = allAccounts.reduce((sum, acc) => sum + acc.balance, 0);
            
            // Load transactions for first account
            if (allAccounts.length > 0) {
              this.loadRecentTransactions(allAccounts[0].accountNumber);
            }
          }
        },
        error: () => processed++
      });
    });
  }

  loadRecentTransactions(accountNumber: string): void {
    this.transactionService.getTransactionsByAccount(accountNumber).subscribe({
      next: (transactions) => {
        this.recentTransactions = transactions.slice(0, 5);
        this.stats.totalTransactions = transactions.length;
      },
      error: (error) => console.error('Error loading transactions:', error)
    });
  }
}
