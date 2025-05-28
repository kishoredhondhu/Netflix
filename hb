import { Component, OnInit } from '@angular/core';
import { MovieProject, ProjectService } from './services/project.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
})
export class AppComponent implements OnInit {
  projects: MovieProject[] = [];
  showSidebar = true;

  constructor(private service: ProjectService) {}

  ngOnInit(): void {
    this.loadProjects();
  }

  loadProjects() {
    this.service.getAllProjects().subscribe(data => this.projects = data);
  }
}
