import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Account, CreateAccountRequest } from '../../models/account.model';
import { AccountService } from '../../services/account.service';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-accounts',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './accounts.component.html',
  styleUrls: ['./accounts.component.scss']
})
export class AccountsComponent implements OnInit {
  accounts: Account[] = [];
  showCreateForm = false;

  createForm: CreateAccountRequest = {
    customerId: 1,
    accountType: 'CHECKING',
    initialDeposit: 0
  };

  constructor(
    private accountService: AccountService,
    private authService: AuthService
  ) {}

  get customerId(): number {
    return this.authService.getUserId() || 1;
  }

  ngOnInit(): void {
    this.createForm.customerId = this.customerId;
    this.loadAccounts();
  }

  loadAccounts(): void {
    this.accountService.getAccountsByCustomerId(this.customerId).subscribe({
      next: (accounts) => {
        this.accounts = accounts;
      },
      error: (error) => console.error('Error loading accounts:', error)
    });
  }

  toggleCreateForm(): void {
    this.showCreateForm = !this.showCreateForm;
  }

  onCreateAccount(): void {
    if (this.createForm.initialDeposit < 0) {
      alert('Initial deposit must be positive');
      return;
    }

    this.createForm.customerId = this.customerId;
    this.accountService.createAccount(this.createForm).subscribe({
      next: () => {
        alert('Account created successfully!');
        this.showCreateForm = false;
        this.createForm = {
          customerId: this.customerId,
          accountType: 'CHECKING',
          initialDeposit: 0
        };
        this.loadAccounts();
      },
      error: (error) => {
        alert('Failed to create account: ' + (error.error?.message || 'Unknown error'));
      }
    });
  }

  getAccountTypeLabel(type: string): string {
    switch (type) {
      case 'SAVINGS': return 'Savings Account';
      case 'CHECKING': return 'Checking Account';
      case 'BUSINESS': return 'Business Account';
      default: return type;
    }
  }

  getStatusColor(status: string): string {
    switch (status) {
      case 'ACTIVE': return 'success';
      case 'INACTIVE': return 'warning';
      case 'CLOSED': return 'danger';
      default: return '';
    }
  }
}
