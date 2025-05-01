import { Component, OnInit } from '@angular/core';
import { DPatientComponent } from '../../components/d-patient/d-patient.component';
import { User } from '../../../../../core/auth/user.model';
import { QuestionnaireService } from '../../../../questionnaire/questionaire.service';
import { Router } from '@angular/router';
import {NgForOf} from '@angular/common';
import {MatToolbar} from '@angular/material/toolbar';
import {MatFormField, MatLabel} from '@angular/material/form-field';
import {MatInput} from '@angular/material/input';
import {FormsModule} from '@angular/forms';

@Component({
  selector: 'app-d-patients-page',
  imports: [
    DPatientComponent,
    NgForOf,
    MatToolbar,
    MatFormField,
    MatInput,
    FormsModule,
    MatLabel
  ],
  templateUrl: './d-patients-page.component.html',
  styleUrl: './d-patients-page.component.scss',
})
export class DPatientsPageComponent implements OnInit {
  availablePatients: User[] = [];
  patients: User[] = [];
  searchQuery = '';

  constructor(
    private constructorService: QuestionnaireService,
    private router: Router
  ) {}

  ngOnInit(): void {
    const user: User = JSON.parse(sessionStorage.getItem('user')!);
    if (!user) {
      console.log('User is invalid!');
    }

    this.constructorService.getAllDoctorPatients(user.email).subscribe({
      next: (data) => {
        if (Array.isArray(data)) {
          this.availablePatients = data;
          this.applyFilters();
        }
      },
      error: (err) => {
        console.log(err);
      },
    });
  }

  applyFilters() {
    this.patients = this.availablePatients
      .filter(
        (u) =>
          (!this.searchQuery) ||
            u.firstName.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
            u.lastName.toLowerCase().includes(this.searchQuery.toLowerCase()) ||
            (u.firstName.toLowerCase() + " " + u.lastName.toLowerCase()).includes(this.searchQuery.toLowerCase())
      );

    console.log(this.patients);
  }
}
