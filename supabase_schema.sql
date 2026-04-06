-- ========================================
-- 사업 장부 Supabase 스키마
-- ========================================

-- 1. 사람 (persons)
CREATE TABLE persons (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. 사업자 (businesses)
CREATE TABLE businesses (
  id TEXT PRIMARY KEY,
  person_id TEXT REFERENCES persons(id),
  name TEXT NOT NULL,
  reg_no TEXT DEFAULT '',
  owner TEXT DEFAULT '',
  sectors JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. 거래내역 (transactions)
CREATE TABLE transactions (
  id TEXT PRIMARY KEY,
  biz_id TEXT REFERENCES businesses(id),
  date DATE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('income', 'expense', 'salary')),
  category TEXT DEFAULT '',
  partner TEXT DEFAULT '',
  amount INTEGER DEFAULT 0,
  vat INTEGER DEFAULT 0,
  tax_type TEXT DEFAULT 'taxable',
  evidence TEXT DEFAULT 'none',
  card TEXT DEFAULT '',
  bank TEXT DEFAULT '',
  sector TEXT DEFAULT '',
  memo TEXT DEFAULT '',
  -- 급여 전용
  salary_gross INTEGER DEFAULT 0,
  salary_tax_withheld INTEGER DEFAULT 0,
  salary_local_withheld INTEGER DEFAULT 0,
  salary_pension INTEGER DEFAULT 0,
  salary_health INTEGER DEFAULT 0,
  salary_employment INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. 자산 (assets)
CREATE TABLE assets (
  id TEXT PRIMARY KEY,
  biz_id TEXT REFERENCES businesses(id),
  name TEXT NOT NULL,
  date DATE NOT NULL,
  amount INTEGER DEFAULT 0,
  vat INTEGER DEFAULT 0,
  life INTEGER DEFAULT 5,
  method TEXT DEFAULT 'straight',
  category TEXT DEFAULT '비품',
  memo TEXT DEFAULT '',
  payments JSONB DEFAULT '[]',
  payment_tx_ids JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. 구매대행 주문 (proxy_orders)
CREATE TABLE proxy_orders (
  id TEXT PRIMARY KEY,
  biz_id TEXT REFERENCES businesses(id),
  order_date DATE NOT NULL,
  order_no TEXT DEFAULT '',
  customer TEXT NOT NULL,
  customer_amount INTEGER DEFAULT 0,
  items JSONB DEFAULT '[]',
  shipping_cost INTEGER DEFAULT 0,
  platform TEXT DEFAULT '',
  description TEXT DEFAULT '',
  settled BOOLEAN DEFAULT FALSE,
  purchase_amount INTEGER DEFAULT 0,
  extra_cost INTEGER DEFAULT 0,
  commission INTEGER DEFAULT 0,
  settle_date DATE,
  purchase_order_no TEXT DEFAULT '',
  tx_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. 카테고리 (categories)
CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  biz_id TEXT DEFAULT '_global',
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  name TEXT NOT NULL,
  sort_order INTEGER DEFAULT 0
);

-- 7. 카드 (cards)
CREATE TABLE cards (
  id SERIAL PRIMARY KEY,
  biz_id TEXT NOT NULL,
  name TEXT NOT NULL,
  UNIQUE(biz_id, name)
);

-- 8. 은행 (banks)
CREATE TABLE banks (
  id SERIAL PRIMARY KEY,
  biz_id TEXT NOT NULL,
  name TEXT NOT NULL,
  UNIQUE(biz_id, name)
);

-- 9. 연말정산 입력값 (yearend_inputs)
CREATE TABLE yearend_inputs (
  id SERIAL PRIMARY KEY,
  person_id TEXT REFERENCES persons(id),
  year INTEGER NOT NULL,
  data JSONB DEFAULT '{}',
  UNIQUE(person_id, year)
);

-- 10. 소득세 입력값 (income_tax_inputs)
CREATE TABLE income_tax_inputs (
  id SERIAL PRIMARY KEY,
  person_id TEXT REFERENCES persons(id),
  year INTEGER NOT NULL,
  data JSONB DEFAULT '{}',
  UNIQUE(person_id, year)
);

-- 11. 앱 설정 (app_settings)
CREATE TABLE app_settings (
  key TEXT PRIMARY KEY,
  value JSONB
);

-- ========================================
-- 인덱스
-- ========================================
CREATE INDEX idx_transactions_biz_date ON transactions(biz_id, date);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_proxy_orders_biz ON proxy_orders(biz_id);
CREATE INDEX idx_assets_biz ON assets(biz_id);
CREATE INDEX idx_businesses_person ON businesses(person_id);

-- ========================================
-- RLS (Row Level Security) - 일단 비활성화
-- 나중에 인증 추가 시 활성화
-- ========================================
ALTER TABLE persons ENABLE ROW LEVEL SECURITY;
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE proxy_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE banks ENABLE ROW LEVEL SECURITY;
ALTER TABLE yearend_inputs ENABLE ROW LEVEL SECURITY;
ALTER TABLE income_tax_inputs ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

-- 임시: 모든 테이블에 public 접근 허용 (인증 전)
CREATE POLICY "Allow all" ON persons FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON businesses FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON transactions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON assets FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON proxy_orders FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON categories FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON cards FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON banks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON yearend_inputs FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON income_tax_inputs FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON app_settings FOR ALL USING (true) WITH CHECK (true);
