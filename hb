import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface MovieProject {
  id?: number;
  title: string;
  genre: string;
  budget: number;
  startDate: string;
  endDate: string;
  isTemplate: boolean;
  keyTeamMembers: string[];
}

@Injectable({
  providedIn: 'root'
})
export class ProjectService {
  private baseUrl = 'http://localhost:8081/api/projects';

  constructor(private http: HttpClient) {}

  createProject(project: MovieProject): Observable<MovieProject> {
    return this.http.post<MovieProject>(this.baseUrl, project);
  }

  getAllProjects(): Observable<MovieProject[]> {
    return this.http.get<MovieProject[]>(this.baseUrl);
  }
}
