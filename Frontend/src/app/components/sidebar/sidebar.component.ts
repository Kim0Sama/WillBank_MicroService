import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { AuthService, User } from '../../services/auth.service';

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.scss']
})
export class SidebarComponent {
  clientMenuItems = [
    { icon: '🏠', label: 'Dashboard', route: '/dashboard' },
    { icon: '💳', label: 'Transactions', route: '/transactions' },
    { icon: '👤', label: 'Accounts', route: '/accounts' }
  ];

  adminMenuItems = [
    { icon: '👨‍💼', label: 'Admin Dashboard', route: '/admin' },
    { icon: '👥', label: 'Clients', route: '/admin/clients' },
    { icon: '💰', label: 'Comptes', route: '/admin/accounts' },
    { icon: '📊', label: 'Transactions', route: '/admin/transactions' }
  ];

  constructor(public authService: AuthService) {}

  get currentUser(): User | null {
    return this.authService.getCurrentUser();
  }

  get isAdmin(): boolean {
    return this.authService.isAdmin();
  }

  logout(): void {
    this.authService.logout();
  }
}
