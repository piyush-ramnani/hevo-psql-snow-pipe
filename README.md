# PostgreSQL-to-Snowflake Data Pipeline
### *End-to-End Modern Data Stack Implementation*

## 🚀 Project Overview
This project demonstrates the construction of a robust data pipeline that migrates transactional data from a local, containerized PostgreSQL environment to a Snowflake Cloud Data Warehouse. The pipeline utilizes Change Data Capture (CDC) via Logical Replication, secure tunneling, and dbt (data build tool) for final analytical modeling.

## 🛠️ The Tech Stack
* **Source:** PostgreSQL v17 (Dockerized)
* **Infrastructure:** Docker Desktop (macOS)
* **Connectivity:** ngrok (TCP Tunneling)
* **ETL/ELT:** Hevo Data (Logical Replication)
* **Warehouse:** Snowflake (Multi-cluster, Shared Data Architecture)
* **Transformation:** dbt Cloud (Transformation & Data modelling)
