CREATE TABLE operation_registry (
    operation_id UUID PRIMARY KEY
);

CREATE OR REPLACE FUNCTION fn_enforce_unique_operation()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO operation_registry (operation_id) VALUES (NEW.operation_id)
    ON CONFLICT (operation_id) DO NOTHING;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Operation Id: % already exists', NEW.operation_id;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ensure_unique_op
BEFORE INSERT ON payments
FOR EACH ROW EXECUTE FUNCTION fn_enforce_unique_operation();

--change 1
