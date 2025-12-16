classdef VectorHandle < handle
    % VECTORHANDLE Handle class for passing vectors by reference
    %
    % DESCRIPTION:
    %   A simple handle class wrapper for vectors to enable pass-by-reference
    %   semantics in MATLAB. This allows functions to modify vectors in place
    %   without needing to return the modified vector.
    %
    % PROPERTIES:
    %   VectorData - The actual vector data stored in the handle
    %
    % METHODS:
    %   VectorHandle(data) - Constructor that initializes with given data
    %
    % EXAMPLE:
    %   % Create a handle to a vector
    %   vec = zeros(10, 1);
    %   vecHandle = VectorHandle(vec);
    %   
    %   % Modify through the handle
    %   vecHandle.VectorData(1:5) = 1;
    %   
    %   % Access the data
    %   result = vecHandle.VectorData;
    %
    % NOTES:
    %   - This is a handle class, so assignment creates a reference, not a copy
    %   - Multiple handles can point to the same underlying data
    %   - Useful for large arrays to avoid memory overhead of copying
    %
    % SEE ALSO: SparseMatrixHandle, handle
    %
    % AUTHOR: VPNS Development Team
    % DATE: December 2025
    
    properties
        VectorData  % The vector data (column or row vector)
    end
    
    methods
        function obj = VectorHandle(data)
            % VECTORHANDLE Constructor for VectorHandle class
            %
            % SYNTAX:
            %   obj = VectorHandle(data)
            %
            % INPUTS:
            %   data - Initial vector data (optional, defaults to empty)
            %
            % OUTPUTS:
            %   obj - VectorHandle object
            
            if nargin > 0
                obj.VectorData = data;
            else
                obj.VectorData = [];
            end
        end
        
        function n = length(obj)
            % LENGTH Returns the length of the stored vector
            %
            % SYNTAX:
            %   n = length(obj)
            %
            % OUTPUTS:
            %   n - Length of VectorData
            
            n = length(obj.VectorData);
        end
        
        function s = size(obj, varargin)
            % SIZE Returns the size of the stored vector
            %
            % SYNTAX:
            %   s = size(obj)
            %   s = size(obj, dim)
            %
            % INPUTS:
            %   dim - Optional dimension (1 or 2)
            %
            % OUTPUTS:
            %   s - Size of VectorData
            
            s = size(obj.VectorData, varargin{:});
        end
    end
end
