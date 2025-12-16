# Mathematical Theory of VPNS Solver

## Overview

The Variational Projection of Navier-Stokes (VPNS) solver implements a novel approach to incompressible fluid dynamics based on the Udwadia-Kalaba formulation for constrained mechanical systems. This document provides the mathematical foundation for the method.

## Governing Equations

### Incompressible Navier-Stokes Equations

The motion of an incompressible, Newtonian fluid is governed by:

**Continuity (Incompressibility):**
```
∇·u = 0
```

**Momentum:**
```
∂u/∂t + (u·∇)u = -∇p/ρ + ν∇²u + f
```

where:
- **u** = velocity vector [m/s]
- **p** = pressure [Pa]
- **ρ** = density [kg/m³]
- **ν** = kinematic viscosity [m²/s]
- **f** = body force per unit mass [m/s²]

### Reformulation as Constrained System

The key insight is to view the incompressible flow as a constrained mechanical system where the divergence-free condition acts as a holonomic constraint.

## Udwadia-Kalaba Formulation

### Unconstrained Dynamics

Define the "free" acceleration that would occur without the constraint:

```
a^free = -(u·∇)u + ν∇²u + f
```

This includes:
1. **Convective acceleration**: -(u·∇)u
2. **Viscous acceleration**: ν∇²u  
3. **Body forces**: f

### Constraint Equation

The incompressibility constraint applies to the acceleration field:

```
∇·(∂u/∂t) = 0  ⟹  A·ü = 0
```

where **A** is the discrete divergence operator matrix.

### Optimal Projection

The Udwadia-Kalaba equation gives the minimum-norm correction to satisfy constraints:

```
ü* = ü^free + M^(-1)A^T(AM^(-1)A^T)^(-1)(b - Aü^free)
```

For our case with b = 0:

```
ü* = ü^free - M^(-1)A^T(AM^(-1)A^T)^(-1)Aü^free
```

### Transformed Coordinates

Working in mass-scaled coordinates ũ = M^(1/2)u simplifies the formula:

```
ũ̈* = (I - P)·C̃
```

where:
- **P** = Ã^†Ã is the projection onto the constraint range space
- **N** = I - P is the projection onto the constraint null space
- **C̃** = M^(-1/2)C is the transformed free acceleration
- **Ã** = AM^(-1/2) is the transformed constraint matrix

## Discretization

### Spatial Discretization

We use a uniform Cartesian grid with finite difference approximations:

**Grid:**
- Domain: [0,1] × [0,1]
- Grid spacing: Δx = Δy = 1/(P-1)
- Total points: N = P²

**Divergence Operator (2nd order central differences):**
```
(∇·u)_{i,j} ≈ (u_{i+1,j} - u_{i-1,j})/(2Δx) + (v_{i,j+1} - v_{i,j-1})/(2Δy)
```

**Laplacian Operator (2nd order central differences):**
```
(∇²u)_{i,j} ≈ (u_{i+1,j} - 2u_{i,j} + u_{i-1,j})/Δx² + (u_{i,j+1} - 2u_{i,j} + u_{i,j-1})/Δy²
```

**Convective Terms (2nd order central differences):**
```
(u·∇u)_{i,j} ≈ u_{i,j}(u_{i+1,j} - u_{i-1,j})/(2Δx) + v_{i,j}(u_{i,j+1} - u_{i,j-1})/(2Δy)
```

### Mass Matrix

The mass matrix **M** represents the mass distribution:

```
M = diag(m₁, m₁, m₂, m₂, ..., m_N, m_N)
```

where each mass element mᵢ = ρ·Δx·Δy (modified near boundaries).

### Constraint Matrix Structure

The constraint matrix **A** is sparse with size (N × 2N):
- Each row enforces ∇·u = 0 at one grid point
- Maximum 4 non-zero entries per row
- Pattern follows the divergence stencil

## Projection Operator Construction

### Moore-Penrose Pseudoinverse

The projection operator requires computing:

```
P = Ã^†Ã
```

where Ã^† is the Moore-Penrose pseudoinverse.

**Method 1: Direct SVD** (Current Implementation)
```
Ã = USV^T
Ã^† = VS^†U^T
```

**Advantages:**
- Exact solution
- Numerically stable

**Disadvantages:**
- O(N²) complexity for setup
- Not scalable to large grids (P > 100)

**Method 2: Iterative Methods** (Future Enhancement)
Using algebraic multigrid (AMG) preconditioned iterative solvers:
- O(N) complexity per iteration
- Scalable to large grids
- Requires more sophisticated implementation

### Null Space Projector

The null space projector is simply:

```
N = I - P
```

This projects vectors onto the space of divergence-free vector fields.

## Time Integration

### Explicit Euler Method

Current implementation uses first-order explicit time stepping:

