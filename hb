<nav class="navbar navbar-dark bg-dark px-3">
  <a class="navbar-brand" href="#">🎬 Movie Production</a>
</nav>

<div class="container-fluid">
  <div class="row">
    <!-- Sidebar -->
    <div class="col-md-3 sidebar p-3">
      <div class="list-group">
        <a class="list-group-item list-group-item-action active"><i class="bi bi-speedometer2"></i> Dashboard</a>
        <a class="list-group-item list-group-item-action"><i class="bi bi-plus-circle"></i> Create Project</a>
        <a class="list-group-item list-group-item-action"><i class="bi bi-currency-dollar"></i> Manage Budget</a>
      </div>
    </div>

    <!-- Main Content -->
    <div class="col-md-9 p-4">
      <app-project-form></app-project-form>
      <hr />
      <app-project-list></app-project-list>
    </div>
  </div>
</div>
