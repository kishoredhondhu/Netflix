<div class="container-fluid mt-4">
  <!-- Project Header -->
  <ng-container *ngIf="project; else loadingProject">
    <h4 class="mb-3">
      <i class="bi bi-calendar-week me-2"></i>
      Shooting Schedule for: {{ project.title }}
    </h4>
  </ng-container>
  <ng-template #loadingProject>
    <p>Loading project details...</p>
    <div class="spinner-border spinner-border-sm" role="status"></div>
  </ng-template>

  <div class="row">
    <!-- Available Scenes Column -->
    <div class="col-md-4">
      <h5>Available Scenes (Unscheduled)</h5>

      <!-- Loading / Empty states -->
      <ng-container *ngIf="isLoadingAllScenes">
        <div class="text-center">
          <div class="spinner-border spinner-border-sm text-secondary" role="status"></div>
          <p class="small text-muted">Loading scenes...</p>
        </div>
      </ng-container>
      <div *ngIf="!isLoadingAllScenes && availableScenes.length === 0" class="alert alert-light small">
        No unscheduled scenes for this project.
      </div>

      <!-- Drag-drop list of available scenes -->
      <div
        *ngIf="!isLoadingAllScenes && availableScenes.length > 0"
        cdkDropList
        id="availableScenesList"
        [cdkDropListData]="availableScenes"
        [cdkDropListConnectedTo]="getAllDropListIds()"
        class="list-group scene-list available-scenes-list p-2 border rounded bg-light"
        (cdkDropListDropped)="drop($event)"
      >
        <div
          *ngFor="let scene of availableScenes"
          cdkDrag
          [cdkDragData]="scene"
          class="list-group-item list-group-item-action scene-item mb-1 shadow-sm"
        >
          <strong>Sc. {{ scene.sceneNumber }}</strong>: {{ scene.setting }}
          <div class="small text-muted">
            {{ scene.description | slice:0:50 }}<span *ngIf="scene.description?.length > 50">…</span>
          </div>
          <div class="small text-muted">
            Pages: {{ scene.scriptPageRef }} | Chars:
            {{ scene.characters.join(', ') | slice:0:30 }}<span *ngIf="scene.characters.join(', ').length > 30">…</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Shooting Schedule Column -->
    <div class="col-md-8">
      <h5>Shooting Schedule</h5>

      <!-- New Shooting Day Form -->
      <form [formGroup]="newShootingDayForm" (ngSubmit)="addShootingDay()"
            class="card p-3 mb-3 shadow-sm bg-light">
        <div class="row gx-2 align-items-center">
          <div class="col-md-4">
            <input id="shootingDate" type="date" formControlName="date"
                   class="form-control form-control-sm"
                   [class.is-invalid]="dayFormControl['date'].invalid && dayFormControl['date'].touched">
            <div *ngIf="dayFormControl['date'].errors?.['required'] && dayFormControl['date'].touched"
                 class="invalid-feedback small">
              Date is required.
            </div>
          </div>
          <div class="col-md-3">
            <div class="form-check form-switch mt-2">
              <input id="isNightShoot" type="checkbox" formControlName="isNight"
                     class="form-check-input">
              <label for="isNightShoot" class="form-check-label small">Night Shoot</label>
            </div>
          </div>
          <div class="col-md-3">
            <input type="text" formControlName="notes"
                   class="form-control form-control-sm"
                   placeholder="Day notes (optional)">
          </div>
          <div class="col-md-2">
            <button type="submit" class="btn btn-primary btn-sm w-100"
                    [disabled]="newShootingDayForm.invalid || isLoadingShootingDays">
              <i class="bi bi-plus-lg"></i> Add Day
            </button>
          </div>
        </div>
      </form>

      <!-- Loading / Empty states -->
      <ng-container *ngIf="isLoadingShootingDays && shootingDays.length === 0">
        <div class="text-center mt-3">
          <div class="spinner-border text-primary" role="status"></div>
          <p class="text-muted">Loading schedule...</p>
        </div>
      </ng-container>
      <div *ngIf="!isLoadingShootingDays && shootingDays.length === 0" class="alert alert-info">
        No shooting days scheduled yet. Add a day above.
      </div>

      <!-- Shooting Days with Drag-drop -->
      <div class="shooting-days-container">
        <div *ngFor="let day of shootingDays" class="card shooting-day-card mb-3 shadow-sm">
          <div class="card-header d-flex justify-content-between align-items-center p-2 bg-dark text-white">
            <h6 class="mb-0">
              <i class="bi bi-calendar3 me-1"></i>
              {{ day.date | date:'fullDate' }}
              <span class="badge ms-2"
                    [ngClass]="day.isNight ? 'bg-primary' : 'bg-warning text-dark'">
                {{ day.isNight ? 'Night' : 'Day' }}
              </span>
            </h6>
            <button class="btn btn-sm btn-outline-danger py-0 px-1"
                    title="Delete Shooting Day"
                    (click)="deleteShootingDay(day.id!)">
              <i class="bi bi-x-lg"></i>
            </button>
          </div>
          <div class="card-body p-2">
            <!-- Meta info -->
            <div class="mb-2 small">
              <div *ngIf="day.notes"><strong>Notes:</strong> {{ day.notes }}</div>
              <div *ngIf="day.weatherForecast"><strong>Weather:</strong> {{ day.weatherForecast }}</div>
              <div *ngIf="day.allocatedResources?.length">
                <strong>Resources:</strong> {{ day.allocatedResources.join(', ') }}
              </div>
              <div *ngIf="day.hasConflicts" class="text-danger fw-bold">
                <i class="bi bi-exclamation-triangle-fill"></i> Schedule Conflict!
              </div>
            </div>

            <!-- Drag-drop list of scheduled scenes -->
            <div
              cdkDropList
              [id]="'dayList-' + day.id"
              [cdkDropListData]="day.scheduledScenes"
              [cdkDropListConnectedTo]="getAllDropListIds()"
              class="list-group scene-list scheduled-scenes-list p-2 border rounded min-vh-10"
              (cdkDropListDropped)="drop($event)"
            >
              <div *ngIf="!day.scheduledScenes?.length"
                   class="text-center text-muted p-3 small fst-italic">
                Drag scenes here
              </div>
              <div
                *ngFor="let scene of day.scheduledScenes"
                cdkDrag
                [cdkDragData]="scene"
                class="list-group-item list-group-item-action scene-item mb-1 shadow-sm"
              >
                <strong>Sc. {{ scene.sceneNumber }}</strong>: {{ scene.setting }}
                <div class="small text-muted">
                  {{ scene.description | slice:0:50 }}<span *ngIf="scene.description?.length > 50">…</span>
                </div>
                <div class="small text-muted">
                  Pages: {{ scene.scriptPageRef }} | Chars:
                  {{ scene.characters.join(', ') | slice:0:30 }}<span *ngIf="scene.characters.join(', ').length > 30">…</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
