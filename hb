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
  // ALWAYS initialize arrays
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
    this.loadAllProjectScenes(); // This populates this.allProjectScenes
    this.loadShootingDays();    // This populates this.shootingDays and calls tryUpdatingAvailableScenes
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
          ...scene,
          characters: Array.isArray(scene.characters) ? scene.characters : []
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
        this.shootingDays = (days || []).map(day => ({
          ...day,
          // CRITICAL: Ensure scheduledScenes is ALWAYS an array on each day object
          scheduledScenes: Array.isArray(day.scheduledScenes) ? day.scheduledScenes.map(s => ({...s, characters: Array.isArray(s.characters) ? s.characters : []})) : [],
          allocatedResources: Array.isArray(day.allocatedResources) ? day.allocatedResources : []
        })).sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
        this.isLoadingShootingDays = false;
        this.tryUpdateAvailableScenes();
      },
      error: err => { console.error('[ShootingSchedule] Error loading shooting days:', err); this.isLoadingShootingDays = false; }
    });
    this.subscriptions.push(sub);
  }

  tryUpdateAvailableScenes(): void {
    if (!this.isOverallLoading) { // Use the getter
      this.updateAvailableScenesList();
    }
  }

  updateAvailableScenesList(): void {
    console.log('[ShootingSchedule] updateAvailableScenesList - START');
    // Ensure all primary arrays are at least empty arrays before proceeding
    const allScenesCurrent = Array.isArray(this.allProjectScenes) ? this.allProjectScenes : [];
    const shootingDaysCurrent = Array.isArray(this.shootingDays) ? this.shootingDays : [];

    console.log('[ShootingSchedule] Current allProjectScenes (in update):', JSON.parse(JSON.stringify(allScenesCurrent)));
    console.log('[ShootingSchedule] Current shootingDays (in update):', JSON.parse(JSON.stringify(shootingDaysCurrent)));

    const scheduledIds = new Set<number>();
    shootingDaysCurrent.forEach((day, dayIndex) => {
      if (!day) {
        console.warn(`[ShootingSchedule] Day at index ${dayIndex} is undefined/null in shootingDays.`);
        return; // continue to next day
      }
      // Ensure day.scheduledScenes is an array before iterating
      const scenesOnDay = Array.isArray(day.scheduledScenes) ? day.scheduledScenes : [];
      if (!Array.isArray(day.scheduledScenes)) {
          console.warn(`[ShootingSchedule] Day ID ${day.id || 'N/A'} had non-array scheduledScenes. Corrected to empty. Was:`, day.scheduledScenes);
      }

      scenesOnDay.forEach((scene, sceneIndex) => {
        if (!scene) {
          console.warn(`[ShootingSchedule] Scene at index ${sceneIndex} in Day ID ${day.id || 'N/A'} is undefined/null.`);
          return; // continue to next scene
        }
        if (scene.id != null) {
          scheduledIds.add(scene.id);
        } else {
          console.warn(`[ShootingSchedule] Scene at index ${sceneIndex} in Day ID ${day.id || 'N/A'} has undefined/null ID.`);
        }
      });
    });
    console.log('[ShootingSchedule] Calculated scheduledSceneIds:', scheduledIds);

    // Ensure allProjectScenes itself is an array and filter out null/undefined scenes before accessing scene.id
    this.availableScenes = allScenesCurrent
      .filter(scene => {
        if (!scene) {
          console.warn('[ShootingSchedule] Undefined/null scene found in allProjectScenes during filter.');
          return false;
        }
        return scene.id != null && !scheduledIds.has(scene.id);
      })
      .sort((a, b) => a.sceneNumber - b.sceneNumber);

    this.cdr.detectChanges(); // Manually trigger change detection
    console.log('[ShootingSchedule] Available scenes updated, count:', this.availableScenes.length);
  }

  getAllDropListIds(): string[] {
    return [
      'availableScenesList',
      ...((this.shootingDays || []).filter(day => day && day.id != null).map(day => 'dayList-' + day.id))
    ];
  }

  drop(event: CdkDragDrop<Scene[]>): void {
    if (this.isUpdatingSchedule) {
      console.log('[ShootingSchedule] Drop ignored, update already in progress.');
      return;
    }
    console.log('[ShootingSchedule] Drop event triggered.');

    // Use the actual bound arrays directly, assuming they are always arrays
    const previousArray = event.previousContainer.data;
    const currentArray = event.container.data;

    if (!Array.isArray(previousArray) || !Array.isArray(currentArray)) {
      console.error('[ShootingSchedule] Drop Error: CDK container data is not an array. Bailing out.', {
          prev: previousArray,
          curr: currentArray
      });
      return; // Critical error, cannot proceed
    }
     if (previousArray.length > 0 && (event.previousIndex >= previousArray.length || event.previousIndex < 0) ) {
      console.error('[ShootingSchedule] Drop Error: previousIndex out of bounds.', { index: event.previousIndex, length: previousArray.length });
      return; // Bail out
    }
    if (previousArray.length > 0 && !event.item.data) {
         // event.item.data is the [cdkDragData]
        console.error('[ShootingSchedule] Drop Error: event.item.data is undefined. Ensure [cdkDragData] is set.');
        return;
    }

    this.isUpdatingSchedule = true;

    if (event.previousContainer === event.container) {
      moveItemInArray(currentArray, event.previousIndex, event.currentIndex);
      // event.container.data is now the updated local array (e.g., this.availableScenes or day.scheduledScenes)
    } else {
      transferArrayItem(
        previousArray,
        currentArray,
        event.previousIndex,
        event.currentIndex
      );
    }
    // After CDK manipulates the arrays that are directly bound to [cdkDropListData],
    // these arrays (this.availableScenes or a specific day.scheduledScenes) are changed.
    // We need to ensure these changes are reflected in a way Angular detects for other bindings if necessary,
    // and then persist.

    // Create new references for the top-level arrays to help change detection if their contents changed.
    this.availableScenes = [...(this.availableScenes || [])];
    this.shootingDays = (this.shootingDays || []).map(day => ({
        ...day,
        scheduledScenes: Array.isArray(day.scheduledScenes) ? [...day.scheduledScenes] : []
    }));


    // Now, call persist and then update the available list.
    // The error was at the call to updateAvailableScenesList, so let's see if the above helps.
    this.persistDropChanges(event.previousContainer.id, event.container.id);
    // updateAvailableScenesList will be called from persistDropChanges success/error handlers
    // or if no backend update is needed by persistDropChanges.
  }


  private persistDropChanges(fromListId: string, toListId: string): void {
    const affectedDayIds = new Set<number>();
    if (fromListId.startsWith('dayList-')) affectedDayIds.add(parseInt(fromListId.split('-')[1], 10));
    if (toListId.startsWith('dayList-')) affectedDayIds.add(parseInt(toListId.split('-')[1], 10));

    if (affectedDayIds.size === 0) {
      this.isUpdatingSchedule = false;
      this.updateAvailableScenesList(); // Only local change (e.g., reorder availableScenes)
      return;
    }
    let updatesPending = affectedDayIds.size;
    console.log(`[ShootingSchedule] Persisting changes for ${updatesPending} day(s).`);

    affectedDayIds.forEach(dayId => {
      const dayToUpdate = this.shootingDays.find(d => d.id === dayId); // Get from the latest this.shootingDays
      if (dayToUpdate?.id != null) { // Ensure dayToUpdate and its id are valid
        const payload: Partial<ShootingDay> = {
            ...dayToUpdate,
            // Ensure scheduledScenes contains only necessary data for backend (e.g., array of Scene DTOs with just IDs)
            // For now, sending the full scene objects as they are in the local array.
            scheduledScenes: (dayToUpdate.scheduledScenes || []).map(s => ({ ...s }))
        };
        const sub = this.shootingScheduleService.updateShootingDay(dayToUpdate.id, payload as ShootingDay).subscribe({
          next: (updatedDayFromServer) => {
            console.log(`[ShootingSchedule] Successfully updated day ID ${dayId}`, updatedDayFromServer);
            this.handleScheduleUpdateSuccess(updatedDayFromServer, `Schedule updated for day ID ${dayId}`, --updatesPending === 0);
          },
          error: (err: HttpErrorResponse) => {
            console.error(`[ShootingSchedule] Error updating shooting day ID ${dayId}:`, err);
            this.handleScheduleUpdateError(err, `updating day ID ${dayId}`, --updatesPending === 0);
          }
        });
        this.subscriptions.push(sub);
      } else {
          updatesPending--;
           if (updatesPending === 0) { this.isUpdatingSchedule = false; this.updateAvailableScenesList(); }
      }
    });
  }

  private handleScheduleUpdateSuccess(updatedDay: ShootingDay, message: string, isLastUpdate: boolean = true): void {
    console.log(message, JSON.parse(JSON.stringify(updatedDay)));
    const index = this.shootingDays.findIndex(d => d.id === updatedDay.id);
    if (index > -1) {
        // Ensure the updatedDay from server also has its arrays initialized
        const dayWithEnsuredArrays = {
            ...updatedDay,
            scheduledScenes: Array.isArray(updatedDay.scheduledScenes) ? updatedDay.scheduledScenes.map(s => ({...s, characters: Array.isArray(s.characters) ? s.characters : []})) : [],
            allocatedResources: Array.isArray(updatedDay.allocatedResources) ? updatedDay.allocatedResources : []
        };
        const newShootingDaysArray = [...this.shootingDays];
        newShootingDaysArray[index] = dayWithEnsuredArrays;
        this.shootingDays = newShootingDaysArray.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
    } else {
        // If day wasn't found (e.g., it's a new day that got an ID from backend during an update somehow, unlikely)
        // Or if it's a response from creating a day (though this handler is for updates)
        this.shootingDays = [...this.shootingDays, {
            ...updatedDay,
            scheduledScenes: Array.isArray(updatedDay.scheduledScenes) ? updatedDay.scheduledScenes.map(s => ({...s, characters: Array.isArray(s.characters) ? s.characters : []})) : [],
            allocatedResources: Array.isArray(updatedDay.allocatedResources) ? updatedDay.allocatedResources : []
        }].sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
    }

    // CRITICAL: Call updateAvailableScenesList only AFTER all backend updates are done
    // and the local this.shootingDays array is fully consistent with the server.
    if (isLastUpdate) {
        this.updateAvailableScenesList();
        this.isUpdatingSchedule = false;
    }
  }

  private handleScheduleUpdateError(error: any, action: string, isLastUpdate: boolean = true): void {
    console.error(`Error ${action}:`, error);
    if (isLastUpdate) {
        this.isUpdatingSchedule = false;
        alert(`Failed to update schedule while ${action}. Data might be out of sync. Please try refreshing the page.`);
        // Force a full reload from server to get consistent state on error
        this.loadShootingDays();
        this.loadAllProjectScenes();
    }
  }

  addShootingDay(): void { /* ... same as previous ... */ 
    if (this.newShootingDayForm.invalid) { this.newShootingDayForm.markAllAsTouched(); return; }
    const newDay: ShootingDay = { projectId: this.projectId, date: this.newShootingDayForm.value.date, isNight: this.newShootingDayForm.value.isNight, notes: this.newShootingDayForm.value.notes, scheduledScenes: [], allocatedResources: [], hasConflicts: false };
    this.isLoadingShootingDays = true;
    const sub = this.shootingScheduleService.createShootingDay(newDay).subscribe({
      next: created => {
        this.shootingDays = [...this.shootingDays, {...created, scheduledScenes: [], allocatedResources: []}];
        this.shootingDays.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
        this.newShootingDayForm.reset({ isNight: false, notes: '' });
        this.tryUpdateAvailableScenes();
        this.isLoadingShootingDays = false;
      },
      error: err => { console.error('Error adding day:', err); this.isLoadingShootingDays = false; }
    });
    this.subscriptions.push(sub);
  }

  deleteShootingDay(dayId?: number): void { /* ... same as previous ... */ 
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

