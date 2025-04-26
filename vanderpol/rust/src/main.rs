use differential_equations::ode::*;
use nalgebra::Vector2;

// Van der Pol oscillator ODE
struct VanDerPol {
    pub mu: f64,
}

impl ODE<f64, Vector2<f64>> for VanDerPol {
    fn diff(&self, _t: f64, u: &Vector2<f64>, dudt: &mut Vector2<f64>) {
        dudt.x = u.y;
        dudt.y = self.mu * (1.0 - u.x * u.x) * u.y - u.x;
    }
}

fn main() {
    // Van der Pol Oscillator
    let mu = 0.2;
    let system = VanDerPol { mu };
    
    // Numerical Method
    let atol = 1e-12;
    let rtol = 1e-12;
    let mut solver = DOP853::new().rtol(rtol).atol(atol);

    // Initial Value Problem
    let t0 = 0.0;
    let tf = 1000.0;
    let y0 = Vector2::new(0.0, 0.1);
    let ivp = IVP::new(system, t0, tf, y0);
    
    // Solve the ODE
    let result = ivp.solve(&mut solver).unwrap();

    // Print the results
    let (t, u) = result.last().unwrap();
    println!("t = {:.1}, u = {:.5}, {:.5}", t, u.x, u.y);
}