SELECT * 
FROM {{ source('raw', 'dim_customers') }}