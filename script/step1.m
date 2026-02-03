%% STEP 1 – Single simulation inspection
clear; clc; close all;

%% --- Select one simulation file ---
dataPath = '../sim_data/01_5_150.mat';  
load(dataPath);

%% --- Convert to double (important for processing) ---
vars = whos;
for k = 1:length(vars)
    if strcmp(vars(k).class, 'single')
        eval([vars(k).name ' = double(' vars(k).name ');']);
    end
end

%% --- Distance vector ---
s = weg;          % distance [m]
t = zeit;         % time [s] (not used further here)

%% --- Example: Wheelset 1 ---
% Left and right wheel forces
Y_L = RS1_L_Y;
Y_R = RS1_R_Y;
Q_L = RS1_L_Q;
Q_R = RS1_R_Q;

% Wheelset forces (recommended for interpretation)
Y_WS = Y_L + Y_R;
Q_WS = Q_L + Q_R;

% Y/Q ratio
YQ_WS = Y_WS ./ Q_WS;

%% --- Plot 1: Vertical wheel load Q ---
figure;
plot(s, Q_L, 'b', s, Q_R, 'r', s, Q_WS, 'k', 'LineWidth', 1.2);
grid on;
xlabel('Distance s [m]');
ylabel('Vertical force Q [N]');
title('Wheelset 1 – Vertical forces');
legend('Left wheel','Right wheel','Wheelset sum','Location','best');

%% --- Plot 2: Lateral force Y ---
figure;
plot(s, Y_L, 'b', s, Y_R, 'r', s, Y_WS, 'k', 'LineWidth', 1.2);
grid on;
xlabel('Distance s [m]');
ylabel('Lateral force Y [N]');
title('Wheelset 1 – Lateral forces');
legend('Left wheel','Right wheel','Wheelset sum','Location','best');

%% --- Plot 3: Y/Q ratio ---
figure;
plot(s, YQ_WS, 'k', 'LineWidth', 1.5);
grid on;
xlabel('Distance s [m]');
ylabel('Y / Q [-]');
title('Wheelset 1 – Y/Q ratio');

%% --- Mark maximum Y/Q ---
[YQ_max, idx] = max(YQ_WS);
hold on;
plot(s(idx), YQ_max, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
text(s(idx), YQ_max, sprintf('  max Y/Q = %.3f', YQ_max), ...
     'VerticalAlignment','bottom');

%% --- Console output ---
fprintf('STEP 1 – Single scenario summary\n');
fprintf('File: 01_5_150.mat\n');
fprintf('Max Y/Q (wheelset 1): %.3f at s = %.1f m\n', YQ_max, s(idx));