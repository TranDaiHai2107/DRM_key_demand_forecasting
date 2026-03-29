# drm-key-demand-forecasting

> **Operational Business Intelligence Project** — Analyzing, monitoring, and forecasting DRM key demand on an OTT platform to optimize digital content licensing costs.

---

## Business Context

On an OTT platform, when a user accesses DRM-protected content, the system issues a **DRM (Digital Rights Management) Key** to their device for that day. DRM keys are a purchased resource: the business must acquire them in advance from content rights holders under a fixed quota.

DRM keys are triggered by two distinct content types:

| Content Type | Source | Condition |
|---|---|---|
| **Premium live channels** | K+, Đặc Sắc | Any access to a channel under a Premium package |
| **On-demand movies** | Fim+, BHD | Only movies flagged as `isDRM = 1` |

```
1 User × 1 day with any DRM-protected content access = 1 DRM Key issued
```

> Note: If a customer watches 10 DRM-protected movies **and** streams a K+ channel on the different devices in a single day, the system still issues only **1 DRM Key** for that user. The core metric is **COUNT DISTINCT** (CustomerID) per day — aggregated across all content sources.

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
| `Log_Get_DRM_List` | Key issuance log for **Premium channel packages** (K+, Đặc Sắc) | `CustomerID`, `Date`, `Mac` |
| `Log_Fimplus_MovieID` | Full viewing log for **Fim+ on-demand movies** (all titles, DRM and non-DRM) | `CustomerID`, `MovieId`, `date`, `folder`, `Ftype` |
| `Log_BHD_MovieID` | Full viewing log for **BHD on-demand movies** (all titles, DRM and non-DRM) | `CustomerID`, `MovieID`, `DATE`, `folder`, `FTYPE` |
| `MV_PropertiesShowVN` | Content metadata — used to filter DRM-protected movies (`isDRM = 1`) | `id`, `isDRM`, `toptitle`, `Duration` |
| `Customers` | Device registry per customer | `customerid`, `mac`, `created_date` |
| `CustomerService` | Customer service transaction history | `CustomerID`, `ServiceID`, `Amount`, `Date` |

**Scale:** 500K – 5M records · **Source:** Azure SQL via DataGrip

---

## Key Business Logic

Total daily DRM keys must be computed by combining **two independent sources**, then deduplicating at the device level:

```
Total DRM Keys (per day) =
    COUNT DISTINCT (CustomerID, MAC) from:

    [Source A] Log_Get_DRM_List
               → Premium channel access (K+, Đặc Sắc)
               → No additional filter needed

    UNION ALL

    [Source B] Log_Fimplus_MovieID + Log_BHD_MovieID
               → On-demand movie views
               → JOIN MV_PropertiesShowVN WHERE isDRM = 1
```

A customer who watches a BHD movie **and** streams K+ on the same device in one day counts as **1 key**, not 2.

---

## Solution Architecture

```
Raw Data (Azure SQL)
        │
        ▼
[1] SQL — Extraction & Business Logic
        │   · Unify all 3 log sources into a single base view
        │   · Apply isDRM = 1 filter on movie logs (Fim+ and BHD)
        │   · Compute daily key count via COUNT DISTINCT (CustomerID, MAC)
        │   · Segment by content type (channel vs movie), source, and day of week
        │
        ▼
[2] Power BI — Operational Dashboard
        │   · KPI cards: keys today, this week, vs prior period
        │   · Trend line with 7-day and 30-day moving averages
        │   · Heatmap: consumption intensity by weekday × month
        │   · Split view: channel-driven keys vs movie-driven keys over time
        │
        ▼
[3] Python — Forecasting Pipeline
            · EDA & seasonality decomposition
            · Time series forecasting (Prophet / LightGBM)
            · Model evaluation: MAPE,RMSE, confidence intervals
            · Output: recommended purchase quantity + sensitivity analysis
```

---

## Repository Structure

```
drm-key-demand-forecasting/
│
├── sql/
│   ├── 01_view_drm_base.sql            # Base view: union all 3 sources, filter isDRM = 1
│   ├── 02_daily_key_count.sql          # Daily DRM key count (COUNT DISTINCT)
│   ├── 03_weekly_trend.sql             # Week-over-week trend + moving averages
│   ├── 04_weekday_pattern.sql          # Consumption pattern by day of week
│   ├── 05_monthly_summary.sql          # Monthly aggregation for procurement planning
│   └── 06_source_breakdown.sql         # Channel (K+/Đặc Sắc) vs movie (Fim+/BHD) split
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
- Implemented DRM key counting logic that correctly unifies **3 log sources** and deduplicates at the device level
- Identified clear **weekly seasonality** — weekend consumption significantly exceeds weekdays
- Quantified the split between **channel-driven keys** (K+, Đặc Sắc) and **movie-driven keys** (Fim+, BHD) to understand demand composition

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


*This project addresses a real-world Operational Business Intelligence problem: replacing intuition-based procurement with a data-driven forecasting system for DRM key demand planning.*
