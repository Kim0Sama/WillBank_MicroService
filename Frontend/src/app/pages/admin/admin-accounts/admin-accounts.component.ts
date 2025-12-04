import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Account } from '../../../models/account.model';
import { AccountService } from '../../../services/account.service';
import { ClientService } from '../../../services/client.service';

@Component({
  selector: 'app-admin-accounts',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './admin-accounts.component.html',
  styleUrls: ['./admin-accounts.component.scss']
})
export class AdminAccountsComponent implements OnInit {
  accounts: Account[] = [];
  filteredAccounts: Account[] = [];
  clients: any[] = [];
  searchTerm = '';
  filterType = 'ALL';
  filterStatus = 'ALL';

  constructor(
    private accountService: AccountService,
    private clientService: ClientService
  ) {}

  ngOnInit(): void {
    this.loadClients();
  }

  loadClients(): void {
    this.clientService.getAllClients().subscribe({
      next: (clients) => {
        this.clients = clients;
        this.loadAllAccounts();
      },
      error: (error) => console.error('Error loading clients:', error)
    });
  }

  loadAllAccounts(): void {
    let allAccounts: Account[] = [];
    let processed = 0;

    this.clients.forEach(client => {
      this.accountService.getAccountsByCustomerId(client.id).subscribe({
        next: (accounts) => {
          allAccounts = [...allAccounts, ...accounts];
          processed++;

          if (processed === this.clients.length) {
            this.accounts = allAccounts;
            this.applyFilters();
          }
        },
        error: () => processed++
      });
    });
  }

  applyFilters(): void {
    this.filteredAccounts = this.accounts.filter(account => {
      const matchesSearch = !this.searchTerm || 
        account.accountNumber.toLowerCase().includes(this.searchTerm.toLowerCase());

      const matchesType = this.filterType === 'ALL' || account.accountType === this.filterType;
      const matchesStatus = this.filterStatus === 'ALL' || account.status === this.filterStatus;

      return matchesSearch && matchesType && matchesStatus;
    });
  }

  getClientName(customerId: number): string {
    const client = this.clients.find(c => c.id === customerId);
    return client ? `${client.firstName} ${client.lastName}` : 'Unknown';
  }

  getTotalBalance(): number {
    return this.filteredAccounts.reduce((sum, acc) => sum + acc.balance, 0);
  }
}
