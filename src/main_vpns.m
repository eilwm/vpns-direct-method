%% ========================================================================
%  VPNS SOLVER: Variational Projection of Navier-Stokes
%  Main Script for Lid-Driven Cavity Flow Simulation
% =========================================================================
%
% DESCRIPTION:
%   This script implements an incompressible flow solver based on the
%   Udwadia-Kalaba formulation for constrained mechanical systems. The
%   method uses a direct SVD-based projection to enforce the divergence-free
%   constraint on the velocity field.
%
% PROBLEM: 2D Lid-Driven Cavity Flow
%   - Square domain: 1m x 1m
%   - No-slip walls (left, bottom, right)
%   - Moving lid at top with velocity U_lid
%   - Incompressible Newtonian fluid (water)
%
% METHOD: Direct Variational Projection
%   1. Compute free acceleration (convection + viscous + forcing)
%   2. Project onto divergence-free manifold using SVD-based pseudoinverse
%   3. Update velocity field explicitly
%
% REFERENCE:
%   Udwadia, F. E., & Kalaba, R. E. (1992). A new perspective on 
%   constrained motion. Proceedings of the Royal Society A, 439(1906).
%
% AUTHOR: [Your Name]
% DATE: December 2025
% VERSION: 1.0.0
%
% =========================================================================

%% Housekeeping
close all;
clear;
clc;

fprintf('========================================\n');
fprintf('  VPNS SOLVER - Lid-Driven Cavity Flow\n');
fprintf('========================================\n\n');

%% ========================================================================
%  SECTION 1: GRID DEFINITION
% =========================================================================

fprintf('Setting up computational grid...\n');

% Domain dimensions
W = 1.0;                % Width of cavity [m]
H = 1.0;                % Height of cavity [m]

% Grid resolution
P = 75;                 % Number of interior points in x-direction
Q = 75;                 % Number of interior points in y-direction

% Grid spacing
dx = W/(P+1);          % Grid spacing in x [m]
dy = H/(Q+1);          % Grid spacing in y [m]

fprintf('  Grid resolution: %d x %d\n', P, Q);
fprintf('  Grid spacing: dx = %.6f m, dy = %.6f m\n', dx, dy);

%% ========================================================================
%  SECTION 2: MATERIAL PROPERTIES
% =========================================================================

fprintf('\nSetting material properties...\n');

% Fluid properties (Water at room temperature)
rho = 999.8;           % Density [kg/m³]
mu = 0.9;              % Dynamic viscosity [Pa·s]
nu = mu / rho;         % Kinematic viscosity [m²/s]

fprintf('  Fluid: Water\n');
fprintf('  Density: %.1f kg/m³\n', rho);
fprintf('  Dynamic viscosity: %.1f Pa·s\n', mu);
fprintf('  Kinematic viscosity: %.6f m²/s\n', nu);

%% ========================================================================
%  SECTION 3: BOUNDARY CONDITIONS
% =========================================================================

fprintf('\nDefining boundary conditions...\n');

% Lid velocity (top boundary)
U_lid = 0.02;          % Lid velocity [m/s]

fprintf('  Lid velocity: %.3f m/s\n', U_lid);
fprintf('  Reynolds number: %.2f\n', U_lid * W / nu);

%% ========================================================================
%  SECTION 4: INITIALIZATION
% =========================================================================

fprintf('\nInitializing fields...\n');

% Velocity field (interior points only)
% Stored as [u1, v1, u2, v2, ..., uN, vN]'
U = zeros(2*P*Q, 1);
U_vecHandle = VectorHandle(U);

% Temporal acceleration field
U_dot = zeros(2*P*Q, 1);
U_dot_vecHandle = VectorHandle(U_dot);

%% ========================================================================
%  SECTION 5: GRID POINT CLASSIFICATION
% =========================================================================

fprintf('Identifying boundary and interior points...\n');

% Corner points
corners = [1, P, P*Q-P+1, P*Q];

% Left boundary (excluding corners)
l = 1:Q-2;
leftB = l*P + 1;

% Right boundary (excluding corners)
l = 2:Q-1;
rightB = l*P;

% Bottom boundary (excluding corners)
l = 2:P-1;
bottomB = l;

% Top boundary (excluding corners)
l = (P*Q-P+2):(P*Q-1);
topB = l;

% Interior points
interiorPoints = zeros(1, (P-2)*(Q-2));
for i = 1:Q-2
    beginIdx = 1 + (i-1)*(P-2);
    endIdx = beginIdx + P - 3;
    interiorPoints(beginIdx:endIdx) = ((P+2):(2*P-1)) + (i-1)*P;
end
intPoints_vecHandle = VectorHandle(interiorPoints);

fprintf('  Total grid points: %d\n', P*Q);
fprintf('  Interior points: %d\n', length(interiorPoints));
fprintf('  Boundary points: %d\n', P*Q - length(interiorPoints));

%% ========================================================================
%  SECTION 6: MASS MATRIX CONSTRUCTION
% =========================================================================

fprintf('\nConstructing mass matrix...\n');

