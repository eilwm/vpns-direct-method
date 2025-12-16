# VPNS Solver: Variational Projection of Navier-Stokes

A MATLAB implementation of an incompressible fluid dynamics solver based on Udwadia-Kalaba formulation with direct SVD-based projection.

## Overview

The Variational Projection of Navier-Stokes (VPNS) solver uses a novel approach to solve incompressible fluid flow problems. This implementation is based on the methodology described in Udwadia & Kalaba's 1992 paper "A New Perspective on Lagrangian Mechanics."

### Key Features

- **Direct SVD Method**: Uses singular value decomposition for projection operations
- **Lid-Driven Cavity Flow**: Current implementation solves the classic lid-driven cavity benchmark problem
- **Structured Grid**: Uniform Cartesian grid with finite difference discretization
- **Explicit-Implicit Time Integration**: Explicit convection, implicit viscous treatment
- **Optimized Data Structures**: Efficient sparse matrix operations

## Physical Problem

The solver simulates incompressible flow in a 2D square cavity:

- **Domain**: Unit square (1m × 1m)
- **Boundary Conditions**:
  - Left, bottom, and right walls: No-slip (u=0, v=0)
  - Top wall (lid): Moving at U_lid = 1.0 m/s to the right
- **Fluid**: Water (ρ = 999.8 kg/m³, μ = 0.9 Pa·s)

## Mathematical Formulation

### Governing Equations

The incompressible Navier-Stokes equations:

```
∇·u = 0                           (continuity)
∂u/∂t + (u·∇)u = -∇p/ρ + ν∇²u    (momentum)
```

### Variational Projection Method

The method projects the unconstrained acceleration onto the constraint manifold:

1. **Free Acceleration**: 
   ```
   u̇^free = -(u·∇)u + ν∇²u + f
   ```

2. **Projection**: 
   ```
   u̇ = (I - P)M^(-1/2)·u̇^free
   ```
   where P is the Moore-Penrose pseudoinverse of the constraint matrix.

3. **Constraint Matrix A**: Discretized divergence-free constraint
   ```
   A·u̇ = 0  ⟹  ∇·u̇ = 0
   ```

## Repository Structure

```
VPNS-Solver/
├── README.md                 # This file
├── LICENSE                   # License information
├── src/                      # Source code
│   ├── main_vpns.m          # Main solver script
│   ├── core/                # Core solver functions
│   │   ├── constructA.m     # Constraint matrix construction
│   │   ├── constructC_ref.m # Free acceleration computation
│   │   └── optimUdot.m      # Optimization solver
│   ├── boundary/            # Boundary condition handlers
│   │   ├── cornersA_vis.m   # Corner constraints
│   │   ├── leftA_vis.m      # Left boundary constraints
│   │   ├── rightA_vis.m     # Right boundary constraints
│   │   ├── topA_vis.m       # Top boundary constraints
│   │   ├── bottomA_vis.m    # Bottom boundary constraints
│   │   └── interior_vis.m   # Interior constraints
│   ├── forces/              # Force computation
│   │   ├── cornersC_vis.m   # Corner free acceleration
│   │   ├── leftC_vis.m      # Left boundary free acceleration
│   │   ├── rightC_vis.m     # Right boundary free acceleration
│   │   ├── topC_vis.m       # Top boundary free acceleration
│   │   ├── bottomC_vis.m    # Bottom boundary free acceleration
│   │   └── interiorC_vis.m  # Interior free acceleration
│   └── utils/               # Utility functions
│       └── vtk_script_writer.m
├── examples/                # Example scripts
│   └── run_lid_driven_cavity.m
├── docs/                    # Documentation
│   ├── theory.md           # Mathematical theory
│   ├── user_guide.md       # User guide
│   └── api_reference.md    # API documentation
├── tests/                   # Test cases
└── results/                 # Output directory
```

## Requirements

### Software
- MATLAB R2019b or later
- Required MATLAB Toolboxes:
  - None (uses only base MATLAB functions)

### Dependencies (Not Included)
The following utility classes are referenced but not included in this release:
- `VectorHandle` - Vector wrapper class
- `SparseMatrixHandle` - Sparse matrix wrapper class  
- `generateMatrixHeatMap` - Matrix visualization utility
- `sparse_pinv` - Iterative pseudoinverse solver

Users can implement these as simple wrapper classes or modify the code to use native MATLAB arrays.

