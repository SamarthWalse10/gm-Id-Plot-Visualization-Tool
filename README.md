# gm/Id Plot Visualization Tool

A Python-based tool for visualizing and analyzing **gm/Id** characteristics of MOSFET transistors across different process technologies.  
Processes characterization data exported from Cadence Virtuoso by doing Parametric Analysis and creates interactive Plotly-based plots to help circuit designers optimize transistor sizing and operating points using the **gm/Id** methodology.

---

## Features

- **Multi-Technology Support:** tested and implemented currently with GPDK180 and TSMC N65.
- **Interactive Plots:** Real-time parameter selection and interpolation updates using Plotly.
- **Multiple Channel Lengths:** Compare across 10 channel lengths per technology.
- **Real-time Interpolation:** Cubic-spline interpolation for smooth curves & accurate intersections.
- **Guide Lines:** Add vertical/horizontal reference lines with auto intersection detection.
- **Flexible Parameters:** Choose from `gm/Id`, `gm/gds`, `Id/W`, `gm/W`, `gm/cgg`, `gds/Id`, `Vov` and plot with any reference on any axis.
- **Performance Controls:** Configurable row reduction (`row_drop_rate`) to improve responsiveness.

---

## Getting Started

### Prerequisites

- **Python 3.13.2** (tested on)
- **Jupyter Notebook** or **JupyterLab**
- Required Python packages:
  - `numpy`, `pandas`, `plotly`, `scipy`, `ipywidgets`

### Installation

Clone the repository:

```bash
git clone https://github.com/SamarthWalse10/gm-Id-Plot-Visualization-Tool.git
```

Install required packages (if needed):

````bash
pip install numpy pandas plotly scipy ipywidgets jupyter
``


---

## Usage
1. Open the notebook for the technology you want: (note you need to first export the data from cadence which i have not uploded here as it is large in size)
   - `main_gpdk180.ipynb` — GPDK180
   - `main_tsmcN65.ipynb` — TSMC N65

2. Run **Cell → Run All**. The interactive UI appears in the notebook output.

3. Configure the plot:
   - Select transistor type (NMOS / PMOS)
   - Choose X and Y axis parameters
   - Multi-select channel lengths to display
   - Toggle interpolation, markers, scales, and guide lines

---

## Interactive Controls
- **Transistor Selection:** NMOS / PMOS
- **Parameters:** `gm/Id`, `gm/gds`, `Id/W`, `gm/W`, `gm/cgg`, `gds/Id`, `Vov`
- **Channel Lengths:** Multi-select (see Supported Technologies)
- **Guide Lines:** Vertical/horizontal references with intersection points
- **Display:** Linear/log scale, markers, real-time cubic-spline interpolation
- **Performance:** `row_drop_rate` to reduce data rows for faster plotting

---

## Supported Technologies

**GPDK 180nm** channel lengths:  (you will have to change these as per the lenghths you will be exporting from the cadence parameteric analysis)
`180nm`, `360nm`, `540nm`, `720nm`, `900nm`, `1µm`, `2µm`, `3µm`, `4µm`, `5µm`

**TSMC N65 (65nm)** channel lengths:  (you will have to change these as per the lenghths you will be exporting from the cadence parameteric analysis)
`280nm`, `560nm`, `840nm`, `1.12µm`, `1.4µm`, `1.68µm`, `2µm`, `3µm`, `4µm`, `5µm`

---

## gm/Id Methodology
`gm/Id` (transconductance over drain current) normalizes transistor behavior and gives technology-independent insight into operating regions (weak, moderate, strong inversion). Use `gm/Id` to:
- Compare device efficiency across nodes
- Identify operating points for trade-offs between speed, gain, power, and bandwidth
- Aid sizing and bias decisions with normalized metrics

---

## Troubleshooting
- **Plot not loading:** Verify CSV file paths and ensure files are present in the expected directories.
- **Missing data points:** Check CSV formatting and column names (case-sensitive). Ensure numeric columns are clean.
- **Performance issues:** Increase `row_drop_rate` or reduce selected channel lengths.
- **Widgets not displaying:** Ensure `ipywidgets` is installed and enabled:
```bash
jupyter nbextension enable --py widgetsnbextension
````

For JupyterLab, ensure compatible ipywidgets support (JLab >= 3.x usually works).

---

## License

Intended for **educational and research** purposes. When using proprietary PDK data or characterization files, comply with the relevant PDK licensing and distribution agreements.

---

## Contact / Acknowledgements

If this repo helps you, please ⭐ the project and file issues for bugs or feature requests.  
Acknowledgements: Cadence Virtuoso workflows, Plotly & SciPy for plotting and interpolation tools used in this project.
