import { Component, OnInit, OnDestroy, ChangeDetectorRef } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ActivatedRoute } from '@angular/router';
import { Subscription } from 'rxjs';
import { CdkDragDrop, moveItemInArray, transferArrayItem } from '@angular/cdk/drag-drop';
import { ShootingScheduleService } from '../../services/shooting-schedule.service';
import { ProjectService } from '../../services/project.service';
import { Scene } from '../../models/scene.model';
import { ShootingDay } from '../../models/shooting-day.model';
import { MovieProject } from '../../models/movie-project.model';

@Component({
  selector: 'app-shooting-schedule',
  templateUrl: './shooting-schedule.component.html',
  styleUrls: ['./shooting-schedule.component.css']
})
export class ShootingScheduleComponent implements OnInit, OnDestroy {
  projectId!: number;
  project?: MovieProject;
  allProjectScenes: Scene[] = [];
  availableScenes: Scene[] = [];
  shootingDays: ShootingDay[] = [];
  newShootingDayForm!: FormGroup;

  isLoadingProject = true;
  isLoadingShootingDays = true;
  isLoadingAllScenes = true;
  isUpdatingSchedule = false;

  private subscriptions: Subscription[] = [];

  constructor(
    private route: ActivatedRoute,
    private fb: FormBuilder,
    private shootingScheduleService: ShootingScheduleService,
    private projectService: ProjectService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    this.route.paramMap.subscribe(params => {
      const idParam = params.get('projectId');
      if (idParam) {
        this.projectId = +idParam;
        this.loadInitialData();
      }
    });

    this.newShootingDayForm = this.fb.group({
      date: ['', Validators.required],
      isNight: [false],
      notes: ['']
    });
  }

  loadInitialData(): void {
    this.loadProjectDetails();
    this.loadAllScenes();
    this.loadShootingDays();
  }

  loadProjectDetails(): void {
    const sub = this.projectService.getProjectById(this.projectId).subscribe({
      next: project => {
        this.project = project;
        this.isLoadingProject = false;
        this.tryUpdateAvailableScenes();
      },
      error: () => { this.isLoadingProject = false; }
    });
    this.subscriptions.push(sub);
  }

  loadAllScenes(): void {
    const sub = this.shootingScheduleService.getScenesByProjectId(this.projectId).subscribe({
      next: scenes => {
        this.allProjectScenes = scenes || [];
        this.isLoadingAllScenes = false;
        this.tryUpdateAvailableScenes();
      },
      error: () => { this.isLoadingAllScenes = false; }
    });
    this.subscriptions.push(sub);
  }

  loadShootingDays(): void {
    const sub = this.shootingScheduleService.getShootingDaysByProjectId(this.projectId).subscribe({
      next: days => {
        this.shootingDays = days || [];
        this.isLoadingShootingDays = false;
        this.tryUpdateAvailableScenes();
      },
      error: () => { this.isLoadingShootingDays = false; }
    });
    this.subscriptions.push(sub);
  }

  tryUpdateAvailableScenes(): void {
    if (!this.isLoadingProject && !this.isLoadingAllScenes && !this.isLoadingShootingDays) {
      const scheduledIds = new Set<number>();
      this.shootingDays.forEach(day => {
        (day.scheduledScenes || []).forEach(scene => {
          if (scene.id != null) scheduledIds.add(scene.id);
        });
      });
      this.availableScenes = this.allProjectScenes.filter(scene => !scheduledIds.has(scene.id!));
      this.cdr.detectChanges();
    }
  }

  getAllDropListIds(): string[] {
    return ['availableScenesList', ...this.shootingDays.map(day => `dayList-${day.id}`)];
  }

  drop(event: CdkDragDrop<Scene[]>): void {
    if (this.isUpdatingSchedule) return;

    const from = event.previousContainer.data;
    const to = event.container.data;

    if (event.previousContainer === event.container) {
      moveItemInArray(to, event.previousIndex, event.currentIndex);
    } else {
      transferArrayItem(from, to, event.previousIndex, event.currentIndex);
    }

    this.tryUpdateAvailableScenes();
  }

  addShootingDay(): void {
    if (this.newShootingDayForm.invalid) return;
    const day: ShootingDay = {
      projectId: this.projectId,
      date: this.newShootingDayForm.value.date,
      isNight: this.newShootingDayForm.value.isNight,
      notes: this.newShootingDayForm.value.notes,
      scheduledScenes: [],
      allocatedResources: [],
      hasConflicts: false
    };
    const sub = this.shootingScheduleService.createShootingDay(day).subscribe({
      next: created => {
        this.shootingDays.push(created);
        this.newShootingDayForm.reset({ isNight: false });
        this.tryUpdateAvailableScenes();
      }
    });
    this.subscriptions.push(sub);
  }

  deleteShootingDay(id?: number): void {
    if (!id) return;
    const sub = this.shootingScheduleService.deleteShootingDay(id).subscribe({
      next: () => {
        this.shootingDays = this.shootingDays.filter(day => day.id !== id);
        this.tryUpdateAvailableScenes();
      }
    });
    this.subscriptions.push(sub);
  }

  get dayFormControl() {
    return this.newShootingDayForm.controls;
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(s => s.unsubscribe());
  }
}
