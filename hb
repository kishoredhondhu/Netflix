import { Component, OnInit } from '@angular/core';
import { ProjectService, MovieProject } from 'src/app/services/project.service';

@Component({
  selector: 'app-project-list',
  templateUrl: './project-list.component.html'
})
export class ProjectListComponent implements OnInit {
  projects: MovieProject[] = [];

  constructor(private service: ProjectService) {}

  ngOnInit() {
    this.load();
  }

  load() {
    this.service.getAllProjects().subscribe(data => this.projects = data);
  }
}