## Quick Start

### Installation

```bash
git clone https://github.com/yourusername/VPNS-Solver.git
cd VPNS-Solver
```

### Running the Solver

1. Open MATLAB and navigate to the repository directory
2. Add paths:
   ```matlab
   addpath('src');
   addpath('src/core');
   addpath('src/boundary');
   addpath('src/forces');
   addpath('src/utils');
   ```
3. Run the main script:
   ```matlab
   cd examples
   run_lid_driven_cavity
   ```

### Basic Usage

```matlab
%% Grid Setup
P = 75;                    % Grid points per dimension
dx = 1/(P+1);             % Grid spacing
dt = 0.01;                % Time step
n_steps = 1000;           % Number of time steps

%% Physical Properties
rho = 999.8;              % Density [kg/m³]
mu = 0.9;                 % Dynamic viscosity [Pa·s]
nu = mu/rho;              % Kinematic viscosity [m²/s]
U_lid = 0.02;             % Lid velocity [m/s]

%% Initialize solver and run
% (See examples/run_lid_driven_cavity.m for complete example)
```

## Output

The solver generates:
- **Velocity fields**: Stored at each time step in `results/VelVecs/`
- **Appellian evolution**: Normalized optimum Appellian vs time
- **Convergence plots**: Rate of change of Appellian

### Visualization
Results are saved in MATLAB `.mat` format and can be visualized using standard MATLAB plotting functions.

## Numerical Parameters

### Current Implementation
- Grid resolution: 75×75 (configurable)
- Time step: 0.01 s (adaptive time stepping recommended for production)
- Total simulation time: 10 s (1000 steps)
- Lid velocity: 0.02 m/s

### Stability Considerations
- Current version uses explicit time integration for convection
- Viscous terms can be treated implicitly for better stability (future enhancement)
- CFL condition should be monitored for explicit schemes

## Performance

### Computational Complexity
- Grid setup: O(N)
- Matrix assembly: O(N)
- SVD for projection: O(N²) - dominant cost
- Time integration: O(N) per step
- Overall: O(N²) for setup, O(N) per time step after projection matrices computed

### Memory Requirements
For P×P grid:
- Velocity field: 2P² doubles
- Constraint matrix A: ~4P² non-zeros (sparse)
- Projection matrices: Dense O(P⁴) - significant for large grids

**Note**: This direct SVD implementation is suitable for small to moderate grids (P < 100). For larger problems, consider the AMG-based iterative version described in `docs/AMG_PCG_VPNS.md`.

## Validation

The lid-driven cavity is a standard CFD benchmark. Results can be compared against:
- Ghia et al. (1982) benchmark solutions
- Other CFD solvers (OpenFOAM, Fluent, etc.)

Key validation metrics:
- Velocity profiles along centerlines
- Vortex center location
- Steady-state Appellian value

## Future Development

Planned enhancements:
1. **AMG-based solver**: Algebraic multigrid preconditioner for O(N) complexity
2. **Adaptive time stepping**: CFL-based automatic time step selection
3. **Extended geometries**: Support for non-rectangular domains
4. **3D extension**: Three-dimensional flow solver
5. **Parallel implementation**: GPU acceleration for large grids

See `docs/AMG_PCG_VPNS.md` for details on the next-generation solver.

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## Citation

If you use this code in your research, please cite:

```bibtex
@software{vpns_solver,
  author = {Kshitij Anand, Haithem E. Taha},
  title = {VPNS Solver: Variational Projection of Navier-Stokes},
  year = {2025},
  url = {https://github.com/eilwm/vpns-direct-method}
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## References

1. Udwadia, F. E., & Kalaba, R. E. (1992). A new perspective on constrained motion. *Proceedings of the Royal Society of London. Series A: Mathematical and Physical Sciences*, 439(1906), 407-410.

2. Ghia, U., Ghia, K. N., & Shin, C. T. (1982). High-Re solutions for incompressible flow using the Navier-Stokes equations and a multigrid method. *Journal of Computational Physics*, 48(3), 387-411.

## Contact

For questions, issues, or suggestions:
- Open an issue on GitHub
- Email: your.email@institution.edu

## Acknowledgments

This work was developed as part of research in computational fluid dynamics and constrained mechanics.

---

**Version**: 1.0.0 (Direct SVD Implementation)  
**Last Updated**: December 2025
