-- створити користувача на сервері, звідки робиться репліка
CREATE ROLE replica_user WITH LOGIN REPLICATION PASSWORD 'replica_pass_123';
GRANT SELECT ON TABLE public.payments TO replica_user;
CREATE PUBLICATION payment_pub FOR TABLE payments;

-- був використаний сервіс neondb для зручності тестування та інтеграції тож скрипт адаптований під середу
-- на сервері, куди робиться репліка, створюємо таблицю, як у таску 1
CREATE TABLE payments (
    created_at TIMESTAMPTZ NOT NULL,
    user_id BIGINT NOT NULL,
    amount NUMERIC(18, 2) NOT NULL,
    status_code SMALLINT NOT NULL DEFAULT 0,
    operation_id UUID NOT NULL,
    payload JSONB NOT NULL
) PARTITION BY RANGE (created_at);

CREATE TABLE payments_y2026_m01 PARTITION OF payments FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
CREATE TABLE payments_y2026_m02 PARTITION OF payments FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
CREATE TABLE payments_y2026_m03 PARTITION OF payments FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');
CREATE TABLE payments_y2026_m04 PARTITION OF payments FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');

CREATE INDEX idx_pay_date ON payments (created_at);
CREATE INDEX idx_pay_user ON payments (user_id);
CREATE INDEX idx_pay_status ON payments (status_code);

-- потім виконуємо скрипт, де логінимся під створеним користувачем для реплікації
CREATE SUBSCRIPTION payment_sub 
CONNECTION 'postgresql://replica_user:replica_pass_123@ep-lucky-hall.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require' 
PUBLICATION payment_pub
WITH (copy_data = true);