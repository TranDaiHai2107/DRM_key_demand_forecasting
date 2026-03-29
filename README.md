# drm-key-demand-forecasting

> **Operational Business Intelligence Project** — Analyzing, monitoring, and forecasting DRM key demand on an OTT platform to optimize digital content licensing costs.

---

## Business Context

On an OTT platform, when a user accesses DRM-protected content — including on-demand movies from BHD and Fim+, or premium live channels such as K+ and Đặc Sắc — the system issues a **DRM (Digital Rights Management) Key** to their device for that day. DRM keys are a purchased resource: the business must acquire them in advance from content rights holders under a fixed quota.

```
1 device (MAC address) × 1 day watching DRM-protected content = 1 DRM Key issued
```

> Note: If a customer watches 10 DRM-protected titles on the same device in a single day, the system still issues only **1 DRM Key**. The core metric is therefore **COUNT DISTINCT** (device per day).

---

## Problem Statement

| Scenario | Consequence |
|---|---|
| Purchase **too many** DRM keys | Budget waste — unused keys expire with no refund |
| Purchase **too few** DRM keys | Users cannot access content → poor experience, churn risk |
| No data-driven purchase plan | Procurement decisions rely on guesswork |

**Core business question:** *How many DRM keys should we purchase next month — optimizing for cost without risking supply shortage?*

---

## Project Objectives

1. **Understand current state** — How many keys does the system issue per day? Is demand trending up or down?
2. **Identify consumption patterns** — Which days of the week and months of the year drive peak demand?
3. **Forecast future demand** — Predict key consumption for the next 7 to 30 days with confidence intervals.
4. **Recommend action** — Produce a concrete monthly purchase recommendation with a justifiable buffer margin.

---

## Dataset

| Table | Description | Key Columns |
|---|---|---|
| `Log_Get_DRM_List` | System log of DRM key issuances | `CustomerID`, `Date`, `Mac` |
| `Log_Fimplus_MovieID` | Viewing log from Fim+ content source | `CustomerID`, `MovieId`, `date`, `folder`, `Ftype` |
| `Log_BHD_MovieID` | Viewing log from BHD content source | `CustomerID`, `MovieID`, `DATE`, `folder`, `FTYPE` |
| `MV_PropertiesShowVN` | Content metadata | `id`, `isDRM`, `toptitle`, `Duration` |
| `Customers` | Device registry per customer | `customerid`, `mac`, `created_date` |
| `CustomerService` | Customer service transaction history | `CustomerID`, `ServiceID`, `Amount`, `Date` |

**Scale:** 500K – 5M records · **Source:** Azure SQL via DataGrip

---

## Solution Architecture

```
Raw Data (Azure SQL)
        │
        ▼
[1] SQL — Extraction & Business Logic
        │   · Compute daily DRM key count (COUNT DISTINCT MAC per day)
        │   · Segment by content source (Fim+ vs BHD) and day of week
        │   · Build reusable CTEs / Views as the analytical foundation
        │
        ▼
[2] Power BI — Operational Dashboard
        │   · KPI cards: keys today, this week, vs prior period
        │   · Trend line with 7-day and 30-day moving averages
        │   · Heatmap: consumption intensity by weekday × month
        │   · Drill-through by content source and service package
        │
        ▼
[3] Python — Forecasting Pipeline
            · EDA & seasonality decomposition
            · Time series forecasting (Prophet / SARIMA)
            · Model evaluation: MAPE, confidence intervals
            · Output: recommended purchase quantity + sensitivity analysis
```

---

## Repository Structure

```
drm-key-demand-forecasting/
│
├── sql/
│   ├── 01_view_drm_base.sql            # Base view consolidating DRM log sources
│   ├── 02_daily_key_count.sql          # Daily key issuance count
│   ├── 03_weekly_trend.sql             # Week-over-week trend analysis
│   ├── 04_weekday_pattern.sql          # Consumption pattern by day of week
│   ├── 05_monthly_summary.sql          # Monthly aggregation for planning
│   └── 06_source_breakdown.sql         # Fim+ vs BHD contribution breakdown
│
├── powerbi/
│   └── DRM_Key_Monitor.pbix            # Operational dashboard file
│
├── python/
│   ├── 01_data_preparation.ipynb       # Data loading, cleaning, feature engineering
│   ├── 02_eda_visualization.ipynb      # Exploratory analysis and pattern discovery
│   ├── 03_forecasting_model.ipynb      # Forecasting model training and evaluation
│   └── 04_recommendation_output.ipynb  # Purchase recommendation with buffer scenarios
│
├── assets/
│   └── screenshots/                    # Dashboard and chart exports
│
├── Dataset/
│   
└── README.md
```

---

## Key Results

### SQL
- Implemented precise DRM key counting logic aligned with business rules (COUNT DISTINCT MAC per day)
- Identified clear **weekly seasonality** — weekend consumption significantly exceeds weekdays
- Quantified the relative contribution of Fim+ and BHD across different time periods

### Power BI Dashboard
- Operational dashboard enabling the business team to monitor daily key issuance in near real-time
- **Utilization Rate** indicator comparing keys consumed vs. purchased quota — the primary signal for procurement decisions
- Heatmap visualization of weekday × monthly consumption patterns to support forward planning

### Python Forecasting
- Time series forecast of daily DRM key demand achieving **MAPE < X%** on holdout test set
- 90% confidence intervals provide decision-makers with quantified uncertainty for risk-aware procurement
- Sensitivity analysis across 5%, 10%, and 15% buffer scenarios — making the cost-vs-shortage trade-off explicit and actionable

---

## Tech Stack

| Tool | Purpose |
|---|---|
| Azure SQL + DataGrip | Raw data querying and transformation |
| Power BI | Operational dashboard and visual analytics |
| Python — pandas, Prophet, matplotlib, seaborn | Forecasting pipeline and EDA |
| Jupyter Notebook | Analysis documentation and reproducibility |

---

## Author

**[Your Name]**  
Data Analyst · [LinkedIn](https://linkedin.com) · [Email](mailto:you@email.com)

---

*This project addresses a real-world Operational Business Intelligence problem: replacing intuition-based procurement with a data-driven forecasting system for DRM key demand planning.*
