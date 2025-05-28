<div class="card shadow-sm mb-4">
  <div class="card-header bg-primary text-white">Create Movie Project</div>
  <div class="card-body">
    <form [formGroup]="projectForm" (ngSubmit)="onSubmit()">

      <div class="mb-3">
        <label class="form-label">Title</label>
        <input class="form-control" formControlName="title" />
        <small class="text-danger" *ngIf="projectForm.get('title')?.invalid && projectForm.get('title')?.touched">Title required</small>
      </div>

      <div class="mb-3">
        <label class="form-label">Genre</label>
        <input class="form-control" formControlName="genre" />
        <small class="text-danger" *ngIf="projectForm.get('genre')?.invalid && projectForm.get('genre')?.touched">Genre required</small>
      </div>

      <div class="mb-3">
        <label class="form-label">Budget</label>
        <input type="number" class="form-control" formControlName="budget" />
        <small class="text-danger" *ngIf="projectForm.get('budget')?.invalid && projectForm.get('budget')?.touched">Valid budget required</small>
      </div>

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

      <div class="form-check mt-3">
        <input class="form-check-input" type="checkbox" formControlName="isTemplate" />
        <label class="form-check-label">Use Template</label>
      </div>

      <div class="mt-3">
        <label>Team Members</label>
        <input #teamInput class="form-control d-inline w-75" placeholder="Team Member" />
        <button type="button" class="btn btn-outline-secondary mt-2" (click)="addTeamMember(teamInput.value); teamInput.value=''">Add Member</button>
      </div>

      <ul class="list-group mt-2 mb-3">
        <li *ngFor="let m of keyTeamMembers.controls; let i=index" class="list-group-item d-flex justify-content-between">
          {{ m.value }} <button class="btn btn-sm btn-danger" (click)="removeTeamMember(i)">X</button>
        </li>
      </ul>

      <button class="btn btn-success" type="submit">Create Project</button>
    </form>
  </div>
</div>