% Mass matrix M (diagonal)
% M = ρ·dx·dy·I for interior points
% Modified near boundaries to account for half-elements
% Using M^(-1/2) directly for efficiency
M_negSqrt = sparse((rho * dx * dy)^(-0.5) * eye(2*P*Q));
M_ns_SMHandle = SparseMatrixHandle(M_negSqrt);

fprintf('  Mass matrix: %d x %d sparse diagonal\n', ...
        size(M_negSqrt, 1), size(M_negSqrt, 2));

%% ========================================================================
%  SECTION 7: CONSTRAINT MATRIX CONSTRUCTION
% =========================================================================

fprintf('\nConstructing constraint matrix A...\n');

% Inverse grid spacings (for divergence operator)
invDx = 1/dx;
invDy = 1/dy;

% Build constraint matrix A
% Each row enforces ∇·u = 0 at a grid point
A = sparse(constructA(corners, leftB, rightB, bottomB, topB, ...
                      intPoints_vecHandle, P, Q, invDx, invDy, U));
A_SMHandle = SparseMatrixHandle(A);

fprintf('  Constraint matrix A: %d x %d sparse\n', ...
        size(A, 1), size(A, 2));
fprintf('  Non-zero entries: %d (%.2f%% sparse)\n', ...
        nnz(A), 100*(1 - nnz(A)/(size(A,1)*size(A,2))));

%% ========================================================================
%  SECTION 8: PROJECTION MATRIX COMPUTATION
% =========================================================================

fprintf('\nComputing projection matrices (SVD-based)...\n');
fprintf('  This may take a while for large grids...\n');

% Compute AM^(-1/2)
AM_ns_SMHandle = A_SMHandle * M_ns_SMHandle;

% Compute Moore-Penrose pseudoinverse
tic;
P_inv_SMHandle = AM_ns_SMHandle.pseudoinverse();
P_SMHandle = SparseMatrixHandle(P_inv_SMHandle.MatrixData * AM_ns_SMHandle.MatrixData);
totalTime = toc;

fprintf('  SVD computation time: %.2f seconds\n', totalTime);

% Null space projection matrix N = I - P
N_SMHandle = SparseMatrixHandle(sparse(eye(size(P_SMHandle.MatrixData)))) - P_SMHandle;

% Matrix statistics
avg_nnz_per_row = nnz(N_SMHandle.MatrixData) / size(N_SMHandle.MatrixData, 1);
fprintf('  Projection matrix N: %d x %d\n', ...
        size(N_SMHandle.MatrixData, 1), size(N_SMHandle.MatrixData, 2));
fprintf('  Average non-zeros per row: %.2f\n', avg_nnz_per_row);

%% ========================================================================
%  SECTION 9: EIGENVALUE ANALYSIS (OPTIONAL)
% =========================================================================

fprintf('\nPerforming eigenvalue analysis of projection matrix...\n');

N_mat = N_SMHandle.MatrixData;
k = 200;  % Number of eigenvalues to compute
lambda = eigs(N_mat, k, 'LR');

% Plot eigenvalue spectrum
figure('Name', 'Eigenvalue Spectrum');
plot(real(lambda), zeros(size(lambda)), 'ko', ...
     'MarkerSize', 5, 'MarkerFaceColor', 'k');
xlabel('Real Axis');
ylabel('');
title('Eigenvalues of Projection Matrix N');
yticks([]);
xlim([-0.1, 1.1]);
grid on;

fprintf('  Computed %d eigenvalues\n', k);
fprintf('  Eigenvalues should cluster near 0 and 1\n');

%% ========================================================================
%  SECTION 10: FREE ACCELERATION INITIALIZATION
% =========================================================================

fprintf('\nInitializing free acceleration vector...\n');

% Free acceleration C = -(u·∇)u + ν∇²u + f
C = zeros(2*P*Q, 1);
C_vecHandle = VectorHandle(C);

% Compute initial free acceleration
constructC_ref(C_vecHandle, corners, leftB, rightB, bottomB, topB, ...
               intPoints_vecHandle, P, Q, dx, dy, U_vecHandle, rho, nu, U_lid);

%% ========================================================================
%  SECTION 11: TIME INTEGRATION SETUP
% =========================================================================

fprintf('\nSetting up time integration...\n');

% Time stepping parameters
n_steps = 1000;        % Number of time steps
dt = 0.01;             % Time step [s]
T_final = n_steps * dt; % Final simulation time [s]

fprintf('  Time step: %.4f s\n', dt);
fprintf('  Number of steps: %d\n', n_steps);
fprintf('  Final time: %.2f s\n', T_final);

% CFL number check
u_max = max(abs(U));
if u_max > 0
    CFL = u_max * dt / dx;
    fprintf('  Initial CFL number: %.4f\n', CFL);
end

% Storage for optimum Appellian
S_star = zeros(1, n_steps);
S_star_vecHandle = VectorHandle(S_star);

% Storage for transformed velocity gradient
Udot_tilde_star = zeros(1, 2*P*Q);
Udot_tilde_star_vecHandle = VectorHandle(Udot_tilde_star);

