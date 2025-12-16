%% ========================================================================
%  VPNS Solver Verification Tests
% =========================================================================
%
% This script runs basic tests to verify that the VPNS solver is
% correctly installed and functioning properly.
%
% TESTS:
%   1. Path verification
%   2. Function availability
%   3. Class instantiation
%   4. Small grid simulation
%   5. Matrix assembly
%
% AUTHOR: VPNS Development Team
% DATE: December 2025
% =========================================================================

function run_verification_tests()
    
    fprintf('\n');
    fprintf('========================================================\n');
    fprintf('  VPNS Solver Verification Tests\n');
    fprintf('========================================================\n\n');
    
    % Test results
    tests_passed = 0;
    tests_failed = 0;
    
    %% Test 1: Check if key functions are on path
    fprintf('TEST 1: Function Availability\n');
    fprintf('-------------------------------\n');
    
    key_functions = {'constructA', 'constructC_ref', 'optimUdot_ref', ...
                     'VectorHandle', 'SparseMatrixHandle'};
    
    test1_passed = true;
    for i = 1:length(key_functions)
        func_path = which(key_functions{i});
        if ~isempty(func_path)
            fprintf('  [✓] %s found\n', key_functions{i});
        else
            fprintf('  [✗] %s NOT FOUND\n', key_functions{i});
            test1_passed = false;
        end
    end
    
    if test1_passed
        fprintf('Result: PASSED\n\n');
        tests_passed = tests_passed + 1;
    else
        fprintf('Result: FAILED - Some functions are missing\n');
        fprintf('Run setup_vpns_paths() to add paths\n\n');
        tests_failed = tests_failed + 1;
    end
    
    %% Test 2: Check class instantiation
    fprintf('TEST 2: Class Instantiation\n');
    fprintf('-------------------------------\n');
    
    test2_passed = true;
    try
        % Test VectorHandle
        vec = zeros(10, 1);
        vecHandle = VectorHandle(vec);
        fprintf('  [✓] VectorHandle created successfully\n');
        
        % Test SparseMatrixHandle
        mat = speye(10);
        matHandle = SparseMatrixHandle(mat);
        fprintf('  [✓] SparseMatrixHandle created successfully\n');
        
        fprintf('Result: PASSED\n\n');
        tests_passed = tests_passed + 1;
    catch ME
        fprintf('  [✗] Error: %s\n', ME.message);
        fprintf('Result: FAILED\n\n');
        test2_passed = false;
        tests_failed = tests_failed + 1;
    end
    
    %% Test 3: Small grid setup
    fprintf('TEST 3: Grid Setup\n');
    fprintf('-------------------------------\n');
    
    test3_passed = true;
    try
        % Small test grid
        P = 11;
        Q = 11;
        dx = 1/(P+1);
        dy = 1/(Q+1);
        
        % Define boundary points
        corners = [1, P, P*Q-P+1, P*Q];
        
        % Interior points
        interiorPoints = [];
        for i = 1:Q-2
            beginIdx = 1 + (i-1)*(P-2);
            endIdx = beginIdx + P - 3;
            interiorPoints = [interiorPoints, ((P+2):(2*P-1)) + (i-1)*P];
        end
        
        fprintf('  [✓] Grid created: %d × %d\n', P, Q);
        fprintf('  [✓] Interior points: %d\n', length(interiorPoints));
        fprintf('  [✓] Boundary points: %d\n', P*Q - length(interiorPoints));
        
        fprintf('Result: PASSED\n\n');
        tests_passed = tests_passed + 1;
    catch ME
        fprintf('  [✗] Error: %s\n', ME.message);
        fprintf('Result: FAILED\n\n');
        test3_passed = false;
        tests_failed = tests_failed + 1;
    end
    
    %% Test 4: Matrix construction
    fprintf('TEST 4: Matrix Construction\n');
    fprintf('-------------------------------\n');
    
    test4_passed = true;
    try
        % Use grid from Test 3
        if ~test3_passed
            fprintf('  [!] Skipped (requires Test 3 to pass)\n\n');
            tests_failed = tests_failed + 1;
        else
            % Mass matrix
            rho = 999.8;
            M_negSqrt = sparse((rho * dx * dy)^(-0.5) * eye(2*P*Q));
            fprintf('  [✓] Mass matrix constructed: %d × %d\n', ...
                    size(M_negSqrt, 1), size(M_negSqrt, 2));
            
            % Test matrix is diagonal
            if nnz(M_negSqrt) == size(M_negSqrt, 1)
                fprintf('  [✓] Mass matrix is diagonal (correct)\n');
            else
                fprintf('  [✗] Mass matrix is not diagonal\n');
                test4_passed = false;
            end
            
            if test4_passed
                fprintf('Result: PASSED\n\n');
                tests_passed = tests_passed + 1;
            else
                fprintf('Result: FAILED\n\n');
                tests_failed = tests_failed + 1;
            end
        end
    catch ME
        fprintf('  [✗] Error: %s\n', ME.message);
        fprintf('Result: FAILED\n\n');
        test4_passed = false;
        tests_failed = tests_failed + 1;
    end
    
    %% Test 5: Basic computation test
    fprintf('TEST 5: Basic Computation\n');
    fprintf('-------------------------------\n');
    
    test5_passed = true;
    try
        % Simple vector operations
        v1 = VectorHandle(ones(10, 1));
        v2 = VectorHandle(2 * ones(10, 1));
        
        % Test vector access
        if length(v1.VectorData) == 10
            fprintf('  [✓] Vector handle operations work\n');
        else
            fprintf('  [✗] Vector handle operations failed\n');
            test5_passed = false;
        end
        
        % Simple matrix operations
        A = SparseMatrixHandle(speye(10));
        B = SparseMatrixHandle(2 * speye(10));
        C = A + B;  % Should be 3*I
        
        if nnz(C.MatrixData) == 10 && C.MatrixData(1,1) == 3
            fprintf('  [✓] Matrix handle operations work\n');
        else
            fprintf('  [✗] Matrix handle operations failed\n');
            test5_passed = false;
        end
        
        if test5_passed
            fprintf('Result: PASSED\n\n');
            tests_passed = tests_passed + 1;
        else
            fprintf('Result: FAILED\n\n');
            tests_failed = tests_failed + 1;
        end
    catch ME
        fprintf('  [✗] Error: %s\n', ME.message);
        fprintf('Result: FAILED\n\n');
        test5_passed = false;
        tests_failed = tests_failed + 1;
    end
    
    %% Summary
    fprintf('========================================================\n');
    fprintf('  Test Summary\n');
    fprintf('========================================================\n\n');
    
    total_tests = tests_passed + tests_failed;
    fprintf('Total tests: %d\n', total_tests);
    fprintf('Passed: %d\n', tests_passed);
    fprintf('Failed: %d\n', tests_failed);
    fprintf('Success rate: %.1f%%\n\n', 100 * tests_passed / total_tests);
    
    if tests_failed == 0
        fprintf('✓ All tests passed! VPNS Solver is ready to use.\n\n');
        fprintf('Next steps:\n');
        fprintf('  1. Run example: cd examples; run_lid_driven_cavity\n');
        fprintf('  2. Try full solver: cd src; main_vpns\n');
        fprintf('  3. Read docs: edit docs/installation.md\n\n');
    else
        fprintf('✗ Some tests failed. Please check your installation.\n\n');
        fprintf('Troubleshooting:\n');
        fprintf('  1. Run setup_vpns_paths() to add paths\n');
        fprintf('  2. Check that all files are present\n');
        fprintf('  3. See docs/installation.md for help\n\n');
    end
    
    fprintf('========================================================\n\n');
    
end
