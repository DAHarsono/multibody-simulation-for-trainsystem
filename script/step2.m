%% TASK 2 – Evaluation of all simulations (all wheelsets)
clear; clc; close all;

%% --- Paths ---
dataDir = '../sim_data';
outDir  = '../output';

files = dir(fullfile(dataDir, '*.mat'));
nFiles = length(files);

%% --- Preallocate result arrays ---
mu          = zeros(nFiles,1);
v           = zeros(nFiles,1);
R           = zeros(nFiles,1);
maxYQ       = zeros(nFiles,1);
criticalRS  = zeros(nFiles,1);
s_atMax     = zeros(nFiles,1);

%% --- Filter settings ---
filterLength = 2.0;   % [m] distance-domain filter length
ds           = 0.01;  % [m] distance grid resolution

%% --- Loop over all simulations ---
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

    %% Uniform distance grid
    s_grid = (s_raw(1):ds:s_raw(end))';
    windowSize = round(filterLength / ds);

    %% --- Evaluate all wheelsets ---
    maxYQ_ws = zeros(4,1);
    s_ws     = zeros(4,1);

    for rs = 1:4

        % Access wheelset data dynamically
        Y_L = eval(sprintf('RS%d_L_Y', rs));
        Y_R = eval(sprintf('RS%d_R_Y', rs));
        Q_L = eval(sprintf('RS%d_L_Q', rs));
        Q_R = eval(sprintf('RS%d_R_Q', rs));

        % Wheelset forces
        Y = Y_L + Y_R;
        Q = Q_L + Q_R;

        % Interpolate to uniform distance grid
        Y_i = interp1(s_raw, Y, s_grid, 'linear');
        Q_i = interp1(s_raw, Q, s_grid, 'linear');

        % Distance-domain filtering
        Y_f = movmean(Y_i, windowSize);
        Q_f = movmean(Q_i, windowSize);

        % Y/Q ratio
        YQ = Y_f ./ Q_f;

        % Maximum for this wheelset
        [maxYQ_ws(rs), idx] = max(YQ);
        s_ws(rs) = s_grid(idx);

    end

    %% --- Global maximum across all wheelsets ---
    [maxYQ(i), criticalRS(i)] = max(maxYQ_ws);
    s_atMax(i) = s_ws(criticalRS(i));

    %% Progress info
    fprintf('Processed %3d / %3d: %s | max Y/Q = %.3f (RS%d)\n', ...
            i, nFiles, fileName, maxYQ(i), criticalRS(i));

end

%% --- Store results in table ---
results = table(mu, v, R, maxYQ, criticalRS, s_atMax);

%% --- Save results ---
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

save(fullfile(outDir, 'step2_results.mat'), 'results');

%% --- Display summary ---
disp('Step 2 completed (all wheelsets evaluated).');
disp(results(1:10,:));