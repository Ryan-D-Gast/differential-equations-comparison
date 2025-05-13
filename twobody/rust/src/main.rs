use differential_equations::prelude::*;
use nalgebra::Vector6;
use std::f64::consts::PI;

// Two-Body Problem with Analytical Solution Comparison
struct TwoBodyProblem {
    pub mu: f64, // Gravitational parameter (GM)
}

impl ODE<f64, Vector6<f64>> for TwoBodyProblem {
    fn diff(&self, _t: f64, u: &Vector6<f64>, dudt: &mut Vector6<f64>) {
        // State vector: [x, y, z, vx, vy, vz]
        let x = u[0];
        let y = u[1];
        let z = u[2];
        
        // Calculate distance (r)
        let r = (x*x + y*y + z*z).sqrt();
        let r_cubed = r * r * r;
        
        // Position derivatives are just the velocities
        dudt[0] = u[3]; // dx/dt = vx
        dudt[1] = u[4]; // dy/dt = vy
        dudt[2] = u[5]; // dz/dt = vz
        
        // Velocity derivatives from Newton's law of gravitation
        dudt[3] = -self.mu * x / r_cubed; // dvx/dt = -mu * x / r^3
        dudt[4] = -self.mu * y / r_cubed; // dvy/dt = -mu * y / r^3
        dudt[5] = -self.mu * z / r_cubed; // dvz/dt = -mu * z / r^3
    }
}

// Calculate analytical solution for a circular orbit at given time
fn analytical_solution(mu: f64, r0: f64, t: f64) -> Vector6<f64> {
    // For a circular orbit:
    // - orbit radius is constant
    // - angular velocity is constant
    let omega = (mu / (r0*r0*r0)).sqrt();  // angular velocity
    let angle = omega * t;  // angle at time t
    
    // Position in circular orbit
    let x = r0 * angle.cos();
    let y = r0 * angle.sin();
    let z = 0.0;
    
    // Velocity in circular orbit
    let vx = -omega * r0 * angle.sin();
    let vy = omega * r0 * angle.cos();
    let vz = 0.0;
    
    Vector6::new(x, y, z, vx, vy, vz)
}

// Calculate orbital period for a circular orbit
fn orbital_period(mu: f64, r0: f64) -> f64 {
    2.0 * PI * (r0*r0*r0 / mu).sqrt()
}

// Calculate error between numerical and analytical solutions
fn calculate_error(numerical: &Vector6<f64>, analytical: &Vector6<f64>) -> f64 {
    // Calculate the Euclidean norm of the difference vector
    let mut sum_squared = 0.0;
    for i in 0..6 {
        let diff = numerical[i] - analytical[i];
        sum_squared += diff * diff;
    }
    sum_squared.sqrt()
}

fn main() {
    // Earth's gravitational parameter (m^3/s^2)
    let mu = 3.986004418e14;
    
    // Initial orbit parameters (circular orbit at altitude of ~408km - ISS-like orbit)
    let earth_radius = 6_378_137.0; // meters
    let orbit_altitude = 408_000.0; // meters
    let orbit_radius = earth_radius + orbit_altitude;
    
    // Calculate orbital velocity for circular orbit
    let v_circular = f64::sqrt(mu / orbit_radius);
    
    // Initial conditions: starting at (r, 0, 0) with velocity (0, v, 0)
    let y0 = Vector6::new(
        orbit_radius, 0.0, 0.0,         // initial position
        0.0, v_circular, 0.0            // initial velocity
    );
    
    // Calculate orbital period
    let period = orbital_period(mu, orbit_radius);
    
    // Simulation for 10 complete orbits
    let t0 = 0.0;
    let tf = 1000.0 * period;
    
    // Create the ODE problem
    let system = TwoBodyProblem { mu };
    
    // Initialize solver with tight tolerances
    let rtol = 1e-12;
    let atol = 1e-12;
    let mut solver = DOP853::new().rtol(rtol).atol(atol);
    
    // Create and solve the initial value problem
    let ivp = ODEProblem::new(system, t0, tf, y0);
    let result = ivp.solve(&mut solver).unwrap();
    
    // Get the final state
    let (t_final, u_final) = result.last().unwrap();
    
    // Calculate analytical solution at final time
    let analytical = analytical_solution(mu, orbit_radius, *t_final);
    
    // Calculate error
    let error = calculate_error(u_final, &analytical);
    
    // Print results
    println!("Two-Body Problem (Earth Orbit) - Numerical vs. Analytical Solution");
    println!("Simulation time: {:.1} s ({:.2} orbits)", t_final, t_final / period);
    println!("Numerical solution: [{:.5}, {:.5}, {:.5}, {:.5}, {:.5}, {:.5}]", 
             u_final[0], u_final[1], u_final[2], u_final[3], u_final[4], u_final[5]);
    println!("Analytical solution: [{:.5}, {:.5}, {:.5}, {:.5}, {:.5}, {:.5}]", 
             analytical[0], analytical[1], analytical[2], analytical[3], analytical[4], analytical[5]);
    println!("Error: {:.5e}", error);
}
