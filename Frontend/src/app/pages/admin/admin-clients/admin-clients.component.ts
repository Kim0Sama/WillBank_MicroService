import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Client } from '../../../models/client.model';
import { ClientService } from '../../../services/client.service';

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

  constructor(private clientService: ClientService) {}

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
    // TODO: Implement status update API call
    alert(`Update client ${clientId} status to ${status}`);
  }

  updateKycStatus(clientId: number, kycStatus: string): void {
    // TODO: Implement KYC status update API call
    alert(`Update client ${clientId} KYC status to ${kycStatus}`);
  }
}
