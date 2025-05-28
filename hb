<div class="card shadow-sm">
  <div class="card-header bg-dark text-white">Dashboard</div>
  <div class="card-body p-0">
    <table class="table table-striped mb-0">
      <thead>
        <tr>
          <th>Title</th>
          <th>Genre</th>
          <th>Budget</th>
          <th>Timeline</th>
          <th>Template</th>
          <th>Team</th>
        </tr>
      </thead>
      <tbody>
        <tr *ngFor="let p of projects">
          <td>{{ p.title }}</td>
          <td>{{ p.genre }}</td>
          <td>₹{{ p.budget }}</td>
          <td>{{ p.startDate }} → {{ p.endDate }}</td>
          <td><span class="badge bg-info">{{ p.isTemplate ? 'Yes' : 'No' }}</span></td>
          <td>
            <ul class="mb-0 ps-3">
              <li *ngFor="let m of p.keyTeamMembers">{{ m }}</li>
            </ul>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
