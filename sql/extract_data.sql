-- Extract clean user-level dataset for the Scam Warning A/B Test
SELECT 
    a.user_id,
    a.group_name,
    t.transfer_id,
    t.amount,
    t.status,
    -- If there is no row in fraud_reports, mark is_scam as 0
    COALESCE(f.is_reported_scam, 0) AS is_scam
FROM experiment_assignments a
INNER JOIN transfer_events t 
    ON a.user_id = t.user_id
LEFT JOIN fraud_reports f 
    ON t.transfer_id = f.transfer_id
WHERE a.experiment_name = 'scam_warning_v1';
