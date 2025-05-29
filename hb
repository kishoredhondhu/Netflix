import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, FormArray } from '@angular/forms';
import { ActivatedRoute } from '@angular/router';
import { SceneService } from 'src/app/services/scene.service';
import { Scene } from 'src/app/models/scene.model';

@Component({
  selector: 'app-scene-management',
  templateUrl: './scene-management.component.html'
})
export class SceneManagementComponent implements OnInit {
  sceneForm!: FormGroup;
  scenes: Scene[] = [];
  projectId!: number;

  constructor(
    private fb: FormBuilder,
    private route: ActivatedRoute,
    private sceneService: SceneService
  ) {}

  ngOnInit(): void {
    this.projectId = +this.route.snapshot.paramMap.get('projectId')!;
    this.initForm();
    this.loadScenes();
  }

  initForm(): void {
    this.sceneForm = this.fb.group({
      sceneNumber: [1, [Validators.required]],
      setting: ['', Validators.required],
      description: [''],
      locationDetails: [''],
      scriptPageRef: [''],
      characters: ['', Validators.required]
    });
  }

  loadScenes(): void {
    this.sceneService.getScenesByProject(this.projectId).subscribe(data => {
      this.scenes = data;
    });
  }

  onSubmit(): void {
    if (this.sceneForm.invalid) return;

    const formValue = this.sceneForm.value;
    const scene: Scene = {
      ...formValue,
      characters: formValue.characters.split(',').map((s: string) => s.trim()),
      projectId: this.projectId
    };

    this.sceneService.createScene(scene).subscribe(created => {
      this.scenes.push(created);
      this.sceneForm.reset();
    });
  }
}
