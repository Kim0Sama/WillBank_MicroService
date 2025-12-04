import { Injectable } from '@angular/core';
import { CanActivate, Router, ActivatedRouteSnapshot, UrlTree } from '@angular/router';
import { AuthService } from '../services/auth.service';

@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {
  constructor(private authService: AuthService, private router: Router) {}

  canActivate(route: ActivatedRouteSnapshot): boolean | UrlTree {
    // Check if user is logged in
    if (!this.authService.isLoggedIn()) {
      console.warn('AuthGuard: User not authenticated, redirecting to login');
      return this.router.createUrlTree(['/login']);
    }

    // Check for admin routes
    const isAdminRoute = route.routeConfig?.path?.startsWith('admin');
    if (isAdminRoute && !this.authService.isAdmin()) {
      console.warn('AuthGuard: User not authorized for admin route, redirecting to dashboard');
      return this.router.createUrlTree(['/dashboard']);
    }

    return true;
  }
}
