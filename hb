<div class="container my-4">
  <h4 class="mb-3"><i class="bi bi-film"></i> Scene Management</h4>

  <form [formGroup]="sceneForm" (ngSubmit)="onSubmit()" class="card card-body mb-4">
    <div class="row g-3">
      <div class="col-md-2">
        <label class="form-label">Scene #</label>
        <input formControlName="sceneNumber" type="number" class="form-control">
      </div>
      <div class="col-md-5">
        <label class="form-label">Setting</label>
        <input formControlName="setting" type="text" class="form-control" placeholder="INT. OFFICE - DAY">
      </div>
      <div class="col-md-5">
        <label class="form-label">Location Details</label>
        <input formControlName="locationDetails" type="text" class="form-control">
      </div>
      <div class="col-md-6">
        <label class="form-label">Script Page Ref</label>
        <input formControlName="scriptPageRef" type="text" class="form-control">
      </div>
      <div class="col-md-6">
        <label class="form-label">Characters</label>
        <input formControlName="characters" type="text" class="form-control" placeholder="comma separated">
      </div>
      <div class="col-12">
        <label class="form-label">Description</label>
        <textarea formControlName="description" rows="2" class="form-control"></textarea>
      </div>
      <div class="col-12 text-end">
        <button type="submit" class="btn btn-primary" [disabled]="sceneForm.invalid">
          <i class="bi bi-plus-circle"></i> Add Scene
        </button>
      </div>
    </div>
  </form>

  <h5 class="mb-3">Scenes in Project</h5>
  <div *ngIf="scenes.length === 0" class="text-muted">No scenes added yet.</div>
  <div *ngIf="scenes.length > 0">
    <ul class="list-group">
      <li *ngFor="let s of scenes" class="list-group-item d-flex justify-content-between align-items-center">
        <div>
          <strong>Scene {{ s.sceneNumber }}:</strong> {{ s.setting }}
          <small class="text-muted ms-2">({{ s.characters.join(', ') }})</small>
        </div>
        <span class="badge bg-info">{{ s.scriptPageRef }}</span>
      </li>
    </ul>
  </div>
</div>
