import { Component } from '@angular/core';
import { User } from './user/user';

@Component({
  selector: 'app-root',
  templateUrl: './app.html',
  styleUrl: './app.scss',
  imports: [User],
})
export class App {}
