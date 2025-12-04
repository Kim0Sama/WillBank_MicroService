export interface Account {
  id: number;
  accountNumber: string;
  customerId: number;
  accountType: 'SAVINGS' | 'CHECKING' | 'BUSINESS';
  balance: number;
  currency: string;
  status: 'ACTIVE' | 'INACTIVE' | 'CLOSED';
  createdAt: string;
  updatedAt: string;
}

export interface CreateAccountRequest {
  customerId: number;
  accountType: 'SAVINGS' | 'CHECKING' | 'BUSINESS';
  initialDeposit: number;
}
