import { Component, OnInit, OnDestroy, ChangeDetectorRef } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { CdkDragDrop, moveItemInArray, transferArrayItem } from '@angular/cdk/drag-drop';
import { Subscription, forkJoin, of } from 'rxjs';
import { catchError, finalize } from 'rxjs/operators';

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
  shootingDays: ShootingDay[] = [];
  availableScenes: Scene[] = [];

  newShootingDayForm!: FormGroup;
  isLoading = true;
  isUpdatingSchedule = false;

  private subs: Subscription[] = [];

  constructor(
    private route: ActivatedRoute,
    private fb: FormBuilder,
    private projectSvc: ProjectService,
    private scheduleSvc: ShootingScheduleService,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit(): void {
    // build form
    this.newShootingDayForm = this.fb.group({
      date: ['', Validators.required],
      isNight: [false],
      notes: ['']
    });

    // read projectId & load all data
    const routeSub = this.route.paramMap.subscribe(m => {
      const id = m.get('projectId');
      if (!id) return this.finishLoading();
      this.projectId = +id;
      this.loadInitialData();
    });
    this.subs.push(routeSub);
  }

  private loadInitialData(): void {
    this.isLoading = true;

    const project$ = this.projectSvc.getProjectById(this.projectId).pipe(
      catchError(() => of(undefined))
    );
    const scenes$ = this.scheduleSvc.getScenesByProjectId(this.projectId).pipe(
      catchError(() => of([] as Scene[]))
    );
    const days$ = this.scheduleSvc.getShootingDaysByProjectId(this.projectId).pipe(
      catchError(() => of([] as ShootingDay[]))
    );

    const initSub = forkJoin([project$, scenes$, days$]).pipe(
      finalize(() => {
        this.isLoading = false;
        this.updateAvailableScenes();
        this.cdr.detectChanges();
      })
    )
    .subscribe(([proj, scenes, days]) => {
      this.project = proj;
      this.allProjectScenes = (scenes || []).sort((a, b) => a.sceneNumber - b.sceneNumber);
      this.shootingDays = (days || []).sort((a, b) => 
        new Date(a.date).getTime() - new Date(b.date).getTime()
      );
    });

    this.subs.push(initSub);
  }

  /** Recalculate which scenes remain unscheduled */
  private updateAvailableScenes(): void {
    const scheduledIds = new Set<number>();
    this.shootingDays.forEach(d =>
      (d.scheduledScenes || []).forEach(s => s.id != null && scheduledIds.add(s.id!))
    );
    this.availableScenes = this.allProjectScenes
      .filter(s => s.id != null && !scheduledIds.has(s.id!));
  }

  /** Handler for CDK drag-drop events */
  drop(event: CdkDragDrop<Scene[]>): void {
    if (this.isUpdatingSchedule) return;

    const fromData = event.previousContainer.data;
    const toData   = event.container.data;

    // rearrange within same list
    if (event.previousContainer === event.container) {
      moveItemInArray(toData, event.previousIndex, event.currentIndex);
      this.persistDayUpdates(this.extractDayId(event.container.id));
    }
    // transfer between lists
    else {
      transferArrayItem(fromData, toData, event.previousIndex, event.currentIndex);
      this.persistDayUpdates(
        this.extractDayId(event.previousContainer.id),
        this.extractDayId(event.container.id)
      );
    }
    this.updateAvailableScenes();
  }

  /** Extract numeric ID from listId like 'dayList-12' */
  private extractDayId(listId: string): number | null {
    const parts = listId.split('-');
    return parts[0] === 'dayList' ? +parts[1] : null;
  }

  /**
   * Persist one or more ShootingDay updates back to the server
   * @param dayIds one or two dayIds indicating which days changed
   */
  private persistDayUpdates(...dayIds: (number|null)[]): void {
    const validIds = dayIds.filter(id => id != null) as number[];
    if (!validIds.length) return;

    this.isUpdatingSchedule = true;
    let remaining = validIds.length;

    validIds.forEach(id => {
      const day = this.shootingDays.find(d => d.id === id);
      if (!day) { remaining--; return; }

      const sub = this.scheduleSvc.updateShootingDay(id, day).pipe(
        catchError(err => {
          console.error(`Failed updating day ${id}:`, err);
          return of(null);
        }),
        finalize(() => {
          if (--remaining === 0) {
            this.isUpdatingSchedule = false;
            this.loadInitialData(); // reload fresh data
          }
        })
      )
      .subscribe();
      this.subs.push(sub);
    });
  }

  /** Create a new shooting day */
  addShootingDay(): void {
    if (this.newShootingDayForm.invalid || this.isLoading) return;

    const { date, isNight, notes } = this.newShootingDayForm.value;
    const newDay: ShootingDay = {
      projectId: this.projectId,
      date,
      isNight,
      notes,
      scheduledScenes: [],
      allocatedResources: [],
      hasConflicts: false
    };

    this.isLoading = true;
    const sub = this.scheduleSvc.createShootingDay(newDay).pipe(
      catchError(err => { console.error('Add day error:', err); return of(null); }),
      finalize(() => this.isLoading = false)
    )
    .subscribe(created => {
      if (created) {
        this.shootingDays.push(created);
        this.shootingDays.sort((a, b) => 
          new Date(a.date).getTime() - new Date(b.date).getTime()
        );
        this.updateAvailableScenes();
      }
      this.newShootingDayForm.reset({ isNight: false, notes: '' });
    });

    this.subs.push(sub);
  }

  /** Delete a shooting day */
  deleteShootingDay(id?: number): void {
    if (!id || this.isLoading) return;
    if (!confirm('Delete this shooting day?')) return;

    this.isLoading = true;
    const sub = this.scheduleSvc.deleteShootingDay(id).pipe(
      catchError(err => { console.error('Delete day error:', err); return of(null); }),
      finalize(() => this.isLoading = false)
    )
    .subscribe(() => {
      this.shootingDays = this.shootingDays.filter(d => d.id !== id);
      this.updateAvailableScenes();
    });

    this.subs.push(sub);
  }

  getAllDropListIds(): string[] {
    return [
      'availableScenesList',
      ...this.shootingDays.map(d => `dayList-${d.id}`)
    ];
  }

  finishLoading() {
    this.isLoading = false;
  }

  ngOnDestroy(): void {
    this.subs.forEach(s => s.unsubscribe());
  }
}
