<div class="card shadow-sm mb-4">
  <div class="card-body">
    <h5 class="card-title mb-3">Create New Project</h5>

    <form [formGroup]="projectForm" (ngSubmit)="onSubmit()">
      <div class="mb-3">
        <label>Title</label>
        <input class="form-control" formControlName="title" required />
      </div>

      <div class="mb-3">
        <label>Genre</label>
        <input class="form-control" formControlName="genre" required />
      </div>

      <div class="mb-3">
        <label>Budget</label>
        <input type="number" class="form-control" formControlName="budget" required />
      </div>

      <div class="row">
        <div class="col">
          <label>Start Date</label>
          <input type="date" class="form-control" formControlName="startDate" />
        </div>
        <div class="col">
          <label>End Date</label>
          <input type="date" class="form-control" formControlName="endDate" />
        </div>
      </div>

      <div class="form-check mt-3 mb-3">
        <input type="checkbox" class="form-check-input" formControlName="isTemplate" />
        <label class="form-check-label">Use Template</label>
      </div>

      <div class="input-group mb-3">
        <input #teamMemberInput placeholder="Team Member" class="form-control" />
        <button class="btn btn-outline-primary" type="button" (click)="addTeamMember(teamMemberInput.value); teamMemberInput.value=''">Add</button>
      </div>

      <ul class="list-group mb-3">
        <li class="list-group-item d-flex justify-content-between align-items-center" *ngFor="let member of keyTeamMembers.controls; let i = index">
          {{ member.value }}
          <button type="button" class="btn-close" aria-label="Remove" (click)="removeTeamMember(i)"></button>
        </li>
      </ul>

      <button type="submit" class="btn btn-success">Create Project</button>
    </form>
  </div>
</div>
