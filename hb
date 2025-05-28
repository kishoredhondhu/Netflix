<div class="card shadow-sm">
  <div class="card-header bg-secondary text-white">
    <h5 class="mb-0">Project Dashboard</h5>
  </div>
  <div class="card-body p-0">
    <table class="table table-hover mb-0">
      <thead class="table-light">
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
          <td>{{ p.startDate }} to {{ p.endDate }}</td>
          <td><span class="badge bg-info">{{ p.isTemplate ? 'Yes' : 'No' }}</span></td>
          <td>
            <ul class="ps-3 mb-0">
              <li *ngFor="let member of p.keyTeamMembers">{{ member }}</li>
            </ul>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</div>
