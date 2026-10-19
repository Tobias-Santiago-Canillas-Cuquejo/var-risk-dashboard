# Market Risk & Dynamic Value at Risk (VaR) Dashboard

## Project Overview
This repository implements an end-to-end quantitative market risk analysis pipeline using **R** and **Power BI**. It models financial time series volatility and estimates dynamic **Value at Risk (VaR)** at 95% and 99% confidence levels under Student-t distribution assumptions using **GARCH(1,1)** models.

## Repository Structure
var-risk-dashboard/
├── R/
│   ├── 01_ingesta_datos.R      # Downloads market data & computes log-returns
│   └── 02_modelo_garch_var.R   # Fits GARCH(1,1) with Student-t & computes dynamic VaR
├── data/
│   ├── retornos_portafolio.csv # Log-returns time series
│   └── var_garch_resultados.csv# GARCH volatility & VaR metrics (95% and 99%)
├── powerbi/
│   └── dashboard_riesgo_var.pbix# Interactive Power BI Risk Dashboard
└── README.md
## Quantitative Framework
1. **Data Pipeline:** Extracted historical daily prices for `AAPL`, `JPM`, `SPY`, and `GLD` via `tidyquant` and computed logarithmic returns.
2. **GARCH(1,1) Volatility Modeling:** Modeled time-varying conditional variance ($\sigma_t^2$) using `rugarch`:
   $$\sigma_t^2 = \omega + \alpha \epsilon_{t-1}^2 + \beta \sigma_{t-1}^2$$
3. **Parametric VaR Estimation:** Calculated 95% and 99% Value at Risk incorporating heavy tails via Student-t quantile scaling:
   $$\text{VaR}_{\alpha, t} = -(\mu_t + \sigma_t \cdot t_{\nu, \alpha})$$

## Power BI Integration
- **Asset Slicer:** Multi-asset filtering for single-stock and benchmark risk comparisons.
- **Multi-Quantile Risk Bounds:** Dual-threshold time series chart tracking returns against dynamic 95% and 99% VaR levels.
- **Executive KPI Cards:** Real-time summary metrics for daily VaR (95% & 99%) and GARCH conditional volatility.

## Tech Stack
- **R:** `tidyverse`, `tidyquant`, `rugarch`, `xts`
- **BI:** Power BI Desktop
- **Version Control:** Git, GitHub, GitHub Desktop
