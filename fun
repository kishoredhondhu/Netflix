// In your app-routing.module.ts or a relevant feature routing module

import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
// Import your components
import { ProjectListComponent } from './components/project-list/project-list.component';     // Adjust path
import { ProjectFormComponent } from './components/project-form/project-form.component';     // Adjust path
import { BudgetManagementComponent } from './components/budget-management/budget-management.component'; // Adjust path

const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' }, // Example default
  { path: 'dashboard', component: ProjectListComponent },
  { path: 'projects/create', component: ProjectFormComponent },
  // { path: 'projects/edit/:id', component: ProjectFormComponent }, // If you have this for editing projects

  // THIS IS THE ROUTE YOU NEED TO ADD OR ENSURE IS CORRECT:
  { path: 'project/:projectId/budget', component: BudgetManagementComponent },

  // Add other routes here
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
