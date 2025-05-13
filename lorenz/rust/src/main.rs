use differential_equations::prelude::*;
use nalgebra::Vector3;

// Lorenz system ODE
struct Lorenz {
    pub sigma: f64,
    pub rho: f64,
    pub beta: f64,
}

impl ODE<f64, Vector3<f64>> for Lorenz {
    fn diff(&self, _t: f64, u: &Vector3<f64>, dudt: &mut Vector3<f64>) {
        dudt.x = self.sigma * (u.y - u.x);
        dudt.y = u.x * (self.rho - u.z) - u.y;
        dudt.z = u.x * u.y - self.beta * u.z;
    }
}

fn main() {
    // Lorenz system with classic chaotic parameters
    let sigma = 10.0;
    let rho = 28.0;
    let beta = 8.0 / 3.0;
    let system = Lorenz { sigma, rho, beta };
    
    // Numerical Method with tight tolerances for accuracy
    let atol = 1e-12;
    let rtol = 1e-12;
    let mut solver = DOP853::new().rtol(rtol).atol(atol);

    // Initial Value Problem with long simulation time to better test performance
    let t0 = 0.0;
    let tf = 10000.0; // Much longer simulation time to stress-test the solvers
    let y0 = Vector3::new(1.0, 1.0, 1.0);
    let ivp = ODEProblem::new(system, t0, tf, y0);
    
    // Solve the ODE
    let result = ivp.solve(&mut solver).unwrap();

    // Print the results
    let (t, u) = result.last().unwrap();
    println!("t = {:.1}, u = {:.5}, {:.5}, {:.5}", t, u.x, u.y, u.z);
}
