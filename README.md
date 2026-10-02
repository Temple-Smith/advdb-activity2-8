# advdb-activity2-8

In this activity, you’ll apply your database design skills to implement and query a working SQL database. You’ll build a database, define entities and relationships, populate it with data, and write SQL queries that generate insights about the system.

## Setup & Execution

1. **Create the database**: Create a new database within PG Admin.
2. **Create the Schema**: Execute the `create-schema.sql` file within PG Admin.
3. **Insert Sample Data**: Execute the `insert-sample-data.sql` file within PG Admin.
4. **Run Queries**: Execute the individual queries in `query-data.sql` to verify results against project documentation.

## Design Process

We created the EERD within Lucid Charts initially and then recreated the finalized EERD within PG Admin to create the schema.

We decided it made sense for the **PATIENT** and **DOCTOR** entities to overlap since a doctor could be a patient and a patient could be a doctor. They share similar attributes to the **PERSON** supertype.

In order for clarity and realistic data we made a separate entity for **EMERGENCY_CONTACT** information for patients. This made sense for storing cleaner data rather then having all emergency information in one singular string inside **PATIENT**.

Having **SPECIALTY** table for doctors made logical sense for clary and will result in more optimal queries if a user wanted to search for a catalog of doctors with a specific specialization.

Every other decision followed the business rules with proper entity relationships.

## AI Use

We used AI to generate sample data and help with debugging our code.
