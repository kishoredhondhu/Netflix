export interface CastCrewMember {
  id?: number;
  name: string;
  role: string;
  contactEmail: string;
  contactPhone: string;
  contractStatus: 'PENDING' | 'SIGNED' | 'EXPIRED';
  availabilityDates: string[];  // ISO date strings
  contractFileName?: string;
}
