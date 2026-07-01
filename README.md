# MICROSTRIP-PATCH-ANTENNA-MINIATURIZATION
MATLAB, Genetic Algorithm, Antenna Toolbox
# Genetic Algorithm Antenna Optimization & Pixel Matrix Mapping

A custom heuristic optimization framework designed for the aggressive structural miniaturization of microstrip patch antennas. This project utilizes a **Symmetric Genetic Algorithm (GA)** coupled with a manual **Breadth-First Search (BFS) flood-fill connectivity check** to evolve a binary pixel matrix, maximizing electrical path lengths within a tightly constrained physical footprint.

---

## 📌 Project Overview
Standard continuous-metal microstrip patch antennas operating over an air substrate ($\varepsilon_r = 1.0$) require significant physical dimensions to resonate at lower frequencies. When confined to a rigid physical boundary constraint of **53 mm × 53 mm**, standard geometries inherently resonate near 3.35 GHz.

This project bypasses traditional, resource-heavy commercial optimization toolboxes by discretizing the antenna surface into an automated binary grid. The optimization framework intelligently carves away metal elements to create custom, highly meandered symmetric paths that optimize current distributions, driving down structural boundaries while enforcing 100% component connectivity.

---

## 🚀 Key Features
- **Binary Pixel Discretization:** Maps the antenna patch layout onto a high-resolution 24×24 grid matrix (576 independent search nodes) where `1` represents polished copper and `0` represents a carved air void.
- **Symmetric Genetic Algorithm:** Enforces dual-axis mirror symmetry across chromosomes
