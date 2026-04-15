CREATE EXTENSION IF NOT EXISTS pg_cron;

CREATE OR REPLACE FUNCTION job_add_pending_payment()
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO payments (created_at, user_id, amount, status_code, operation_id, payload)
    VALUES (
        NOW(),
        (random() * 5000 + 1)::BIGINT,
        round((random() * 200)::NUMERIC, 2),
        0, 
        gen_random_uuid(),
        jsonb_build_object('account_no', 'ACC-AUTO', 'client_id', (random() * 5000 + 1)::BIGINT, 'op_type', 'online')
    );
END;
$$;

SELECT cron.schedule(
    'add_pending_payment_every_5s',
    '5 seconds',
    'SELECT job_add_pending_payment();'
);

--change 2
