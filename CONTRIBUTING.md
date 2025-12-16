# Contributing to VPNS Solver

Thank you for your interest in contributing to the VPNS Solver project! This document provides guidelines for contributing to the project.

## Code of Conduct

This project adheres to a code of conduct that all contributors are expected to uphold. Please be respectful and constructive in all interactions.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue on GitHub with:
- A clear, descriptive title
- Steps to reproduce the problem
- Expected behavior vs. actual behavior
- Your MATLAB version and operating system
- Relevant code snippets or error messages

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:
- A clear description of the proposed feature
- Why this enhancement would be useful
- Any relevant examples or mockups

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following the coding standards below
3. **Test your changes** thoroughly
4. **Document your changes** with appropriate comments and docstrings
5. **Submit a pull request** with a clear description of the changes

## Coding Standards

### MATLAB Code Style

- **Function Documentation**: All functions must have comprehensive header comments following the template:
  ```matlab
  function output = functionName(input1, input2)
  % FUNCTIONNAME Brief description
  %
  % SYNTAX:
  %   output = functionName(input1, input2)
  %
  % DESCRIPTION:
  %   Detailed description of what the function does
  %
  % INPUTS:
  %   input1 - Description [units if applicable]
  %   input2 - Description [units if applicable]
  %
  % OUTPUTS:
  %   output - Description [units if applicable]
  %
  % EXAMPLE:
  %   output = functionName(value1, value2);
  %
  % SEE ALSO: relatedFunction1, relatedFunction2
  %
  % AUTHOR: Your Name
  % DATE: Month Year
  ```

- **Variable Naming**:
  - Use descriptive names: `velocity`, `pressure`, `gridSpacing`
  - Avoid single letters except for loop counters (`i`, `j`, `k`)
  - Physical quantities should include units in comments
  - Constants in UPPER_CASE: `MAX_ITERATIONS`, `CFL_NUMBER`

- **Code Organization**:
  - Use section breaks (`%%`) to organize code
  - Keep functions focused on a single task
  - Limit function length to ~200 lines when possible
  - Use helper functions for repeated operations

- **Comments**:
  - Explain *why*, not *what*
  - Document assumptions and limitations
  - Reference equations or papers where relevant

### File Organization

```
src/
├── core/          # Core solver algorithms
├── boundary/      # Boundary condition handling
├── forces/        # Force computation routines
└── utils/         # Utility functions
```

Place new files in the appropriate directory.

### Testing

- Add test cases for new functionality in `tests/`
- Verify that existing tests pass
- Document test cases and expected results
- Include validation against known benchmarks when applicable

## Development Workflow

### Setting Up Development Environment

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/VPNS-Solver.git
   cd VPNS-Solver
   ```

2. Add the source directories to your MATLAB path:
   ```matlab
   addpath('src');
   addpath(genpath('src'));
   ```

3. Run the test suite:
   ```matlab
   cd tests
   run_all_tests
   ```

### Making Changes

1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes, following the coding standards

3. Test your changes thoroughly

4. Commit with clear, descriptive messages:
   ```bash
   git commit -m "Add feature: brief description"
   ```

5. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

6. Open a pull request on GitHub

### Commit Message Guidelines

- Use present tense: "Add feature" not "Added feature"
- Use imperative mood: "Move file to..." not "Moves file to..."
- First line should be a brief summary (<50 characters)
- Optionally follow with a detailed description

Examples:
```
Add adaptive time stepping for convection-dominated flows

Implements CFL-based automatic time step adjustment to improve
stability in high Reynolds number simulations. Includes tests
for various flow regimes.
```

## Priority Areas for Contribution

We especially welcome contributions in:

1. **Numerical Methods**
   - AMG-based iterative solvers
   - Adaptive mesh refinement
   - Higher-order discretization schemes
   - Improved time integration schemes

2. **Performance Optimization**
   - GPU acceleration
   - Parallel processing
   - Sparse matrix optimizations

3. **Extended Capabilities**
   - 3D solver implementation
   - Complex geometries
   - Additional boundary conditions
   - Turbulence models

4. **Validation & Testing**
   - Benchmark comparisons
   - Convergence studies
   - Test case library

5. **Documentation**
   - Tutorial examples
   - Theory documentation
   - API reference improvements

## Questions?

If you have questions about contributing, feel free to:
- Open an issue with the `question` label
- Start a discussion on GitHub Discussions
- Contact the maintainers directly

Thank you for contributing to VPNS Solver!
