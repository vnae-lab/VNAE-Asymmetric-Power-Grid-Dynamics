import numpy as np
import matplotlib.pyplot as plt

# ------------------------------------------------------------
# VNAE Asymmetric Power Grid Stability 
# ------------------------------------------------------------

# Set seed for reproducibility
np.random.seed(123)

# Network parameters
N = 12                # Number of grid nodes
T_max = 20.0          # Total simulation time
dt = 0.01             # Time step
time_seq = np.arange(0, T_max + dt, dt)
n_steps = len(time_seq)

# Node types: 1 = generator, 2 = load, 3 = renewable
node_type = np.array([1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3])

# Asymmetric structural parameters (Theta - Rigidity/Inertia)
theta_vals = np.array([1.5, 1.2, 1.0, 0.6, 0.5, 0.7, 0.4, 0.8, 0.9, 0.6, 0.7, 0.5])
Theta = np.diag(theta_vals)

# Power dissipation parameters (Gamma)
gamma_vals = np.random.uniform(0.6, 1.2, N)
Gamma = np.diag(gamma_vals)

# Network Laplacian (L) representing grid connectivity
A = np.random.rand(N, N)
A = (A + A.T) / 2      # Symmetrize adjacency matrix
np.fill_diagonal(A, 0)
D = np.diag(np.sum(A, axis=1))
L = D - A

# Initial states (Frequency and Power)
Omega = np.zeros((n_steps, N))
Power = np.zeros((n_steps, N))
Omega[0, :] = np.random.uniform(-0.3, 0.3, N)
Power[0, :] = np.random.uniform(-1.0, 1.0, N)

# ------------------------------------------------------------
# Simulation Loop (VNAE Gradient Flow)
# ------------------------------------------------------------

for k in range(1, n_steps):
    w = Omega[k-1, :]
    p = Power[k-1, :]
    
    # Frequency dynamics: dw/dt = -Lw - Theta*w + p
    dw = -L.dot(w) - Theta.dot(w) + p
    
    # Power dynamics: dp/dt = -Gamma*p + Renewable Noise
    dp = -Gamma.dot(p)
    
    # Apply intermittent renewable forcing to type 3 nodes
    current_time = time_seq[k]
    for i in range(N):
        if node_type[i] == 3:
            # Identical noise logic: Sine wave + White Noise
            noise = 0.3 * np.sin(2 * np.pi * 0.4 * current_time) + np.random.normal(0, 0.05)
            dp[i] += noise
            
    # Euler integration step
    Omega[k, :] = w + dt * dw
    Power[k, :] = p + dt * dp

# ------------------------------------------------------------
# Visualization 
# ------------------------------------------------------------

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Frequency Dynamics
for i in range(N):
    ax1.plot(time_seq, Omega[:, i], linewidth=1.2)
ax1.set_title("Asymmetric Frequency Dynamics under VNAE")
ax1.set_xlabel("Time")
ax1.set_ylabel("Frequency deviation")
ax1.grid(True, linestyle=':', alpha=0.6)

# Plot 2: Power Dynamics
for i in range(N):
    ax2.plot(time_seq, Power[:, i], linewidth=1.2)
ax2.set_title("Power Dynamics with Renewable Intermittency")
ax2.set_xlabel("Time")
ax2.set_ylabel("Power injection")
ax2.grid(True, linestyle=':', alpha=0.6)

plt.tight_layout()
plt.show()
