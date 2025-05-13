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

plot:
    @echo "Plotting benchmark results..."
    @echo "Histgrams plots..."
    python ./plot_histogram.py ./target/vanderpol.json --type barstacked --labels Rust,Fortran --title "Van der Pol Oscillator" --legend-location "upper right" --output ./target/vanderpol_histogram.png
    python ./plot_histogram.py ./target/cr3bp.json --type barstacked --labels Rust,Fortran --title "CR3BP" --legend-location "upper right" --output ./target/cr3bp_histogram.png
    python ./plot_histogram.py ./target/lorenz.json --type barstacked --labels Rust,Fortran --title "Lorenz System (Long-running)" --legend-location "upper right" --output ./target/lorenz_histogram.png
    @echo "Whisker plots..."
    python ./plot_whisker.py ./target/vanderpol.json --labels Rust,Fortran --title "Van der Pol Oscillator" --output ./target/vanderpol_whisker.png
    python ./plot_whisker.py ./target/cr3bp.json --labels Rust,Fortran --title "CR3BP" --output ./target/cr3bp_whisker.png
    python ./plot_whisker.py ./target/lorenz.json --labels Rust,Fortran --title "Lorenz System (Long-running)" --output ./target/lorenz_whisker.png


# Clean all project files and benchmark results
clean:
    cd cr3bp && cd rust && cargo clean
    cd lorenz && cd rust && cargo clean
    cd vanderpol && cd rust && cargo clean
    rm -f ./vanderpol/fortran/target/vanderpol
    rm -f ./lorenz/fortran/target/lorenz
    rm -f ./cr3bp/fortran/target/cr3bp
    rm -f ./target/vanderpol.md ./target/vander
    rm -f ./target/lorenz.md ./target/lorenz.jsonpol.json
    rm -f ./target/cr3bp.md ./target/cr3bp.json