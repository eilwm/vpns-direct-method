# Installation and Setup Guide

## Prerequisites

### Software Requirements
- **MATLAB** R2019b or later
- No additional toolboxes required

### System Requirements
- **Memory**: Minimum 8 GB RAM (16 GB recommended for larger grids)
- **Storage**: ~100 MB for code, variable for results
- **OS**: Windows, macOS, or Linux

## Installation

### Option 1: Clone from GitHub (Recommended)

```bash
# Clone the repository
git clone https://github.com/yourusername/VPNS-Solver.git

# Navigate to the directory
cd VPNS-Solver
```

### Option 2: Download ZIP

1. Download the ZIP file from GitHub
2. Extract to your desired location
3. Open MATLAB and navigate to the extracted directory

## Setup

### 1. Add Paths to MATLAB

Open MATLAB and run:

```matlab
% Navigate to VPNS-Solver directory
cd /path/to/VPNS-Solver

% Add all paths
addpath('src');
addpath(genpath('src'));

% Verify paths
which constructA  % Should return the full path to the function
```

Or create a `startup.m` file in your MATLAB home directory:

```matlab
% Add VPNS-Solver paths automatically on MATLAB startup
addpath('/path/to/VPNS-Solver/src');
addpath(genpath('/path/to/VPNS-Solver/src'));
```

### 2. Verify Installation

Run the verification script:

```matlab
cd tests
run_verification_tests
```

This will:
- Check that all required functions are accessible
- Verify basic functionality
- Run a small test case

### 3. Create Results Directory

```matlab
% Create output directory if it doesn't exist
if ~exist('results', 'dir')
    mkdir('results')
    mkdir('results/VelVecs')
end
```

## Quick Start

### Run Example Simulation

```matlab
% Navigate to examples directory
cd examples

% Run the lid-driven cavity example
run_lid_driven_cavity
```

### Run Full Solver

```matlab
% Navigate to src directory
cd src

% Edit parameters in main_vpns.m if desired
edit main_vpns.m

% Run the solver
main_vpns
```

## Configuration

### Adjusting Grid Resolution

In `main_vpns.m` or your script:

```matlab
P = 51;   % For quick tests
P = 75;   % For standard resolution
P = 101;  % For higher resolution (slower)
```

**Note**: SVD computation time scales as O(P⁴), so doubling P increases time by ~16×.

### Adjusting Time Step

```matlab
dt = 0.01;     % Default
dt = 0.001;    % For higher accuracy (but slower)

% Or use adaptive time stepping (future feature)
CFL_target = 0.5;
dt = CFL_target * min(dx / max(abs(u)));
```

### Fluid Properties

```matlab
% Water (default)
rho = 999.8;   % kg/m³
mu = 0.9;      % Pa·s

% Air at 20°C
rho = 1.2;     % kg/m³
mu = 1.8e-5;   % Pa·s

% Oil
rho = 900;     % kg/m³
mu = 100;      % Pa·s
```

## Troubleshooting

### Common Issues

#### Issue: "Undefined function or variable 'VectorHandle'"

**Solution**: The VectorHandle class is not on your path.

```matlab
% Add utils to path
addpath('src/utils');
```

Or implement your own VectorHandle class (see `src/utils/VectorHandle.m`).

#### Issue: "Out of memory" during SVD

**Solution**: Reduce grid size or use sparse matrix operations.

```matlab
% Reduce grid resolution
P = 51;  % Instead of 101

% Or upgrade to iterative solver (v2.0 feature)
```

#### Issue: "Matrix dimensions must agree" error

**Solution**: Check that all input vectors have correct dimensions.

```matlab
% Velocity should be 2*P*Q × 1
assert(length(U) == 2*P*Q);

% Constraint matrix should be P*Q × 2*P*Q
assert(all(size(A) == [P*Q, 2*P*Q]));
```

#### Issue: Simulation diverges or becomes unstable

**Solution**: Reduce time step or check CFL condition.

```matlab
% Calculate CFL number
u_max = max(abs(U));
CFL = u_max * dt / dx;

% CFL should be < 1 for stability
if CFL > 1
    dt = 0.5 * dx / u_max;  % Adjust time step
end
```

### Getting Help

If you encounter issues:

1. **Check documentation**: See `docs/` for detailed information
2. **Review examples**: Look at `examples/run_lid_driven_cavity.m`
3. **Open an issue**: Report bugs on GitHub
4. **Contact maintainers**: See README.md for contact information

## Verification

### Test Cases

Run these to verify correct installation:

```matlab
% Test 1: Small grid
P = 21; Q = 21;
% Run simulation and check for convergence

% Test 2: Benchmark comparison
% Compare with Ghia et al. (1982) data
compare_with_benchmark('results/final_state.mat', 'benchmark_data.mat');
```

### Expected Results

For lid-driven cavity at Re ≈ 20:
- Primary vortex center near (0.5, 0.5)
- Normalized Appellian should decrease with time
- No instabilities or divergence

## Performance Tips

### For Faster Simulations

1. **Start with coarse grid**: Test with P=51 before running P=101
2. **Use sparse operations**: Ensure all matrices are sparse
3. **Reduce save frequency**: Save every 10 or 50 steps, not every step
4. **Preallocate arrays**: Initialize all arrays before time loop
5. **Profile code**: Use MATLAB Profiler to identify bottlenecks

```matlab
% Example: Reduce save frequency
save_interval = 50;  % Save every 50 steps instead of every step
```

### Memory Management

```matlab
% Clear large arrays when done
clear A P_SMHandle N_SMHandle;

% Save only necessary data
save('results.mat', 'U', 'S_star', '-v7.3');  % Use compressed format
```

## Next Steps

After successful installation:

1. **Run examples**: Explore `examples/` directory
2. **Read documentation**: Study `docs/theory.md` for mathematical background
3. **Modify parameters**: Experiment with different Reynolds numbers
4. **Visualize results**: Create plots and animations
5. **Extend functionality**: Implement new features (see CONTRIBUTING.md)

## Updating

To update to the latest version:

```bash
cd VPNS-Solver
git pull origin main
```

Then restart MATLAB to ensure new paths are loaded.

## Uninstallation

To remove VPNS-Solver:

1. Remove paths from MATLAB:
   ```matlab
   rmpath(genpath('/path/to/VPNS-Solver'));
   ```

2. Delete the directory:
   ```bash
   rm -rf /path/to/VPNS-Solver
   ```

---

**Questions?** Open an issue on GitHub or contact the development team.
