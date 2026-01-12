# PostgreSQL-to-Snowflake Data Pipeline
### *End-to-End Data stack Implementation*

## 📸 Project Gallery
Want to see the pipeline in action? [View the Full Workflow Gallery here](./WORKFLOW_GALLERY.md)

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

## 🌉 Phase 3: The Connectivity Bridge (ngrok)

A common challenge in modern data stacks is connecting cloud-based ETL tools (like Hevo) to databases running on a local machine behind a firewall or in a container like docker. To solve this, **ngrok** was used to via reverse tunnelling.

### 1. The Purpose of Tunneling
Because the PostgreSQL database is hosted inside a local Docker container, it lacks a public IP address. By using ngrok, created a secure "bridge" that allows Hevo to "ping" on a public URL, which then safely routes the traffic directly to my local port `5433`.

### 2. Implementation & Terminal Commands
Using Homebrew, I configured and launched the tunnel to expose the PostgreSQL port:

```bash
# 1. Install ngrok via Homebrew
brew install ngrok

# 2. Authenticate the local agent with the cloud service
ngrok config add-authtoken YOUR_REDACTED_TOKEN

# 3. Start the TCP tunnel on the custom Postgres port
ngrok tcp 5433
```

## 🔗 Phase 4: Pipeline Configuration (Hevo Data)

This phase acts as the "glue" of the project, establishing the automated flow of data from the local source to the cloud destination.

### 1. Source Security & Permissions
To ensure professional security standards, I avoided using a superuser. Instead, I created a dedicated `hevo_user` with restricted access, specifically configured for **Logical Replication**.

```sql
-- 1. Create a dedicated service user
CREATE USER hevo_user WITH PASSWORD 'REDACTED_PASSWORD';

-- 2. Grant the REPLICATION attribute to stream Write-Ahead Logs (WAL)
ALTER USER hevo_user REPLICATION;

-- 3. Grant connection and schema access
GRANT CONNECT ON DATABASE postgres TO hevo_user;
GRANT USAGE ON SCHEMA public TO hevo_user;

-- 4. Grant SELECT permissions for data ingestion
GRANT SELECT ON ALL TABLES IN SCHEMA public TO hevo_user;

-- 5. Create the "Publication" to broadcast table changes
CREATE PUBLICATION hevo_pub FOR ALL TABLES;
```

### 2. Connection Logic

**Source Connection**: Using the public hostname and port generated by ngrok in Phase 3, I linked Hevo Data to the local PostgreSQL instance using the hevo_user credentials.

**Destination**: Utilized Snowflake Partner Connect to bridge Hevo and Snowflake. This automatically provisioned the necessary warehouse, database, and user permissions within Snowflake, significantly reducing manual configuration errors.

## ⚡ Phase 5: Transformation (dbt Cloud)

⚠️ NOTE: Could not upload the project directly to github as the free tier does not allow merging the project directly, neither it allows free tier users to create a new project

The final stage of the pipeline involves transforming the raw, normalized tables in Snowflake into an analytical "Golden Record" using **dbt (data build tool)** via snowflake partner connect.

### 1. Data Modeling Strategy
Built a modular dbt project in the studio. This ensures that the logic is centralized and version-controlled.

* **Sources:** Defined in `models/sources.yml`, mapping the raw data landed by Hevo in `PC_DBT_DB.DBT_PRAMNANI`.
* **Models:** Created a `models/customers.sql` model that joins customers, orders, and payments to create a single, comprehensive view.

### 2. Key Metrics Calculated
The `customers` model transforms the raw data into actionable insights by calculating:
* **`first_order_date`**: The date of the customer's first purchase.
* **`number_of_orders`**: Total transaction count per customer.
* **`customer_lifetime_value` (CLV)**: The total revenue generated by a customer across all orders.
