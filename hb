import { Component, EventEmitter, Output } from '@angular/core';
import { FormBuilder, FormGroup, FormArray, Validators } from '@angular/forms';
import { ProjectService } from 'src/app/services/project.service';

@Component({
  selector: 'app-project-form',
  templateUrl: './project-form.component.html',
})
export class ProjectFormComponent {
  projectForm: FormGroup;
  submitted = false;

  @Output() projectCreated = new EventEmitter<void>();

  constructor(private fb: FormBuilder, private service: ProjectService) {
    this.projectForm = this.fb.group({
      title: ['', Validators.required],
      genre: ['', Validators.required],
      budget: [null, [Validators.required, Validators.min(1)]],
      startDate: ['', Validators.required],
      endDate: ['', Validators.required],
      isTemplate: [false],
      keyTeamMembers: this.fb.array([], Validators.required)
    });

    this.projectForm.get('isTemplate')?.valueChanges.subscribe(checked => {
      if (checked) {
        this.projectForm.patchValue({
          title: 'Template Project',
          genre: 'Sci-Fi',
          budget: 5000000,
          startDate: '2025-07-01',
          endDate: '2025-12-01'
        });
        this.keyTeamMembers.clear();
        ['Director', 'Producer', 'Cinematographer'].forEach(m =>
          this.keyTeamMembers.push(this.fb.control(m))
        );
      } else {
        this.projectForm.reset();
        this.keyTeamMembers.clear();
      }
    });
  }

  get keyTeamMembers(): FormArray {
    return this.projectForm.get('keyTeamMembers') as FormArray;
  }

  addTeamMember(name: string) {
    if (name.trim()) this.keyTeamMembers.push(this.fb.control(name.trim()));
  }

  removeTeamMember(index: number) {
    this.keyTeamMembers.removeAt(index);
  }

  onSubmit() {
    if (this.projectForm.invalid) {
      this.projectForm.markAllAsTouched();
      return;
    }

    this.service.createProject(this.projectForm.value).subscribe({
      next: () => {
        this.submitted = true;
        this.projectCreated.emit();
        this.projectForm.reset();
        this.keyTeamMembers.clear();
      }
    });
  }
}
