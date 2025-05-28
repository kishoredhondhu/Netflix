<div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 1055;">
  <div #successToastRef id="successToast" class="toast align-items-center text-bg-success border-0" role="alert" aria-live="assertive" aria-atomic="true">
    <div class="d-flex">
      <div class="toast-body">
        <i class="bi bi-check-circle-fill me-2"></i> Project created successfully!
      </div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
    </div>
  </div>
</div>

<div class="card shadow mb-4">
  <div class="card-header bg-primary text-white">
    <h5 class="mb-0">Create Movie Project</h5>
  </div>
  <div class="card-body">
    <form [formGroup]="projectForm" (ngSubmit)="onSubmit()" novalidate>

      <fieldset class="mb-4 p-3 border rounded">
        <legend class="float-none w-auto px-2 fs-6 fw-semibold">Project Details</legend>

        <div class="mb-3">
          <label for="title" class="form-label">Title</label>
          <input id="title" type="text" class="form-control" formControlName="title" [class.is-invalid]="isInvalid('title')">
          <div *ngIf="isInvalid('title')" class="invalid-feedback">Title is required.</div>
        </div>

        <div class="mb-3">
          <label class="form-label">Genres</label>
          <div formArrayName="genres"
               class="row border p-3 rounded"
               [class.is-invalid]="projectForm.hasError('requireOneCheckbox') && genresFormArray.touched"
               [class.border-danger]="projectForm.hasError('requireOneCheckbox') && genresFormArray.touched">
            <div *ngFor="let genre of availableGenres; let i = index" class="col-6 col-sm-4 col-md-3">
              <div class="form-check">
                <input class="form-check-input" type="checkbox" [formControlName]="i" [id]="'genre_' + i">
                <label class="form-check-label" [for]="'genre_' + i">{{ genre }}</label>
              </div>
            </div>
          </div>
          <div *ngIf="projectForm.hasError('requireOneCheckbox') && genresFormArray.touched" class="invalid-feedback d-block">
             At least one genre must be selected.
          </div>
        </div>

        <div class="mb-3">
          <label for="budget" class="form-label">Budget (₹)</label>
          <input id="budget" type="number" class="form-control" formControlName="budget" [class.is-invalid]="isInvalid('budget')">
          <div *ngIf="isInvalid('budget')" class="invalid-feedback">
            <span *ngIf="getControl('budget')?.errors?.['required']">Budget is required.</span>
            <span *ngIf="getControl('budget')?.errors?.['min']">Budget must be at least ₹1000.</span>
          </div>
        </div>
      </fieldset>

      <fieldset class="mb-4 p-3 border rounded">
        <legend class="float-none w-auto px-2 fs-6 fw-semibold">Timeline</legend>
        <div class="row">
          <div class="col-md-6 mb-3 mb-md-0">
            <label for="startDate" class="form-label">Start Date</label>
            <input id="startDate" type="date" class="form-control" formControlName="startDate" [class.is-invalid]="isInvalid('startDate')">
            <div *ngIf="isInvalid('startDate')" class="invalid-feedback">Start Date is required.</div>
          </div>
          <div class="col-md-6">
            <label for="endDate" class="form-label">End Date</label>
            <input id="endDate" type="date" class="form-control" formControlName="endDate" [class.is-invalid]="isInvalid('endDate') || (projectForm.hasError('invalidDateRange') && getControl('endDate')?.touched)">
            <div *ngIf="isInvalid('endDate')" class="invalid-feedback">End Date is required.</div>
            <div *ngIf="projectForm.hasError('invalidDateRange') && getControl('endDate')?.touched && !isInvalid('endDate')" class="invalid-feedback d-block">
              End Date must be after Start Date.
            </div>
          </div>
        </div>
      </fieldset>

      <div class="form-check form-switch mb-4 p-3 border rounded">
        <input id="templateSwitch" type="checkbox" class="form-check-input" formControlName="isTemplate">
        <label class="form-check-label" for="templateSwitch">
          Use Template
          <i class="bi bi-info-circle-fill ms-1" data-bs-toggle="tooltip" data-bs-placement="top" title="Prefills the form with default project data."></i>
        </label>
      </div>

      <fieldset class="mb-4 p-3 border rounded">
        <legend class="float-none w-auto px-2 fs-6 fw-semibold">Team Members</legend>
        <div class="row g-3 align-items-start mb-3" [formGroup]="newTeamMemberForm">
          <div class="col-sm-5">
            <label for="newMemberName" class="form-label visually-hidden">Member Name</label>
            <input id="newMemberName" type="text" class="form-control" placeholder="Enter name" formControlName="name" [class.is-invalid]="isInvalid('name', newTeamMemberForm)">
            <div *ngIf="isInvalid('name', newTeamMemberForm)" class="invalid-feedback">Name is required.</div>
          </div>
          <div class="col-sm-5">
            <label for="newMemberRole" class="form-label visually-hidden">Role</label>
            <select id="newMemberRole" class="form-select" formControlName="role">
              <option *ngFor="let r of roles" [value]="r">{{ r }}</option>
            </select>
          </div>
          <div class="col-sm-2 d-flex align-items-end">
            <button class="btn btn-outline-primary w-100" type="button" (click)="addTeamMember()" [disabled]="newTeamMemberForm.invalid">Add</button>
          </div>
        </div>

        <div *ngIf="keyTeamMembers.controls.length > 0" class="mt-3">
            <h6 class="mb-2 small text-muted">Added Team Members:</h6>
            <ul class="list-group">
              <li *ngFor="let memberCtrl of keyTeamMembers.controls; let i=index"
                  class="list-group-item d-flex justify-content-between align-items-center">
                <span>
                  {{ memberCtrl.get('name')?.value }}
                  <small class="text-muted">({{ memberCtrl.get('role')?.value }})</small>
                </span>
                <button class="btn btn-sm btn-outline-danger py-0 px-2" type="button" (click)="removeTeamMember(i)" title="Remove {{ memberCtrl.get('name')?.value }}">
                  <i class="bi bi-x-lg"></i>
                </button>
              </li>
            </ul>
        </div>
        <div *ngIf="isInvalid('keyTeamMembers') && getControl('keyTeamMembers')?.touched" class="invalid-feedback d-block">
            At least one team member is required.
        </div>
      </fieldset>

      <button type="submit" class="btn btn-success w-100 btn-lg" [disabled]="projectForm.invalid">
        <i class="bi bi-plus-circle-fill me-2"></i> Create Project
      </button>

    </form>
  </div>
</div>
