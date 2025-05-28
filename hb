import { Component } from '@angular/core';
import { FormBuilder, FormGroup, FormArray } from '@angular/forms';
import { ProjectService, MovieProject } from 'src/app/services/project.service';

@Component({
  selector: 'app-project-form',
  templateUrl: './project-form.component.html',
})
export class ProjectFormComponent {
  projectForm: FormGroup;
  submitted = false;

  constructor(private fb: FormBuilder, private projectService: ProjectService) {
    this.projectForm = this.fb.group({
      title: [''],
      genre: [''],
      budget: [0],
      startDate: [''],
      endDate: [''],
      isTemplate: [false],
      keyTeamMembers: this.fb.array([])
    });
  }

  get keyTeamMembers(): FormArray {
    return this.projectForm.get('keyTeamMembers') as FormArray;
  }

  addTeamMember(member: string) {
    if (member) this.keyTeamMembers.push(this.fb.control(member));
  }

  removeTeamMember(index: number) {
    this.keyTeamMembers.removeAt(index);
  }

  onSubmit() {
    const project: MovieProject = this.projectForm.value;
    this.projectService.createProject(project).subscribe({
      next: () => {
        this.submitted = true;
        this.projectForm.reset();
        this.keyTeamMembers.clear();
      }
    });
  }
}
