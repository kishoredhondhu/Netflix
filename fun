import { Component, EventEmitter, Output, OnInit, OnDestroy, AfterViewInit, ElementRef, ViewChild } from '@angular/core';
import { FormBuilder, FormGroup, FormArray, Validators, AbstractControl, FormControl } from '@angular/forms';
import { ProjectService } from 'src/app/services/project.service';
import { Subscription } from 'rxjs';
import { HttpErrorResponse } from '@angular/common/http';

// Declare bootstrap for JS components (Toast, Tooltip)
declare var bootstrap: any;

@Component({
  selector: 'app-project-form',
  templateUrl: './project-form.component.html',
  styleUrls: ['./project-form.component.css']
})
export class ProjectFormComponent implements OnInit, OnDestroy, AfterViewInit {
  @Output() projectCreated = new EventEmitter<void>();
  @ViewChild('successToastRef') successToastRef!: ElementRef;

  projectForm!: FormGroup;
  newTeamMemberForm!: FormGroup;

  availableGenres: string[] = ['Action', 'Comedy', 'Drama', 'Sci-Fi', 'Thriller', 'Horror', 'Fantasy', 'Romance'];
  roles: string[] = ['Director', 'Producer', 'Writer', 'Cinematographer', 'Editor', 'Lead Actor', 'Composer'];

  private templateSubscription?: Subscription;
  private bsToastInstance: any;

  constructor(
    private fb: FormBuilder,
    private projectService: ProjectService
  ) {}

  // --- Angular Lifecycle Hooks ---

  ngOnInit(): void {
    this.initMainForm();
    this.initNewTeamMemberForm();
    this.subscribeToTemplateChanges();
  }

  ngAfterViewInit(): void {
    this.initializeBootstrapComponents();
  }

  ngOnDestroy(): void {
    this.templateSubscription?.unsubscribe();
  }

  // --- Form Initialization & Setup ---

  private initMainForm(): void {
    this.projectForm = this.fb.group({
      title: ['', Validators.required],
      genres: this.buildGenresControls(), // Use FormArray for checkboxes
      budget: [null, [Validators.required, Validators.min(1000)]],
      startDate: ['', Validators.required],
      endDate: ['', Validators.required],
      isTemplate: [false], // Or your renamed field like 'useAsTemplate'
      keyTeamMembers: this.fb.array([], [Validators.required, Validators.minLength(1)]),
    }, { validators: [this.dateRangeValidator, this.minOneCheckboxValidator('genres')] });
  }

  private initNewTeamMemberForm(): void {
    this.newTeamMemberForm = this.fb.group({
      name: ['', Validators.required],
      role: [this.roles[0], Validators.required], // Default to the first role
    });
  }

  private buildGenresControls(): FormArray {
    // Create a FormControl for each available genre, initialized to false (unchecked)
    const controls = this.availableGenres.map(() => new FormControl(false));
    return this.fb.array(controls);
  }

  get genresFormArray(): FormArray {
    return this.projectForm.controls['genres'] as FormArray;
  }

  get keyTeamMembers(): FormArray {
    return this.projectForm.get('keyTeamMembers') as FormArray;
  }

  // --- Template & Reset Logic ---

  private subscribeToTemplateChanges(): void {
    this.templateSubscription = this.projectForm.get('isTemplate')?.valueChanges.subscribe(checked => { // Ensure this matches your formControlName for the template flag
      checked ? this.applyTemplateValues() : this.resetMainForm();
    });
  }

  private applyTemplateValues(): void {
    const templateGenres = ['Sci-Fi', 'Action']; // Example template genres
    const templateGenreBooleans = this.availableGenres.map(genre => templateGenres.includes(genre));

    this.projectForm.patchValue({
      title: 'Default Sci-Fi Adventure',
      genres: templateGenreBooleans,
      budget: 7500000,
      startDate: '2025-08-01',
      endDate: '2026-02-15',
      isTemplate: true // Ensure this is set if you are applying a template
    }, { emitEvent: false });

    this.keyTeamMembers.clear();
    this.addMemberToFormArray('Kishore Kumar', 'Director');
    this.addMemberToFormArray('Alia Shane', 'Lead Actor');
  }

  private resetMainForm(): void {
    this.projectForm.reset({
      title: '',
      genres: this.availableGenres.map(() => false),
      budget: null,
      startDate: '',
      endDate: '',
      isTemplate: false, // Ensure this matches your formControlName for the template flag
    }, { emitEvent: false });
    this.keyTeamMembers.clear();
    this.newTeamMemberForm.reset({ name: '', role: this.roles[0] });
  }

  // --- Team Member Actions ---

  addTeamMember(): void {
    if (this.newTeamMemberForm.invalid) {
      this.newTeamMemberForm.markAllAsTouched();
      return;
    }
    const { name, role } = this.newTeamMemberForm.value;
    this.addMemberToFormArray(name, role);
    this.newTeamMemberForm.reset({ name: '', role: this.roles[0] });
  }

  private addMemberToFormArray(name: string, role: string): void {
    this.keyTeamMembers.push(this.fb.group({
      name: [name, Validators.required],
      role: [role, Validators.required]
    }));
  }

