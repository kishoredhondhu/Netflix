import { Component, EventEmitter, Output } from '@angular/core';
import { FormArray, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ProjectService } from 'src/app/services/project.service';

declare var bootstrap: any;

@Component({
  selector: 'app-project-form',
  templateUrl: './project-form.component.html'
})
export class ProjectFormComponent {
  @Output() projectCreated = new EventEmitter<void>();
  projectForm: FormGroup;

  roles: string[] = ['Director', 'Producer', 'Writer', 'Cinematographer', 'Editor'];
  genres: string[] = ['Action', 'Comedy', 'Drama', 'Sci-Fi', 'Thriller'];

  constructor(private fb: FormBuilder, private service: ProjectService) {
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
          budget: 5000000,
          startDate: '2025-07-01',
          endDate: '2025-12-01'
        }, { emitEvent: false });

        this.projectForm.get('genre')?.setValue(['Sci-Fi', 'Action']);
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

  updateGenres(event: Event) {
    const selectedOptions = (event.target as HTMLSelectElement).selectedOptions;
    const values: string[] = [];
    for (let i = 0; i < selectedOptions.length; i++) {
      values.push(selectedOptions[i].value);
    }
    this.projectForm.get('genre')?.setValue(values);
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
      const toastEl = document.getElementById('successToast');
      const toast = new bootstrap.Toast(toastEl!);
      toast.show();

      this.projectCreated.emit();
      this.projectForm.reset();
      this.keyTeamMembers.clear();
    });
  }
}
