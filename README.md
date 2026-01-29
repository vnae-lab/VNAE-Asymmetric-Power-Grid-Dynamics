# VNAE Asymmetric Power Grid Stability

## Overview

This repository presents an abstract multi-variable power grid model interpreted through the Victoria-Nash Asymmetric Equilibrium  (VNAE) framework. As we can note, the goal is not to reproduce electrical realism in detail, but to demonstrate how **heterogeneity and asymmetric dissipation** induce **global stability** in networked energy systems.

This example is intentionally structural and explanatory.

---

## Network Structure

The grid is modeled as a network of interacting nodes belonging to three structural classes:

- **Generators**  
  Nodes with higher inertia and rigidity, representing active power sources.

- **Loads**  
  Nodes with lower dissipation, representing consumption and demand variability.

- **Renewables**  
  Nodes subject to intermittent forcing, representing fluctuating power injection.

Each node is treated individually, even within the same class.

---

## State Variables

The model evolves two coupled state variables per node:

- **ω(t)** : frequency deviation at node *i*  
- **pᵢ(t)** : power injection at node *i*  

---

## Dynamics

The core frequency dynamics are given by:

dω/dt = − L · ω − Θ · ω + p

where:

• L is the network Laplacian encoding grid connectivity  
• Θ = diag(θ₁, … , θₙ) is a diagonal matrix of asymmetric dissipation parameters  
• p ∈ ℝⁿ represents injected or consumed power  

Power dynamics follow a dissipative evolution with intermittent forcing on renewable nodes.

---

## Asymmetry Parameter (θ)

- **θᵢ** represents structural rigidity or dissipation at node *i*  
- Each node has its own θ value  
- Generator, load, and renewable labels determine parameter ranges, not variables  

**Asymmetry emerges from the distribution of theta across the network, not from node type alone.**

---

## Geometric Interpretation (VNAE)

A quadratic effective metric is introduced as:

g = I + β · (Θ + A)

where:

• I is the identity matrix  
• Θ = diag(θ₁, … , θₙ) is the asymmetric dissipation matrix  
• A is the weighted adjacency matrix  
• β > 0 controls the strength of geometric deformation  

A scalar curvature proxy **K** is computed from heterogeneity and connectivity to **interpret stability**, not to drive the dynamics.

It is good to highlight that:

> **This is not a full Riemannian construction,  
> but a quadratic/canonical effective geometry derived from the VNAE framework.**

Positive **K** corresponds to structural contraction induced by asymmetric dissipation.

---

## Purpose

This repository serves as a canonical example of how asymmetric heterogeneity in power networks can be interpreted geometrically, providing an operational illustration of stability under the VNAE framework.

---

## Reference

Pereira, D. H. (2025). Riemannian Manifolds of Asymmetric Equilibria: The Victoria-Nash Geometry.

---

## License

MIT License
