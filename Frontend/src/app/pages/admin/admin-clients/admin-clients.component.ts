import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { Client } from '../../../models/client.model';
import { ClientService } from '../../../services/client.service';
import { AdminService } from '../../../services/admin.service';

@Component({
  selector: 'app-admin-clients',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './admin-clients.component.html',
  styleUrls: ['./admin-clients.component.scss']
})
export class AdminClientsComponent implements OnInit {
  clients: Client[] = [];
  filteredClients: Client[] = [];
  searchTerm = '';
  filterStatus = 'ALL';
  filterKyc = 'ALL';
  selectedClient: Client | null = null;
  showCreateForm = false;
  editingClient: any = null;

  createForm = {
    firstName: '',
    lastName: '',
    email: '',
    phoneNumber: '',
    address: '',
    city: '',
    postalCode: '',
    country: '',
    dateOfBirth: '',
    nationalId: '',
    password: 'password123'
  };

  constructor(
    private clientService: ClientService,
    private http: HttpClient,
    private adminService: AdminService
  ) {}

  ngOnInit(): void {
    this.loadClients();
  }

  loadClients(): void {
    this.clientService.getAllClients().subscribe({
      next: (clients) => {
        this.clients = clients;
        this.applyFilters();
      },
      error: (error) => console.error('Error loading clients:', error)
    });
  }

  applyFilters(): void {
    this.filteredClients = this.clients.filter(client => {
      const matchesSearch = !this.searchTerm || 
        client.firstName.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
        client.lastName.toLowerCase().includes(this.searchTerm.toLowerCase()) ||
        client.email.toLowerCase().includes(this.searchTerm.toLowerCase());

      const matchesStatus = this.filterStatus === 'ALL' || client.status === this.filterStatus;
      const matchesKyc = this.filterKyc === 'ALL' || client.kycStatus === this.filterKyc;

      return matchesSearch && matchesStatus && matchesKyc;
    });
  }

  viewClient(client: Client): void {
    this.selectedClient = client;
  }

  closeDetails(): void {
    this.selectedClient = null;
  }

  updateStatus(clientId: number, status: string): void {
    this.adminService.updateClientStatus(clientId, status).subscribe({
      next: () => {
        alert(`Statut du client mis à jour avec succès`);
        this.loadClients();
        this.closeDetails();
      },
      error: (error) => {
        console.error('Error updating status:', error);
        alert('Erreur lors de la mise à jour: ' + (error.error?.message || error.message || 'Erreur inconnue'));
      }
    });
  }

  updateKycStatus(clientId: number, kycStatus: string): void {
    this.adminService.updateClientKycStatus(clientId, kycStatus, 'Updated by admin').subscribe({
      next: () => {
        alert(`Statut KYC mis à jour avec succès`);
        this.loadClients();
        this.closeDetails();
      },
      error: (error) => {
        console.error('Error updating KYC status:', error);
        alert('Erreur lors de la mise à jour: ' + (error.error?.message || error.message || 'Erreur inconnue'));
      }
    });
  }

  toggleCreateForm(): void {
    this.showCreateForm = !this.showCreateForm;
    if (!this.showCreateForm) {
      this.resetCreateForm();
    }
  }

  resetCreateForm(): void {
    this.createForm = {
      firstName: '',
      lastName: '',
      email: '',
      phoneNumber: '',
      address: '',
      city: '',
      postalCode: '',
      country: '',
      dateOfBirth: '',
      nationalId: '',
      password: 'password123'
    };
  }

  onCreateClient(): void {
    this.clientService.createClient(this.createForm).subscribe({
      next: () => {
        alert('Client created successfully!');
        this.showCreateForm = false;
        this.resetCreateForm();
        this.loadClients();
      },
      error: (error) => {
        alert('Failed to create client: ' + (error.error?.message || 'Unknown error'));
      }
    });
  }

  editClient(client: Client): void {
    this.editingClient = { ...client };
  }

  onUpdateClient(): void {
    if (!this.editingClient) return;
    
    this.clientService.updateClient(this.editingClient.id, this.editingClient).subscribe({
      next: () => {
        alert('Client updated successfully!');
        this.editingClient = null;
        this.loadClients();
      },
      error: (error) => {
        alert('Failed to update client: ' + (error.error?.message || 'Unknown error'));
      }
    });
  }

  cancelEdit(): void {
    this.editingClient = null;
  }
}
