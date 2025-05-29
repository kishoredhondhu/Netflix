import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Scene } from '../models/scene.model';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class SceneService {
  private baseUrl = 'http://localhost:8081/api/scene';

  constructor(private http: HttpClient) {}

  createScene(scene: Scene): Observable<Scene> {
    return this.http.post<Scene>(this.baseUrl, scene);
  }

  getScenesByProject(projectId: number): Observable<Scene[]> {
    return this.http.get<Scene[]>(`${this.baseUrl}/project/${projectId}`);
  }
}
