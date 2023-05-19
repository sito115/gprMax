filename = 'C:\OneDrive - Delft University of Technology\3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax\ProcessedFiles\HalfSpace_dx6.0m_eps_5.0_i3D1_er0_12.5_h0.5mDecreaseRLFLA.vti';
% filename = 'example.vti';
fid = fopen(filename);
if fid == -1
    error(['Error opening file ' filename]);
end
while ~feof(fid)
    tline = fgetl(fid);
    disp(tline);
end
fclose(fid);