4 unchanged chunks

Build at: 2025-05-29T15:37:58.404Z - Hash: 7aa31af5eea2c095 - Time: 1259ms

Error: src/app/components/shooting-schedule/shooting-schedule.component.html:20:30 - error TS2339: Property 'isLoadingAllScenes' does not exist on type 'ShootingScheduleComponent'.

20         <ng-container *ngIf="isLoadingAllScenes">
                                ~~~~~~~~~~~~~~~~~~

  src/app/components/shooting-schedule/shooting-schedule.component.ts:16:16
    16   templateUrl: './shooting-schedule.component.html',
                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Error occurs in the template of component ShootingScheduleComponent.


Error: src/app/components/shooting-schedule/shooting-schedule.component.html:26:22 - error TS2339: Property 'isLoadingAllScenes' does not exist on type 'ShootingScheduleComponent'.

26         <div *ngIf="!isLoadingAllScenes && availableScenes.length === 0" class="alert alert-light small">
                        ~~~~~~~~~~~~~~~~~~

  src/app/components/shooting-schedule/shooting-schedule.component.ts:16:16
    16   templateUrl: './shooting-schedule.component.html',
                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Error occurs in the template of component ShootingScheduleComponent.


Error: src/app/components/shooting-schedule/shooting-schedule.component.html:32:19 - error TS2339: Property 'isLoadingAllScenes' does not exist on type 'ShootingScheduleComponent'.

32           *ngIf="!isLoadingAllScenes && availableScenes.length > 0"
                     ~~~~~~~~~~~~~~~~~~

  src/app/components/shooting-schedule/shooting-schedule.component.ts:16:16
    16   templateUrl: './shooting-schedule.component.html',
                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Error occurs in the template of component ShootingScheduleComponent.


Error: src/app/components/shooting-schedule/shooting-schedule.component.html:48:64 - error TS2532: Object is possibly 'undefined'.

48               {{ scene.description | slice:0:50 }}<span *ngIf="scene.description?.length > 50">…</span>
                                                                  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  src/app/components/shooting-schedule/shooting-schedule.component.ts:16:16
    16   templateUrl: './shooting-schedule.component.html',
                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Error occurs in the template of component ShootingScheduleComponent.


Error: src/app/components/shooting-schedule/shooting-schedule.component.html:69:42 - error TS2339: Property 'dayFormControl' does not exist on type 'ShootingScheduleComponent'.

69                      [class.is-invalid]="dayFormControl['date'].invalid && dayFormControl['date'].touched">
                                            ~~~~~~~~~~~~~~

  src/app/components/shooting-schedule/shooting-schedule.component.ts:16:16
    16   templateUrl: './shooting-schedule.component.html',
                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Error occurs in the template of component ShootingScheduleComponent.


Error: src/app/components/shooting-schedule/shooting-schedule.component.html:69:76 - error TS2339: Property 'dayFormControl' does not exist on type 'ShootingScheduleComponent'.

69                      [class.is-invalid]="dayFormControl['date'].invalid && dayFormControl['date'].touched">
                                                                              ~~~~~~~~~~~~~~

  src/app/components/shooting-schedule/shooting-schedule.component.ts:16:16
    16   templateUrl: './shooting-schedule.component.html',
                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Error occurs in the template of component ShootingScheduleComponent.


Error: src/app/components/shooting-schedule/shooting-schedule.component.html:70:27 - error TS2339: Property 'dayFormControl' does not exist on type 'ShootingScheduleComponent'.

70               <div *ngIf="dayFormControl['date'].errors?.['required'] && dayFormControl['date'].touched"
                             ~~~~~~~~~~~~~~

  src/app/components/shooting-schedule/shooting-schedule.component.ts:16:16
    16   templateUrl: './shooting-schedule.component.html',
                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Error occurs in the template of component ShootingScheduleComponent.


Error: src/app/components/shooting-schedule/shooting-schedule.component.html:70:74 - error TS2339: Property 'dayFormControl' does not exist on type 'ShootingScheduleComponent'.

70               <div *ngIf="dayFormControl['date'].errors?.['required'] && dayFormControl['date'].touched"
                                                                            ~~~~~~~~~~~~~~

  src/app/components/shooting-schedule/shooting-schedule.component.ts:16:16
    16   templateUrl: './shooting-schedule.component.html',
                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Error occurs in the template of component ShootingScheduleComponent.


Error: src/app/components/shooting-schedule/shooting-schedule.component.html:89:65 - error TS2339: Property 'isLoadingShootingDays' does not exist on type 'ShootingScheduleComponent'.

89                       [disabled]="newShootingDayForm.invalid || isLoadingShootingDays">
                                                                   ~~~~~~~~~~~~~~~~~~~~~

  src/app/components/shooting-schedule/shooting-schedule.component.ts:16:16
    16   templateUrl: './shooting-schedule.component.html',
                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Error occurs in the template of component ShootingScheduleComponent.


Error: src/app/components/shooting-schedule/shooting-schedule.component.html:97:30 - error TS2339: Property 'isLoadingShootingDays' does not exist on type 'ShootingScheduleComponent'.

97         <ng-container *ngIf="isLoadingShootingDays && shootingDays.length === 0">
                                ~~~~~~~~~~~~~~~~~~~~~

  src/app/components/shooting-schedule/shooting-schedule.component.ts:16:16
    16   templateUrl: './shooting-schedule.component.html',
                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Error occurs in the template of component ShootingScheduleComponent.


Error: src/app/components/shooting-schedule/shooting-schedule.component.html:103:22 - error TS2339: Property 'isLoadingShootingDays' does not exist on type 'ShootingScheduleComponent'.

103         <div *ngIf="!isLoadingShootingDays && shootingDays.length === 0" class="alert alert-info">    
                         ~~~~~~~~~~~~~~~~~~~~~

  src/app/components/shooting-schedule/shooting-schedule.component.ts:16:16
    16   templateUrl: './shooting-schedule.component.html',
                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Error occurs in the template of component ShootingScheduleComponent.


Error: src/app/components/shooting-schedule/shooting-schedule.component.html:159:70 - error TS2532: Object is possibly 'undefined'.

159                     {{ scene.description | slice:0:50 }}<span *ngIf="scene.description?.length > 50">…</span>
                                                                         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   

  src/app/components/shooting-schedule/shooting-schedule.component.ts:16:16
    16   templateUrl: './shooting-schedule.component.html',
                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Error occurs in the template of component ShootingScheduleComponent.




× Failed to compile.




























× Failed to compile.






× Failed to compile.
× Failed to compile.



















