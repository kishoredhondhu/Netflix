import { Component, OnInit, OnDestroy, ChangeDetectorRef } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Subscription } from 'rxjs';
import { CdkDragDrop, moveItemInArray, transferArrayItem } from '@angular/cdk/drag-drop';

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
        this.loadInitialData();
      } else {
        console.error('[ShootingSchedule] Project ID not found in route');
        this.isLoadingProject = this.isLoadingShootingDays = this.isLoadingAllScenes = false;
      }
    });
    this.subscriptions.push(routeSub);

    this.newShootingDayForm = this.fb.group({
      date: ['', Validators.required],
      isNight: [false, Validators.required],
      notes: ['']
    });
  }

  loadInitialData(): void {
    this.loadProjectDetails();
    this.loadAllProjectScenes();
    this.loadShootingDays();
  }

  loadProjectDetails(): void {
    this.isLoadingProject = true;
    const sub = this.projectService.getProjectById(this.projectId).subscribe({
      next: project => { this.project = project; this.isLoadingProject = false; this.tryUpdateAvailableScenes(); },
      error: err => { console.error('[ShootingSchedule] Error loading project details:', err); this.isLoadingProject = false; }
    });
    this.subscriptions.push(sub);
  }

  loadAllProjectScenes(): void {
    this.isLoadingAllScenes = true;
    const sub = this.shootingScheduleService.getScenesByProjectId(this.projectId).subscribe({
      next: scenes => {
        this.allProjectScenes = (scenes || []).map(scene => ({
          ...scene, characters: Array.isArray(scene.characters) ? scene.characters : []
        })).sort((a, b) => a.sceneNumber - b.sceneNumber);
        this.isLoadingAllScenes = false;
        this.tryUpdateAvailableScenes();
      },
      error: err => { console.error('[ShootingSchedule] Error loading all scenes:', err); this.isLoadingAllScenes = false; }
    });
    this.subscriptions.push(sub);
  }

  loadShootingDays(): void {
    this.isLoadingShootingDays = true;
    const sub = this.shootingScheduleService.getShootingDaysByProjectId(this.projectId).subscribe({
      next: days => {
        this.shootingDays = (days || []).map(day => this.ensureDayIntegrity(day))
                            .sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
        this.isLoadingShootingDays = false;
        this.tryUpdateAvailableScenes();
      },
      error: err => { console.error('[ShootingSchedule] Error loading shooting days:', err); this.isLoadingShootingDays = false; }
    });
    this.subscriptions.push(sub);
  }

  // Helper to ensure a ShootingDay object and its nested arrays are well-formed
  private ensureDayIntegrity(day: ShootingDay | undefined | null): ShootingDay {
    const safeDay = day || {} as ShootingDay; // Start with an empty object if day is null/undefined
    return {
      id: safeDay.id,
      projectId: safeDay.projectId || this.projectId, // Ensure projectId
      date: safeDay.date || '', // Default to empty string or handle appropriately
      isNight: safeDay.isNight || false,
      notes: safeDay.notes || '',
      scheduledScenes: Array.isArray(safeDay.scheduledScenes)
        ? safeDay.scheduledScenes.map(s => s ? ({ ...s, characters: Array.isArray(s.characters) ? s.characters : [] }) : null).filter(s => s !== null) as Scene[]
        : [],
      allocatedResources: Array.isArray(safeDay.allocatedResources) ? safeDay.allocatedResources : [],
      hasConflicts: safeDay.hasConflicts || false,
      weatherForecast: safeDay.weatherForecast
    };
  }


  tryUpdateAvailableScenes(): void {
    if (!this.isOverallLoading) {
      this.updateAvailableScenesList();
    }
  }

  updateAvailableScenesList(): void {
    console.log('[ShootingSchedule] updateAvailableScenesList - START');
    const allScenesCurrent = Array.isArray(this.allProjectScenes) ? this.allProjectScenes : [];
    const shootingDaysCurrent = Array.isArray(this.shootingDays) ? this.shootingDays : [];

    console.log('[ShootingSchedule] Current allProjectScenes (in update):', JSON.parse(JSON.stringify(allScenesCurrent)));
    console.log('[ShootingSchedule] Current shootingDays (in update):', JSON.parse(JSON.stringify(shootingDaysCurrent)));

    const scheduledIds = new Set<number>();
    shootingDaysCurrent.forEach((day, dayIndex) => {
      if (!day) { console.warn(`[updateAvailableScenesList] Day at index ${dayIndex} is null/undefined.`); return; }
      const scenesOnDay = Array.isArray(day.scheduledScenes) ? day.scheduledScenes : [];
      if (!Array.isArray(day.scheduledScenes)) {
          console.warn(`[updateAvailableScenesList] Day ID ${day.id || 'N/A'} has non-array scheduledScenes. Was:`, day.scheduledScenes);
      }
      scenesOnDay.forEach((scene, sceneIndex) => {
        if (!scene) { console.warn(`[updateAvailableScenesList] Scene at index ${sceneIndex} in Day ID ${day.id || 'N/A'} is null/undefined.`); return; }
        if (scene.id != null) { scheduledIds.add(scene.id); }
      });
    });
    console.log('[ShootingSchedule] Calculated scheduledSceneIds:', scheduledIds);

    this.availableScenes = allScenesCurrent
      .filter(scene => {
        if (!scene) { console.warn('[updateAvailableScenesList] Null/undefined scene in allProjectScenes.'); return false; }
        return scene.id != null && !scheduledIds.has(scene.id);
      })
      .sort((a, b) => a.sceneNumber - b.sceneNumber);

    this.cdr.detectChanges();
    console.log('[ShootingSchedule] Available scenes updated, count:', this.availableScenes.length);
  }

  getAllDropListIds(): string[] {
    return ['availableScenesList', ...((this.shootingDays || []).filter(day => day && day.id != null).map(day => 'dayList-' + day.id))];
  }

  drop(event: CdkDragDrop<Scene[]>): void {
    if (this.isUpdatingSchedule) { console.log('[ShootingSchedule] Drop ignored, update in progress.'); return; }
    console.log('[ShootingSchedule] Drop event triggered.');

    const previousArray = event.previousContainer.data;
    const currentArray = event.container.data;

    if (!Array.isArray(previousArray) || !Array.isArray(currentArray)) {
      console.error('[ShootingSchedule] Drop Error: CDK container data is not an array.', {p: previousArray, c: currentArray}); return;
    }
    if (previousArray.length > 0 && (event.previousIndex >= previousArray.length || event.previousIndex < 0) ) {
      console.error('[ShootingSchedule] Drop Error: previousIndex out of bounds.', { idx: event.previousIndex, len: previousArray.length }); return;
    }
    if (previousArray.length > 0 && !event.item.data) {
        console.error('[ShootingSchedule] Drop Error: event.item.data is undefined. Ensure [cdkDragData] is set.'); return;
    }

    this.isUpdatingSchedule = true;

    if (event.previousContainer === event.container) {
      moveItemInArray(currentArray, event.previousIndex, event.currentIndex);
    } else {
      transferArrayItem(previousArray, currentArray, event.previousIndex, event.currentIndex);
    }

    // Force new array references for the top-level arrays AFTER CDK has modified them.
    this.availableScenes = [...(this.availableScenes || [])];
    this.shootingDays = (this.shootingDays || []).map(day => this.ensureDayIntegrity(day)); // Use helper

    this.persistDropChanges(event.previousContainer.id, event.container.id);
  }

  private persistDropChanges(fromListId: string, toListId: string): void {
    const affectedDayIds = new Set<number>();
    if (fromListId.startsWith('dayList-')) affectedDayIds.add(parseInt(fromListId.split('-')[1], 10));
    if (toListId.startsWith('dayList-')) affectedDayIds.add(parseInt(toListId.split('-')[1], 10));

    if (affectedDayIds.size === 0) {
      this.isUpdatingSchedule = false;
      console.log('[ShootingSchedule] persistDropChanges: No shooting days affected by drop, calling updateAvailableScenesList for local UI sync.');
      this.updateAvailableScenesList();
      return;
    }
    let updatesPending = affectedDayIds.size;
    affectedDayIds.forEach(dayId => {
      const dayToUpdate = this.shootingDays.find(d => d.id === dayId);
      if (dayToUpdate?.id != null) {
        const payload: Partial<ShootingDay> = {
            ...dayToUpdate,
            scheduledScenes: (dayToUpdate.scheduledScenes || []).map(s => s ? ({ ...s, characters: Array.isArray(s.characters) ? s.characters : [] }) : null).filter(s => s !== null) as Scene[]
        };
        const sub = this.shootingScheduleService.updateShootingDay(dayToUpdate.id, payload as ShootingDay).subscribe({
          next: (updatedDayFromServer) => this.handleScheduleUpdateSuccess(updatedDayFromServer, `Schedule updated for day ID ${dayId}`, --updatesPending === 0),
          error: (err: HttpErrorResponse) => this.handleScheduleUpdateError(err, `updating day ID ${dayId}`, --updatesPending === 0)
        });
        this.subscriptions.push(sub);
      } else {
          updatesPending--;
           if (updatesPending === 0) { this.isUpdatingSchedule = false; this.updateAvailableScenesList(); }
      }
    });
  }

  private handleScheduleUpdateSuccess(updatedDayFromServer: ShootingDay, message: string, isLastUpdate: boolean = true): void {
    console.log(`[ShootingSchedule] handleScheduleUpdateSuccess: ${message}. Data from server:`, JSON.parse(JSON.stringify(updatedDayFromServer)));
    
    const safeUpdatedDay = this.ensureDayIntegrity(updatedDayFromServer); // Ensure data from server is also safe

    const index = this.shootingDays.findIndex(d => d.id === safeUpdatedDay.id);
    if (index > -1) {
        const newShootingDaysArray = [...this.shootingDays];
        newShootingDaysArray[index] = safeUpdatedDay;
        this.shootingDays = newShootingDaysArray.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
    } else {
        this.shootingDays = [...this.shootingDays, safeUpdatedDay].sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
    }

    console.log('[ShootingSchedule] handleScheduleUpdateSuccess: this.shootingDays after update:', JSON.parse(JSON.stringify(this.shootingDays)));

    if (isLastUpdate) {
        console.log('[ShootingSchedule] handleScheduleUpdateSuccess: isLastUpdate is true. Calling updateAvailableScenesList.');
        this.updateAvailableScenesList(); // This should now use the fully sanitized this.shootingDays
        this.isUpdatingSchedule = false;
    }
  }

  private handleScheduleUpdateError(error: any, action: string, isLastUpdate: boolean = true): void {
    console.error(`Error ${action}:`, error);
    if (isLastUpdate) {
        this.isUpdatingSchedule = false;
        alert(`Failed to update schedule while ${action}. Data might be out of sync. Please try refreshing the page.`);
        this.loadShootingDays();
        this.loadAllProjectScenes();
    }
  }

  addShootingDay(): void {
    if (this.newShootingDayForm.invalid) { this.newShootingDayForm.markAllAsTouched(); return; }
    const newDay: ShootingDay = this.ensureDayIntegrity({ // Use helper for new day too
        projectId: this.projectId, date: this.newShootingDayForm.value.date,
        isNight: this.newShootingDayForm.value.isNight, notes: this.newShootingDayForm.value.notes,
        scheduledScenes: [], allocatedResources: [], hasConflicts: false
    });
    this.isLoadingShootingDays = true;
    const sub = this.shootingScheduleService.createShootingDay(newDay).subscribe({
      next: created => {
        this.shootingDays = [...this.shootingDays, this.ensureDayIntegrity(created)];
        this.shootingDays.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
        this.newShootingDayForm.reset({ isNight: false, notes: '' });
        this.tryUpdateAvailableScenes();
        this.isLoadingShootingDays = false;
      },
      error: err => { console.error('Error adding day:', err); this.isLoadingShootingDays = false; }
    });
    this.subscriptions.push(sub);
  }

  deleteShootingDay(dayId?: number): void {
    if (dayId == null) return;
    if (!confirm('Are you sure you want to delete this shooting day?')) return;
    this.isLoadingShootingDays = true;
    const sub = this.shootingScheduleService.deleteShootingDay(dayId).subscribe({
      next: () => {
        this.shootingDays = this.shootingDays.filter(d => d.id !== dayId);
        this.tryUpdateAvailableScenes();
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
