import {AfterViewInit, Component, ElementRef, ViewChild} from '@angular/core';
import {MatCard, MatCardContent, MatCardTitle} from '@angular/material/card';
import {MatFormField, MatLabel, MatSuffix} from '@angular/material/form-field';
import {
  MatDatepickerToggle,
  MatDateRangeInput,
  MatDateRangePicker,
  MatEndDate,
  MatStartDate
} from '@angular/material/datepicker';
import {FormControl, FormGroup, ReactiveFormsModule} from '@angular/forms';
import {ChartData} from '../../../../../shared/models/chart-data.model';
import {QuestionnaireService} from '../../../../questionnaire/questionaire.service';
import {ChartStatistic} from '../../../../../shared/models/chart-statistic.model';
import {Chart} from 'chart.js/auto';
import {MatOption, MatSelect} from '@angular/material/select';
import {MatButton} from '@angular/material/button';
import {User} from '../../../../../core/auth/user.model';
import {NgForOf} from '@angular/common';
import {saveAs} from 'file-saver';

@Component({
  selector: 'app-d-dashboard-page',
  imports: [
    MatCard,
    MatCardTitle,
    MatFormField,
    MatCardContent,
    MatDateRangeInput,
    MatDatepickerToggle,
    MatDateRangePicker,
    ReactiveFormsModule,
    MatEndDate,
    MatLabel,
    MatStartDate,
    MatSuffix,
    MatSelect,
    MatOption,
    MatButton,
    NgForOf
  ],
  templateUrl: './d-dashboard-page.component.html',
  styleUrl: './d-dashboard-page.component.scss'
})
export class DDashboardPageComponent implements AfterViewInit{
  @ViewChild('reportsCanvas') reportCanvas: ElementRef | undefined;
  @ViewChild('patientCanvas') patientCanvas: ElementRef | undefined;

  reportsChart: any;
  patientChart: any;

  reportsChartData: ChartStatistic;
  patientChartData: ChartStatistic;

  public reportsFormGroup = new FormGroup({
    start: new FormControl(new Date()),
    end: new FormControl(new Date()),
  });

  patients: User[];
  selectedPatient: string;

  constructor(private questionnaireService: QuestionnaireService) {
    this.reportsChartData = new ChartStatistic();
    this.patientChartData = new ChartStatistic();
    this.patientChartData.chartsData.push(new ChartData());
    this.patientChartData.chartsData.push(new ChartData());
    this.patientChartData.chartsData.push(new ChartData());

    let end = this.reportsFormGroup.get('end')?.value;
    if(end != undefined){
      let startDate = new Date();
      startDate.setDate(end?.getDate() - 7);
      this.reportsFormGroup.get('start')?.setValue(startDate);
    }

    this.patients = [];
    this.selectedPatient = "";
  }
  ngAfterViewInit(): void {
    this.getPatients();
    this.reportsPieChartMethod();
    this.patientPieChartMethod();
    this.updateReportsChart();
  }


  reportsPieChartMethod(){
    this.reportsChart = new Chart(this.reportCanvas?.nativeElement, {
      type: 'pie',
      options: {
        responsive: true,
        plugins: {
          legend: {
            position: 'bottom'
          }
        }
      },
      data: {
        labels: this.reportsChartData.chartsData.map(row => row.type),
        datasets: [
          {
            label: '',
            data: this.reportsChartData.chartsData.map(row => row.value),
            backgroundColor: ["#059bff", "#22cfcf", "#ff4069"]
          }
        ]
      }
    })
  }
  patientPieChartMethod(){
    this.patientChart = new Chart(this.patientCanvas?.nativeElement, {
      type: 'pie',
      options: {
        responsive: true,
        plugins: {
          legend: {
            position: 'bottom'
          }
        }
      },
      data: {
        labels: this.patientChartData.chartsData.map(row => row.type),
        datasets: [
          {
            label: '',
            data: this.patientChartData.chartsData.map(row => row.value),
            backgroundColor: ["#059bff", "#22cfcf", "#ff4069"]
          }
        ]
      }
    })
  }

  updateReportsChart() {
    let startDate = this.reportsFormGroup.get('start')?.value;
    let endDate = this.reportsFormGroup.get('end')?.value;

    if(startDate == null ||
      endDate == null){
      console.log("dates are undefined or null")
      return
    }

    let user = this.getCurrentUser();

    this.questionnaireService.getReportsChart(user.email, startDate, endDate).subscribe({
      next: data => {
        this.reportsChartData.chartsData = [];
        for(let cd of data.chartsData) {
          this.reportsChartData.chartsData.push(cd);
        }
        this.reportsChartData.valueSum = data.valueSum;
        this.reportsChartData.percentage = data.percentage;

        this.reportsChart.destroy();
        console.log(this.reportsChartData);

        this.reportsPieChartMethod();
      },
      error: err => console.log(err)
    })
  }

  updatePatientChart() {
    let user = this.getCurrentUser();

    if(this.selectedPatient == "") {
      console.log("No selected patient");
      return;
    }
    this.questionnaireService.getPatientChart(user.email, this.selectedPatient).subscribe({
      next: data => {
        this.patientChartData.chartsData = [];
        for(let cd of data.chartsData) {
          this.patientChartData.chartsData.push(cd);
        }
        this.patientChartData.valueSum = data.valueSum;
        this.patientChartData.percentage = data.percentage;

        this.patientChart.destroy();
        console.log(this.reportsChartData);

        this.patientPieChartMethod();
      },
      error: err => console.log(err)
    })
  }

  getPatients(){
    let user = this.getCurrentUser();

    this.questionnaireService.getAllDoctorPatients(user.email).subscribe({
      next: (data) => {
        if (Array.isArray(data)) {
          this.patients = data;
          let patient = this.patients.at(0);
          this.selectedPatient = patient.email;
          this.updatePatientChart();
        }
      },
      error: (err) => {
        console.log(err);
      },
    });
  }

  downloadQuestionnaireReport(){
    let startDate = this.reportsFormGroup.get('start')?.value;
    let endDate = this.reportsFormGroup.get('end')?.value;

    if(startDate == null ||
      endDate == null){
      console.log("dates are undefined or null")
      return
    }

    let user = this.getCurrentUser();

    this.questionnaireService.getQuestionnaireReport(user.email, startDate, endDate).subscribe({
      next: data => {
        saveAs(data, 'Questionnaire_Report.csv');
      },
      error: err => console.log(err)
    })
  }

  downloadPatientReport(){
    let user = this.getCurrentUser();

    this.questionnaireService.getPatientReport(user.email, this.selectedPatient).subscribe({
      next: data => {
        saveAs(data, 'Patient_Report.csv');
      },
      error: err => console.log(err)
    })
  }

  getCurrentUser(): User {
    const user: User = JSON.parse(sessionStorage.getItem('user')!);
    if (!user) {
      console.log('User is invalid!');
    }

    return user;
  }
}
