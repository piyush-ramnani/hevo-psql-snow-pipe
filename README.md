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

--------

## 🏗️ Phase 1: PostgreSQL & Docker Environment
Deployed latest version of docker, created latest postgres 17 img and containerize the environment. This helps in keeping the environment clean and avoid conflicts on different machines with different configurations as this container has everything a code needs to run.

### Key Implementation Details:
* **Custom Port Mapping:** Used `5433:5432` to avoid conflicts with existing local PostgreSQL instances.
* **Security Configuration:** Applied `--security-opt seccomp=unconfined` to resolve macOS "initdb" handshake errors where the system was preventing the "handshake" between the physical CPU and the virtual file.

```bash
# Command to launch the container
docker run --name postgres17-docker \
  --security-opt seccomp=unconfined \
  -e POSTGRES_PASSWORD=YOUR_PASSWORD_HERE \
  -p 5433:5432 \
  -d postgres:17
