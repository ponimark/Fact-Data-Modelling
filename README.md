# Fact-Data-Modelling


This repository contains two analytical dimensional modelling projects — **Host** and **Events** — each simulating how raw operational and user interaction data can be modeled into star schemas suitable for BI dashboards, behavioral analysis, and usage metrics.


---

## 1️⃣ Host – Hosting Activity Modelling

The **Host** project tracks website/server-level data such as daily user visits, site hits, and overall uptime or engagement across a month. It uses **arrays and bitmaps** to compress and track recurring time-series metrics efficiently.

### 🔍 Key Concepts
- `host_cumulated` — cumulative visit/activity tracking using arrays
- `host_activity_reduced` — daily site hits and user counts
- Bit-based activity flags for **daily**, **weekly**, and **monthly** host activeness
- Placeholder logic to simulate low-storage analytics computation

### 🧠 Highlighted Queries
- Site activity aggregation by day
- Cross-month comparisons and user trends
- Use of `generate_series`, `bit_count`, `array_agg` for analytics

---

## 2️⃣ Events – User Behavior & Device Analytics

The **Events** project models user interaction with the platform using detailed facts and dimensions for sessions, devices, and players (in a sports-like context).

### 📌 Core Tables & Logic

- **`u_cumulated`**  
  Tracks user login/active dates as an array  
  *(Script: `ddl_data_insert.sql`)*

- **`bit_conversion.sql`**  
  Converts date arrays into bit representations to identify active users by day/week/month

- **`array_unnest_agg.sql`**  
  Aggregates and unnests arrays into a flat, analytics-ready structure

- **`fct_game_details`**  
  A fact table designed for sports-style event data with player performance metrics  
  *(Script: `FDM1.sql`)*

### 🔢 Metrics Tracked
- `m_minutes`, `m_fgm`, `m_fga`, `m_reb`, `m_ast`, `m_stl`, etc.
- Player activity status: DNP (Did Not Play), DND (Did Not Dress), NWT (Not With Team)
- Bit-flagged behavioral traits based on login frequency

---

## ⚙️ Technologies Used

- PostgreSQL (`generate_series`, `bit_count`, `array_agg`, etc.)
- SQL CTEs, window functions, and joins
- Dimensional modelling and fact tables
- Optional BI tooling integration (Power BI, Tableau)

