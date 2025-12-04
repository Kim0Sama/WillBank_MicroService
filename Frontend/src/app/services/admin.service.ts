import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class AdminService {
  private apiUrl = '/api/admin';

  constructor(private http: HttpClient) {}

  // Clients
  getAllClients(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/clients`);
  }

  getClient(id: number): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/clients/${id}`);
  }

  createClient(client: any): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/clients`, client);
  }

  updateClient(id: number, client: any): Observable<any> {
    return this.http.put<any>(`${this.apiUrl}/clients/${id}`, client);
  }

  // Accounts
  getAllAccounts(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/accounts`);
  }

  getAccount(accountNumber: string): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/accounts/${accountNumber}`);
  }

  createAccount(account: any): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/accounts`, account);
  }

  updateAccountStatus(accountNumber: string, status: string): Observable<any> {
    return this.http.put<any>(`${this.apiUrl}/accounts/${accountNumber}/status?status=${status}`, {});
  }

  updateClientStatus(id: number, status: string): Observable<any> {
    return this.http.patch<any>(`/api/clients/${id}/status?status=${status}`, {});
  }

  updateClientKycStatus(id: number, kycStatus: string, notes?: string): Observable<any> {
    return this.http.patch<any>(`/api/clients/${id}/kyc`, { kycStatus, notes });
  }

  // Transactions
  getAllTransactions(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/transactions`);
  }

  getTransaction(id: number): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/transactions/${id}`);
  }
}
