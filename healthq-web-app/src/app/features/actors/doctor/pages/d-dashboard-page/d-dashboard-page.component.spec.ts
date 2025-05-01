import { ComponentFixture, TestBed } from '@angular/core/testing';

import { DDashboardPageComponent } from './d-dashboard-page.component';

describe('DDashboardPageComponent', () => {
  let component: DDashboardPageComponent;
  let fixture: ComponentFixture<DDashboardPageComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DDashboardPageComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(DDashboardPageComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
