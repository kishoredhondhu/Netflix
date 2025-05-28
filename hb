<div class="card shadow">
  <div class="card-header bg-dark text-white">Project Dashboard</div>
  <div class="card-body p-0">
    <table class="table table-hover">
      <thead>
        <tr>
          <th>Title</th><th>Genre</th><th>Budget</th><th>Timeline</th><th>Template</th><th>Team</th>
        </tr>
      </thead>
      <tbody>
        <tr *ngFor="let p of projects">
          <td>{{ p.title }}</td>
          <td>{{ p.genre }}</td>
          <td>₹{{ p.budget }}</td>
          <td>{{ p.startDate }} to {{ p.endDate }}</td>
          <td><span class="badge bg-info">{{ p.isTemplate ? 'Yes' : 'No' }}</span></td>
          <td>
            <ul class="mb-0 ps-3">
              <li *ngFor="let m of p.keyTeamMembers">{{ m.name }} ({{ m.role }})</li>
            </ul>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
