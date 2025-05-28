<div class="card shadow-sm">
  <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
    <h5 class="mb-0">
      <i class="bi bi-film me-2"></i>Movie Projects Dashboard
    </h5>
    </div>

  <div class="card-body p-0">
    <div *ngIf="isLoading" class="text-center p-5">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Loading projects...</span>
      </div>
      <p class="mt-2">Loading projects...</p>
    </div>

    <div *ngIf="!isLoading && projects.length === 0" class="text-center p-5">
      <i class="bi bi-folder-x fs-1 text-muted"></i>
      <h5 class="mt-3">No Projects Found</h5>
      <p class="text-muted">Get started by creating a new movie project!</p>
      <!-- <a routerLink="/create-project" class="btn btn-primary mt-2">
        <i class="bi bi-plus-circle me-1"></i> Create Project
      </a> -->
    </div>

    <div *ngIf="!isLoading && projects.length > 0" class="table-responsive">
      <table class="table table-striped table-hover mb-0 align-middle">
        <thead class="table-light">
          <tr>
            <th scope="col">Title</th>
            <th scope="col">Genres</th>
            <th scope="col" class="text-end">Budget</th>
            <th scope="col">Timeline</th>
            <th scope="col" class="text-center">Template</th>
            <th scope="col">Key Team</th>
          </tr>
        </thead>
        <tbody>
          <tr *ngFor="let project of projects; let i = index">
            <td class="fw-medium">{{ project.title }}</td>
            <td>
              <ng-container *ngIf="project.genre && project.genre.length > 0; else noGenres">
                <span *ngFor="let genre of project.genre" class="badge bg-secondary me-1 mb-1">{{ genre }}</span>
              </ng-container>
              <ng-template #noGenres><span class="text-muted fst-italic">N/A</span></ng-template>
            </td>
            <td class="text-end">{{ project.budget | currency:'₹':'symbol':'1.0-0' }}</td>
            <td>
              {{ project.startDate | date:'MMM d, y' }} - {{ project.endDate | date:'MMM d, y' }}
              <div class="small text-muted">
                Duration: {{ calculateDuration(project.startDate, project.endDate) }}
              </div>
            </td>
            <td class="text-center">
              <span class="badge" [ngClass]="project.isTemplate ? 'bg-success' : 'bg-secondary'">
                {{ project.isTemplate ? 'Yes' : 'No' }}
              </span>
            </td>
            <td>
              <ng-container *ngIf="project.keyTeamMembers && project.keyTeamMembers.length > 0; else noTeam">
                <ul class="list-unstyled mb-0 small">
                  <li *ngFor="let member of project.keyTeamMembers.slice(0, 3)" class="text-truncate" title="{{member}}">
                    <i class="bi bi-person me-1"></i>{{ member }}
                  </li>
                  <li *ngIf="project.keyTeamMembers.length > 3" class="text-muted" title="{{ project.keyTeamMembers.slice(3).join(', ') }}">
                    + {{ project.keyTeamMembers.length - 3 }} more
                  </li>
                </ul>
              </ng-container>
              <ng-template #noTeam><span class="text-muted fst-italic">N/A</span></ng-template>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</div>
