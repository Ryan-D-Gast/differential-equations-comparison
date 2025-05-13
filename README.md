# Differential Equations Solver Comparison

Benchmark and comparison of differential equations solver implementations across multiple programming languages using the [hyperfine](https://github.com/sharkdp/hyperfine) command-line benchmarking tool.

## Compared Implementations

- **Rust**: Using the [differential-equations](https://github.com/Ryan-D-Gast/differential-equations) crate
- **Fortran**: Using the original [Hairer](https://www.unige.ch/~hairer/software.html) implementation

Feel free to add more!

## Test Problems

### 1. Van der Pol Oscillator

The Van der Pol oscillator is a non-conservative oscillator with non-linear damping, described by:

$$
\begin{aligned}
\dot{x} &= y \\
\dot{y} &= \mu(1-x^2)y - x
\end{aligned}
$$

### 2. Circular Restricted Three-Body Problem (CR3BP)

The CR3BP models the motion of a small body under the gravitational influence of two massive bodies, described by:

$$
\begin{aligned}
\dot{x} &= v_x \\
\dot{y} &= v_y \\
\dot{z} &= v_z \\
\dot{v}_x &= x + 2v_y - \frac{(1-\mu)(x+\mu)}{r_1^3} - \frac{\mu(x-1+\mu)}{r_2^3} \\
\dot{v}_y &= y - 2v_x - \frac{(1-\mu)y}{r_1^3} - \frac{\mu y}{r_2^3} \\
\dot{v}_z &= -\frac{(1-\mu)z}{r_1^3} - \frac{\mu z}{r_2^3}
\end{aligned}
$$

Where:

$$
\begin{aligned}
r_1 &= \sqrt{(x+\mu)^2 + y^2 + z^2} \\
r_2 &= \sqrt{(x-1+\mu)^2 + y^2 + z^2}
\end{aligned}
$$

### 3. Lorenz System (Long-running Benchmark)

The Lorenz system is a set of ordinary differential equations that exhibit chaotic behavior. This problem is designed as a long-running benchmark to better evaluate performance differences between implementations. It is described by:

$$
\begin{aligned}
\dot{x} &= \sigma(y - x) \\
\dot{y} &= x(\rho - z) - y \\
\dot{z} &= xy - \beta z
\end{aligned}
$$

Where:
- $\sigma = 10$
- $\rho = 28$
- $\beta = 8/3$

The simulation runs for an extended time period (t = 10,000) to stress test the solvers.

> **Note on Divergent Results**: The Lorenz system is inherently chaotic, meaning implementations in different languages will naturally produce divergent results over long time periods, even when using the same numerical algorithm. This is expected behavior due to tiny differences in floating-point handling, and doesn't indicate an error in either implementation. When the `tf/xend` was set to 10 seconds for both implementations the results were the same. Because of this comparing the results of the Lorenz system isn't perfect but that is why you compare many different equations to see the trend!

## Directory Structure

```
differential-equations-comparison/
├── lib/                  # Common libraries
│   └── dop853.f          # Fortran DOP853 implementation
├── vanderpol/            # Van der Pol oscillator
│   ├── rust/             # Rust implementation
│   └── fortran/          # Fortran implementation
├── cr3bp/                # Circular Restricted Three-Body Problem
│   ├── rust/             # Rust implementation
│   └── fortran/          # Fortran implementation
├── lorenz/               # Lorenz system (long-running benchmark)
│   ├── rust/             # Rust implementation
│   └── fortran/          # Fortran implementation
├── target/               # Benchmark results
└── justfile              # Task runner configuration
```

## Usage

To run the benchmarks and generate plots, you can use the `justfile` commands. Make sure you have [Just](https://github.com/casey/just).

```
just bench
just plot
```

View results in `target/` directory.

# Sample Results

This test was on a Windows 10 machine with an Intel i5-9400F @ 2.90Ghz and 16GB of RAM.

| Problem | Implementation | Mean [ms] | Min [ms] | Max [ms] | Relative |
| :---: |:---:|---:|---:|---:|---:|
| Van der Pol Osc. | Rust | 20.3 ± 1.7 | 18.7 | 51.5 | 1.00 |
| Van der Pol Osc. | Fortran | 22.7 ± 1.8 | 21.4 | 59.2 | 1.12 ± 0.13 |
| CR3BP | Rust | 19.6 ± 2.2 | 18.4 | 58.0 | 1.00 |
| CR3BP | Fortran | 21.2 ± 1.9 | 20.0 | 60.5 | 1.08 ± 0.16 |
| Lorenz System | Rust | 235.0 ± 2.0 | 232.9 | 245.3 | 1.00 |
| Lorenz System | Fortran | 247.0 ± 7.3 | 243.8 | 296.4 | 1.05 ± 0.03 |

We can see that the Rust implementation is about 10% faster than the Fortran implementation for both short problems. The long-running Lorenz system benchmark shows that Rust maintains its performance advantage with approximately 5% better execution time compared to Fortran.
