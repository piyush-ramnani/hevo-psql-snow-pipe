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
```

## 📥 Phase 2: Data Loading (Local CSVs to SQL)

This phase involved moving physical data files from the host machine (Mac) into the isolated Docker container environment and ingesting them into the database.

### 1. File Transfer to Container
To make the raw data accessible to PostgreSQL, I transferred three CSV files (`raw_customers.csv`, `raw_orders.csv`, and `raw_payments.csv`) into the container's `/tmp` folder. 
* **Method:** Used the Docker Desktop Files UI (alternatively, `docker cp` via CLI can be used).
* **Best Practice:** Files were placed in `/tmp` to ensure the PostgreSQL process had the necessary read permissions for ingestion.

### 2. Schema Creation
I defined the "buckets" for the raw data by creating three tables with specific data types to match the source files:

```sql
CREATE TABLE raw_customers (
    id INT, 
    first_name VARCHAR, 
    last_name VARCHAR
);

CREATE TABLE raw_orders (
    id INT, 
    user_id INT, 
    order_date DATE, 
    status VARCHAR
);

CREATE TABLE raw_payments (
    id INT, 
    order_id INT, 
    payment_method INT, 
    amount INT
);
```
### 3. Copied the tables into the buckets from the docker `/tmp` file

```sql
-- Ingesting Customer data
COPY raw_customers FROM '/tmp/raw_customers.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Ingesting Order data
COPY raw_orders FROM '/tmp/raw_orders.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Ingesting Payment data
COPY raw_payments FROM '/tmp/raw_payments.csv' 
WITH (FORMAT csv, HEADER true, DELIMITER ',');
```
