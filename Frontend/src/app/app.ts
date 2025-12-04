import { Component } from '@angular/core';
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
export class App {
  title = 'WillBank';

  constructor(public authService: AuthService, private router: Router) {}

  get showSidebar(): boolean {
    return this.authService.isLoggedIn() && !this.router.url.includes('/login');
  }
}