  removeTeamMember(index: number): void {
    this.keyTeamMembers.removeAt(index);
  }

  // --- Form Submission ---

  onSubmit(): void {
    this.projectForm.markAllAsTouched();

    if (this.projectForm.invalid) {
      console.error("--- FORM SUBMISSION FAILED: Main projectForm is invalid. ---");
      console.log("ProjectForm Status:", this.projectForm.status);
      console.log("ProjectForm Overall Errors:", this.projectForm.errors);
      Object.keys(this.projectForm.controls).forEach(key => {
        const control = this.projectForm.get(key);
        if (control && control.invalid) {
          console.log(`Control '${key}' is invalid. Status: ${control.status}, Errors:`, control.errors);
          if (control instanceof FormArray) {
            control.controls.forEach((arrayControl, index) => {
              if (arrayControl.invalid) {
                console.log(`  FormArray '${key}' at index ${index} is invalid. Errors:`, arrayControl.errors);
              }
            });
          }
        }
      });
      console.error("--- END OF FORM SUBMISSION FAILURE DETAILS ---");
      return;
    }

    const submissionData = this.prepareSubmissionData();
    console.log("Attempting to create project with data:", submissionData);

    this.projectService.createProject(submissionData).subscribe({
      next: (response) => {
        console.log("Project creation successful:", response);
        this.showSuccessToast();
        this.projectCreated.emit();
        this.resetMainForm();
      },
      error: (err: HttpErrorResponse) => {
        console.error('Failed to create project - API Error:', err);
        console.error('API Error Body:', err.error);
      }
    });
  }

  private prepareSubmissionData(): any {
    // Get the raw form values
    const rawFormValue = this.projectForm.getRawValue(); // Use getRawValue() to include disabled controls if any

    // Transform genres from boolean array to string array
    let selectedGenres: string[] = [];
    if (rawFormValue.genres && Array.isArray(rawFormValue.genres)) {
      selectedGenres = rawFormValue.genres
        .map((checked: boolean, i: number) => checked ? this.availableGenres[i] : null)
        .filter((value: string | null): value is string => value !== null); // Type guard
    }

    // Transform keyTeamMembers from array of objects to array of names
    let teamMemberNames: string[] = [];
    if (rawFormValue.keyTeamMembers && Array.isArray(rawFormValue.keyTeamMembers)) {
      teamMemberNames = rawFormValue.keyTeamMembers.map((member: { name: string, role: string }) => member.name);
    }

    // Construct the payload explicitly
    const payload = {
      title: rawFormValue.title,
      budget: rawFormValue.budget,
      startDate: rawFormValue.startDate,
      endDate: rawFormValue.endDate,
      isTemplate: rawFormValue.isTemplate, // Or your renamed field
      genres: selectedGenres, // Ensure this is included
      keyTeamMembers: teamMemberNames
    };
    
    return payload;
  }

  // --- Validation Helpers ---

  isInvalid(controlName: string, form: FormGroup = this.projectForm): boolean {
    const control = form.get(controlName);
    if (controlName === 'genres' && form.hasError('requireOneCheckbox') && (control?.touched || this.genresFormArray.dirty) ) {
        return true;
    }
    return !!(control && control.invalid && (control.dirty || control.touched));
  }

  getControl(controlName: string, form: FormGroup = this.projectForm): AbstractControl | null {
    return form.get(controlName);
  }

  dateRangeValidator(form: AbstractControl): { [key: string]: boolean } | null {
    const start = form.get('startDate')?.value;
    const end = form.get('endDate')?.value;
    return (start && end && new Date(start) > new Date(end)) ? { invalidDateRange: true } : null;
  }

  minOneCheckboxValidator(formArrayName: string) {
    return (formGroup: AbstractControl): { [key: string]: boolean } | null => {
      const formArray = formGroup.get(formArrayName) as FormArray;
      if (!formArray) { return null; }
      const isAnyChecked = formArray.controls.some(control => control.value === true);
      return isAnyChecked ? null : { requireOneCheckbox: true };
    };
  }

  // --- Bootstrap Integration ---

  private initializeBootstrapComponents(): void {
    console.log("Attempting to initialize Bootstrap components...");
    try {
      const tooltipTriggerList = Array.from(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
      tooltipTriggerList.forEach(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));
      console.log(`Initialized ${tooltipTriggerList.length} tooltips.`);
    } catch (e) {
      console.error("Error initializing tooltips:", e);
    }
    try {
      if (this.successToastRef?.nativeElement) {
         this.bsToastInstance = new bootstrap.Toast(this.successToastRef.nativeElement);
         console.log("Bootstrap Toast instance CREATED successfully.");
      } else {
         console.error("Could not find #successToastRef element to initialize Toast.");
      }
    } catch (e) {
       console.error("Error creating Bootstrap Toast instance:", e);
    }
  }

  private showSuccessToast(): void {
    console.log("Attempting to show success toast...");
    if (this.bsToastInstance) {
       console.log("bsToastInstance exists. Calling show().");
       this.bsToastInstance.show();
    } else {
       console.error("bsToastInstance is NOT available. Showing fallback alert.");
       alert("Project created successfully! (Toast failed to show)");
    }
  }
}
