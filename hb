import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { AppComponent } from './app.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import { ProjectFormComponent } from './components/project-form/project-form.component';
import { ProjectListComponent } from './components/project-list/project-list.component';

@NgModule({
  declarations: [AppComponent, ProjectFormComponent, ProjectListComponent],
  imports: [BrowserModule, FormsModule, ReactiveFormsModule, HttpClientModule],
  providers: [],
  bootstrap: [AppComponent],
})
export class AppModule {}
