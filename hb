<div class="container-fluid mt-4">
    <div *ngIf="isLoadingProject && !project">
      <p>Loading project details...</p>
      <div class="spinner-border spinner-border-sm" role="status"></div>
    </div>
  
    <div *ngIf="project">
      <h4 class="mb-3">
        <i class="bi bi-calendar-week me-2"></i>Shooting Schedule for: {{ project.title }}
      </h4>
    </div>
  
    <div class="row">
      <div class="col-md-4">
        <h5>Available Scenes (Unscheduled)</h5>
        <div *ngIf="isLoadingAllScenes && availableScenes.length === 0" class="text-center">
          <div class="spinner-border spinner-border-sm text-secondary" role="status"></div>
          <p class="small text-muted">Loading scenes...</p>
        </div>
        <div *ngIf="!isLoadingAllScenes && availableScenes.length === 0" class="alert alert-light small">
          No unscheduled scenes for this project, or all scenes are scheduled.
        </div>
        <div
          *ngIf="!isLoadingAllScenes && availableScenes.length > 0"
          cdkDropList
          id="availableScenesList"
          [cdkDropListData]="availableScenes"
          [cdkDropListConnectedTo]="getAllDropListIds()" class="list-group scene-list available-scenes-list p-2 border rounded bg-light"
          (cdkDropListDropped)="drop($event)">
          <div *ngFor="let scene of availableScenes" cdkDrag [cdkDragData]="scene" class="list-group-item list-group-item-action scene-item mb-1 shadow-sm">
            <strong>Sc. {{ scene.sceneNumber }}</strong>: {{ scene.setting }}
            <div class="small text-muted">{{ scene.description | slice:0:50 }}{{ scene.description && scene.description.length > 50 ? '...' : '' }}</div>
            <div class="small text-muted">Pages: {{ scene.scriptPageRef }} | Chars: {{ scene.characters.join(', ') | slice:0:30 }}{{ scene.characters.join(', ').length > 30 ? '...' : '' }}</div>
          </div>
        </div>
      </div>
  
      <div class="col-md-8">
        <h5>Shooting Schedule</h5>
        <form [formGroup]="newShootingDayForm" (ngSubmit)="addShootingDay()" class="card p-3 mb-3 shadow-sm bg-light">
          <div class="row gx-2 align-items-center">
            <div class="col-md-4">
              <label for="shootingDate" class="form-label visually-hidden">Date</label>
              <input id="shootingDate" type="date" formControlName="date" class="form-control form-control-sm"
                     [class.is-invalid]="dayFormControl['date'].invalid && dayFormControl['date'].touched">
              <div *ngIf="dayFormControl['date'].errors?.['required'] && dayFormControl['date'].touched" class="invalid-feedback small">
                Date is required.
              </div>
            </div>
            <div class="col-md-3">
              <div class="form-check form-switch mt-2">
                <input id="isNightShoot" type="checkbox" formControlName="isNight" class="form-check-input">
                <label for="isNightShoot" class="form-check-label small">Night Shoot</label>
              </div>
            </div>
            <div class="col-md-3">
               <input type="text" formControlName="notes" class="form-control form-control-sm" placeholder="Day notes (optional)">
            </div>
            <div class="col-md-2">
              <button type="submit" class="btn btn-primary btn-sm w-100" [disabled]="newShootingDayForm.invalid || isLoadingShootingDays">
                <i class="bi bi-plus-lg"></i> Add Day
              </button>
            </div>
          </div>
        </form>
  
        <div *ngIf="isLoadingShootingDays && shootingDays.length === 0" class="text-center mt-3">
          <div class="spinner-border text-primary" role="status"></div>
          <p class="text-muted">Loading schedule...</p>
        </div>
  
        <div *ngIf="!isLoadingShootingDays && shootingDays.length === 0" class="alert alert-info">
          No shooting days scheduled yet. Add a day using the form above.
        </div>
  
        <div class="shooting-days-container">
          <div *ngFor="let day of shootingDays" class="card shooting-day-card mb-3 shadow-sm" [id]="'day-' + day.id">
            <div class="card-header d-flex justify-content-between align-items-center p-2 bg-dark text-white">
              <h6 class="mb-0">
                <i class="bi bi-calendar3 me-1"></i> {{ day.date | date:'fullDate' }}
                <span class="badge ms-2" [ngClass]="day.isNight ? 'bg-primary' : 'bg-warning text-dark'">{{ day.isNight ? 'Night' : 'Day' }}</span>
              </h6>
              <button class="btn btn-sm btn-outline-danger py-0 px-1" title="Delete Shooting Day" (click)="deleteShootingDay(day.id!)">
                  <i class="bi bi-x-lg"></i>
              </button>
            </div>
            <div class="card-body p-2">
              <div class="mb-2 small">
                  <div *ngIf="day.notes"><strong>Notes:</strong> {{ day.notes }}</div>
                  <div *ngIf="day.weatherForecast"><strong>Weather:</strong> {{ day.weatherForecast }}</div>
                  <div *ngIf="day.allocatedResources && day.allocatedResources.length > 0"><strong>Resources:</strong> {{ day.allocatedResources.join(', ') }}</div>
                  <div *ngIf="day.hasConflicts" class="text-danger fw-bold"><i class="bi bi-exclamation-triangle-fill"></i> Schedule Conflict!</div>
              </div>
              <div
                cdkDropList
                [id]="'dayList-' + day.id"
                [cdkDropListData]="day.scheduledScenes"
                [cdkDropListConnectedTo]="getAllDropListIds()" class="list-group scene-list scheduled-scenes-list p-2 border rounded min-vh-10"
                (cdkDropListDropped)="drop($event)">
                <div *ngIf="!day.scheduledScenes || day.scheduledScenes.length === 0" class="text-center text-muted p-3 small fst-italic">
                  Drag scenes here or add them.
                </div>
                <div *ngFor="let scene of day.scheduledScenes" cdkDrag [cdkDragData]="scene" class="list-group-item list-group-item-action scene-item mb-1 shadow-sm">
                  <strong>Sc. {{ scene.sceneNumber }}</strong>: {{ scene.setting }}
                  <div class="small text-muted">{{ scene.description | slice:0:50 }}{{ scene.description && scene.description.length > 50 ? '...' : '' }}</div>
                  <div class="small text-muted">Pages: {{ scene.scriptPageRef }} | Chars: {{ scene.characters.join(', ') | slice:0:30 }}{{ scene.characters.join(', ').length > 30 ? '...' : '' }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  
