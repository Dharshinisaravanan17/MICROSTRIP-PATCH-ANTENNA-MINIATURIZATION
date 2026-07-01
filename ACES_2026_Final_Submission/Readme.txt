### **README.txt **

**Project:** ACES 2026 Antenna Miniaturization (2.6 GHz)

---

### **1. Package Contents**

Ensure the following **8 MATLAB files** are in your current folder:

* **`ACES_main_Symmetric.m`**: The main entry point. Sets optimization parameters (Grid size, Population, Generations) and executes the Genetic Algorithm.
* **`build_patch_geometry.m`**: Converts the binary pixel map into a physical 3D PCB stack using `pcbStack`.
* **`check_connectivity.m`**: A custom Breadth-First Search (BFS) flood-fill algorithm that ensures the antenna is physically connected without requiring the Image Processing Toolbox.
* **`compute_fitness.m`**: The objective function. It evaluates designs based on frequency accuracy, bandwidth requirements, and connectivity ratios.
* **`connectivity_constraint.m`**: Acts as the gatekeeper for the GA, ensuring only valid, connected structures are prioritized.
* **`find_feed_point.m`**: Automatically calculates the optimal coaxial probe location based on the centroid of the pixelated patch to achieve 50-ohm matching.
* **`plot_all_results.m`**: Generates and saves the required competition plots (S11, 2D/3D Radiation Patterns, and the Pixel Map).
* **`simulate_patch.m`**: The EM simulation engine. It applies the symmetry mirror logic and calls the MATLAB Antenna Toolbox solvers.

---

### **2. How to Run**

1. Open **`ACES_main_Symmetric.m`**.
2. **To verify the code quickly (approx. 1 hour):** Set `params.grid_N = 12;`.
3. **To replicate the high-resolution results (approx. 6-8 hours):** Set `params.grid_N = 24;`.
4. Click **Run**.

---

### **3. Strategic Implementation Details**

* **Symmetry Constraint:** To maintain radiation pattern stability and reduce the search space, the GA optimizes a half-grid which is then mirrored across the X-axis in `simulate_patch.m`.
* **Hail Mary Targeter:** The `compute_fitness.m` function uses a soft-penalty approach. If a design is not at 2.6 GHz, it receives a penalty proportional to its distance from the target, guiding the GA toward the desired resonance even from a distance.
* **Robustness:** The code is designed to be "toolbox-lean," meaning it relies on core MATLAB and the Antenna/Optimization toolboxes, avoiding errors caused by missing specialized image libraries.

---