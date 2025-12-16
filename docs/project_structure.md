# VPNS Solver Project Structure

This document describes the organization of the VPNS Solver codebase.

## Directory Tree

```
VPNS-Solver/
│
├── README.md                      # Main project documentation
├── LICENSE                        # MIT License
├── CHANGELOG.md                   # Version history and changes
├── CONTRIBUTING.md                # Contribution guidelines
├── .gitignore                     # Git ignore patterns
├── setup_vpns_paths.m            # Path setup script
│
├── src/                          # Source code
│   ├── main_vpns.m              # Main solver script
│   │
│   ├── core/                    # Core solver algorithms
│   │   ├── constructA.m         # Constraint matrix construction
│   │   ├── constructC_ref.m     # Free acceleration computation
│   │   └── optimUdot_ref.m      # Udwadia-Kalaba projection
│   │
│   ├── boundary/                # Boundary condition handlers
│   │   ├── interior_vis.m       # Interior point constraints
│   │   ├── cornersA_vis.m       # Corner constraints
│   │   ├── leftA_vis.m          # Left boundary constraints
│   │   ├── rightA_vis.m         # Right boundary constraints
│   │   ├── topA_vis.m           # Top boundary constraints
│   │   └── bottomA_vis.m        # Bottom boundary constraints
│   │
│   ├── forces/                  # Force computation routines
│   │   ├── interiorC_vis.m      # Interior free acceleration
│   │   ├── cornersC_vis.m       # Corner free acceleration
│   │   ├── leftC_vis.m          # Left boundary free acceleration
│   │   ├── rightC_vis.m         # Right boundary free acceleration
│   │   ├── topC_vis.m           # Top boundary free acceleration
│   │   └── bottomC_vis.m        # Bottom boundary free acceleration
│   │
│   └── utils/                   # Utility functions and classes
│       ├── VectorHandle.m       # Vector wrapper class
│       ├── SparseMatrixHandle.m # Sparse matrix wrapper class
│       └── vtk_script_writer.m  # VTK output utility
│
├── examples/                     # Example scripts and tutorials
│   └── run_lid_driven_cavity.m  # Lid-driven cavity example
│
├── docs/                         # Documentation
│   ├── theory.md                # Mathematical theory and formulation
│   ├── installation.md          # Installation and setup guide
│   ├── user_guide.md            # User guide (to be created)
│   └── api_reference.md         # API documentation (to be created)
│
├── tests/                        # Test cases and validation
│   └── run_verification_tests.m # Verification script (to be created)
│
└── results/                      # Output directory (created at runtime)
    └── VelVecs/                 # Velocity field data
```

## File Descriptions

### Root Directory

| File | Purpose |
|------|---------|
| `README.md` | Project overview, features, installation, usage |
| `LICENSE` | MIT License text |
| `CHANGELOG.md` | Version history and release notes |
| `CONTRIBUTING.md` | Guidelines for contributors |
| `.gitignore` | Files to exclude from version control |
| `setup_vpns_paths.m` | Script to add paths to MATLAB |

### src/ - Source Code

#### Core Algorithms (`src/core/`)

| File | Description | Key Functions |
|------|-------------|---------------|
| `constructA.m` | Builds constraint matrix for ∇·u = 0 | Divergence operator assembly |
| `constructC_ref.m` | Computes free acceleration | Convection, viscosity, forcing |
| `optimUdot_ref.m` | Udwadia-Kalaba projection | Optimal constrained acceleration |

#### Boundary Conditions (`src/boundary/`)

| File | Description | Grid Points |
|------|-------------|-------------|
| `interior_vis.m` | Interior point constraints | All non-boundary points |
| `cornersA_vis.m` | Corner constraints | 4 corners |
| `leftA_vis.m` | Left wall constraints | Left edge (excl. corners) |
| `rightA_vis.m` | Right wall constraints | Right edge (excl. corners) |
| `topA_vis.m` | Top lid constraints | Top edge (excl. corners) |
| `bottomA_vis.m` | Bottom wall constraints | Bottom edge (excl. corners) |

#### Force Computation (`src/forces/`)

Similar structure to boundary conditions, but computes free acceleration rather than constraints.

| File | Description |
|------|-------------|
| `interiorC_vis.m` | Interior point free acceleration |
| `cornersC_vis.m` | Corner point free acceleration |
| `leftC_vis.m` | Left boundary free acceleration |
| `rightC_vis.m` | Right boundary free acceleration |
| `topC_vis.m` | Top boundary free acceleration |
| `bottomC_vis.m` | Bottom boundary free acceleration |

