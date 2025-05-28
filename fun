import { Component, OnInit } from '@angular/core';
import { BudgetService } from 'src/app/services/budget.service';
import { BudgetCategory, BudgetLineItem } from 'src/app/models/budget-category.model';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

@Component({
  selector: 'app-budget-management',
  templateUrl: './budget-management.component.html'
})
export class BudgetManagementComponent implements OnInit {
  projectId = 1; // 👈 Replace with dynamic project ID
  categories: BudgetCategory[] = [];

  categoryForm!: FormGroup;
  lineItemForms: { [key: number]: FormGroup } = {};

  constructor(private service: BudgetService, private fb: FormBuilder) {}

  ngOnInit(): void {
    this.categoryForm = this.fb.group({
      categoryName: ['', Validators.required]
    });
    this.loadBudget();
  }

  loadBudget(): void {
    this.service.getProjectBudget(this.projectId).subscribe(data => {
      this.categories = data;
      // init line item forms per category
      data.forEach(cat => {
        this.lineItemForms[cat.id!] = this.fb.group({
          itemName: ['', Validators.required],
          estimatedCost: [0, [Validators.required, Validators.min(1)]],
          actualCost: [0, [Validators.required, Validators.min(0)]]
        });
      });
    });
  }

  addCategory(): void {
    if (this.categoryForm.invalid) return;
    const payload = {
      categoryName: this.categoryForm.value.categoryName,
      projectId: this.projectId
    };
    this.service.addCategory(payload).subscribe(() => {
      this.categoryForm.reset();
      this.loadBudget();
    });
  }

  addLineItem(categoryId: number): void {
    const form = this.lineItemForms[categoryId];
    if (form.invalid) return;

    const item: BudgetLineItem = {
      itemName: form.value.itemName,
      estimatedCost: form.value.estimatedCost,
      actualCost: form.value.actualCost,
      categoryId
    };

    this.service.addLineItem(item).subscribe(() => {
      form.reset({ estimatedCost: 0, actualCost: 0 });
      this.loadBudget();
    });
  }

  deleteLineItem(id: number): void {
    this.service.deleteLineItem(id).subscribe(() => this.loadBudget());
  }

  calculateCategoryTotals(category: BudgetCategory) {
    let estimated = 0, actual = 0;
    category.lineItems.forEach(i => {
      estimated += i.estimatedCost;
      actual += i.actualCost;
    });
    return {
      estimated,
      actual,
      variance: actual - estimated
    };
  }
}
