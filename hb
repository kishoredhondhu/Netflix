<nav class="navbar navbar-dark bg-dark px-4">
  <span class="navbar-brand">🎬 Movie Production</span>
  <button class="btn btn-outline-light btn-sm" (click)="toggleSidebar()">☰</button>
</nav>

<div class="container-fluid mt-3">
  <div class="row">
    <div class="col-md-3 bg-light border-end" *ngIf="showSidebar"
         style="min-height: 100vh; overflow-y: auto; resize: horizontal;">
      <div class="list-group">
        <a class="list-group-item list-group-item-action"
           [class.active]="activeSection === 'dashboard'"
           (click)="setSection('dashboard')">Dashboard</a>
        <a class="list-group-item list-group-item-action"
           [class.active]="activeSection === 'form'"
           (click)="setSection('form')">Create Project</a>
      </div>
    </div>

    <div [class.col-md-9]="showSidebar" [class.col-md-12]="!showSidebar">
      <app-project-form *ngIf="activeSection === 'form'" (projectCreated)="setSection('dashboard')"></app-project-form>
      <app-project-list *ngIf="activeSection === 'dashboard'"></app-project-list>
    </div>
  </div>
</div>
