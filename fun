<div class="container mt-4">
  <h4>🎯 Budget Management</h4>

  <!-- Category Form -->
  <form [formGroup]="categoryForm" (ngSubmit)="addCategory()" class="d-flex gap-2 mb-4">
    <input formControlName="categoryName" class="form-control" placeholder="Enter category name">
    <button type="submit" class="btn btn-primary" [disabled]="categoryForm.invalid">Add Category</button>
  </form>

  <!-- Categories + Line Items -->
  <div *ngFor="let cat of categories" class="card mb-3 shadow-sm">
    <div class="card-header bg-secondary text-white d-flex justify-content-between">
      <strong>{{ cat.categoryName }}</strong>
      <span class="text-end small">
        Total: ₹{{ calculateCategoryTotals(cat).estimated | number }} → ₹{{ calculateCategoryTotals(cat).actual | number }}
        <span class="ms-2 badge" [ngClass]="{
          'bg-success': calculateCategoryTotals(cat).variance <= 0,
          'bg-danger': calculateCategoryTotals(cat).variance > 0
        }">
          Variance: ₹{{ calculateCategoryTotals(cat).variance | number }}
        </span>
      </span>
    </div>

    <div class="card-body">
      <form [formGroup]="lineItemForms[cat.id!]" (ngSubmit)="addLineItem(cat.id!)" class="row g-2 align-items-end">
        <div class="col-md-4">
          <input formControlName="itemName" class="form-control" placeholder="Item name">
        </div>
        <div class="col-md-3">
          <input type="number" formControlName="estimatedCost" class="form-control" placeholder="Estimated ₹">
        </div>
        <div class="col-md-3">
          <input type="number" formControlName="actualCost" class="form-control" placeholder="Actual ₹">
        </div>
        <div class="col-md-2">
          <button type="submit" class="btn btn-success w-100" [disabled]="lineItemForms[cat.id!].invalid">Add</button>
        </div>
      </form>

      <table class="table table-bordered table-sm mt-3">
        <thead class="table-light">
          <tr>
            <th>Item</th>
            <th>Estimated ₹</th>
            <th>Actual ₹</th>
            <th>Variance</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr *ngFor="let item of cat.lineItems">
            <td>{{ item.itemName }}</td>
            <td>{{ item.estimatedCost | number }}</td>
            <td>{{ item.actualCost | number }}</td>
            <td [ngClass]="{'text-success': (item.actualCost - item.estimatedCost) <= 0, 'text-danger': (item.actualCost - item.estimatedCost) > 0}">
              ₹{{ item.actualCost - item.estimatedCost | number }}
            </td>
            <td>
              <button class="btn btn-sm btn-outline-danger" (click)="deleteLineItem(item.id!)">🗑</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</div>
