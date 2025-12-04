export interface Client {
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber: string;
  address: string;
  city: string;
  postalCode: string;
  country: string;
  dateOfBirth: string;
  nationalId: string;
  status: 'ACTIVE' | 'PENDING' | 'SUSPENDED' | 'CLOSED';
  kycStatus: 'PENDING_VERIFICATION' | 'VERIFIED' | 'REJECTED';
  kycVerificationDate?: string;
  kycNotes?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateClientRequest {
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber: string;
  address: string;
  city: string;
  postalCode: string;
  country: string;
  dateOfBirth: string;
  nationalId: string;
}
