CREATE EXTENSION IF NOT EXISTS pg_cron;

CREATE OR REPLACE FUNCTION job_update_status_by_parity_of_seconds()
RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE
    sec_parity INT := EXTRACT(SECOND FROM NOW())::INT % 2;
BEGIN
    UPDATE payments
    SET status_code = 1
    WHERE status_code = 0
    AND user_id % 2 = sec_parity;
END;
$$;

CREATE OR REPLACE FUNCTION job_update_status_by_parity_of_seconds_every_3s()
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    PERFORM job_update_status_by_parity_of_seconds();
END;
$$;

SELECT cron.schedule(
    'task_5_every_3s', 
    '3 seconds', 
    'SELECT job_update_status_by_parity_of_seconds_every_3s()'
);