% ------------------------------------------------------------
% VNAE Asymmetric Power Grid Stability 
% ------------------------------------------------------------
clear; clc;

% Set seed for reproducibility
rng(123);

% Network parameters
N = 12;                % Number of grid nodes
T_max = 20;            % Total simulation time
dt = 0.01;             % Time step
time_seq = 0:dt:T_max; % Time vector
n_steps = length(time_seq);

% Node types: 1 = generator, 2 = load, 3 = renewable
node_type = [1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3];

% Asymmetric structural parameters (Theta - Rigidity/Inertia)
theta_vals = [1.5, 1.2, 1.0, 0.6, 0.5, 0.7, 0.4, 0.8, 0.9, 0.6, 0.7, 0.5];
Theta = diag(theta_vals);

% Power dissipation parameters (Gamma)
gamma_vals = 0.6 + (1.2 - 0.6) * rand(1, N);
Gamma = diag(gamma_vals);

% Network Laplacian (L) representing grid connectivity
A = rand(N, N);
A = (A + A') / 2;      % Symmetrize adjacency matrix
A(logical(eye(N))) = 0; % Fill diagonal with zeros
D = diag(sum(A, 2));
L = D - A;

% Initial states (Frequency and Power)
Omega = zeros(N, n_steps);
Power = zeros(N, n_steps);
Omega(:, 1) = -0.3 + (0.3 - (-0.3)) * rand(N, 1);
Power(:, 1) = -1.0 + (1.0 - (-1.0)) * rand(N, 1);

% ------------------------------------------------------------
% Simulation Loop (VNAE Gradient Flow)
% ------------------------------------------------------------

for k = 2:n_steps
    w = Omega(:, k-1);
    p = Power(:, k-1);
    
    % Frequency dynamics: dw/dt = -Lw - Theta*w + p
    dw = -L*w - Theta*w + p;
    
    % Power dynamics: dp/dt = -Gamma*p + Renewable Noise
    dp = -Gamma*p;
    
    current_time = time_seq(k);
    for i = 1:N
        if node_type(i) == 3
            % Identical noise logic: Sine wave + White Noise
            noise = 0.3 * sin(2 * pi * 0.4 * current_time) + 0.05 * randn();
            dp(i) = dp(i) + noise;
        end
    end
    
    % Euler integration step
    Omega(:, k) = w + dt * dw;
    Power(:, k) = p + dt * dp;
end

% ------------------------------------------------------------
% Visualization 
% ------------------------------------------------------------

figure('Color', 'w', 'Position', [100, 100, 1200, 500]);

% Plot 1: Frequency Dynamics
subplot(1, 2, 1);
plot(time_seq, Omega', 'LineWidth', 1.2);
title('Asymmetric Frequency Dynamics under VNAE');
xlabel('Time');
ylabel('Frequency deviation');
grid on;

% Plot 2: Power Dynamics
subplot(1, 2, 2);
plot(time_seq, Power', 'LineWidth', 1.2);
title('Power Dynamics with Renewable Intermittency');
xlabel('Time');
ylabel('Power injection');
grid on;

% Add a common legend feel (optional, simplified for clarity)
% legend('Node 1', 'Node 2', ...);
