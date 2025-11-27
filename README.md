# gm/Id Plot Visualization Tool

A Python-based tool for visualizing and analyzing **gm/Id** characteristics of MOSFET transistors across multiple process technologies.  
Processes characterization data exported from Cadence Virtuoso and creates interactive Plotly-based plots to help circuit designers optimize transistor sizing and operating points using the **gm/Id** methodology.

---

## Table of Contents
- [Features](#features)  
- [Getting Started](#getting-started)  
  - [Prerequisites](#prerequisites)  
  - [Installation](#installation)  
- [Usage](#usage)  
- [Interactive Controls](#interactive-controls)  
- [Supported Technologies](#supported-technologies)  
- [gm/Id Methodology](#gmid-methodology)  
- [Troubleshooting](#troubleshooting)  
- [Contributing](#contributing)  
- [License](#license)  
- [Contact / Acknowledgements](#contact--acknowledgements)

---

## Features
- **Multi-Technology Support:** GPDK180 and TSMC N65.  
- **Interactive Plots:** Real-time parameter selection and updates using Plotly.  
- **Multiple Channel Lengths:** Compare across 10 channel lengths per technology.  
- **Real-time Interpolation:** Cubic-spline interpolation for smooth curves & accurate intersections.  
- **Guide Lines:** Add vertical/horizontal reference lines with auto intersection detection.  
- **Flexible Parameters:** Choose from `gm/Id`, `gm/gds`, `Id/W`, `gm/W`, `gm/cgg`, `gds/Id`, `Vov`.  
- **Performance Controls:** Configurable row reduction (`row_drop_rate`) to improve responsiveness.

---

## Getting Started

### Prerequisites
- **Python 3.13.2** (an environment named `env` is included with this configuration)  
- **Jupyter Notebook** or **JupyterLab**  
- Required Python packages:
  - `numpy`, `pandas`, `plotly`, `scipy`, `ipywidgets`

### Installation
Clone the repository:
```bash
git clone https://github.com/your-username/gm_Id_Plots.git
cd gm_Id_Plots
```

Activate the existing virtual environment:
```bash
# macOS / Linux
source env/bin/activate

# Windows (PowerShell)
env\Scripts\Activate.ps1

# Windows (cmd)
env\Scripts\activate
```

Install required packages (if needed):
```bash
pip install numpy pandas plotly scipy ipywidgets jupyter
```

Launch Jupyter:
```bash
jupyter notebook
# or
jupyter lab
```

---

## Usage
1. Open the notebook for the technology you want:
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

**GPDK 180nm** channel lengths:  
`180nm`, `360nm`, `540nm`, `720nm`, `900nm`, `1µm`, `2µm`, `3µm`, `4µm`, `5µm`

**TSMC N65 (65nm)** channel lengths:  
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
```
For JupyterLab, ensure compatible ipywidgets support (JLab >= 3.x usually works).  
- **Python version mismatch:** Use the provided `env` (Python 3.13.2) or point your kernel to that environment.

---

## Contributing
Contributions welcome. Suggested areas:
- Add new PDK / technology support  
- New visualization/export features  
- Performance and caching improvements  
- Documentation and example datasets

Workflow:
1. Fork the repo  
2. Create a feature branch (`feature/xyz`)  
3. Add code / notebooks and tests/examples  
4. Submit a PR with a clear description

---

## License
Intended for **educational and research** purposes. When using proprietary PDK data or characterization files, comply with the relevant PDK licensing and distribution agreements.

---

## Contact / Acknowledgements
If this repo helps you, please ⭐ the project and file issues for bugs or feature requests.  
Acknowledgements: Cadence Virtuoso workflows, Plotly & SciPy for plotting and interpolation tools used in this project.
