import { Component, OnInit, OnDestroy, ChangeDetectorRef } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Subscription, forkJoin, of } from 'rxjs';
import { CdkDragDrop, moveItemInArray, transferArrayItem } from '@angular/cdk/drag-drop';
import { catchError, finalize } from 'rxjs/operators';

import { ShootingScheduleService } from '../../services/shooting-schedule.service';
import { Scene } from '../../models/scene.model';
import { ShootingDay } from '../../models/shooting-day.model';
import { MovieProject } from '../../models/movie-project.model';
import { ProjectService } from '../../services/project.service';
import { HttpErrorResponse } from '@angular/common/http';

@Component({
  selector: 'app-shooting-schedule',
  templateUrl: './shooting-schedule.component.html',
  styleUrls: ['./shooting-schedule.component.css']
})
export class ShootingScheduleComponent implements OnInit, OnDestroy {
  projectId!: number;
  project?: MovieProject;
  shootingDays: ShootingDay[] = [];
  allProjectScenes: Scene[] = [];
  availableScenes: Scene[] = [];

  newShootingDayForm!: FormGroup;

  isLoadingProject = true;
  isLoadingShootingDays = true;
  isLoadingAllScenes = true;
  isUpdatingSchedule = false;

  get isOverallLoading(): boolean {
    return this.isLoadingProject || this.isLoadingAllScenes || this.isLoadingShootingDays;
  }

  private subscriptions: Subscription[] = [];

  constructor(
    private route: ActivatedRoute,
    private fb: FormBuilder,
    private shootingScheduleService: ShootingScheduleService,
    private projectService: ProjectService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    const routeSub = this.route.paramMap.subscribe(params => {
      const idParam = params.get('projectId');
      if (idParam) {
        this.projectId = +idParam;
        this.loadInitialData(); // Initial load
      } else {
        console.error('[ShootingSchedule] Project ID not found in route');
        this.setAllLoadingFlags(false);
      }
    });
    this.subscriptions.push(routeSub);

    this.newShootingDayForm = this.fb.group({
      date: ['', Validators.required],
      isNight: [false, Validators.required],
      notes: ['']
    });
  }

  private setAllLoadingFlags(isLoading: boolean): void {
    this.isLoadingProject = isLoading;
    this.isLoadingAllScenes = isLoading;
    this.isLoadingShootingDays = isLoading;
  }

  loadInitialData(onComplete?: () => void): void {
    console.log('[ShootingSchedule] loadInitialData - START');
    this.setAllLoadingFlags(true);

    const projectDetails$ = this.projectService.getProjectById(this.projectId).pipe(
      catchError(err => {
        console.error('[ShootingSchedule] Error loading project details:', err);
        return of(undefined);
      })
    );
    const allScenes$ = this.shootingScheduleService.getScenesByProjectId(this.projectId).pipe(
      catchError(err => {
        console.error('[ShootingSchedule] Error loading all scenes:', err);
        return of([]);
      })
    );
    const shootingDays$ = this.shootingScheduleService.getShootingDaysByProjectId(this.projectId).pipe(
      catchError(err => {
        console.error('[ShootingSchedule] Error loading shooting days:', err);
        return of([]);
      })
    );

    const initialDataSub = forkJoin([projectDetails$, allScenes$, shootingDays$])
      .pipe(
        finalize(() => {
          this.isLoadingProject = false;
          this.isLoadingAllScenes = false;
          this.isLoadingShootingDays = false;
          console.log('[ShootingSchedule] loadInitialData - forkJoin finalized.');
          this.updateAvailableScenesList(); // Update available scenes after all data is processed or defaulted
          if (onComplete) {
            onComplete(); // Execute the final callback
          }
          this.cdr.detectChanges(); // Ensure UI updates after all loading and processing
          console.log('[ShootingSchedule] loadInitialData - END');
        })
      )
      .subscribe(
        ([projectData, scenesData, daysData]) => {
            console.log('[ShootingSchedule] loadInitialData - forkJoin success. Processing data...');
            this.project = projectData;
            this.allProjectScenes = (scenesData || []).map(s => this.ensureSceneIntegrity(s))
                                  .sort((a, b) => a.sceneNumber - b.sceneNumber);
            this.shootingDays = (daysData || []).map(d => this.ensureDayIntegrity(d))
                                  .sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
            // updateAvailableScenesList() is now called in finalize
        }
    );
    this.subscriptions.push(initialDataSub);
  }

