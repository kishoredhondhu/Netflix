import { Component, EventEmitter, Output } from '@angular/core';
import { AbstractControl, FormArray, FormBuilder, FormControl, FormGroup, ValidationErrors, ValidatorFn, Validators } from '@angular/forms';
import { ProjectService } from 'src/app/services/project.service';

declare var bootstrap: any;

@Component({
  selector: 'app-project-form',
  templateUrl: './project-form.component.html'
})
export class ProjectFormComponent {
  @Output() projectCreated = new EventEmitter<void>();
  projectForm!: FormGroup;
  newTeamMemberForm!: FormGroup;

  availableGenres: string[] = ['Action', 'Drama', 'Comedy', 'Sci-Fi', 'Thriller'];
  roles: string[] = ['Director', 'Producer', 'Writer', 'Cinematographer', 'Editor'];

  constructor(private fb: FormBuilder, private service: ProjectService) {
    this.initializeForm();
  }

  initializeForm(): void {
    this.projectForm = this.fb.group({
      title: ['', Validators.required],
      genres: this.fb.array(this.availableGenres.map(() => this.fb.control(false)), this.requireOneCheckbox()),
      budget: [null, [Validators.required, Validators.min(1000)]],
      startDate: ['', Validators.required],
      endDate: ['', Validators.required],
      isTemplate: [false],
      keyTeamMembers: this.fb.array([], Validators.required),
    }, { validators: this.validateDateRange });

    this.newTeamMemberForm = this.fb.group({
      name: ['', Validators.required],
      role: [this.roles[0], Validators.required]
    });

    this.projectForm.get('isTemplate')?.valueChanges.subscribe((checked) => {
      if (checked) {
        this.projectForm.patchValue({
          title: 'Default Sci-Fi Adventure',
          budget: 7500000,
          startDate: '2025-08-01',
          endDate: '2026-02-15'
        }, { emitEvent: false });

        this.genresFormArray.controls.forEach((ctrl, index) => {
          ctrl.setValue(['Sci-Fi', 'Action'].includes(this.availableGenres[index]));
        });

        this.keyTeamMembers.clear();
        this.keyTeamMembers.push(this.fb.group({ name: ['Kishore Kumar'], role: ['Director'] }));
        this.keyTeamMembers.push(this.fb.group({ name: ['Alia Shane'], role: ['Writer'] }));
      } else {
        this.projectForm.reset();
        this.keyTeamMembers.clear();
        this.genresFormArray.clear();
        this.availableGenres.forEach(() => this.genresFormArray.push(this.fb.control(false)));
      }
    });
  }

  // ✅ genre checkbox validation
  requireOneCheckbox(): ValidatorFn {
    return (formArray: AbstractControl): ValidationErrors | null => {
      const selected = (formArray as FormArray).controls.some(ctrl => ctrl.value);
      return selected ? null : { requireOneCheckbox: true };
    };
  }

  // ✅ startDate < endDate
  validateDateRange(group: AbstractControl): ValidationErrors | null {
    const start = group.get('startDate')?.value;
    const end = group.get('endDate')?.value;
    if (start && end && new Date(start) >= new Date(end)) {
      return { invalidDateRange: true };
    }
    return null;
  }

  get genresFormArray(): FormArray {
    return this.projectForm.get('genres') as FormArray;
  }

  get keyTeamMembers(): FormArray {
    return this.projectForm.get('keyTeamMembers') as FormArray;
  }

  getControl(controlName: string, form: FormGroup = this.projectForm): FormControl {
    return form.get(controlName) as FormControl;
  }

  isInvalid(controlName: string, form: FormGroup = this.projectForm): boolean {
    const ctrl = form.get(controlName);
    return !!ctrl && ctrl.invalid && (ctrl.touched || ctrl.dirty);
  }

  addTeamMember(): void {
    if (this.newTeamMemberForm.invalid) {
      this.newTeamMemberForm.markAllAsTouched();
      return;
    }

    this.keyTeamMembers.push(this.fb.group({
      name: [this.newTeamMemberForm.value.name],
      role: [this.newTeamMemberForm.value.role]
    }));

    this.newTeamMemberForm.reset({ role: this.roles[0] });
  }

  removeTeamMember(index: number): void {
    this.keyTeamMembers.removeAt(index);
  }

  onSubmit(): void {
    if (this.projectForm.invalid) {
      this.projectForm.markAllAsTouched();
      return;
    }

    const selectedGenres = this.genresFormArray.controls
      .map((ctrl, i) => ctrl.value ? this.availableGenres[i] : null)
      .filter(g => g !== null);

    const payload = {
      ...this.projectForm.value,
      genres: selectedGenres
    };

    this.service.createProject(payload).subscribe(() => {
      const toastEl = document.getElementById('successToast');
      const toast = new bootstrap.Toast(toastEl!);
      toast.show();

      this.projectCreated.emit();
      this.projectForm.reset();
      this.keyTeamMembers.clear();
      this.genresFormArray.clear();
      this.availableGenres.forEach(() => this.genresFormArray.push(this.fb.control(false)));
    });
  }
}
