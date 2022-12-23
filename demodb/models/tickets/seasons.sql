with basics_cte AS (SELECT t.customer_id, 
t.season_code,
t.item_code, 
s.renewal_opendate,
s.renewal_deadline,
t.seat_loc, 
t.price_level_full, 
t.price_type_desc,
ROUND(avg(t.num_seats_event),0)::int as seat_count,
max(t.item_amt) as cost,
max(t.item_payment) as payments,
(max(t.item_amt)-max(t.item_payment)) as balance_due,
min(t.orig_datetime) as purchase_datetime
FROM {{ source('raw', 't_ticket_w')}} t
INNER JOIN {{ ref('seed_packages') }} s
ON CONCAT(t.season_code, '-', t.item_code) = s.event_id
AND lower(s.item_type) = 'full season'
GROUP BY 1,2,3,4,5,6,7,8
)
SELECT *,
sum(seat_count) OVER (PARTITION BY season_code ORDER BY purchase_datetime asc) as renewed_seats_to_date,
extract(day from (date_trunc('day', renewal_deadline) - date_trunc('day', purchase_datetime))) as renewed_days_before_deadline,
extract(day from (date_trunc('day', purchase_datetime) - date_trunc('day', renewal_opendate))) as renewed_days_after_open
FROM basics_cte
