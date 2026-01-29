# ------------------------------------------------------------
# VNAE Asymmetric Power Grid Stability
# Abstract Multi-Variable Network Model
# ------------------------------------------------------------

rm(list = ls())
set.seed(123)

# ------------------------------------------------------------
# Network parameters
# ------------------------------------------------------------

N <- 12               # number of grid nodes
T  <- 20
dt <- 0.01
time <- seq(0, T, by = dt)

# Node types:
# 1 = generator, 2 = load, 3 = renewable
node_type <- c(1,1,1, 2,2,2,2, 3,3,3,3,3)

# ------------------------------------------------------------
# Asymmetric structural parameters (VNAE core)
# ------------------------------------------------------------

# Inertia / rigidity (Theta)
theta <- c(
  1.5, 1.2, 1.0,      # generators
  0.6, 0.5, 0.7, 0.4,# loads
  0.8, 0.9, 0.6, 0.7, 0.5  # renewables
)

Theta <- diag(theta)

# Power dissipation
gamma <- diag(runif(N, 0.6, 1.2))

# ------------------------------------------------------------
# Network Laplacian (asymmetric grid)
# ------------------------------------------------------------

A <- matrix(runif(N*N, 0, 1), N, N)
A <- (A + t(A)) / 2
diag(A) <- 0

D <- diag(rowSums(A))
L <- D - A

# ------------------------------------------------------------
# Initial states
# ------------------------------------------------------------

omega <- runif(N, -0.3, 0.3)   # frequency deviations
p     <- runif(N, -1, 1)       # power injections

Omega <- matrix(0, length(time), N)
Power <- matrix(0, length(time), N)

Omega[1, ] <- omega
Power[1, ] <- p

# ------------------------------------------------------------
# Intermittent renewable forcing
# ------------------------------------------------------------

renewable_noise <- function(t, i) {
  if (node_type[i] == 3) {
    return(0.3 * sin(2 * pi * 0.4 * t) + rnorm(1, 0, 0.05))
  } else {
    return(0)
  }
}

# ------------------------------------------------------------
# Simulation loop
# ------------------------------------------------------------

for (k in 2:length(time)) {
 
  w <- Omega[k-1, ]
  p <- Power[k-1, ]
 
  # Frequency dynamics (VNAE structure)
  dw <- -L %*% w - Theta %*% w + p
 
  # Power dynamics
  dp <- -gamma %*% p
 
  for (i in 1:N) {
    dp[i] <- dp[i] + renewable_noise(time[k], i)
  }
 
  Omega[k, ] <- w + dt * dw
  Power[k, ] <- p + dt * dp
}

# ------------------------------------------------------------
# VNAE metric tensor and curvature (abstract)
# ------------------------------------------------------------

beta <- 0.2

# Metric tensor g_ij = delta_ij + beta (Theta + A)
g <- diag(N) + beta * (Theta + A)

# Scalar curvature proxy (VNAE-style)
K <- 0
for (i in 1:(N-1)) {
  for (j in (i+1):N) {
    K <- K + abs(theta[i] - theta[j]) * abs(A[i,j]) /
      (1 + beta * (theta[i] + theta[j]))
  }
}
K <- 2 * K / (N * (N - 1))

cat("VNAE scalar curvature K =", round(K, 4), "\n")

# ------------------------------------------------------------
# Visualization
# ------------------------------------------------------------

matplot(time, Omega, type = "l", lwd = 1.8,
        xlab = "Time",
        ylab = "Frequency deviation",
        main = "Asymmetric Frequency Dynamics under VNAE")
grid()

matplot(time, Power, type = "l", lwd = 1.8,
        xlab = "Time",
        ylab = "Power injection",
        main = "Power Dynamics with Renewable Intermittency")
grid()

             

