import { Component, OnInit } from '@angular/core';
import { ProjectService, MovieProject } from './services/project.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
})
export class AppComponent implements OnInit {
  showSidebar = true;
  projects: MovieProject[] = [];

  constructor(private projectService: ProjectService) {}

  ngOnInit(): void {
    this.loadProjects();
  }

  loadProjects() {
    this.projectService.getAllProjects().subscribe(data => this.projects = data);
  }
}
