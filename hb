import { Component, Input } from '@angular/core';
import { MovieProject } from 'src/app/services/project.service';

@Component({
  selector: 'app-project-list',
  templateUrl: './project-list.component.html',
})
export class ProjectListComponent {
  @Input() projects: MovieProject[] = [];
}
