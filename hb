onSubmit() {
  if (this.projectForm.invalid) {
    this.projectForm.markAllAsTouched();
    return;
  }

  this.service.createProject(this.projectForm.value).subscribe(() => {
    // ✅ Show toast
    const toastElement = document.getElementById('successToast');
    const toast = new bootstrap.Toast(toastElement!);
    toast.show();

    this.projectCreated.emit();
    this.projectForm.reset();
    this.keyTeamMembers.clear();
  });
}