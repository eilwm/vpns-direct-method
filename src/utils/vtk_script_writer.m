% Define grid dimensions
nx = 10; ny = 10; % Grid size
[x, y] = meshgrid(linspace(0, 1, nx), linspace(0, 1, ny)); % Grid coordinates

% Generate velocity components
u = sin(2 * pi * x); % x-component of velocity
v = cos(2 * pi * y); % y-component of velocity

% Open file to write
fileID = fopen('velocityField.vtk', 'w');

% Write VTK header
fprintf(fileID, '# vtk DataFile Version 3.0\n');
fprintf(fileID, '2D Velocity Field\n');
fprintf(fileID, 'ASCII\n');
fprintf(fileID, 'DATASET STRUCTURED_GRID\n');
fprintf(fileID, 'DIMENSIONS %d %d 1\n', nx, ny);

% Write grid points
fprintf(fileID, 'POINTS %d float\n', nx * ny);
for j = 1:ny
    for i = 1:nx
        fprintf(fileID, '%f %f 0.0\n', x(j, i), y(j, i));
    end
end

% Write velocity vectors
fprintf(fileID, '\nPOINT_DATA %d\n', nx * ny);
fprintf(fileID, 'VECTORS velocity float\n');
for j = 1:ny
    for i = 1:nx
        fprintf(fileID, '%f %f 0.0\n', u(j, i), v(j, i));
    end
end

% Close the file
fclose(fileID);

disp('VTK file written successfully. You can now open it in ParaView.');
