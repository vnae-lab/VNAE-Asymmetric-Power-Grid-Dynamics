using Plots
using LinearAlgebra
using Random

# ------------------------------------------------------------
# VNAE Asymmetric Power Grid Stability 
# ------------------------------------------------------------

# Set seed for reproducibility
Random.seed!(123)

# Network parameters
N = 12                # Number of grid nodes
T_max = 20.0          # Total simulation time
dt = 0.01             # Time step
time_seq = 0:dt:T_max # Time vector
n_steps = length(time_seq)

# Node types: 1 = generator, 2 = load, 3 = renewable
node_type = [1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3]

# Asymmetric structural parameters (Theta - Rigidity/Inertia)
theta = [1.5, 1.2, 1.0, 0.6, 0.5, 0.7, 0.4, 0.8, 0.9, 0.6, 0.7, 0.5]
Theta = Diagonal(theta)

# Power dissipation parameters (Gamma)
gamma_vals = rand(N) .* (1.2 - 0.6) .+ 0.6
Gamma = Diagonal(gamma_vals)

# Network Laplacian (L) representing grid connectivity
A = rand(N, N)
A = (A + A') / 2      # Symmetrize adjacency matrix
for i in 1:N A[i, i] = 0 end
D = Diagonal(sum(A, dims=2)[:])
L = D - A

# Initial states (Frequency and Power)
Omega = zeros(n_steps, N)
Power = zeros(n_steps, N)
Omega[1, :] = rand(N) .* 0.6 .- 0.3
Power[1, :] = rand(N) .* 2.0 .- 1.0

# ------------------------------------------------------------
# Simulation Loop (VNAE Gradient Flow)
# ------------------------------------------------------------

for k in 2:n_steps
    w = Omega[k-1, :]
    p = Power[k-1, :]
    
    # Frequency dynamics: dw/dt = -Lw - Theta*w + p
    dw = -L * w - Theta * w + p
    
    # Power dynamics: dp/dt = -Gamma*p + Renewable Noise
    dp = -Gamma * p
    for i in 1:N
        if node_type[i] == 3
            # Identical noise to R version: Sine wave + White Noise
            noise = 0.3 * sin(2 * pi * 0.4 * time_seq[k]) + randn() * 0.05
            dp[i] += noise
        end
    end
    
    # Euler integration step
    Omega[k, :] = w + dt * dw
    Power[k, :] = p + dt * dp
end

# ------------------------------------------------------------
# Visualization 
# ------------------------------------------------------------

# Plot 1: Frequency Dynamics
p1 = plot(time_seq, Omega, 
          lw=1.5, 
          title="Asymmetric Frequency Dynamics under VNAE",
          xlabel="Time", ylabel="Frequency deviation",
          grid=true, legend=false, palette=:auto)

# Plot 2: Power Dynamics
p2 = plot(time_seq, Power, 
          lw=1.5, 
          title="Power Dynamics with Renewable Intermittency",
          xlabel="Time", ylabel="Power injection",
          grid=true, legend=false, palette=:auto)

# Display side-by-side 
plot(p1, p2, layout=(1, 2), size=(1000, 450))
