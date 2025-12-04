import { Routes } from '@angular/router';
import { LoginComponent } from './pages/login/login.component';
import { DashboardComponent } from './pages/dashboard/dashboard.component';
import { TransactionsComponent } from './pages/transactions/transactions.component';
import { AccountsComponent } from './pages/accounts/accounts.component';
import { AdminDashboardComponent } from './pages/admin/admin-dashboard/admin-dashboard.component';
import { AdminClientsComponent } from './pages/admin/admin-clients/admin-clients.component';
import { AdminAccountsComponent } from './pages/admin/admin-accounts/admin-accounts.component';
import { AdminTransactionsComponent } from './pages/admin/admin-transactions/admin-transactions.component';
import { AuthGuard } from './guards/auth.guard';

export const routes: Routes = [
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'dashboard', component: DashboardComponent, canActivate: [AuthGuard] },
  { path: 'transactions', component: TransactionsComponent, canActivate: [AuthGuard] },
  { path: 'accounts', component: AccountsComponent, canActivate: [AuthGuard] },
  { path: 'admin', component: AdminDashboardComponent, canActivate: [AuthGuard] },
  { path: 'admin/clients', component: AdminClientsComponent, canActivate: [AuthGuard] },
  { path: 'admin/accounts', component: AdminAccountsComponent, canActivate: [AuthGuard] },
  { path: 'admin/transactions', component: AdminTransactionsComponent, canActivate: [AuthGuard] },
  { path: '**', redirectTo: '/login' } // Wildcard route - redirect unknown routes to login
];