#### Utilities (`src/utils/`)

| File | Description |
|------|-------------|
| `VectorHandle.m` | Handle class for pass-by-reference vectors |
| `SparseMatrixHandle.m` | Handle class for sparse matrices with operator overloading |
| `vtk_script_writer.m` | Utility for writing VTK format output |

### examples/ - Example Scripts

| File | Description |
|------|-------------|
| `run_lid_driven_cavity.m` | Complete example of lid-driven cavity simulation |

### docs/ - Documentation

| File | Content |
|------|---------|
| `theory.md` | Mathematical theory, discretization, algorithms |
| `installation.md` | Setup, configuration, troubleshooting |
| `user_guide.md` | Usage instructions, tutorials (future) |
| `api_reference.md` | Function documentation (future) |

### tests/ - Test Suite

Test files for validation and verification (to be implemented).

### results/ - Output

Runtime-generated directory for simulation results:
- Velocity fields at each time step
- Appellian evolution
- Visualization data

## Code Organization Principles

### Modularity
- **Core algorithms** are independent of specific boundary conditions
- **Boundary handlers** are interchangeable for different geometries
- **Utilities** provide reusable components

### Separation of Concerns
- **Constraint matrix (A)**: Purely geometric, encodes divergence operator
- **Free acceleration (C)**: Physics (convection, viscosity, forcing)
- **Projection (optimUdot)**: Mathematical operation, problem-independent

### Naming Conventions

| Pattern | Meaning | Example |
|---------|---------|---------|
| `*A_vis.m` | Constraint matrix construction | `leftA_vis.m` |
| `*C_vis*.m` | Free acceleration computation | `interiorC_vis.m` |
| `construct*.m` | Assembly routines | `constructA.m` |
| `optim*.m` | Optimization/solver routines | `optimUdot_ref.m` |
| `*_ref` | Reference implementation (vs. optimized) | `constructC_ref.m` |

## Data Flow

```
Input Parameters (P, Q, ρ, ν, U_lid, dt)
  ↓
Grid Setup (corners, boundaries, interior points)
  ↓
Matrix Construction (M, A)
  ↓
Projection Operators (P, N via SVD)
  ↓
┌─────────────────────────────────────┐
│ Time Integration Loop               │
│  ↓                                  │
│ Compute Free Acceleration (C)       │
│  ↓                                  │
│ Project to Satisfy Constraints (ü*) │
│  ↓                                  │
│ Update Velocity (u = u + dt·ü*)    │
│  ↓                                  │
│ Save Results                        │
└─────────────────────────────────────┘
  ↓
Post-Processing (plots, animations)
```

## Extension Points

### Adding New Boundary Conditions
1. Create new `*A_vis.m` file in `src/boundary/`
2. Create corresponding `*C_vis.m` file in `src/forces/`
3. Add calls in `constructA.m` and `constructC_ref.m`

### Adding New Geometries
1. Modify grid setup in main script
2. Update boundary point classification
3. Implement specialized boundary handlers if needed

### Adding New Physics
1. Modify free acceleration computation in `src/forces/`
2. Add new terms (e.g., buoyancy, rotation)
3. Update constraint matrix if needed

### Adding New Solvers
1. Implement in new file (e.g., `optimUdot_amg.m`)
2. Replace call in main time loop
3. Maintain same interface for compatibility

## Performance Considerations

### Memory Footprint
- **Velocity**: 2·P·Q doubles (~16 bytes each)
- **Matrices**: Sparse, ~4 non-zeros per row
- **Total**: ~O(P²) for structured grid

### Computational Cost
- **Setup (SVD)**: O(P⁴) - one time
- **Per time step**: O(P²) - sparse operations

### Scalability
| Grid Size | Memory | SVD Time | Step Time |
|-----------|--------|----------|-----------|
| 51×51 | ~1 MB | ~0.1 s | ~0.01 s |
| 101×101 | ~8 MB | ~5 s | ~0.05 s |
| 201×201 | ~60 MB | ~300 s | ~0.2 s |

## Version Control

### Git Workflow
- `main` branch: Stable releases
- `develop` branch: Active development
- Feature branches: `feature/description`
- Hotfix branches: `hotfix/description`

### Tracked Files
- All source code (`.m` files)
- Documentation (`.md` files)
- License and configuration files

### Ignored Files (see `.gitignore`)
- Results and output files
- Temporary files
- IDE-specific files
- Large data files

---

*This structure is designed for clarity, maintainability, and extensibility.*
