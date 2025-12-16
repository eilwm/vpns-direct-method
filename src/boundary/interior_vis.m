function A = interior_vis(A, intPoints_vecHandle, P, Q, invDx, invDy, U)
% INTERIOR_VIS Constructs divergence operator for interior grid points
%
% SYNTAX:
%   A = interior_vis(A, intPoints_vecHandle, P, Q, invDx, invDy, U)
%
% DESCRIPTION:
%   Fills in the constraint matrix rows corresponding to interior grid points.
%   Uses central difference stencil for the divergence operator.
%
% INPUTS:
%   A                  - [P*Q × 2*P*Q] Partially filled constraint matrix
%   intPoints_vecHandle- VectorHandle containing interior point indices
%   P                  - Number of grid points in x-direction
%   Q                  - Number of grid points in y-direction
%   invDx              - Inverse of grid spacing in x [1/m]
%   invDy              - Inverse of grid spacing in y [1/m]
%   U                  - Current velocity field (unused)
%
% OUTPUTS:
%   A                  - Updated constraint matrix
%
% STENCIL:
%   For interior point m, the divergence is approximated as:
%   ∇·u ≈ (u_{i+1,j} - u_{i-1,j})/(2Δx) + (v_{i,j+1} - v_{i,j-1})/(2Δy)
%
% AUTHOR: VPNS Development Team
% DATE: December 2025

    for i = 1:length(intPoints_vecHandle.VectorData)
        m = intPoints_vecHandle.VectorData(i);
        
        % Central difference stencil for ∂u/∂x and ∂v/∂y
        A(m, 2*m-2*P)   = -invDy;  % v_{i,j-1}
        A(m, 2*m-3)     = -invDx;  % u_{i-1,j}
        A(m, 2*m+1)     =  invDx;  % u_{i+1,j}
        A(m, 2*m+2*P)   =  invDy;  % v_{i,j+1}
    end
    
end
