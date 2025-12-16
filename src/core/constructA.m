function A = constructA(corners, leftB, rightB, bottomB, topB, intPoints_vecHandle, P, Q, invDx, invDy, U)
% CONSTRUCTA Constructs the constraint matrix for divergence-free condition
%
% SYNTAX:
%   A = constructA(corners, leftB, rightB, bottomB, topB, intPoints_vecHandle, P, Q, invDx, invDy, U)
%
% DESCRIPTION:
%   Builds the sparse constraint matrix A that enforces the divergence-free
%   condition ∇·u = 0 at all grid points. Each row of A represents the
%   discretized divergence operator at a specific grid point.
%
% INPUTS:
%   corners            - [1×4] Array of corner point indices
%   leftB              - [1×n] Array of left boundary point indices
%   rightB             - [1×n] Array of right boundary point indices
%   bottomB            - [1×n] Array of bottom boundary point indices
%   topB               - [1×n] Array of top boundary point indices
%   intPoints_vecHandle- VectorHandle containing interior point indices
%   P                  - Number of grid points in x-direction
%   Q                  - Number of grid points in y-direction
%   invDx              - Inverse of grid spacing in x-direction [1/m]
%   invDy              - Inverse of grid spacing in y-direction [1/m]
%   U                  - Current velocity field (not used in current implementation)
%
% OUTPUTS:
%   A                  - [P*Q × 2*P*Q] Sparse constraint matrix
%
% MATHEMATICAL FORMULATION:
%   The divergence operator in 2D is discretized as:
%   ∇·u ≈ (u_{i+1,j} - u_{i-1,j})/(2Δx) + (v_{i,j+1} - v_{i,j-1})/(2Δy)
%
%   For interior points, central differences are used.
%   For boundary points, one-sided differences may be employed.
%
% MATRIX STRUCTURE:
%   A is a sparse matrix with dimensions P*Q × 2*P*Q where:
%   - Each row corresponds to a grid point
%   - Each column pair corresponds to (u,v) velocity components
%   - Maximum 4 non-zero entries per row (2D stencil)
%
% EXAMPLE:
%   A = constructA(corners, leftB, rightB, bottomB, topB, ...
%                  intPoints_vecHandle, 75, 75, 1/dx, 1/dy, U);
%
% SEE ALSO: cornersA_vis, leftA_vis, rightA_vis, topA_vis, bottomA_vis, interior_vis
%
% AUTHOR: VPNS Development Team
% DATE: December 2025

    % Initialize constraint matrix
    % A has one row per grid point and two columns per grid point (u and v components)
    A = zeros(P*Q, 2*P*Q);
    
    %% Construct boundary constraints
    % Each boundary handler fills in the appropriate rows of A
    % corresponding to the divergence operator at boundary points
    
    A = cornersA_vis(A, corners, P, Q, invDx, invDy, U);
    A = leftA_vis(A, leftB, P, Q, invDx, invDy, U);
    A = rightA_vis(A, rightB, P, Q, invDx, invDy, U);
    A = topA_vis(A, topB, P, Q, invDx, invDy, U);
    A = bottomA_vis(A, bottomB, P, Q, invDx, invDy, U);
    
    %% Construct interior constraints
    % Interior points use standard central difference stencil
    A = interior_vis(A, intPoints_vecHandle, P, Q, invDx, invDy, U);
    
end
