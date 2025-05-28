import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  showSidebar = true;
  activeSection: 'dashboard' | 'form' = 'dashboard';

  toggleSidebar() {
    this.showSidebar = !this.showSidebar;
  }

  setSection(section: 'dashboard' | 'form') {
    this.activeSection = section;
  }
}
