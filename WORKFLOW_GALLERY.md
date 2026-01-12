### Phase 1: Local Environment (Docker & Postgres)
![Docker Setup](assets/docker_files.png)
*Postgres v17 container is running with custom port 5433.*

### Phase 3: The Connectivity Bridge (ngrok)
![ngrok Tunnel](assets/psql_tables.png)
*Created tables in the PSQL bucket from Snowflake files*

### Phase 3: The Connectivity Bridge (ngrok)
![ngrok Tunnel](assets/ngrok_live_tcp.png)
*The active TCP tunnel providing the public endpoint for hevo pipeline source connection.*

### Phase 4: Pipeline Success (Hevo Data)
![Hevo Pipeline](assets/hevo-pipeline.png)
*Successful Pipeline created*

### Phase 5: Transformation (dbt & Snowflake)
![dbt Lineage](assets/dbt_data_model.png)
*The dbt model to create the final Customer model.*

![Snowflake Results](assets/snowflake-customers.png)
*Final query results in Snowsight showing customers, their first oder and calculated Customer Lifetime Value (CLV).*