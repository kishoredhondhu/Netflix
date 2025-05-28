<nav class="navbar navbar-dark bg-dark px-4">
  <span class="navbar-brand">🎬 Movie Production</span>
</nav>

<div class="container-fluid mt-4">
  <button class="btn btn-outline-secondary mb-3" (click)="showSidebar = !showSidebar">
    {{ showSidebar ? 'Hide' : 'Show' }} Sidebar
  </button>

  <div class="row">
    <div class="col-md-3" *ngIf="showSidebar">
      <div class="list-group">
        <a class="list-group-item active">Dashboard</a>
        <a class="list-group-item">Create Project</a>
        <a class="list-group-item">Manage Budget</a>
      </div>
    </div>

    <div [class.col-md-9]="showSidebar" [class.col-md-12]="!showSidebar">
      <app-project-form (projectCreated)="loadProjects()"></app-project-form>
      <app-project-list [projects]="projects"></app-project-list>
    </div>
  </div>
</div>
