<div class="card shadow mb-4">
  <div class="card-header bg-primary text-white">Create Movie Project</div>
  <div class="card-body">
    <form [formGroup]="projectForm" (ngSubmit)="onSubmit()">
      <div class="mb-3">
        <label>Title</label>
        <input class="form-control" formControlName="title" />
      </div>

      <div class="mb-3">
        <label>Genre</label>
        <select class="form-select" formControlName="genre">
          <option value="">Select Genre</option>
          <option *ngFor="let g of genres" [value]="g">{{ g }}</option>
        </select>
      </div>

      <div class="mb-3">
        <label>Budget</label>
        <input type="number" class="form-control" formControlName="budget" />
      </div>

      <div class="row mb-3">
        <div class="col">
          <label>Start Date</label>
          <input type="date" class="form-control" formControlName="startDate" />
        </div>
        <div class="col">
          <label>End Date</label>
          <input type="date" class="form-control" formControlName="endDate" />
        </div>
      </div>

      <div class="form-check mb-3">
        <input type="checkbox" class="form-check-input" formControlName="isTemplate" />
        <label class="form-check-label">Use Template</label>
      </div>

      <div class="mb-2">
        <label>Add Team Member</label>
        <div class="row">
          <div class="col">
            <select #name class="form-select">
              <option *ngFor="let n of names">{{ n }}</option>
            </select>
          </div>
          <div class="col">
            <select #role class="form-select">
              <option *ngFor="let r of roles">{{ r }}</option>
            </select>
          </div>
          <div class="col">
            <button class="btn btn-outline-secondary" type="button" (click)="addTeamMember(name.value, role.value)">
              Add
            </button>
          </div>
        </div>
      </div>

      <ul class="list-group mb-3">
        <li *ngFor="let tm of keyTeamMembers.controls; let i = index" class="list-group-item d-flex justify-content-between">
          {{ tm.value.name }} ({{ tm.value.role }})
          <button class="btn btn-sm btn-danger" type="button" (click)="removeTeamMember(i)">×</button>
        </li>
      </ul>

      <button type="submit" class="btn btn-success">Create Project</button>
    </form>
  </div>
</div>
