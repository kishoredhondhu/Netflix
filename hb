import { Component, EventEmitter, Output } from '@angular/core';
import { FormBuilder, FormGroup, FormArray, Validators } from '@angular/forms';
import { ProjectService, MovieProject, TeamMember } from 'src/app/services/project.service';

@Component({
  selector: 'app-project-form',
  templateUrl: './project-form.component.html',
})
export class ProjectFormComponent {
  @Output() projectCreated = new EventEmitter<void>();
  projectForm: FormGroup;
  genres = ['Action', 'Drama', 'Comedy', 'Sci-Fi', 'Horror', 'Romance'];
  roles = ['Director', 'Producer', 'Writer', 'Actor', 'Editor'];
  names = ['Kishore', 'Anjali', 'Ron', 'Swati', 'Aryan'];

  constructor(private fb: FormBuilder, private service: ProjectService) {
    this.projectForm = this.fb.group({
      title: ['', Validators.required],
      genre: ['', Validators.required],
      budget: [null, [Validators.required, Validators.min(1)]],
      startDate: ['', Validators.required],
      endDate: ['', Validators.required],
      isTemplate: [false],
      keyTeamMembers: this.fb.array([], Validators.required),
    });

    this.projectForm.get('isTemplate')?.valueChanges.subscribe(checked => {
      if (checked) {
        this.projectForm.patchValue({
          title: 'Default Template',
          genre: 'Sci-Fi',
          budget: 5000000,
          startDate: '2025-06-01',
          endDate: '2025-12-01',
        }, { emitEvent: false });
        this.keyTeamMembers.clear();
        this.keyTeamMembers.push(this.fb.group({ name: ['Kishore'], role: ['Director'] }));
      } else {
        this.projectForm.reset(undefined, { emitEvent: false });
        this.keyTeamMembers.clear();
      }
    });
  }

  get keyTeamMembers(): FormArray {
    return this.projectForm.get('keyTeamMembers') as FormArray;
  }

  addTeamMember(name: string, role: string) {
    if (name && role) {
      this.keyTeamMembers.push(this.fb.group({ name: [name], role: [role] }));
    }
  }

  removeTeamMember(index: number) {
    this.keyTeamMembers.removeAt(index);
  }

  onSubmit() {
    if (this.projectForm.invalid) {
      this.projectForm.markAllAsTouched();
      return;
    }

    this.service.createProject(this.projectForm.value).subscribe(() => {
      this.projectCreated.emit();
      this.projectForm.reset();
      this.keyTeamMembers.clear();
    });
  }
}
