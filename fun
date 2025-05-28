<div class="card shadow mb-4">
  <div class="card-header bg-primary text-white">
    <h5 class="mb-0">Create Movie Project</h5>
  </div>
  <div class="card-body">

    <!-- Project Details -->
    <div class="mb-4">
      <h6>Project Details</h6>
      <div class="mb-3">
        <label class="form-label">Title</label>
        <input class="form-control" formControlName="title" />
      </div>

      <div class="mb-3">
        <label class="form-label">Genres</label>
        <select class="form-select" multiple (change)="updateGenres($event)">
          <option *ngFor="let g of genres" [value]="g">{{ g }}</option>
        </select>
      </div>

      <div class="mb-3">
        <label class="form-label">Budget (₹)</label>
        <input type="number" class="form-control" formControlName="budget" />
      </div>
    </div>

    <!-- Timeline -->
    <div class="mb-4">
      <h6>Timeline</h6>
      <div class="row">
        <div class="col">
          <label class="form-label">Start Date</label>
          <input type="date" class="form-control" formControlName="startDate" />
        </div>
        <div class="col">
          <label class="form-label">End Date</label>
          <input type="date" class="form-control" formControlName="endDate" />
        </div>
      </div>
    </div>

    <!-- Template Toggle -->
    <div class="form-check form-switch mb-4">
      <input type="checkbox" class="form-check-input" formControlName="isTemplate" id="templateSwitch">
      <label class="form-check-label" for="templateSwitch">
        Use Template <span title="Prefills title, genres, team roles, and budget">🛈</span>
      </label>
    </div>

    <!-- Team Members -->
    <div class="mb-3">
      <h6>Team Members</h6>
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

      <ul class="list-group mt-3">
        <li *ngFor="let m of keyTeamMembers.controls; let i=index"
            class="list-group-item d-flex justify-content-between align-items-center">
          {{ m.value.name }} ({{ m.value.role }})
          <button class="btn btn-sm btn-danger" (click)="removeTeamMember(i)">×</button>
        </li>
      </ul>
    </div>

    <button type="submit" class="btn btn-success w-100" [disabled]="projectForm.invalid">
      Create Project
    </button>
  </div>
</div>

<!-- Bootstrap Toast -->
<div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 1055;">
  <div class="toast align-items-center text-bg-success border-0" role="alert" id="successToast">
    <div class="d-flex">
      <div class="toast-body">✅ Project created successfully!</div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto"
              data-bs-dismiss="toast" aria-label="Close"></button>
    </div>
  </div>
</div>
