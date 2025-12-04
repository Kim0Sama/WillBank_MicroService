import { Component, OnInit } from '@angular/core';
import { RouterOutlet, Router } from '@angular/router';
import { CommonModule } from '@angular/common';
import { SidebarComponent } from './components/sidebar/sidebar.component';
import { AuthService } from './services/auth.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, SidebarComponent, CommonModule],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App implements OnInit {
  title = 'WillBank';

  constructor(public authService: AuthService, private router: Router) {}

  ngOnInit(): void {
    // Force logout on app initialization to ensure fresh login
    // Comment this line in production if you want to keep users logged in
    this.authService.logout();
  }

  get showSidebar(): boolean {
    return this.authService.isLoggedIn() && !this.router.url.includes('/login');
  }
}
