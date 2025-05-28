import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { BudgetCategory, BudgetLineItem } from '../models/budget-category.model';

@Injectable({ providedIn: 'root' })
export class BudgetService {
  private baseUrl = 'http://localhost:8081/api/budget';

  constructor(private http: HttpClient) {}

  getProjectBudget(projectId: number): Observable<BudgetCategory[]> {
    return this.http.get<BudgetCategory[]>(`${this.baseUrl}/project/${projectId}`);
  }

  addCategory(category: { categoryName: string; projectId: number }): Observable<BudgetCategory> {
    return this.http.post<BudgetCategory>(`${this.baseUrl}/category`, category);
  }

  addLineItem(item: BudgetLineItem): Observable<BudgetLineItem> {
    return this.http.post<BudgetLineItem>(`${this.baseUrl}/line-item`, item);
  }

  updateLineItem(item: BudgetLineItem): Observable<BudgetLineItem> {
    return this.http.put<BudgetLineItem>(`${this.baseUrl}/line-item`, item);
  }

  deleteLineItem(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/line-item/${id}`);
  }
}
