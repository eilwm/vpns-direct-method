function optimUdot_ref(M_ns_SMHandle, C_vecHandle, P_SMHandle, N_SMHandle, ...
                       Udot_tilde_star_vecHandle, S_star_vecHandle, t)
% OPTIMUDOT_REF Computes the optimal constrained temporal acceleration
%
% SYNTAX:
%   optimUdot_ref(M_ns_SMHandle, C_vecHandle, P_SMHandle, N_SMHandle, ...
%                 Udot_tilde_star_vecHandle, S_star_vecHandle, t)
%
% DESCRIPTION:
%   Computes the optimal temporal acceleration that satisfies the divergence-free
%   constraint using the Udwadia-Kalaba projection method. The method projects
%   the free acceleration onto the constraint manifold.
%
% INPUTS:
%   M_ns_SMHandle            - SparseMatrixHandle for M^(-1/2) (inverse sqrt of mass matrix)
%   C_vecHandle              - VectorHandle for free acceleration vector
%   P_SMHandle               - SparseMatrixHandle for projection operator P
%   N_SMHandle               - SparseMatrixHandle for null space projector N = I - P
%   Udot_tilde_star_vecHandle- VectorHandle for output (transformed optimal acceleration)
%   S_star_vecHandle         - VectorHandle for Appellian (constraint violation measure)
%   t                        - Current time step index
%
% OUTPUTS:
%   None (modifies Udot_tilde_star_vecHandle and S_star_vecHandle in place)
%
% MATHEMATICAL FORMULATION:
%   The Udwadia-Kalaba projection formula gives:
%
%   ü* = ü^free + M^(-1)A^T(AM^(-1)A^T)^(-1)(b - Aü^free)
%
%   In transformed coordinates (ũ = M^(1/2)u):
%   
%   ü̃* = -N·C̃   where C̃ = M^(-1/2)·C
%   
%   Here:
%   - N = I - P is the null space projector
%   - P = (ÃM^(-1/2))^†·ÃM^(-1/2) is the range space projector
%   - C is the free acceleration
%
% APPELLIAN:
%   The Appellian S* is a measure of the constraint violation:
%   
%   S* = (1/2)||Q_c̃||²  where Q_c̃ = -P·C̃
%   
%   For a perfect constraint satisfaction, S* → 0.
%
% ALGORITHM:
%   1. Transform free acceleration: C̃ = M^(-1/2)·C
%   2. Compute optimal transformed acceleration: ü̃* = -N·C̃
%   3. Compute constraint force projection: Q_c̃ = -P·C̃
%   4. Compute Appellian: S* = (1/2)||Q_c̃||²
%
% NOTES:
%   - All computations are performed in transformed (scaled) coordinates
%   - The physical acceleration is recovered by: ü* = M^(-1/2)·ü̃*
%   - This function modifies output handles in place (pass by reference)
%
% EXAMPLE:
%   optimUdot_ref(M_ns_SMHandle, C_vecHandle, P_SMHandle, N_SMHandle, ...
%                 Udot_tilde_star_vecHandle, S_star_vecHandle, 1);
%
% REFERENCES:
%   Udwadia, F. E., & Kalaba, R. E. (1992). A new perspective on constrained
%   motion. Proceedings of the Royal Society of London A, 439(1906), 407-410.
%
% SEE ALSO: constructC_ref, constructA
%
% AUTHOR: VPNS Development Team
% DATE: December 2025

    %% Step 1: Transform free acceleration to scaled coordinates
    % C̃ = M^(-1/2) * C
    C_tilde = M_ns_SMHandle.MatrixData * C_vecHandle.VectorData;
    
    %% Step 2: Compute optimal transformed temporal acceleration
    % ü̃* = -N * C̃
    % This projects the free acceleration onto the constraint-satisfying subspace
    Udot_tilde_star = -N_SMHandle.MatrixData * C_tilde;
    
    % Store result in output handle
    Udot_tilde_star_vecHandle.VectorData = Udot_tilde_star';
    
    %% Step 3: Compute constraint force projection
    % Q_c̃ = -P * C̃
    % This is the component of the free acceleration that violates the constraints
    Q_c_tilde = -P_SMHandle.MatrixData * C_tilde;
    
    %% Step 4: Compute Appellian (constraint violation measure)
    % S* = (1/2) * Q_c̃^T * Q_c̃
    % This scalar measures how much the free acceleration violates the constraints
    S_star = 0.5 * (Q_c_tilde' * Q_c_tilde);
    
    % Store Appellian at current time step
    S_star_vecHandle.VectorData(t) = S_star;
    
end