```
u^(n+1) = u^n + Δt·ü*^n
```

where ü*^n is the projected acceleration at time step n.

**Stability:**
- CFL condition: Δt ≤ C·min(Δx/|u|_max, Δy/|v|_max)
- Viscous stability: Δt ≤ C·min(Δx², Δy²)/(2ν)

### Future Enhancements

Planned improvements for stability and accuracy:
1. **Implicit viscous treatment**: Solve (I - Δt·ν·∇²)u* = u^n + Δt·convection
2. **Higher-order schemes**: RK2, RK4, or Adams-Bashforth
3. **Adaptive time stepping**: Automatic Δt selection based on CFL

## Appellian: Constraint Violation Measure

### Definition

The Appellian S* measures how much the free acceleration violates constraints:

```
S* = (1/2)||Pc̃||²
```

where Pc̃ is the projection of the free acceleration onto the constraint range space.

### Physical Interpretation

- **S* = 0**: Free acceleration already satisfies constraints (rare)
- **S* > 0**: Magnitude of constraint violation
- **S* → 0**: System approaching equilibrium or steady state

### Normalization

For comparison across problems:

```
S*_norm = S* / (ρU_lid⁴)
```

This removes dimensional dependence and scales with characteristic velocity.

## Boundary Conditions

### No-Slip Walls

At solid walls, both velocity components are zero:

```
u = v = 0
```

This is enforced by:
1. Excluding boundary points from the solution vector
2. Using known boundary values in stencils for interior points

### Moving Lid

The top boundary has prescribed velocity:

```
u = U_lid,  v = 0
```

### Implementation

Boundary values are:
- Not part of the dynamic solution (not in **u** vector)
- Used as known quantities in discretization stencils
- Affect the constraint matrix **A** and free acceleration **C**

## Convergence and Accuracy

### Spatial Convergence

With 2nd order discretization, the spatial error scales as:

```
||error|| ~ O(Δx²)
```

Doubling the grid resolution (P → 2P) reduces error by factor of 4.

### Temporal Convergence

With 1st order Euler time integration:

```
||error|| ~ O(Δt)
```

Halving the time step reduces error by factor of 2.

### Benchmarking

Results should be compared against:
1. **Ghia et al. (1982)**: Standard lid-driven cavity benchmark
2. **Analytical solutions**: Where available (Stokes flow, etc.)
3. **Other numerical methods**: FEM, FVM, spectral methods

## Computational Complexity

### Current Implementation (Direct SVD)

**Setup Phase:**
- Matrix assembly: O(N)
- SVD computation: O(N²)
- **Total setup: O(N²)**

**Per Time Step:**
- Free acceleration: O(N) 
- Projection: O(N) (sparse matrix-vector products)
- Velocity update: O(N)
- **Total per step: O(N)**

**Practical Limit:** P ≈ 100 (10,000 grid points)

### Future Implementation (AMG-based)

**Setup Phase:**
- Matrix assembly: O(N)
- AMG hierarchy: O(N)
- **Total setup: O(N)**

**Per Time Step:**
- Free acceleration: O(N)
- Iterative projection: O(N) per iteration
- **Total per step: O(N·k)** where k is iteration count

**Practical Limit:** P ≈ 1000+ (1,000,000+ grid points)

## References

### Core Theory

1. **Udwadia, F. E., & Kalaba, R. E.** (1992). A new perspective on constrained motion. *Proceedings of the Royal Society of London. Series A: Mathematical and Physical Sciences*, 439(1906), 407-410.

2. **Udwadia, F. E., & Kalaba, R. E.** (1996). *Analytical Dynamics: A New Approach*. Cambridge University Press.

3. **Udwadia, F. E.** (2000). A new perspective on the tracking control of nonlinear structural and mechanical systems. *Proceedings of the Royal Society of London. Series A*, 456(2003), 2071-2089.

### Numerical Methods

4. **Ghia, U., Ghia, K. N., & Shin, C. T.** (1982). High-Re solutions for incompressible flow using the Navier-Stokes equations and a multigrid method. *Journal of Computational Physics*, 48(3), 387-411.

5. **Ferziger, J. H., & Perić, M.** (2002). *Computational Methods for Fluid Dynamics* (3rd ed.). Springer.

6. **Briggs, W. L., Henson, V. E., & McCormick, S. F.** (2000). *A Multigrid Tutorial* (2nd ed.). SIAM.

### Incompressible Flow Solvers

7. **Chorin, A. J.** (1968). Numerical solution of the Navier-Stokes equations. *Mathematics of Computation*, 22(104), 745-762.

8. **Kim, J., & Moin, P.** (1985). Application of a fractional-step method to incompressible Navier-Stokes equations. *Journal of Computational Physics*, 59(2), 308-323.

---

*This document provides the theoretical foundation for VPNS Solver v1.0.0*
