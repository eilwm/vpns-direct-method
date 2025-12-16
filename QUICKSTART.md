# VPNS Solver Quick Reference

## Installation (One-time Setup)

```matlab
% Navigate to VPNS-Solver directory
cd /path/to/VPNS-Solver

% Run path setup
setup_vpns_paths

% Verify installation
cd tests
run_verification_tests
```

## Running a Simulation

### Quick Start (Example)
```matlab
cd examples
run_lid_driven_cavity
```

### Full Simulation
```matlab
cd src
edit main_vpns.m    % Adjust parameters if desired
main_vpns           % Run simulation
```

## Key Parameters

### Grid Resolution
```matlab
P = 51;   % Small grid (fast, ~seconds)
P = 75;   % Medium grid (moderate, ~10s-1min)
P = 101;  % Large grid (slow, ~5-10min)
```

### Fluid Properties
```matlab
% Water (default)
rho = 999.8;  % Density [kg/m³]
mu = 0.9;     % Dynamic viscosity [Pa·s]
nu = mu/rho;  % Kinematic viscosity [m²/s]
```

### Boundary Conditions
```matlab
U_lid = 0.02;  % Lid velocity [m/s]
% Walls: u = v = 0 (no-slip)
```

### Time Integration
```matlab
dt = 0.01;      % Time step [s]
n_steps = 1000; % Number of steps
```

## Important Equations

### Constraint (Incompressibility)
```
∇·u = 0  ⟹  A·ü = 0
```

### Free Acceleration
```
C = -(u·∇)u + ν∇²u + f
```

### Projection
```
ü* = (I - P)·M^(-1/2)·C
```

### Appellian
```
S* = (1/2)||P·C̃||²
```

## File Structure

```
VPNS-Solver/
├── src/
│   ├── main_vpns.m          # Main solver
│   ├── core/                # Core algorithms
│   ├── boundary/            # Boundary handlers
│   ├── forces/              # Force computation
│   └── utils/               # Utilities
├── examples/                # Example scripts
├── docs/                    # Documentation
└── tests/                   # Verification tests
```

## Common Tasks

### Change Reynolds Number
```matlab
% Re = U_lid * L / nu
U_lid = 0.1;   % Increase lid speed
% OR
nu = 0.001;    % Decrease viscosity
```

### Save Results
```matlab
% Results automatically saved in results/VelVecs/
% Load saved data:
load('results/VelVecs/U_vec_100.mat');
```

### Visualize Results
```matlab
% Plot velocity magnitude
U_field = reshape(U, [2, P*Q]);
u = U_field(1, :);
v = U_field(2, :);
speed = sqrt(u.^2 + v.^2);

% Create contour plot
figure;
contourf(reshape(speed, [P, Q]));
colorbar;
title('Velocity Magnitude');
```

## Troubleshooting

### "Undefined function or variable"
```matlab
% Run path setup
setup_vpns_paths
```

### "Out of memory"
```matlab
% Reduce grid size
P = 51;  % Instead of P = 101
```

### Simulation diverges
```matlab
% Reduce time step
dt = 0.001;  % Instead of dt = 0.01

% Check CFL condition
CFL = max(abs(U)) * dt / dx;  % Should be < 1
```

## Key Functions

| Function | Purpose |
|----------|---------|
| `constructA` | Build constraint matrix |
| `constructC_ref` | Compute free acceleration |
| `optimUdot_ref` | Project to satisfy constraints |
| `VectorHandle` | Vector wrapper class |
| `SparseMatrixHandle` | Sparse matrix wrapper |

## Performance Tips

1. **Start small**: Test with P=51 before running larger grids
2. **Monitor memory**: Check `whos` to see variable sizes
3. **Reduce saves**: Save every 10-50 steps, not every step
4. **Use sparse**: Ensure all matrices are sparse
5. **Profile code**: Use MATLAB Profiler to find bottlenecks

## Validation

### Check Conservation
```matlab
% Divergence should be ~0
div_error = norm(A * U_dot);
fprintf('Divergence error: %.2e\n', div_error);
```

### Compare with Benchmark
- Ghia et al. (1982) for lid-driven cavity
- Check velocity profiles along centerlines

## Getting Help

1. **Documentation**: See `docs/` directory
2. **Examples**: Look in `examples/`
3. **Issues**: Report on GitHub
4. **Contributing**: See `CONTRIBUTING.md`

## Useful MATLAB Commands

```matlab
% Add paths
addpath(genpath('src'));

% Clear workspace
clear all; close all; clc;

% Profile performance
profile on
main_vpns
profile viewer

% Check variable size
whos

% Save workspace
save('my_simulation.mat');

% Load workspace
load('my_simulation.mat');
```

## Version Information

**Current Version**: 1.0.0 (Direct SVD Implementation)

**Known Limitations**:
- Grid size limited to P < 100 (O(N²) SVD cost)
- 2D only (3D planned for v2.0)
- Rectangular domains only

**Future Features** (v2.0+):
- AMG-based iterative solver (O(N) complexity)
- Adaptive time stepping
- 3D extension
- Complex geometries

---

**Quick Links**:
- [Full README](README.md)
- [Installation Guide](docs/installation.md)
- [Theory](docs/theory.md)
- [Contributing](CONTRIBUTING.md)