  private ensureSceneIntegrity(scene: Scene | undefined | null): Scene {
    const safeScene = scene || {} as Scene;
    return {
      id: safeScene.id,
      sceneNumber: safeScene.sceneNumber || 0,
      setting: safeScene.setting || '',
      description: safeScene.description || '',
      locationDetails: safeScene.locationDetails || '',
      scriptPageRef: safeScene.scriptPageRef || '',
      characters: Array.isArray(safeScene.characters) ? [...safeScene.characters] : [],
      projectId: safeScene.projectId || this.projectId,
    };
  }

  private ensureDayIntegrity(day: ShootingDay | undefined | null): ShootingDay {
    const safeDay = day || {} as ShootingDay;
    return {
      id: safeDay.id,
      projectId: safeDay.projectId || this.projectId,
      date: safeDay.date || '',
      isNight: safeDay.isNight || false,
      notes: safeDay.notes || '',
      scheduledScenes: Array.isArray(safeDay.scheduledScenes)
        ? safeDay.scheduledScenes.map(s => this.ensureSceneIntegrity(s))
        : [],
      allocatedResources: Array.isArray(safeDay.allocatedResources) ? [...safeDay.allocatedResources] : [],
      hasConflicts: safeDay.hasConflicts || false,
      weatherForecast: safeDay.weatherForecast,
    };
  }

  // These individual load methods are kept for potential granular reloads,
  // and they now accept an optional onComplete callback.
  loadAllProjectScenes(onComplete?: () => void): void {
    this.isLoadingAllScenes = true;
    const sub = this.shootingScheduleService.getScenesByProjectId(this.projectId).subscribe({
      next: scenes => {
        this.allProjectScenes = (scenes || []).map(scene => this.ensureSceneIntegrity(scene))
                              .sort((a, b) => a.sceneNumber - b.sceneNumber);
        this.isLoadingAllScenes = false;
        this.updateAvailableScenesList(); // Update after this specific load
        if (onComplete) {
          onComplete();
        }
      },
      error: err => {
        console.error('[ShootingSchedule] Error loading all scenes:', err);
        this.isLoadingAllScenes = false;
        if (onComplete) {
          onComplete();
        }
      }
    });
    this.subscriptions.push(sub);
  }

  loadShootingDays(onComplete?: () => void): void {
    this.isLoadingShootingDays = true;
    const sub = this.shootingScheduleService.getShootingDaysByProjectId(this.projectId).subscribe({
      next: days => {
        this.shootingDays = (days || []).map(day => this.ensureDayIntegrity(day))
                            .sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
        this.isLoadingShootingDays = false;
        this.updateAvailableScenesList(); // Update after this specific load
        if (onComplete) {
          onComplete();
        }
      },
      error: err => {
        console.error('[ShootingSchedule] Error loading shooting days:', err);
        this.isLoadingShootingDays = false;
        if (onComplete) {
          onComplete();
        }
      }
    });
    this.subscriptions.push(sub);
  }

  updateAvailableScenesList(): void {
    console.log('[ShootingSchedule] updateAvailableScenesList - START');
    const allScenesCurrent = Array.isArray(this.allProjectScenes) ? this.allProjectScenes : [];
    const shootingDaysCurrent = Array.isArray(this.shootingDays) ? this.shootingDays : [];

    if (!this.isOverallLoading && (allScenesCurrent.length === 0 && shootingDaysCurrent.length === 0 && this.projectId)) {
        this.availableScenes = []; this.cdr.detectChanges(); return;
    }

    const scheduledIds = new Set<number>();
    shootingDaysCurrent.forEach(day => {
      if (!day) return;
      (day.scheduledScenes || []).forEach(scene => {
        if (scene && scene.id != null) { scheduledIds.add(scene.id); }
      });
    });

    this.availableScenes = allScenesCurrent
      .filter(scene => scene && scene.id != null && !scheduledIds.has(scene.id))
      .sort((a, b) => a.sceneNumber - b.sceneNumber);
    console.log('[ShootingSchedule] updateAvailableScenesList - END. Available Scenes count:', this.availableScenes.length);
    // cdr.detectChanges() is called at the end of loadInitialData's finalize block
  }

