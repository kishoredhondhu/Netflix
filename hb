this.projectForm = this.fb.group({
  title: ['', Validators.required],
  genre: ['', Validators.required],
  budget: [null, [Validators.required, Validators.min(1)]],
  startDate: ['', Validators.required],
  endDate: ['', Validators.required],
  isTemplate: [false],
  keyTeamMembers: this.fb.array([], Validators.required)
});
