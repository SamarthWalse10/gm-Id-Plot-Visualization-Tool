# gm/Id Plot Visualization Tool

## Automated gm/Id Characterization Pipeline

A complete, end-to-end automation toolkit for extracting and visualizing gm/Id Look-Up Tables (LUTs) for MOSFETs. This pipeline bridges the gap between Cadence Virtuoso and modern data visualization environments (Python and MATLAB), allowing analog IC designers to instantly generate testbenches, run massive ultra-high-resolution simulations, and interactively analyze device physics.

> **Note:** This toolkit was specifically built and tested using the **TSMC 65nm (tsmcN65)** PDK. However, the SKILL and OCEAN scripts are fully generalized and can be easily adapted to other PDKs (like GPDK180 or TSMC 45nm) by updating the configuration variables.

---

## The Toolkit

This repository contains a three-stage automated workflow:

1. **`create_gmId_tb.il` (The Architect):** A fully generalized Cadence SKILL script. It programmatically generates a perfectly wired, unified schematic testbench for simultaneous diode-connected NMOS and PMOS characterization.
2. **`run_gmId_char.ocn` (The Engine):** A robust OCEAN script that executes an ultra-high-resolution DC sweep (e.g., 100nA to 10mA with 10nA steps). It extracts the exact operating points (gm, gds, cgg, Vth), formats them into `.csv` files, and automatically scrubs gigabytes of temporary simulation data from your hard drive to keep your workspace clean.
3. **Visualization Dashboards (The Lens):** Choose between two highly optimized interactive dashboards that effortlessly handle millions of data points using real-time cubic spline interpolation, allowing you to interactively analyze sizing methodologies:
   - **`main_gmId_plotter.ipynb`:** A Python dashboard using Plotly and SciPy for JupyterLab.
   - **`gmId_Plotter.m`:** A native, standalone MATLAB App featuring smart `.mat` caching for instant load times and dynamic vectorized DataTips.

---

## Features

- **PDK Mapped Design:** Easily configurable for different technology nodes. Simply update the variables block at the top of the scripts to match your target PDK.
- **Unified Extraction:** Characterize NMOS and PMOS devices simultaneously in a single simulation run.
- **True Vbs Biasing:** NMOS and PMOS bodies are correctly initialized to Source, allowing for accurate Body-Effect (gmb) extraction which can later be changed.
- **Ultra-High Resolution:** Capable of sweeping massive ranges (e.g., 10nA steps) yielding millions of data points for highly accurate derivative extraction (gm, cgg).
- **Auto-Cleanup:** The OCEAN script automatically deletes Cadence `psf` and numbered job folders post-extraction to save disk space.
- **Interactive Visualization:** Real-time parameter selection, cross-hair tracking, and interpolation updates available natively in **JupyterLab** or **MATLAB**.
- **Smart Caching (MATLAB):** Automatically compiles massive CSVs into fast-loading `.mat` files for instantaneous boot times on subsequent runs.

---

## Prerequisites

**For the Simulation Pipeline:**

- Cadence Virtuoso (IC23.1)
- Spectre Circuit Simulator
- Access to the TSMC 65nm (tsmcN65) or any other PDK

**For the Python Visualization Dashboard:**

- Python 3.10+
- Jupyter Notebook or JupyterLab
- Required packages: numpy, pandas, plotly, scipy, ipywidgets

`pip install numpy pandas plotly scipy ipywidgets jupyter`

**For the MATLAB Visualization Dashboard:**

- MATLAB (R2021a or newer recommended)

---

## Step-by-Step Workflow

### Step 1: Configure the Scripts

Both `create_gmId_tb.il` and `run_gmId_char.ocn` feature a **!!! USER CONFIGURATION VARIABLES !!!** block at the very top of the file. Before running, open both scripts and update:

- Your absolute file paths for saving the CSVs.
- The specific model paths for your Spectre simulation.
- Your transistor cell names (e.g., `nch` and `pch` or equivalent).

> ⚠️ **Important Note on Transistor Width (W):** By default, the OCEAN script extracts data using a transistor width of `W = 10u`. If you modify this value in `run_gmId_char.ocn`, **you must also update the `W` variable in your chosen visualization script** (`main_gmId_plotter.ipynb` or `gmId_Plotter.m`, default is `W = 10e-6`). This ensures that normalized metrics like `Id/W` and `gm/W` are calculated accurately.

### Step 2: Generate the Testbench

Open the Cadence CIW (Command Interface Window) and load the SKILL script:

`load("/path/to/your/create_gmId_tb.il")`

_Result: A new library named `gm_Id_characterization` will be created containing a fully wired `nmos_pmos_tb` schematic._

### Step 3: Run the Characterization

In the Cadence CIW, load the OCEAN script:

`load("/path/to/your/run_gmId_char.ocn")`

_Result: Spectre will run the high-resolution sweeps. Once finished, it will generate `nmos_LUT.csv` and `pmos_LUT.csv` and delete the temporary simulation folders. (This process may take several minutes to execute.)_

### Step 4: Visualize the Data

Ensure `nmos_LUT.csv` and `pmos_LUT.csv` are in your current working directory, then choose your preferred visualization environment:

**Option A: Using Python (JupyterLab)**
1. Launch Jupyter and open the `main_gmId_plotter.ipynb` notebook.
2. Run all cells.
3. Use the interactive dropdowns to plot metrics like `gm/Id` vs `gm/gds`, `Id/W`, or `Vov`.
4. Toggle `Real Time Interpolation` to generate smooth curves between raw data points.
5. Hover over any curve to see formatted DataTips.

**Option B: Using MATLAB**
1. Open MATLAB and navigate to the folder containing your CSVs and `gmId_Plotter.m`.
2. Run the command `gmId_Plotter()` in the Command Window.
3. A standalone, high-performance GUI will launch. It will automatically cache your data into a `.mat` file for instant loading on future runs.
4. Use the interactive dropdowns to plot metrics and toggle `Real Time Interpolation` to generate smooth curves between raw data points.
5. Hover over any curve to see formatted DataTips.

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
**Acknowledgements:** Cadence Virtuoso workflows, the Plotly and SciPy libraries used for Python plotting and interpolation, and MATLAB's native UI/App computing architecture for the standalone dashboard.