  getAllDropListIds(): string[] { /* ... same ... */ 
    return ['availableScenesList', ...((this.shootingDays || []).filter(day => day && day.id != null).map(day => 'dayList-' + day.id))];
  }
  drop(event: CdkDragDrop<Scene[]>): void { /* ... same ... */ 
    if (this.isUpdatingSchedule) { console.log('[ShootingSchedule] Drop ignored, update in progress.'); return; }
    const previousArray = event.previousContainer.data; const currentArray = event.container.data;
    if (!Array.isArray(previousArray) || !Array.isArray(currentArray)) { console.error('[ShootingSchedule] Drop Error: CDK container data is not an array.'); return; }
    if (previousArray.length > 0 && (event.previousIndex >= previousArray.length || event.previousIndex < 0) ) { console.error('[ShootingSchedule] Drop Error: previousIndex out of bounds.'); return; }
    if (previousArray.length > 0 && !event.item.data) { console.error('[ShootingSchedule] Drop Error: event.item.data is undefined.'); return; }
    this.isUpdatingSchedule = true;
    if (event.previousContainer === event.container) { moveItemInArray(currentArray, event.previousIndex, event.currentIndex); } else { transferArrayItem( previousArray, currentArray, event.previousIndex, event.currentIndex ); }
    this.availableScenes = [...(this.availableScenes || [])];
    this.shootingDays = (this.shootingDays || []).map(day => this.ensureDayIntegrity(day));
    this.persistDropChanges(event.previousContainer.id, event.container.id);
  }
  private persistDropChanges(fromListId: string, toListId: string): void { /* ... same ... */ 
    const affectedDayIds = new Set<number>();
    if (fromListId.startsWith('dayList-')) affectedDayIds.add(parseInt(fromListId.split('-')[1], 10));
    if (toListId.startsWith('dayList-')) affectedDayIds.add(parseInt(toListId.split('-')[1], 10));
    if (affectedDayIds.size === 0) { this.isUpdatingSchedule = false; this.updateAvailableScenesList(); this.cdr.detectChanges(); return; }
    let updatesPending = affectedDayIds.size;
    affectedDayIds.forEach(dayId => {
      const dayToUpdate = this.shootingDays.find(d => d.id === dayId);
      if (dayToUpdate?.id != null) {
        const payload = this.ensureDayIntegrity(dayToUpdate);
        const sub = this.shootingScheduleService.updateShootingDay(dayToUpdate.id, payload as ShootingDay).subscribe({
          next: () => { updatesPending--; if (updatesPending === 0) this.handleAllScheduleUpdatesComplete(); },
          error: (err: HttpErrorResponse) => { updatesPending--; if (updatesPending === 0) this.handleAllScheduleUpdatesError(err, `updating day ID ${dayId}`); }
        });
        this.subscriptions.push(sub);
      } else { updatesPending--; if (updatesPending === 0) { this.isUpdatingSchedule = false; this.updateAvailableScenesList(); } }
    });
  }

  private handleAllScheduleUpdatesComplete(): void {
    console.log('[ShootingSchedule] All backend updates successful. Reloading all data.');
    this.loadInitialData(() => { // loadInitialData expects this callback
        this.isUpdatingSchedule = false;
        console.log('[ShootingSchedule] Data reloaded after successful drop/persist.');
    });
  }

  private handleAllScheduleUpdatesError(error: any, action: string): void {
    console.error(`Error ${action}:`, error);
    this.isUpdatingSchedule = false;
    alert(`Failed to update schedule while ${action}. Data might be out of sync. Please try refreshing the page.`);
    this.loadInitialData();
  }

  addShootingDay(): void { /* ... same ... */ 
    if (this.newShootingDayForm.invalid) { this.newShootingDayForm.markAllAsTouched(); return; }
    const newDay: ShootingDay = this.ensureDayIntegrity({ projectId: this.projectId, date: this.newShootingDayForm.value.date, isNight: this.newShootingDayForm.value.isNight, notes: this.newShootingDayForm.value.notes, scheduledScenes: [], allocatedResources: [], hasConflicts: false });
    this.isLoadingShootingDays = true;
    const sub = this.shootingScheduleService.createShootingDay(newDay).subscribe({
      next: created => {
        this.shootingDays = [...this.shootingDays, this.ensureDayIntegrity(created)];
        this.shootingDays.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
        this.newShootingDayForm.reset({ isNight: false, notes: '' });
        this.updateAvailableScenesList(); // Direct call here is fine after local list mod
        this.isLoadingShootingDays = false;
      },
      error: err => { console.error('Error adding day:', err); this.isLoadingShootingDays = false; }
    });
    this.subscriptions.push(sub);
  }

  deleteShootingDay(dayId?: number): void { /* ... same ... */ 
    if (dayId == null) return;
    if (!confirm('Are you sure you want to delete this shooting day?')) return;
    this.isLoadingShootingDays = true;
    const sub = this.shootingScheduleService.deleteShootingDay(dayId).subscribe({
      next: () => {
        this.shootingDays = this.shootingDays.filter(d => d.id !== dayId);
        this.updateAvailableScenesList(); // Direct call here is fine after local list mod
        this.isLoadingShootingDays = false;
      },
      error: err => { console.error('Error deleting day:', err); this.isLoadingShootingDays = false; }
    });
    this.subscriptions.push(sub);
  }

  get dayFormControl() {
    return this.newShootingDayForm.controls;
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(sub => sub.unsubscribe());
  }
}
