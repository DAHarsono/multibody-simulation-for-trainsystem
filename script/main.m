% VS Code – MATLAB integration test script

clc            % clear command window
clear          % clear workspace
close all      % close all figures

disp('MATLAB is running correctly from VS Code!')

x = 0:0.01:2*pi;
y = sin(x);

figure
plot(x, y)
grid on
xlabel('x')
ylabel('sin(x)')
title('MATLAB–VS Code Test Plot')

fprintf('Max value of sin(x): %.2f\n', max(y))