-- ========================================================
-- 1. USERS (Customers, Restaurant Owners, Couriers)
-- ========================================================
INSERT INTO users (first_name, last_name, email, phone, role) VALUES
('Giorgi', 'Beridze', 'giorgi.b@gmail.com', '+995599112233', 'CUSTOMER'),
('Nino', 'Kapanadze', 'nino.k@gmail.com', '+995598223344', 'CUSTOMER'),
('David', 'Maisuradze', 'david.m@gmail.com', '+995597334455', 'CUSTOMER'),
('Levan', 'Gelashvili', 'levan.g@gmail.com', '+995595445566', 'RESTAURANT_OWNER'),
('Tamar', 'Chkheidze', 'tamar.ch@gmail.com', '+995591556677', 'RESTAURANT_OWNER'),
('Irakli', 'Kavtaradze', 'irakli.k@gmail.com', '+995593667788', 'COURIER'),
('Alex', 'Nozadze', 'alex.n@gmail.com', '+995596778899', 'COURIER');

-- ========================================================
-- 2. RESTAURANTS
-- ========================================================
INSERT INTO restaurants (owner_id, name, address, cuisine_type) VALUES
((SELECT user_id FROM users WHERE email = 'levan.g@gmail.com'), 'Tavern Genacvale', '12 Rustaveli Ave, Tbilisi', 'Georgian'),
((SELECT user_id FROM users WHERE email = 'tamar.ch@gmail.com'), 'Pizza Di Roma', '45 Chavchavadze Ave, Tbilisi', 'Italian');

-- ========================================================
-- 3. MENU_ITEMS
-- ========================================================
INSERT INTO menu_items (restaurant_id, name, description, price) VALUES
((SELECT restaurant_id FROM restaurants WHERE name = 'Tavern Genacvale'), 'Khinkali (City Style)', 'Juicy meat dumpling (1 pc)', 1.80),
((SELECT restaurant_id FROM restaurants WHERE name = 'Tavern Genacvale'), 'Adjaruli Khachapuri', 'Traditional boat-shaped cheese bread with egg & butter', 15.00),
((SELECT restaurant_id FROM restaurants WHERE name = 'Tavern Genacvale'), 'Pork Mtsvadi', 'Grilled pork skewers served with tkemali sauce', 18.00),
((SELECT restaurant_id FROM restaurants WHERE name = 'Pizza Di Roma'), 'Pizza Margherita', 'Mozzarella, tomato sauce, and fresh basil', 22.00),
((SELECT restaurant_id FROM restaurants WHERE name = 'Pizza Di Roma'), 'Pizza Pepperoni', 'Spicy pepperoni, mozzarella, and tomato sauce', 26.50);

-- ========================================================
-- 4. COURIERS
-- ========================================================
INSERT INTO couriers (user_id, vehicle, status, rating) VALUES
((SELECT user_id FROM users WHERE email = 'irakli.k@gmail.com'), 'SCOOTER', 'AVAILABLE', 4.85),
((SELECT user_id FROM users WHERE email = 'alex.n@gmail.com'), 'CAR', 'BUSY', 4.92);

-- ========================================================
-- 5. ORDERS & ORDER_ITEMS (Full Order Lifecycle)
-- ========================================================
WITH new_order AS (
    INSERT INTO orders (customer_id, restaurant_id, status, total_amount, delivery_address)
    VALUES (
        (SELECT user_id FROM users WHERE email = 'giorgi.b@gmail.com'),
        (SELECT restaurant_id FROM restaurants WHERE name = 'Tavern Genacvale'),
        'COMPLETED',
        33.00,
        '20 Vazha-Pshavela Ave, Tbilisi'
    )
    RETURNING order_id
)
INSERT INTO order_items (order_id, item_id, quantity, price_at_time)
VALUES 
(
    (SELECT order_id FROM new_order),
    (SELECT item_id FROM menu_items WHERE name = 'Khinkali (City Style)'),
    10,
    1.80
),
(
    (SELECT order_id FROM new_order),
    (SELECT item_id FROM menu_items WHERE name = 'Adjaruli Khachapuri'),
    1,
    15.00
);

-- ========================================================
-- 6. PAYMENTS, DELIVERIES & REVIEWS
-- ========================================================
-- Payment
INSERT INTO payments (order_id, amount, method, status, paid_at)
VALUES (
    (SELECT order_id FROM orders WHERE total_amount = 33.00 LIMIT 1),
    33.00,
    'CARD',
    'SUCCESSFUL',
    CURRENT_TIMESTAMP - INTERVAL '2 hours'
);

-- Delivery
INSERT INTO deliveries (order_id, courier_id, status, pickup_time, delivered_time)
VALUES (
    (SELECT order_id FROM orders WHERE total_amount = 33.00 LIMIT 1),
    (SELECT courier_id FROM couriers WHERE user_id = (SELECT user_id FROM users WHERE email = 'irakli.k@gmail.com')),
    'DELIVERED',
    CURRENT_TIMESTAMP - INTERVAL '1 hour 45 minutes',
    CURRENT_TIMESTAMP - INTERVAL '1 hour 15 minutes'
);

-- Review
INSERT INTO reviews (order_id, customer_id, restaurant_rating, courier_rating, comment)
VALUES (
    (SELECT order_id FROM orders WHERE total_amount = 33.00 LIMIT 1),
    (SELECT user_id FROM users WHERE email = 'giorgi.b@gmail.com'),
    5,
    5,
    'The food was piping hot and the courier arrived super fast!'
);
