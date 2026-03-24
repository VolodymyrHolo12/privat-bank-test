CREATE MATERIALIZED VIEW client_payment_stats AS
SELECT 
    (payload->>'client_id')::BIGINT AS client_id,
    payload->>'op_type' AS op_type,
    SUM(amount) AS total_amount
FROM payments
WHERE status_code = 1
GROUP BY 1, 2;

CREATE UNIQUE INDEX idx_stats_unique ON client_payment_stats (client_id, op_type);

CREATE OR REPLACE FUNCTION fn_refresh_stats_on_update()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF OLD.status_code = 0 AND NEW.status_code = 1 THEN
        REFRESH MATERIALIZED VIEW CONCURRENTLY client_payment_stats;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_refresh_stats
AFTER UPDATE OF status_code ON payments
FOR EACH ROW EXECUTE FUNCTION fn_refresh_stats_on_update();