%% ========================================================================
%  SECTION 12: CREATE OUTPUT DIRECTORY
% =========================================================================

fprintf('\nPreparing output directory...\n');

% Create results directory if it doesn't exist
if ~exist('../results', 'dir')
    mkdir('../results');
end
if ~exist('../results/VelVecs', 'dir')
    mkdir('../results/VelVecs');
end

fprintf('  Output directory: ../results/VelVecs/\n');

%% ========================================================================
%  SECTION 13: MAIN TIME INTEGRATION LOOP
% =========================================================================

fprintf('\n========================================\n');
fprintf('  Starting Time Integration\n');
fprintf('========================================\n\n');

% Progress tracking
save_interval = 10;    % Save every 10 steps
print_interval = 50;   % Print progress every 50 steps

% Start timer
tic;

for t = 1:n_steps
    
    % ------------------------------------------------------------------
    % STEP 1: Solve for optimal temporal acceleration
    % ------------------------------------------------------------------
    optimUdot_ref(M_ns_SMHandle, C_vecHandle, P_SMHandle, N_SMHandle, ...
                  Udot_tilde_star_vecHandle, S_star_vecHandle, t);
    
    % Transform back to physical space
    U_dot_vecHandle.VectorData = M_ns_SMHandle.MatrixData * ...
                                 Udot_tilde_star_vecHandle.VectorData';
    
    % ------------------------------------------------------------------
    % STEP 2: Update velocity field (Explicit Euler)
    % ------------------------------------------------------------------
    U_vecHandle.VectorData = U_vecHandle.VectorData + dt * U_dot_vecHandle.VectorData;
    
    % ------------------------------------------------------------------
    % STEP 3: Update free acceleration for next step
    % ------------------------------------------------------------------
    C_vecHandle.VectorData = zeros(size(C_vecHandle.VectorData));
    constructC_ref(C_vecHandle, corners, leftB, rightB, bottomB, topB, ...
                   intPoints_vecHandle, P, Q, dx, dy, U_vecHandle, rho, nu, U_lid);
    
    % ------------------------------------------------------------------
    % STEP 4: Monitor and save results
    % ------------------------------------------------------------------
    
    % Print progress
    if mod(t, print_interval) == 0 || t == 1
        fprintf('Step %4d/%d | t = %.3f s | S* = %12.6e\n', ...
                t, n_steps, t*dt, S_star_vecHandle.VectorData(t));
    end
    
    % Save velocity field
    if (t == 1) || (mod(t, save_interval) == 0)
        fileName = sprintf('../results/VelVecs/U_vec_%d.mat', t);
        tempVec = U_vecHandle.VectorData;
        save(fileName, 'tempVec');
        clear tempVec;
    end
    
end

% Total simulation time
totalTime = toc;
fprintf('\n========================================\n');
fprintf('  Time Integration Complete\n');
fprintf('========================================\n');
fprintf('  Total computation time: %.2f seconds\n', totalTime);
fprintf('  Average time per step: %.4f seconds\n', totalTime/n_steps);

%% ========================================================================
%  SECTION 14: POST-PROCESSING
% =========================================================================

fprintf('\nPost-processing results...\n');

% Extract Appellian data
S_star = S_star_vecHandle.VectorData;

% Normalize Appellian
S_star_norm = S_star / (rho * U_lid^4);

% Time stamps
timeStamps = linspace(dt, n_steps*dt, n_steps);

%% Plot 1: Normalized Appellian Evolution
figure('Name', 'Appellian Evolution');
plot(timeStamps, S_star_norm, 'LineWidth', 2, 'Color', 'r');
xlabel('Time [s]');
ylabel('S^* / (\rho U_{lid}^4)');
title('Evolution of Normalized Optimum Appellian');
grid on;

fprintf('  Final normalized Appellian: %.6e\n', S_star_norm(end));

%% Plot 2: Rate of Change of Appellian
S_star_norm_dot = zeros(n_steps-2, 1);

for i = 1:n_steps-2
    S_star_norm_dot(i) = (S_star_norm(i+1) - S_star_norm(i)) / dt;
end

figure('Name', 'Appellian Rate of Change');
plot(timeStamps(2:end-1), S_star_norm_dot, 'LineWidth', 2, 'Color', 'b');
xlabel('Time [s]');
ylabel('dS^*/dt');
title('Rate of Change of Normalized Optimum Appellian');
grid on;

fprintf('  Final rate of change: %.6e\n', S_star_norm_dot(end));

%% ========================================================================
%  SECTION 15: SAVE FINAL RESULTS
% =========================================================================

fprintf('\nSaving final results...\n');

% Save workspace
save('../results/vpns_simulation_final.mat', 'U', 'S_star', 'S_star_norm', ...
     'P', 'Q', 'dx', 'dy', 'rho', 'nu', 'U_lid', 'dt', 'n_steps');

fprintf('  Final state saved to: ../results/vpns_simulation_final.mat\n');

fprintf('\n========================================\n');
fprintf('  Simulation Complete!\n');
fprintf('========================================\n\n');

%% END OF SCRIPT
