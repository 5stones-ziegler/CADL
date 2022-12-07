SELECT customer_id, 
season_code, 
item_code, 
seat_loc, 
price_level_full, 
price_type_desc,
ROUND(avg(num_seats_event),0)::int as seat_count,
max(item_amt) as cost,
max(item_payment) as payments,
(max(item_amt)-max(item_payment)) as balance_due,
min(orig_datetime) as purchase_datetime
FROM {{ source('raw', 't_ticket_w')}}
WHERE CONCAT(season_code, '-', item_code) IN (
    SELECT event_id FROM {{ ref('seed_packages') }} 
    WHERE item_type = 'Full Season'
)
GROUP BY 1,2,3,4,5,6
