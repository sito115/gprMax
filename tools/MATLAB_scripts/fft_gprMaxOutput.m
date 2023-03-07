%% Select Path
function [allData,fieldName] = fft_gprMaxOutput(path, fileName)

%%
pathRoot     = 'C:\OneDrive - Delft University of Technology';
trdSemester  = '3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax\thomas\python';
figureFolder = '4. Semester - Thesis\OutputgprMax\Figures';

fullfilename  = fullfile(path, fileName);
allComponents = {'Ex', 'Ey', 'Ez'};         % to perform fft


%% Load MetaData
fprintf('%s\n', fileName)
fprintf('\tLoading Metadata...')

header.title = h5readatt(fullfilename, '/', 'Title');
header.iterations = double(h5readatt(fullfilename,'/', 'Iterations'));
tmp = h5readatt(fullfilename, '/', 'dx_dy_dz');
header.dx = tmp(1);
header.dy = tmp(2);
header.dz = tmp(3);
header.dt = h5readatt(fullfilename, '/', 'dt');
header.nsrc = h5readatt(fullfilename, '/', 'nsrc');
header.nrx = h5readatt(fullfilename, '/', 'nrx');
header.nx_ny_nz = h5readatt(fullfilename, '/', 'nx_ny_nz');
header.fullfileName = fullfilename;

srcTemp      = h5readatt(fullfilename, '/srcs/src1', 'Position');
header.sx = srcTemp(1);
header.sy = srcTemp(2);
header.sz = srcTemp(3);

fprintf('Done \n')

%% Load E-Field Time Domain
fprintf('\tLoading E & H field time domain...')
% Time vector for plotting
time = linspace(0, (header.iterations - 1) * header.dt, header.iterations)';

% Initialise structure for field arrays
fields.Ex = zeros(header.iterations, header.nrx);
fields.Ey = zeros(header.iterations, header.nrx);
fields.Ez = zeros(header.iterations, header.nrx);
fields.Hx = zeros(header.iterations, header.nrx);
fields.Hy = zeros(header.iterations, header.nrx);
fields.Hz = zeros(header.iterations, header.nrx);

for n=1:header.nrx
    path = strcat('/rxs/rx', num2str(n));
    tmp = h5readatt(fullfilename, path, 'Position');
    header.rx(n) = tmp(1);
    header.ry(n) = tmp(2);
    header.rz(n) = tmp(3);
    path = strcat(path, '/');
    fields.Ex(:,n) = h5read(fullfilename, strcat(path, 'Ex'));
    fields.Ey(:,n) = h5read(fullfilename, strcat(path, 'Ey'));
    fields.Ez(:,n) = h5read(fullfilename, strcat(path, 'Ez'));
    fields.Hx(:,n) = h5read(fullfilename, strcat(path, 'Hx'));
    fields.Hy(:,n) = h5read(fullfilename, strcat(path, 'Hy'));
    fields.Hz(:,n) = h5read(fullfilename, strcat(path, 'Hz'));
end

fprintf('Done \n')
%% FFT of Components
% https://de.mathworks.com/help/wavelet/gs/from-fourier-analysis-to-wavelet-analysis.html
% https://de.mathworks.com/help/matlab/math/fourier-transforms.html
% fs = 1/header.dt;
% fAxis = (0:header.iterations-1)*fs/header.iterations;
fprintf('\tPerforming FFT...')
df    = 1/(header.dt*header.iterations);
fAxis = linspace(0,header.iterations/2,fix(header.iterations/2+1))*df;    %making the frequency axis

for component = allComponents
    for iRx = 1:header.nrx
        comp = component{1};
        FFT.(comp)(:,iRx) = fft(fields.(comp)(:,iRx), [], 1)*header.dt;
    end
end

fprintf('Done \n')
%% Create output structure

fprintf('\tSaving...')

fieldName = erase(fileName,{'.','-','_'});

allData= struct;
allData.(fieldName).Attributes   = header;
allData.(fieldName).Data.fields  = fields;
allData.(fieldName).Data.FFT     = FFT;
allData.(fieldName).Axis.time    = time;
allData.(fieldName).Axis.fAxis   = fAxis;
allData.(fieldName).FileName     = fileName;

fprintf('Done \n')
    %% Save

%     data = load(fullfile(pathRoot, '3. Semester - Studienunterlagen\ResearchModule\AllResults.mat'));
%     Results = data.Results;
% 
%     if ~ismember(newName, fieldnames(Results))
%        
%         Results.(newName) = allData.(newName);
% 
%         save (fullfile(pathRoot, '3. Semester - Studienunterlagen\ResearchModule\AllResults.mat'),'Results', '-v7.3')
%         fprintf('Succesfully save file.\n')
%     else
%         fprintf('The field %s already exists in Results\n', newName)
%         answer = input('Really save?\n','s');
%         if strcmp(answer, 'y')
%             Results.(newName) = allData.(newName);
%     
%             save (fullfile(pathRoot, '3. Semester - Studienunterlagen\ResearchModule\AllResults.mat'),'Results', '-v7.3')
%             fprintf('Succesfully save file.\n')
%         end
%     end
% 
% end



