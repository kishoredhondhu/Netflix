import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { CastCrewMember } from '../models/cast-crew.model';
import { Observable } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class CastCrewService {
  private baseUrl = 'http://localhost:8081/api/cast-crew';

  constructor(private http: HttpClient) {}

  getAll(): Observable<CastCrewMember[]> {
    return this.http.get<CastCrewMember[]>(this.baseUrl);
  }

  create(member: CastCrewMember): Observable<CastCrewMember> {
    return this.http.post<CastCrewMember>(this.baseUrl, member);
  }

  update(id: number, member: CastCrewMember): Observable<CastCrewMember> {
    return this.http.put<CastCrewMember>(`${this.baseUrl}/${id}`, member);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`);
  }
}
