function setup_vpns_paths()
% SETUP_VPNS_PATHS Add all VPNS Solver paths to MATLAB search path
%
% SYNTAX:
%   setup_vpns_paths()
%
% DESCRIPTION:
%   Adds all necessary directories for VPNS Solver to the MATLAB path.
%   Run this function once after installation or at the start of each
%   MATLAB session.
%
% USAGE:
%   >> setup_vpns_paths
%
% NOTES:
%   - This function should be run from the VPNS-Solver root directory
%   - To add permanently, add this to your startup.m file
%   - Paths are added recursively, including all subdirectories
%
% AUTHOR: VPNS Development Team
% DATE: December 2025

    fprintf('\n');
    fprintf('========================================\n');
    fprintf('  VPNS Solver Path Setup\n');
    fprintf('========================================\n\n');
    
    % Get current directory (should be VPNS-Solver root)
    current_dir = pwd;
    
    % Check if we're in the right directory
    if ~exist(fullfile(current_dir, 'src'), 'dir')
        warning('setup_vpns_paths:wrongDirectory', ...
                ['Cannot find src/ directory.\n' ...
                 'Please run this function from the VPNS-Solver root directory.']);
        return;
    end
    
    fprintf('Adding VPNS Solver paths from:\n  %s\n\n', current_dir);
    
    % Add main source directory
    addpath(fullfile(current_dir, 'src'));
    fprintf('  [✓] Added: src/\n');
    
    % Add core functions
    if exist(fullfile(current_dir, 'src', 'core'), 'dir')
        addpath(fullfile(current_dir, 'src', 'core'));
        fprintf('  [✓] Added: src/core/\n');
    end
    
    % Add boundary functions
    if exist(fullfile(current_dir, 'src', 'boundary'), 'dir')
        addpath(fullfile(current_dir, 'src', 'boundary'));
        fprintf('  [✓] Added: src/boundary/\n');
    end
    
    % Add force functions
    if exist(fullfile(current_dir, 'src', 'forces'), 'dir')
        addpath(fullfile(current_dir, 'src', 'forces'));
        fprintf('  [✓] Added: src/forces/\n');
    end
    
    % Add utilities
    if exist(fullfile(current_dir, 'src', 'utils'), 'dir')
        addpath(fullfile(current_dir, 'src', 'utils'));
        fprintf('  [✓] Added: src/utils/\n');
    end
    
    % Add examples (optional)
    if exist(fullfile(current_dir, 'examples'), 'dir')
        addpath(fullfile(current_dir, 'examples'));
        fprintf('  [✓] Added: examples/\n');
    end
    
    % Add tests (optional)
    if exist(fullfile(current_dir, 'tests'), 'dir')
        addpath(fullfile(current_dir, 'tests'));
        fprintf('  [✓] Added: tests/\n');
    end
    
    fprintf('\n');
    fprintf('========================================\n');
    fprintf('  Path Setup Complete\n');
    fprintf('========================================\n\n');
    
    % Verify key functions are accessible
    fprintf('Verifying installation...\n');
    
    key_functions = {'constructA', 'constructC_ref', 'optimUdot_ref', ...
                     'VectorHandle', 'SparseMatrixHandle'};
    all_found = true;
    
    for i = 1:length(key_functions)
        func_path = which(key_functions{i});
        if ~isempty(func_path)
            fprintf('  [✓] Found: %s\n', key_functions{i});
        else
            fprintf('  [✗] Missing: %s\n', key_functions{i});
            all_found = false;
        end
    end
    
    fprintf('\n');
    
    if all_found
        fprintf('✓ All key functions found!\n');
        fprintf('  You are ready to use VPNS Solver.\n\n');
        fprintf('Next steps:\n');
        fprintf('  1. Run example: cd examples; run_lid_driven_cavity\n');
        fprintf('  2. Read docs: edit docs/installation.md\n');
        fprintf('  3. Try full solver: cd src; main_vpns\n\n');
    else
        fprintf('✗ Some functions are missing.\n');
        fprintf('  Please check your installation.\n');
        fprintf('  See docs/installation.md for troubleshooting.\n\n');
    end
    
    % Create results directory if it doesn't exist
    results_dir = fullfile(current_dir, 'results');
    if ~exist(results_dir, 'dir')
        mkdir(results_dir);
        mkdir(fullfile(results_dir, 'VelVecs'));
        fprintf('Created results directory at:\n  %s\n\n', results_dir);
    end
    
end

%% Helper function to save paths permanently
function save_paths_permanently()
    % This function can be called to save the paths to pathdef.m
    % Note: This requires write access to MATLAB installation directory
    
    response = input('Save paths permanently? (y/n): ', 's');
    if strcmpi(response, 'y')
        try
            savepath;
            fprintf('Paths saved successfully!\n');
            fprintf('They will be available in future MATLAB sessions.\n');
        catch ME
            fprintf('Could not save paths: %s\n', ME.message);
            fprintf('You may need administrator privileges.\n');
            fprintf('Alternative: Add setup_vpns_paths to your startup.m\n');
        end
    end
end
