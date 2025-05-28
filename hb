<h2>Project Dashboard</h2>
<table border="1">
  <tr>
    <th>Title</th>
    <th>Genre</th>
    <th>Budget</th>
    <th>Timeline</th>
    <th>Template</th>
    <th>Team Members</th>
  </tr>
  <tr *ngFor="let p of projects">
    <td>{{ p.title }}</td>
    <td>{{ p.genre }}</td>
    <td>{{ p.budget }}</td>
    <td>{{ p.startDate }} to {{ p.endDate }}</td>
    <td>{{ p.isTemplate ? 'Yes' : 'No' }}</td>
    <td>
      <ul><li *ngFor="let m of p.keyTeamMembers">{{ m }}</li></ul>
    </td>
  </tr>
</table>
