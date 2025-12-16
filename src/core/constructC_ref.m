function constructC_ref(C_vecHandle, corners, leftB, rightB, bottomB, topB, ...
                        intPoints_handle, P, Q, dx, dy, U_vecHandle, rho, nu, U_lid)
% CONSTRUCTC_REF Computes the free acceleration vector (right-hand side)
%
% SYNTAX:
%   constructC_ref(C_vecHandle, corners, leftB, rightB, bottomB, topB, ...
%                  intPoints_handle, P, Q, dx, dy, U_vecHandle, rho, nu, U_lid)
%
% DESCRIPTION:
%   Computes the free acceleration C = -(u·∇)u + ν∇²u + f at all grid points.
%   This represents the acceleration the fluid would have if unconstrained by
%   the incompressibility condition. The result is stored directly in C_vecHandle.
%
% INPUTS:
%   C_vecHandle        - VectorHandle for output free acceleration vector
%   corners            - [1×4] Array of corner point indices
%   leftB              - [1×n] Array of left boundary point indices
%   rightB             - [1×n] Array of right boundary point indices
%   bottomB            - [1×n] Array of bottom boundary point indices
%   topB               - [1×n] Array of top boundary point indices
%   intPoints_handle   - VectorHandle containing interior point indices
%   P                  - Number of grid points in x-direction
%   Q                  - Number of grid points in y-direction
%   dx                 - Grid spacing in x-direction [m]
%   dy                 - Grid spacing in y-direction [m]
%   U_vecHandle        - VectorHandle containing current velocity field
%   rho                - Fluid density [kg/m³]
%   nu                 - Kinematic viscosity [m²/s]
%   U_lid              - Lid velocity for top boundary [m/s]
%
% OUTPUTS:
%   None (modifies C_vecHandle in place)
%
% MATHEMATICAL FORMULATION:
%   The free acceleration includes three terms:
%   
%   1. Convective acceleration: -(u·∇)u = -u(∂u/∂x) - v(∂u/∂y)
%   2. Viscous acceleration: ν∇²u = ν(∂²u/∂x² + ∂²u/∂y²)
%   3. Body force: f (currently zero in this implementation)
%
%   For each component (u and v), the free acceleration is computed using
%   finite difference approximations of the spatial derivatives.
%
% DISCRETIZATION:
%   - Convective terms: Central differences (2nd order accurate)
%   - Viscous terms: Central differences (2nd order accurate)
%   - Special treatment at boundaries using known boundary values
%
% NOTES:
%   - This function modifies C_vecHandle directly (pass by reference)
%   - Boundary conditions are applied through specialized handlers
%   - The sign convention follows: C = mass * acceleration
%
% EXAMPLE:
%   constructC_ref(C_vecHandle, corners, leftB, rightB, bottomB, topB, ...
%                  intPoints_handle, 75, 75, dx, dy, U_vecHandle, 999.8, nu, 0.02);
%
% SEE ALSO: cornersC_vis, leftC_vis, rightC_vis, topC_vis, bottomC_vis, interiorC_vis
%
% AUTHOR: VPNS Development Team
% DATE: December 2025

    %% Compute free acceleration at corners
    % Corners require special treatment due to two adjacent boundaries
    cornersC_vis_ref(C_vecHandle, corners, P, Q, dx, dy, U_vecHandle, rho, nu, U_lid);
    
    %% Compute free acceleration at boundary edges
    % Each edge uses one-sided differences where necessary
    leftC_vis_ref(C_vecHandle, leftB, P, Q, dx, dy, U_vecHandle, rho, nu);
    rightC_vis_ref(C_vecHandle, rightB, P, Q, dx, dy, U_vecHandle, rho, nu);
    bottomC_vis_ref(C_vecHandle, bottomB, P, Q, dx, dy, U_vecHandle, rho, nu);
    topC_vis_ref(C_vecHandle, topB, P, Q, dx, dy, U_vecHandle, rho, nu, U_lid);
    
    %% Compute free acceleration at interior points
    % Interior points use standard central differences
    interiorC_vis_ref(C_vecHandle, intPoints_handle, P, Q, dx, dy, U_vecHandle, rho, nu);
    
end
