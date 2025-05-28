<h3>Project Dashboard</h3>

<table class="table table-bordered table-hover">
  <thead class="table-dark">
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
          <li *ngFor="let member of p.keyTeamMembers">{{ member }}</li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>
