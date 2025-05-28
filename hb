import { Component, OnInit } from '@angular/core';
import { MovieProject, ProjectService } from 'src/app/services/project.service';

@Component({
  selector: 'app-project-list',
  templateUrl: './project-list.component.html',
})
export class ProjectListComponent implements OnInit {
  projects: MovieProject[] = [];

  constructor(private projectService: ProjectService) {}

  ngOnInit(): void {
    this.projectService.getAllProjects().subscribe((data) => {
      this.projects = data;
    });
  }
}
