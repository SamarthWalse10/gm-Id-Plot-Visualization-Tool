# gm/Id Plot Visualization Tool

A Python-based tool for visualizing and analyzing **gm/Id** characteristics of MOSFET transistors across different process technologies. It processes characterization data exported from Cadence Virtuoso through Parametric Analysis and generates interactive Plotly-based plots that help circuit designers optimize transistor sizing and operating points using the **gm/Id** methodology.

---

## Features

- **Multi-Technology Support:** Tested and implemented with GPDK180 and TSMC N65.
- **Interactive Plots:** Real-time parameter selection and interpolation updates using Plotly.
- **Multiple Channel Lengths:** Compare across 10 channel lengths per technology.
- **Real-time Interpolation:** Cubic-spline interpolation for smooth curves and accurate intersections.
- **Guide Lines:** Optional vertical/horizontal reference lines with automatic intersection detection.
- **Flexible Parameters:** Choose from `gm/Id`, `gm/gds`, `Id/W`, `gm/W`, `gm/cgg`, `gds/Id`, `Vov` and plot with any reference on any axis.
- **Performance Controls:** Configurable row reduction (`row_drop_rate`) to improve responsiveness.

---

## Getting Started

### Prerequisites

- **Python 3.13.2** (tested)
- **Jupyter Notebook** or **JupyterLab**
- Required Python packages:
  - `numpy`, `pandas`, `plotly`, `scipy`, `ipywidgets`

### Installation

Clone the repository:

```bash
git clone https://github.com/SamarthWalse10/gm-Id-Plot-Visualization-Tool.git
```

Install required packages:

```bash
pip install numpy pandas plotly scipy ipywidgets jupyter
```

---

## Usage

1. Open the notebook for the technology you want.  
   _(Note: You must first export the characterization data from Cadence Virtuoso. These files are not uploaded here due to their large size.)_

   - `main_gpdk180.ipynb` — GPDK180
   - `main_tsmcN65.ipynb` — TSMC N65

2. Run **Cell → Run All**. The interactive interface will appear in the notebook output.

3. Configure the plot:
   - Select the transistor type (NMOS / PMOS)
   - Choose the X-axis and Y-axis parameters
   - Multi-select the channel lengths to display
   - Toggle interpolation, markers, scale (linear/log), and guide lines

---

## Interactive Controls

- **Transistor Selection:** Choose NMOS or PMOS
- **Parameters:** Select from `gm/Id`, `gm/gds`, `Id/W`, `gm/W`, `gm/cgg`, `gds/Id`, `Vov`
- **Channel Lengths:** Multi-select (refer to Supported Technologies)
- **Guide Lines:** Add vertical or horizontal reference lines with intersection detection
- **Display Options:** Toggle linear/log scale, markers, and real-time cubic-spline interpolation
- **Performance:** Adjust `row_drop_rate` to reduce data points and improve responsiveness

---

## Supported Technologies

**GPDK 180nm** channel lengths  
_(Adjust according to the lengths exported from your Cadence parametric analysis)_  
`180nm`, `360nm`, `540nm`, `720nm`, `900nm`, `1µm`, `2µm`, `3µm`, `4µm`, `5µm`

**TSMC N65 (65nm)** channel lengths  
_(Adjust according to the lengths exported from your Cadence parametric analysis)_  
`280nm`, `560nm`, `840nm`, `1.12µm`, `1.4µm`, `1.68µm`, `2µm`, `3µm`, `4µm`, `5µm`

---

## gm/Id Methodology

The `gm/Id` (transconductance-to-current) metric normalizes transistor behavior and provides technology-independent insight into operating regions (weak, moderate, and strong inversion). It helps you:

- Compare device efficiency across different technology nodes
- Identify optimal operating points for speed, gain, power, and bandwidth trade-offs
- Make informed sizing and biasing decisions using normalized metrics

---

## Troubleshooting

- **Plot not loading:** Verify CSV file paths and ensure the required files are in the correct directories.
- **Missing data points:** Check CSV formatting and column names (case-sensitive). Ensure numeric columns contain valid values.
- **Performance issues:** Increase `row_drop_rate` or reduce the number of selected channel lengths.
- **Widgets not displaying:** Ensure `ipywidgets` is installed and enabled:

```bash
jupyter nbextension enable --py widgetsnbextension
```

For JupyterLab, ensure it has compatible ipywidgets support (JLab ≥ 3.x).

---

## License

This project is intended for **educational and research** purposes. When using proprietary PDK data or characterization files, ensure compliance with the respective PDK licensing and distribution agreements.

---

## Contact / Acknowledgements

Feel free to open issues for bugs or feature requests.  
**Acknowledgements:** Cadence Virtuoso workflows, and the Plotly and SciPy libraries used for plotting and interpolation.
