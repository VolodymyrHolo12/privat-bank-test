CREATE OR REPLACE PROCEDURE seed_payment_data(total_rows INT DEFAULT 100000)
LANGUAGE plpgsql AS $$
DECLARE
    start_date TIMESTAMPTZ := '2026-01-01 00:00:00+00';
    date_range INTERVAL := '119 days'; -- пробував 120, але отримував помилку тож 119 :)
    tags TEXT[] := ARRAY['online', 'offline'];
BEGIN
    FOR i IN 1..total_rows LOOP
        INSERT INTO payments (created_at, user_id, amount, status_code, operation_id, payload)
        VALUES (
            start_date + (random() * date_range),
            (random() * 5000 + 1)::BIGINT,
            round((random() * 1000)::NUMERIC, 2),
            (random() * 2)::INT,
            gen_random_uuid(),
            jsonb_build_object(
                'account_no', 'ACC' || lpad(floor(random() * 100000)::text, 6, '0'),
                'client_id', (random() * 5000 + 1)::BIGINT,
                'op_type', tags[floor(random() * 2 + 1)]
            )
        );
        IF i % 10000 = 0 THEN 
            COMMIT; 
        END IF;
    END LOOP;
END;
$$;

CALL seed_payment_data(150000);

--change 2
--some change for pull test
--ababababa
--conflict pull
