import { Component, EventEmitter, Output } from '@angular/core';
import { FormBuilder, FormGroup, FormArray, Validators } from '@angular/forms';
import { ProjectService } from 'src/app/services/project.service';
import { MatSnackBar } from '@angular/material/snack-bar';

@Component({
  selector: 'app-project-form',
  templateUrl: './project-form.component.html'
})
export class ProjectFormComponent {
  @Output() projectCreated = new EventEmitter<void>();
  projectForm: FormGroup;
  roles = ['Director', 'Producer', 'Writer', 'Cinematographer'];
  genres = ['Action', 'Comedy', 'Drama', 'Sci-Fi', 'Thriller'];

  constructor(
    private fb: FormBuilder,
    private service: ProjectService,
    private snackBar: MatSnackBar
  ) {
    this.projectForm = this.fb.group({
      title: ['', Validators.required],
      genre: [[], Validators.required],
      budget: [null, [Validators.required, Validators.min(1)]],
      startDate: ['', Validators.required],
      endDate: ['', Validators.required],
      isTemplate: [false],
      keyTeamMembers: this.fb.array([], Validators.required),
    });

    this.projectForm.get('isTemplate')?.valueChanges.subscribe((checked) => {
      if (checked) {
        this.projectForm.patchValue({
          title: 'Default Project',
          genre: ['Sci-Fi'],
          budget: 5000000,
          startDate: '2025-07-01',
          endDate: '2025-12-01',
        }, { emitEvent: false });

        this.keyTeamMembers.clear();
        this.keyTeamMembers.push(this.fb.group({ name: ['Kishore'], role: ['Director'] }));
        this.keyTeamMembers.push(this.fb.group({ name: ['Ron'], role: ['Writer'] }));
      } else {
        this.projectForm.reset(undefined, { emitEvent: false });
        this.keyTeamMembers.clear();
      }
    });
  }

  get keyTeamMembers(): FormArray {
    return this.projectForm.get('keyTeamMembers') as FormArray;
  }

  addTeamMember(nameInput: HTMLInputElement, roleSelect: HTMLSelectElement) {
    const name = nameInput.value.trim();
    const role = roleSelect.value;

    if (name && role) {
      this.keyTeamMembers.push(this.fb.group({ name: [name], role: [role] }));
      nameInput.value = '';
    }
  }

  removeTeamMember(i: number) {
    this.keyTeamMembers.removeAt(i);
  }

  onSubmit() {
    if (this.projectForm.invalid) {
      this.projectForm.markAllAsTouched();
      return;
    }

    this.service.createProject(this.projectForm.value).subscribe(() => {
      this.snackBar.open('Project created successfully!', 'Close', { duration: 3000 });
      this.projectCreated.emit();
      this.projectForm.reset();
      this.keyTeamMembers.clear();
    });
  }
}
