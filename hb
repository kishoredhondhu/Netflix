<nav class="navbar navbar-expand-lg navbar-dark bg-dark px-3">
  <a class="navbar-brand" href="#">🎬 Movie Production</a>
</nav>

<div class="container-fluid mt-3">
  <div class="row">
    <div class="col-md-3">
      <div class="list-group">
        <a class="list-group-item list-group-item-action active">Dashboard</a>
        <a class="list-group-item list-group-item-action">Create Project</a>
        <a class="list-group-item list-group-item-action">Manage Budget</a>
      </div>
    </div>
    <div class="col-md-9">
      <app-project-form></app-project-form>
      <hr />
      <app-project-list></app-project-list>
    </div>
  </div>
</div>
