<div *ngIf="submitted" style="color: green;">Project created successfully!</div>

<form [formGroup]="projectForm" (ngSubmit)="onSubmit()">
  <input formControlName="title" placeholder="Title" required /><br>
  <input formControlName="genre" placeholder="Genre" required /><br>
  <input type="number" formControlName="budget" placeholder="Budget" required /><br>
  <input type="date" formControlName="startDate" /><br>
  <input type="date" formControlName="endDate" /><br>

  <label>
    <input type="checkbox" formControlName="isTemplate" /> Use Template
  </label><br>

  <input #teamMemberInput placeholder="Team Member Name" />
  <button type="button" (click)="addTeamMember(teamMemberInput.value); teamMemberInput.value=''">Add Member</button>

  <ul>
    <li *ngFor="let member of keyTeamMembers.controls; let i=index">
      {{ member.value }}
      <button type="button" (click)="removeTeamMember(i)">Remove</button>
    </li>
  </ul>

  <button type="submit">Create Project</button>
</form>
