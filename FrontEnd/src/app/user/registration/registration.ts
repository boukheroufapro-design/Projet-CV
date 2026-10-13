import { Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';

@Component({
  imports: [ReactiveFormsModule],
  selector: 'app-registration',
  styleUrl: './registration.scss',
  templateUrl: './registration.html',
})
export class Registration {
  formBuilder = inject(FormBuilder);

  form = this.formBuilder.group({
    fullName: [''],
    email: [''],
    password: [''],
    confirmPassword: [''],
  });
  onSubmit() {
    console.log(this.form.value);
  }
}
