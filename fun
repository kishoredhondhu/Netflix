<nav class="navbar navbar-dark bg-dark px-4">
  <span class="navbar-brand">🎬 Movie Production</span>
  <button class="btn btn-outline-light btn-sm" (click)="toggleSidebar()" aria-label="Toggle sidebar">☰</button>
</nav>

<div class="container-fluid mt-3">
  <div class="row">
    <div class="col-md-3 bg-light border-end sidebar-container"
         *ngIf="showSidebar"
         style="min-height: calc(100vh - 56px - 1rem); overflow-y: auto;">
         <div class="list-group list-group-flush">
        <a routerLink="/dashboard"
           routerLinkActive="active"
           class="list-group-item list-group-item-action d-flex align-items-center">
          <i class="bi bi-bar-chart-line-fill me-2"></i> <span>Dashboard</span>
        </a>
        <a routerLink="/projects/create"
           routerLinkActive="active"
           class="list-group-item list-group-item-action d-flex align-items-center">
          <i class="bi bi-plus-square-fill me-2"></i> <span>Create Project</span>
        </a>
        </div>
    </div>

    <div [class.col-md-9]="showSidebar" [class.col-md-12]="!showSidebar"
         [class.ms-sm-auto]="showSidebar" [class.ps-md-4]="showSidebar">
      <router-outlet></router-outlet>
    </div>

  </div>
</div>

<div class="toast-container position-fixed bottom-0 end-0 p-3" style="z-index: 1055;">
  <div #successToastAppLevel id="successToastAppLevel" class="toast align-items-center text-bg-success border-0" role="alert" aria-live="assertive" aria-atomic="true">
    <div class="d-flex">
      <div class="toast-body">
        ✅ Notification from App Component!
      </div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto"
              data-bs-dismiss="toast" aria-label="Close"></button>
    </div>
  </div>
</div>
