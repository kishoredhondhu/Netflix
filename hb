<div class="card shadow mb-4">
  <div class="card-header bg-primary text-white">
    <h5 class="mb-0">Create Movie Project</h5>
  </div>
  <div class="card-body">
    <form [formGroup]="projectForm" (ngSubmit)="onSubmit()">
      <div class="mb-3">
        <label class="form-label">Title</label>
        <input class="form-control" formControlName="title" />
      </div>

      <div class="mb-3">
        <label class="form-label">Genre</label>
        <select class="form-select" formControlName="genre">
          <option value="">Select Genre</option>
          <option *ngFor="let g of genres" [value]="g">{{ g }}</option>
        </select>
      </div>

      <div class="mb-3">
        <label class="form-label">Budget (₹)</label>
        <input type="number" class="form-control" formControlName="budget" />
      </div>

      <div class="row mb-3">
        <div class="col">
          <label class="form-label">Start Date</label>
          <input type="date" class="form-control" formControlName="startDate" />
        </div>
        <div class="col">
          <label class="form-label">End Date</label>
          <input type="date" class="form-control" formControlName="endDate" />
        </div>
      </div>

      <div class="form-check mb-3">
        <input type="checkbox" class="form-check-input" formControlName="isTemplate" />
        <label class="form-check-label">Use Template</label>
      </div>

      <div class="mb-3">
        <label class="form-label">Add Team Member</label>
        <div class="row g-2">
          <div class="col-5">
            <input #nameInput class="form-control" placeholder="Enter name" />
          </div>
          <div class="col-5">
            <select #roleSelect class="form-select">
              <option *ngFor="let r of roles" [value]="r">{{ r }}</option>
            </select>
          </div>
          <div class="col-2">
            <button class="btn btn-outline-secondary w-100" type="button"
                    (click)="addTeamMember(nameInput, roleSelect)">Add</button>
          </div>
        </div>
      </div>

      <ul class="list-group mb-3">
        <li *ngFor="let m of keyTeamMembers.controls; let i=index"
            class="list-group-item d-flex justify-content-between align-items-center">
          {{ m.value.name }} ({{ m.value.role }})
          <button class="btn btn-sm btn-danger" (click)="removeTeamMember(i)">×</button>
        </li>
      </ul>

      <button type="submit" class="btn btn-success">Create Project</button>
    </form>
  </div>
</div>
