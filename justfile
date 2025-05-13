# Common variables
RUNS := "50"
WARMUP := "5"
OPT := "-O3"

# Default recipe to run when just is called without arguments
default:
    @just --list

# Build both Rust and Fortran implementations
build:
    @echo "Building vanderpol implementations..."
    cd vanderpol && cd rust && cargo build --release
    @mkdir -p vanderpol/fortran/target
    gfortran {{OPT}} -o vanderpol/fortran/target/vanderpol vanderpol/fortran/vanderpol.f lib/dop853.f -w

    @echo "Building cr3bp implementations..."
    cd cr3bp && cd rust && cargo build --release
    @mkdir -p cr3bp/fortran/target
    gfortran {{OPT}} -o cr3bp/fortran/target/cr3bp cr3bp/fortran/cr3bp.f lib/dop853.f -w
    
    @echo "Building lorenz implementations..."
    cd lorenz && cd rust && cargo build --release
    @mkdir -p lorenz/fortran/target
    gfortran {{OPT}} -o lorenz/fortran/target/lorenz lorenz/fortran/lorenz.f lib/dop853.f -w
    
    @echo "Building two-body problem implementations..."
    cd twobody && cd rust && cargo build --release
    @mkdir -p twobody/fortran/target
    gfortran {{OPT}} -o twobody/fortran/target/twobody twobody/fortran/twobody.f lib/dop853.f -w

# Run both implementations
run: build
    @echo "Van der Pol Oscillator"
    @echo "Running Rust implementation:"
    ./vanderpol/rust/target/release/vanderpol
    @echo "Running Fortran implementation:"
    ./vanderpol/fortran/target/vanderpol

    @echo "Circular Restricted Three-Body Problem (CR3BP)"
    @echo "Running Rust implementation:"
    ./cr3bp/rust/target/release/cr3bp
    @echo "Running Fortran implementation:"
    ./cr3bp/fortran/target/cr3bp
    
    @echo "Lorenz System (Long-running Benchmark)"
    @echo "Running Rust implementation:"
    ./lorenz/rust/target/release/lorenz
    @echo "Running Fortran implementation:"
    ./lorenz/fortran/target/lorenz
    
    @echo "Two-Body Problem (Earth Orbit)"
    @echo "Running Rust implementation:"
    ./twobody/rust/target/release/twobody
    @echo "Running Fortran implementation:"
    ./twobody/fortran/target/twobody

# Benchmark both implementations
bench: build
    @mkdir -p target

    @echo "Benchmarking Van der Pol Oscillator implementations..."
    hyperfine -i -N \
        --warmup {{WARMUP}} \
        --runs {{RUNS}} \
        --export-markdown target/vanderpol.md \
        --export-json target/vanderpol.json \
        './vanderpol/rust/target/release/vanderpol' \
        './vanderpol/fortran/target/vanderpol'

    @echo "Benchmarking CR3BP implementations..."
    hyperfine -i -N \
        --warmup {{WARMUP}} \
        --runs {{RUNS}} \
        --export-markdown target/cr3bp.md \
        --export-json target/cr3bp.json \
        './cr3bp/rust/target/release/cr3bp' \
        './cr3bp/fortran/target/cr3bp'
        
    @echo "Benchmarking Lorenz System (Long-running) implementations..."
    hyperfine -i -N \
        --warmup {{WARMUP}} \
        --runs {{RUNS}} \
        --export-markdown target/lorenz.md \
        --export-json target/lorenz.json \
        './lorenz/rust/target/release/lorenz' \
        './lorenz/fortran/target/lorenz'
        
    @echo "Benchmarking Two-Body Problem (Earth Orbit) implementations..."
    hyperfine -i -N \
        --warmup {{WARMUP}} \
        --runs {{RUNS}} \
        --export-markdown target/twobody.md \
        --export-json target/twobody.json \
        './twobody/rust/target/release/twobody' \
        './twobody/fortran/target/twobody'

plot:
    @echo "Plotting benchmark results..."
    @echo "Histgrams plots..."
    python ./plot_histogram.py ./target/vanderpol.json --type barstacked --labels Rust,Fortran --title "Van der Pol Oscillator" --legend-location "upper right" --output ./target/vanderpol_histogram.png
    python ./plot_histogram.py ./target/cr3bp.json --type barstacked --labels Rust,Fortran --title "CR3BP" --legend-location "upper right" --output ./target/cr3bp_histogram.png
    python ./plot_histogram.py ./target/lorenz.json --type barstacked --labels Rust,Fortran --title "Lorenz System (Long-running)" --legend-location "upper right" --output ./target/lorenz_histogram.png
    python ./plot_histogram.py ./target/twobody.json --type barstacked --labels Rust,Fortran --title "Two-Body Problem (Earth Orbit)" --legend-location "upper right" --output ./target/twobody_histogram.png
    @echo "Whisker plots..."
    python ./plot_whisker.py ./target/vanderpol.json --labels Rust,Fortran --title "Van der Pol Oscillator" --output ./target/vanderpol_whisker.png
    python ./plot_whisker.py ./target/cr3bp.json --labels Rust,Fortran --title "CR3BP" --output ./target/cr3bp_whisker.png
    python ./plot_whisker.py ./target/lorenz.json --labels Rust,Fortran --title "Lorenz System (Long-running)" --output ./target/lorenz_whisker.png
    python ./plot_whisker.py ./target/twobody.json --labels Rust,Fortran --title "Two-Body Problem (Earth Orbit)" --output ./target/twobody_whisker.png


# Clean all project files and benchmark results
clean:
    cd cr3bp && cd rust && cargo clean
    cd lorenz && cd rust && cargo clean
    cd vanderpol && cd rust && cargo clean
    cd twobody && cd rust && cargo clean
    rm -f ./vanderpol/fortran/target/vanderpol
    rm -f ./lorenz/fortran/target/lorenz
    rm -f ./cr3bp/fortran/target/cr3bp
    rm -f ./twobody/fortran/target/twobody
    rm -f ./target/vanderpol.md ./target/vanderpol.json
    rm -f ./target/lorenz.md ./target/lorenz.json
    rm -f ./target/cr3bp.md ./target/cr3bp.json
    rm -f ./target/twobody.md ./target/twobody.json