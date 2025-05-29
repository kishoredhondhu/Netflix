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
  isLoadingProject: boolean = true;
  isLoadingShootingDays: boolean = true;
  isLoadingAllScenes: boolean = true;
  isUpdatingSchedule: boolean = false;

  get isOverallLoading(): boolean {
    return this.isLoadingProject || this.isLoadingAllScenes || this.isLoadingShootingDays;
  }

  private routeSub?: Subscription;
  private projectSub?: Subscription;
  private shootingDaysSub?: Subscription;
  private scenesSub?: Subscription;

  constructor(
    private route: ActivatedRoute,
    private fb: FormBuilder,
    private shootingScheduleService: ShootingScheduleService,
    private projectService: ProjectService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    console.log('[ShootingSchedule] ngOnInit - Initializing...');
    this.routeSub = this.route.paramMap.subscribe(params => {
      const idParam = params.get('projectId');
      if (idParam) {
        this.projectId = +idParam;
        this.loadProjectDetails();
        this.loadAllProjectScenes();
        this.loadShootingDays();
      } else {
        console.error('[ShootingSchedule] Project ID not found in route!');
        this.isLoadingProject = this.isLoadingShootingDays = this.isLoadingAllScenes = false;
      }
    });

    this.newShootingDayForm = this.fb.group({
      date: ['', Validators.required],
      isNight: [false, Validators.required],
      notes: ['']
    });
  }

  loadProjectDetails(): void {
    this.isLoadingProject = true;
    this.projectSub = this.projectService.getProjectById(this.projectId).subscribe({
        next: (project) => { this.project = project; this.isLoadingProject = false; this.tryUpdatingAvailableScenes(); },
        error: (err) => { console.error('[ShootingSchedule] Error loading project details:', err); this.isLoadingProject = false; }
    });
  }

  loadAllProjectScenes(): void {
    this.isLoadingAllScenes = true;
    this.scenesSub = this.shootingScheduleService.getScenesByProjectId(this.projectId).subscribe({
        next: (allScenes) => {
            this.allProjectScenes = (allScenes || []).map(scene => ({
                ...scene,
                characters: Array.isArray(scene.characters) ? scene.characters : [] // Ensure characters is array
            })).sort((a,b) => a.sceneNumber - b.sceneNumber);
            this.isLoadingAllScenes = false;
            this.tryUpdatingAvailableScenes();
        },
        error: (err) => { console.error('[ShootingSchedule] Error loading all project scenes:', err); this.isLoadingAllScenes = false; }
    });
  }

  loadShootingDays(): void {
    this.isLoadingShootingDays = true;
    this.shootingDaysSub = this.shootingScheduleService.getShootingDaysByProjectId(this.projectId).subscribe({
        next: (days) => {
            this.shootingDays = (days || []).map(day => ({
                 ...day,
                 scheduledScenes: Array.isArray(day.scheduledScenes) ? day.scheduledScenes : [],
                 allocatedResources: Array.isArray(day.allocatedResources) ? day.allocatedResources : [] // Ensure allocatedResources is array
            })).sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
            this.isLoadingShootingDays = false;
            this.tryUpdatingAvailableScenes();
        },
        error: (err) => { console.error('[ShootingSchedule] Error loading shooting days:', err); this.isLoadingShootingDays = false; }
    });
  }

  tryUpdatingAvailableScenes(): void {
    if (!this.isLoadingAllScenes && !this.isLoadingShootingDays && !this.isLoadingProject) {
        this.updateAvailableScenesList();
    }
  }

  updateAvailableScenesList(): void {
    console.log('[ShootingSchedule] updateAvailableScenesList - START');
    const currentAllProjectScenes = this.allProjectScenes || [];
    const currentShootingDays = this.shootingDays || [];

    const scheduledSceneIds = new Set<number>();
    currentShootingDays.forEach(day => {
      const scenesOnDay = day.scheduledScenes || [];
      scenesOnDay.forEach(scene => {
        if (scene && scene.id !== undefined) {
          scheduledSceneIds.add(scene.id);
        }
      });
    });

    const filteredScenes = currentAllProjectScenes.filter(scene =>
      scene && scene.id !== undefined && !scheduledSceneIds.has(scene.id)
    );
    this.availableScenes = [...filteredScenes.sort((a, b) => a.sceneNumber - b.sceneNumber)];
    console.log('[ShootingSchedule] updateAvailableScenesList - END. Available Scenes count:', this.availableScenes.length);
    this.cdr.detectChanges();
  }

  addShootingDay(): void {
    if (this.newShootingDayForm.invalid) { this.newShootingDayForm.markAllAsTouched(); return; }
    const newDayData: ShootingDay = {
        projectId: this.projectId,
        date: this.newShootingDayForm.value.date,
        isNight: this.newShootingDayForm.value.isNight,
        notes: this.newShootingDayForm.value.notes,
        scheduledScenes: [], // Initialized as empty array
        allocatedResources: [], // Initialized as empty array
        hasConflicts: false
    };
    this.isLoadingShootingDays = true;
    this.shootingScheduleService.createShootingDay(newDayData).subscribe({
        next: (createdDay) => {
            this.shootingDays = [...this.shootingDays, {
                ...createdDay,
                scheduledScenes: Array.isArray(createdDay.scheduledScenes) ? createdDay.scheduledScenes : [],
                allocatedResources: Array.isArray(createdDay.allocatedResources) ? createdDay.allocatedResources : []
            }].sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
            this.newShootingDayForm.reset({ isNight: false, notes: '' });
            this.tryUpdatingAvailableScenes();
            this.isLoadingShootingDays = false;
        },
        error: (err) => { console.error('[ShootingSchedule] Error adding shooting day:', err); this.isLoadingShootingDays = false; }
    });
  }

  deleteShootingDay(dayId: number | undefined): void {
    if (dayId === undefined) { console.error("Cannot delete shooting day: ID is undefined."); return; }
    if (confirm('Are you sure you want to delete this shooting day? This will unschedule its scenes.')) {
        this.isLoadingShootingDays = true;
        this.shootingScheduleService.deleteShootingDay(dayId).subscribe({
            next: () => {
                this.shootingDays = this.shootingDays.filter(d => d.id !== dayId);
                this.tryUpdatingAvailableScenes();
                this.isLoadingShootingDays = false;
            },
            error: (err) => { console.error(`[ShootingSchedule] Error deleting shooting day ${dayId}:`, err); this.isLoadingShootingDays = false; }
        });
    }
  }

  getAllDropListIds(): string[] {
    const dayListIds = (this.shootingDays || [])
        .filter(day => day && day.id !== undefined)
        .map(day => 'dayList-' + day.id);
    return ['availableScenesList', ...dayListIds];
  }

  drop(event: CdkDragDrop<Scene[]>): void {
    console.log('[ShootingSchedule] Drop event triggered.');
    const previousContainerData = event.previousContainer.data;
    const containerData = event.container.data;

    if (!Array.isArray(previousContainerData) || !Array.isArray(containerData)) {
        console.error('[ShootingSchedule] Drop Error: container data is not an array.');
        return;
    }
    if (previousContainerData.length > 0 && event.previousIndex >= previousContainerData.length) {
        console.error('[ShootingSchedule] Drop Error: previousIndex out of bounds.');
        return;
    }
    if (previousContainerData.length > 0 && !event.item.data) { // Check item.data if source wasn't empty
        console.error('[ShootingSchedule] Drop Error: event.item.data is undefined.');
        return;
    }

    this.isUpdatingSchedule = true;

    if (event.previousContainer === event.container) {
      moveItemInArray(containerData, event.previousIndex, event.currentIndex);
      this.updateLocalArrayData(event.container.id, containerData);
      
      const listId = event.container.id;
      if (listId.startsWith('dayList-')) {
        const dayId = parseInt(listId.split('-')[1], 10);
        const dayToUpdate = this.shootingDays.find(d => d.id === dayId);
        if (dayToUpdate && dayToUpdate.id !== undefined) {
          this.shootingScheduleService.updateShootingDay(dayToUpdate.id, { ...dayToUpdate, scheduledScenes: [...dayToUpdate.scheduledScenes] }).subscribe({
            next: updatedDay => this.handleScheduleUpdateSuccess(updatedDay, "Scene order updated"),
            error: err => this.handleScheduleUpdateError(err, `reordering scenes for day ${dayId}`)
          });
        } else { this.isUpdatingSchedule = false; }
      } else {
        this.isUpdatingSchedule = false;
      }
    } else {
      transferArrayItem(
        previousContainerData,
        containerData,
        event.previousIndex,
        event.currentIndex
      );
      this.updateLocalArrayData(event.previousContainer.id, previousContainerData);
      this.updateLocalArrayData(event.container.id, containerData);

      const daysToUpdate: ShootingDay[] = [];
      if (event.previousContainer.id.startsWith('dayList-')) {
        const sourceDayId = parseInt(event.previousContainer.id.split('-')[1], 10);
        const sourceDay = this.shootingDays.find(d => d.id === sourceDayId);
        if (sourceDay) daysToUpdate.push({...sourceDay, scheduledScenes: [...sourceDay.scheduledScenes]});
      }
      if (event.container.id.startsWith('dayList-')) {
        const targetDayId = parseInt(event.container.id.split('-')[1], 10);
        const targetDay = this.shootingDays.find(d => d.id === targetDayId);
        if (targetDay && !daysToUpdate.find(d => d.id === targetDay.id)) {
            daysToUpdate.push({...targetDay, scheduledScenes: [...targetDay.scheduledScenes]});
        }
      }

      if (daysToUpdate.length > 0) {
        daysToUpdate.forEach((dayToUpdate, index) => {
          if (dayToUpdate.id !== undefined) {
            this.shootingScheduleService.updateShootingDay(dayToUpdate.id, dayToUpdate).subscribe({
              next: updatedDay => this.handleScheduleUpdateSuccess(updatedDay, `Schedule updated for day ${updatedDay.date}`, (index === daysToUpdate.length - 1)),
              error: err => this.handleScheduleUpdateError(err, `updating day ${dayToUpdate.date}`)
            });
          }
        });
      } else {
        this.isUpdatingSchedule = false;
      }
    }
    this.updateAvailableScenesList();
  }

  private updateLocalArrayData(listId: string, newArrayData: Scene[]): void {
    if (listId === 'availableScenesList') {
      this.availableScenes = [...newArrayData];
    } else if (listId.startsWith('dayList-')) {
      const dayId = parseInt(listId.split('-')[1], 10);
      const dayIndex = this.shootingDays.findIndex(d => d.id === dayId);
      if (dayIndex > -1 && this.shootingDays[dayIndex]) {
        const updatedDay = { ...this.shootingDays[dayIndex], scheduledScenes: [...newArrayData] };
        this.shootingDays = [ ...this.shootingDays.slice(0, dayIndex), updatedDay, ...this.shootingDays.slice(dayIndex + 1) ];
      }
    }
  }

  private handleScheduleUpdateSuccess(updatedDay: ShootingDay, message: string, isLastUpdate: boolean = true): void {
    console.log(message, updatedDay);
    const index = this.shootingDays.findIndex(d => d.id === updatedDay.id);
    if (index > -1) {
        this.shootingDays[index] = {...updatedDay, scheduledScenes: Array.isArray(updatedDay.scheduledScenes) ? updatedDay.scheduledScenes : [], allocatedResources: Array.isArray(updatedDay.allocatedResources) ? updatedDay.allocatedResources : []};
        this.shootingDays = [...this.shootingDays].sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
    }
    this.updateAvailableScenesList();
    if (isLastUpdate) { this.isUpdatingSchedule = false; }
  }

  private handleScheduleUpdateError(error: any, action: string): void {
    console.error(`Error ${action}:`, error);
    this.isUpdatingSchedule = false;
    alert(`Failed to update schedule while ${action}. Data might be out of sync. Please try refreshing the page or redoing the last action.`);
  }

  ngOnDestroy(): void {
    this.routeSub?.unsubscribe();
    this.projectSub?.unsubscribe();
    this.shootingDaysSub?.unsubscribe();
    this.scenesSub?.unsubscribe();
  }

  get dayFormControl() {
    return this.newShootingDayForm.controls;
  }
}
