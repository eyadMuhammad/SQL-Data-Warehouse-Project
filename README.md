# Data Warehouse project

Welcome to the **Data Warehouse Project** repository! 🚀  
This project demonstrates a comprehensive data warehousing , from building a data warehouse to generating actionable insights. Designed as a portfolio project, it highlights industry best practices in data engineering

---
## 🏗️ Data Architecture



1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

---
## 📖 Project Overview

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
---

### 1. 🟫 Bronze Layer (Raw Ingestion)
* **Objective:** Serve as a landing zone for raw data directly from upstream sources.
* **Process:** Data is ingested asynchronously via scheduled jobs or real-time hooks. It preserves the exact schema of the source system, storing metadata fields like `ingestion_timestamp` and `source_file_name`.


### 2. 🥈 Silver Layer (Enriched & Cleaned)
* **Objective:** Provide a single source of truth with clean, consistent, and structured data.
* **Process:** * Schema validation and strict type casting.
  * Quality checks: filtering null values in business-critical keys, handling outliers, and formatting date/time fields uniformly.
  * Deduplication and historical tracking using Upsert/Merge operations (SCD Type 1 or Type 2 tracking where applicable).


### 3. 🥇 Gold Layer (Curated Analytical Data)
* **Objective:** Host aggregated, business-ready data optimized for reporting and business intelligence (BI).
* **Process:** Transforms Silver tables into a highly structured **Star Schema** consisting of highly decoupled **Fact and Dimension tables**. Heavy aggregations and key business calculations are computed here.


---

## 📊 Data Model & Warehouse Design

The **Gold Layer** exposes a Dimensional Star Schema optimized for business reporting (e.g., Sales, User Activity, Inventory):

### Dimension Tables
* `dim_customers`: Unified customer registry containing clean attributes, contact information, and geographic tracking.
* `dim_products`: Product catalog normalized across standard categories, pricing tiers, and suppliers.

### Fact Tables
* `fact_sales`: Transaction-grain records capturing links to dimensions, item quantities, total revenue, tax metrics, and delivery timestamps.

---
## 📌 Notes

* The Gold layer represents a **business-oriented data mart**
* The architecture ensures **scalability and maintainability**
* The model is optimized for **BI tools and analytical workloads**

---

## 👨‍💻 About Me

I am **Eyad**, a Data Engineer focused on building scalable data solutions and designing efficient data pipeline architectures. My expertise lies in **data modeling, ETL/ELT processes, database development, and SQL optimization**.

This project represents a hands-on implementation of:
* End-to-end data warehouse design
* Data integration from multiple disparate systems (CRM & ERP)
* Transforming raw data into business-ready insights

It reflects how real-world data pipelines are structured to support modern analytics, robust reporting, and data-driven decision-making.

 Let's connect! 
👉 **[My LinkedIn Profile](https://www.linkedin.com/in/eyad-muhammad-a7a95235a)**
