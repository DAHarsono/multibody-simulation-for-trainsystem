%% TASK 2 – Evaluation of all simulations
clear; clc; close all;

%% --- Paths ---
dataDir = '../sim_data';
files = dir(fullfile(dataDir, '*.mat'));

%% --- Preallocate result arrays ---
nFiles = length(files);

mu      = zeros(nFiles,1);
v       = zeros(nFiles,1);
R       = zeros(nFiles,1);
maxYQ   = zeros(nFiles,1);
s_atMax = zeros(nFiles,1);

%% Filter settings
filterLength = 2.0;   % [m] distance-domain filter length
ds           = 0.01;  % [m] distance grid resolution

%% Loop over all simulations
for i = 1:nFiles

    %% Load data 
    fileName = files(i).name;
    load(fullfile(dataDir, fileName));

    %% Parse parameters from filename
    % Format: (mu_ohne_komma)_(speed)_(radius).mat
    tokens = split(erase(fileName, '.mat'), '_');

    mu(i) = str2double(tokens{1}) / 10;
    v(i)  = str2double(tokens{2});
    R(i)  = str2double(tokens{3});

    %% Convert single -> double
    vars = whos;
    for k = 1:length(vars)
        if strcmp(vars(k).class, 'single')
            eval([vars(k).name ' = double(' vars(k).name ');']);
        end
    end

    %% Distance vector
    s_raw = weg;

    %% Leading wheelset (RS1) forces
    Y = RS1_L_Y + RS1_R_Y;
    Q = RS1_L_Q + RS1_R_Q;

    %% Resample to uniform distance grid
    s_grid = (s_raw(1):ds:s_raw(end))';

    Y_i = interp1(s_raw, Y, s_grid, 'linear');
    Q_i = interp1(s_raw, Q, s_grid, 'linear');

    %% Distance-domain filtering (moving average)
    windowSize = round(filterLength / ds);
    Y_f = movmean(Y_i, windowSize);
    Q_f = movmean(Q_i, windowSize);

    %% Y/Q ratio
    YQ = Y_f ./ Q_f;

    %% Extract maximum
    [maxYQ(i), idx] = max(YQ);
    s_atMax(i) = s_grid(idx);

    %% Progress info
    fprintf('Processed %3d / %3d: %s | max Y/Q = %.3f\n', ...
            i, nFiles, fileName, maxYQ(i));

end

%% Store results in table
results = table(mu, v, R, maxYQ, s_atMax);

%% Save results to output folder
outDir = '../output';

save(fullfile(outDir, 'step52_results.mat'), 'results');
%% Display summary
disp('Task 2 completed.');
disp(results(1:10,:));   % show first 10 rows