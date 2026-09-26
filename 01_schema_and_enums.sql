-- ========================================================
-- 1. ENUM TYPES CREATION
-- ========================================================
CREATE TYPE user_role AS ENUM ('CUSTOMER', 'RESTAURANT_OWNER', 'COURIER', 'ADMIN');
CREATE TYPE order_status AS ENUM ('PENDING', 'ACCEPTED', 'PREPARING', 'READY', 'DELIVERING', 'COMPLETED', 'CANCELLED');
CREATE TYPE vehicle_type AS ENUM ('BICYCLE', 'SCOOTER', 'CAR');
CREATE TYPE courier_status AS ENUM ('OFFLINE', 'AVAILABLE', 'BUSY');
CREATE TYPE delivery_status AS ENUM ('ASSIGNED', 'PICKED_UP', 'DELIVERED', 'FAILED');
CREATE TYPE payment_method AS ENUM ('CARD', 'CASH', 'WALLET');
CREATE TYPE payment_status AS ENUM ('PENDING', 'SUCCESSFUL', 'FAILED', 'REFUNDED');

-- ========================================================
-- 2. CORE TABLES CREATION
-- ========================================================

-- Users Table
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    role user_role NOT NULL DEFAULT 'CUSTOMER',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Restaurants Table
CREATE TABLE restaurants (
    restaurant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    cuisine_type VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Menu Items Table
CREATE TABLE menu_items (
    item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    restaurant_id UUID NOT NULL REFERENCES restaurants(restaurant_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Couriers Profiles Table
CREATE TABLE couriers (
    courier_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    vehicle vehicle_type NOT NULL DEFAULT 'SCOOTER',
    status courier_status NOT NULL DEFAULT 'OFFLINE',
    rating DECIMAL(3, 2) CHECK (rating >= 1.00 AND rating <= 5.00),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Orders Table
CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    restaurant_id UUID NOT NULL REFERENCES restaurants(restaurant_id) ON DELETE RESTRICT,
    status order_status NOT NULL DEFAULT 'PENDING',
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
    delivery_address TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Order Items Table
CREATE TABLE order_items (
    order_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    item_id UUID NOT NULL REFERENCES menu_items(item_id) ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    price_at_time DECIMAL(10, 2) NOT NULL CHECK (price_at_time > 0)
);

-- Deliveries Table
CREATE TABLE deliveries (
    delivery_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID UNIQUE NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    courier_id UUID NOT NULL REFERENCES couriers(courier_id) ON DELETE RESTRICT,
    status delivery_status NOT NULL DEFAULT 'ASSIGNED',
    pickup_time TIMESTAMP WITH TIME ZONE,
    delivered_time TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Payments Table
CREATE TABLE payments (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID UNIQUE NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
    method payment_method NOT NULL,
    status payment_status NOT NULL DEFAULT 'PENDING',
    paid_at TIMESTAMP WITH TIME ZONE
);

-- Reviews Table
CREATE TABLE reviews (
    review_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID UNIQUE NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    restaurant_rating INT CHECK (restaurant_rating BETWEEN 1 AND 5),
    courier_rating INT CHECK (courier_rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
