-- Création des tables
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    category_id INTEGER REFERENCES categories(id),
    price NUMERIC(10,2) NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    email VARCHAR(200) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    country VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL
);

-- Catégories
INSERT INTO categories (name) VALUES
    ('Smartphones'), ('Laptops'), ('Accessories'),
    ('Audio'), ('Cameras');

-- Produits
INSERT INTO products (name, category_id, price, stock) VALUES
    ('ProPhone X1', 1, 799.99, 150),
    ('ProPhone X2 Pro', 1, 1099.99, 80),
    ('BudgetPhone S', 1, 299.99, 300),
    ('UltraBook 14', 2, 1299.99, 60),
    ('UltraBook 16 Pro', 2, 1899.99, 30),
    ('WorkStation Pro', 2, 2499.99, 20),
    ('USB-C Hub 7-in-1', 3, 49.99, 500),
    ('Wireless Charger 20W', 3, 39.99, 400),
    ('Laptop Stand Alu', 3, 59.99, 350),
    ('ProBuds ANC', 4, 249.99, 200),
    ('StudioHeadphones', 4, 349.99, 100),
    ('SpeakerMini BT', 4, 89.99, 250),
    ('MirrorCam A7', 5, 899.99, 40),
    ('ActionCam Pro', 5, 449.99, 75),
    ('WebCam 4K', 5, 149.99, 180);

-- 500 clients générés
INSERT INTO customers (email, first_name, last_name, country, created_at)
SELECT
    'customer' || i || '@shopmetrics.com',
    (ARRAY['Alice','Bob','Charlie','Diana','Eve',
           'Frank','Grace','Henry','Iris','Jack'])[((i-1) % 10) + 1],
    (ARRAY['Martin','Dupont','Bernard','Thomas','Robert',
           'Petit','Richard','Simon','Laurent','Michel'])[((i-1) % 10) + 1],
    (ARRAY['France','Germany','Spain','Italy','Belgium',
           'Switzerland','Netherlands','Portugal','UK','Poland'])[((i-1) % 10) + 1],
    NOW() - (random() * interval '540 days')
FROM generate_series(1, 500) AS i;

-- 4200 commandes sur 18 mois
INSERT INTO orders (customer_id, status, created_at)
SELECT
    (random() * 499 + 1)::integer,
    (ARRAY['pending','confirmed','shipped',
           'delivered','delivered','delivered','cancelled']
    )[floor(random() * 7 + 1)::integer],
    NOW() - (random() * interval '547 days')
FROM generate_series(1, 4200);

-- On génère entre 1 et 3 lignes par commande
-- avec des produits tirés aléatoirement parmi les 15
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
    o.id,
    p.id,
    (random() * 2 + 1)::integer,
    p.price
FROM orders o
JOIN (
    SELECT id, price
    FROM products
    ORDER BY random()
) p ON true
WHERE random() < 0.3
LIMIT 12000;

-- Index pour les performances
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_customers_created_at ON customers(created_at);