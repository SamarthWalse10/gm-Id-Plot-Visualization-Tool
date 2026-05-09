# gm/Id Plot Visualization Tool

## Automated gm/Id Characterization Pipeline

A complete, end-to-end automation toolkit for extracting and visualizing gm/Id Look-Up Tables (LUTs) for MOSFETs. This pipeline bridges the gap between Cadence Virtuoso and modern Python data visualization, allowing analog IC designers to instantly generate testbenches, run massive ultra-high-resolution simulations, and interactively analyze device physics.

> **Note:** This toolkit was specifically built and tested using the **TSMC 65nm (tsmcN65)** PDK. However, the SKILL and OCEAN scripts are fully generalized and can be easily adapted to other PDKs (like GPDK180 or TSMC 45nm) by updating the configuration variables.

---

## The Toolkit

This repository contains a three-stage automated workflow:

1. **`create_gmId_tb.il` (The Architect):** A fully generalized Cadence SKILL script. It programmatically generates a perfectly wired, unified schematic testbench for simultaneous diode-connected NMOS and PMOS characterization.
2. **`run_gmId_char.ocn` (The Engine):** A robust OCEAN script that executes an ultra-high-resolution DC sweep (e.g., 100nA to 10mA with 10nA steps). It extracts the exact operating points (gm, gds, cgg, Vth), formats them into `.csv` files, and automatically scrubs gigabytes of temporary simulation data from your hard drive to keep your workspace clean.
3. **`main_gmId_plotter.ipynb` (The Lens):** A highly optimized Python dashboard using Plotly and SciPy. It effortlessly handles millions of data points using real-time cubic spline interpolation, allowing you to interactively analyze sizing methodologies.

---

## Features

- **PDK Mapped Design:** Easily configurable for different technology nodes. Simply update the variables block at the top of the scripts to match your target PDK.
- **Unified Extraction:** Characterize NMOS and PMOS devices simultaneously in a single simulation run.
- **True Vbs Biasing:** NMOS and PMOS bodies are correctly initialized to Source, allowing for accurate Body-Effect (gmb) extraction which can later be changed.
- **Ultra-High Resolution:** Capable of sweeping massive ranges (e.g., 10nA steps) yielding millions of data points for highly accurate derivative extraction (gm, cgg).
- **Auto-Cleanup:** The OCEAN script automatically deletes Cadence `psf` and numbered job folders post-extraction to save disk space.
- **Interactive Visualization:** Real-time parameter selection, cross-hair tracking, and interpolation updates in JupyterLab.

---

## Prerequisites

**For the Simulation Pipeline:**

- Cadence Virtuoso (IC23.1)
- Spectre Circuit Simulator
- Access to the **TSMC 65nm (tsmcN65)** PDK

**For the Visualization Dashboard:**

- Python 3.10+
- Jupyter Notebook or JupyterLab
- Required packages: numpy, pandas, plotly, scipy, ipywidgets

`pip install numpy pandas plotly scipy ipywidgets jupyter`

---

## Step-by-Step Workflow

### Step 1: Configure the Scripts

Both `create_gmId_tb.il` and `run_gmId_char.ocn` feature a **!!! USER CONFIGURATION VARIABLES !!!** block at the very top of the file. Before running, open both scripts and update:

- Your absolute file paths for saving the CSVs.
- The specific model paths for your Spectre simulation.
- Your transistor cell names (e.g., `nch` and `pch` or equivalent).

> ⚠️ **Important Note on Customizing Channel Lengths:**
> By default, the OCEAN script is configured to sweep 21 channel lengths specific to TSMC 65nm (60nm to 5µm). If you alter the `lengths` array in `run_gmId_char.ocn` to match a different PDK, **you must also update the Python script**. Open `main_gmId_plotter.ipynb` and update the `l_mapping` dictionary so the dashboard can correctly parse and label your new simulated lengths.

### Step 2: Generate the Testbench

Open the Cadence CIW (Command Interface Window) and load the SKILL script:

`load("/path/to/your/create_gmId_tb.il")`

_Result: A new library named `gm_Id_characterization` will be created containing a fully wired `nmos_pmos_tb` schematic._

### Step 3: Run the Characterization

In the Cadence CIW, load the OCEAN script:

`load("/path/to/your/run_gmId_char.ocn")`

_Result: Spectre will run the high-resolution sweeps. Once finished, it will generate `nmos_LUT.csv` and `pmos_LUT.csv` and delete the temporary simulation folders. (This process may take several minutes to execute.)_

### Step 4: Visualize the Data

Launch Jupyter and open the `main_gmId_plotter.ipynb` notebook.

1. Ensure `nmos_LUT.csv` and `pmos_LUT.csv` are in the same directory as the notebook.
2. Run all cells.
3. Use the interactive dropdowns to plot metrics like `gm/Id` vs `gm/gds`, `Id/W`, or `Vov`.
4. Toggle `Real Time Interpolation` to generate smooth curves between raw data points.

---

## The gm/Id Methodology

The gm/Id (transconductance-to-current ratio) metric normalizes transistor behavior and provides technology-independent insight into operating regions (weak, moderate, and strong inversion). It allows analog designers to:

- Circumvent the limitations of square-law equations in deep sub-micron nodes.
- Identify optimal operating points for speed, gain, power, and bandwidth trade-offs.
- Make informed sizing (W, L) and biasing decisions using normalized look-up tables.

---

## License

This project is intended for **educational and research** purposes. When using proprietary PDK data or characterization files, ensure compliance with the respective PDK licensing and distribution agreements.

---

## Contact / Acknowledgements

Feel free to open issues for bugs or feature requests.  
**Acknowledgements:** Cadence Virtuoso workflows, and the Plotly and SciPy libraries used for plotting and interpolation.
