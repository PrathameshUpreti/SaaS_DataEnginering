SELECT TICKET_ID
FROM {{ ref('support_ticket_cleaned') }}
WHERE STATUS = 'RESOLVED'
  AND RESOLVED_AT IS NULL




