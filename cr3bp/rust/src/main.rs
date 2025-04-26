use differential_equations::ode::*;
use differential_equations::derive::State;

// Circular Restricted Three Body Problem (CR3BP)
pub struct Cr3bp {
    pub mu: f64, // CR3BP mass ratio
}

impl ODE<f64, StateVector<f64>> for Cr3bp {
    fn diff(&self, _t: f64, sv: &StateVector<f64>, dsdt: &mut StateVector<f64>) {
        // Mass ratio
        let mu = self.mu;

        // Distance to primary body
        let r13 = ((sv.x + mu).powi(2) + sv.y.powi(2) + sv.z.powi(2)).sqrt();
        // Distance to secondary body
        let r23 = ((sv.x - 1.0 + mu).powi(2) + sv.y.powi(2) + sv.z.powi(2)).sqrt();

        // Computing three-body dynamics
        dsdt.x = sv.vx;
        dsdt.y = sv.vy;
        dsdt.z = sv.vz;
        dsdt.vx = sv.x + 2.0 * sv.vy
            - (1.0 - mu) * (sv.x + mu) / r13.powi(3)
            - mu * (sv.x - 1.0 + mu) / r23.powi(3);
        dsdt.vy = sv.y - 2.0 * sv.vx - (1.0 - mu) * sv.y / r13.powi(3) - mu * sv.y / r23.powi(3);
        dsdt.vz = -(1.0 - mu) * sv.z / r13.powi(3) - mu * sv.z / r23.powi(3);
    }
}

#[derive(State)]
pub struct StateVector<T> {
    pub x: T,
    pub y: T,
    pub z: T,
    pub vx: T,
    pub vy: T,
    pub vz: T,
}

fn main() {
    // Initialize method with relative and absolute tolerances
    let rtol = 1e-12;
    let atol = 1e-12;
    let mut solver = DOP853::new()
        .rtol(rtol)
        .atol(atol);

    // Initialialize the CR3BP ode for the Earth-Moon system
    let ode = Cr3bp {
        mu: 0.012150585609624,
    };

    // Initial value problem
    let t0 = 0.0;
    let tf = 10.0 * 1.509263667286943;
    let sv = StateVector {
        x: 1.021881345465263,
        y: 0.0,
        z: -0.182000000000000,
        vx: 0.0,
        vy: -0.102950816739606,
        vz: 0.0
    };
    let cr3bp_ivp = IVP::new(ode, t0, tf, sv);

    // Solve the ODE
    let result = cr3bp_ivp.solve(&mut solver).unwrap();

    // Print the results
    let (t, u) = result.last().unwrap();
    println!("t = {:.1}, u = {:.5}, {:.5}, {:.5}", t, u.x, u.y, u.z);
}