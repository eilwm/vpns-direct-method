classdef SparseMatrixHandle < handle
    % SPARSEMATRIXHANDLE Handle class for sparse matrices with operator overloading
    %
    % DESCRIPTION:
    %   A handle class wrapper for sparse matrices that enables pass-by-reference
    %   semantics and overloaded operators for convenient matrix operations.
    %
    % PROPERTIES:
    %   MatrixData - The actual sparse matrix data
    %
    % METHODS:
    %   SparseMatrixHandle(data) - Constructor
    %   plus(A, B)               - Matrix addition (A + B)
    %   minus(A, B)              - Matrix subtraction (A - B)
    %   mtimes(A, B)             - Matrix multiplication (A * B)
    %   pseudoinverse()          - Moore-Penrose pseudoinverse
    %
    % EXAMPLE:
    %   % Create sparse matrix handles
    %   A = sparse(rand(100));
    %   A_handle = SparseMatrixHandle(A);
    %   
    %   % Use operator overloading
    %   I = SparseMatrixHandle(speye(100));
    %   result = A_handle + I;
    %
    % SEE ALSO: VectorHandle, handle, sparse
    %
    % AUTHOR: VPNS Development Team
    % DATE: December 2025
    
    properties
        MatrixData  % The sparse matrix data
    end
    
    methods
        function obj = SparseMatrixHandle(data)
            % SPARSEMATRIXHANDLE Constructor
            %
            % SYNTAX:
            %   obj = SparseMatrixHandle(data)
            %
            % INPUTS:
            %   data - Initial sparse matrix (optional, defaults to empty)
            
            if nargin > 0
                if issparse(data)
                    obj.MatrixData = data;
                else
                    obj.MatrixData = sparse(data);
                end
            else
                obj.MatrixData = sparse([]);
            end
        end
        
        function s = size(obj, varargin)
            % SIZE Returns the size of the stored matrix
            %
            % SYNTAX:
            %   s = size(obj)
            %   s = size(obj, dim)
            
            s = size(obj.MatrixData, varargin{:});
        end
        
        function n = nnz(obj)
            % NNZ Returns number of non-zero elements
            %
            % SYNTAX:
            %   n = nnz(obj)
            
            n = nnz(obj.MatrixData);
        end
        
        function result = plus(A, B)
            % PLUS Overloaded addition operator
            %
            % SYNTAX:
            %   C = A + B
            %
            % INPUTS:
            %   A, B - SparseMatrixHandle objects or numeric matrices
            
            if isa(A, 'SparseMatrixHandle')
                A_data = A.MatrixData;
            else
                A_data = A;
            end
            
            if isa(B, 'SparseMatrixHandle')
                B_data = B.MatrixData;
            else
                B_data = B;
            end
            
            result = SparseMatrixHandle(A_data + B_data);
        end
        
        function result = minus(A, B)
            % MINUS Overloaded subtraction operator
            %
            % SYNTAX:
            %   C = A - B
            
            if isa(A, 'SparseMatrixHandle')
                A_data = A.MatrixData;
            else
                A_data = A;
            end
            
            if isa(B, 'SparseMatrixHandle')
                B_data = B.MatrixData;
            else
                B_data = B;
            end
            
            result = SparseMatrixHandle(A_data - B_data);
        end
        
        function result = mtimes(A, B)
            % MTIMES Overloaded matrix multiplication operator
            %
            % SYNTAX:
            %   C = A * B
            
            if isa(A, 'SparseMatrixHandle')
                A_data = A.MatrixData;
            else
                A_data = A;
            end
            
            if isa(B, 'SparseMatrixHandle')
                B_data = B.MatrixData;
            else
                B_data = B;
            end
            
            result_data = A_data * B_data;
            
            % Return appropriate type based on result
            if isvector(result_data)
                result = result_data;  % Return vector directly
            else
                result = SparseMatrixHandle(result_data);
            end
        end
        
        function pinv_handle = pseudoinverse(obj, tol)
            % PSEUDOINVERSE Computes Moore-Penrose pseudoinverse
            %
            % SYNTAX:
            %   pinv_handle = pseudoinverse(obj)
            %   pinv_handle = pseudoinverse(obj, tol)
            %
            % INPUTS:
            %   tol - Tolerance for singular value cutoff (optional)
            %
            % OUTPUTS:
            %   pinv_handle - SparseMatrixHandle with pseudoinverse
            %
            % NOTE:
            %   This uses MATLAB's built-in pinv() which converts to
            %   full matrix. For large sparse matrices, consider
            %   iterative methods instead.
            
            if nargin < 2
                pinv_data = pinv(full(obj.MatrixData));
            else
                pinv_data = pinv(full(obj.MatrixData), tol);
            end
            
            pinv_handle = SparseMatrixHandle(sparse(pinv_data));
        end
        
        function disp(obj)
            % DISP Display method for SparseMatrixHandle
            
            fprintf('SparseMatrixHandle:\n');
            fprintf('  Size: %d x %d\n', size(obj.MatrixData, 1), size(obj.MatrixData, 2));
            fprintf('  Non-zeros: %d (%.2f%% sparse)\n', ...
                    nnz(obj.MatrixData), ...
                    100 * (1 - nnz(obj.MatrixData) / prod(size(obj.MatrixData))));
        end
    end
end
