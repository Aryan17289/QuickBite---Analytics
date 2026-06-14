import random
import mysql.connector
from faker import Faker
from datetime import date, timedelta, datetime

fake = Faker('en_IN')
random.seed(42)

# ── DB CONNECTION ──────────────────────────────────────────
conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='root',       # ← change if your password is different
    database='quickbite'
)
cursor = conn.cursor()
print("✅ Connected to QuickBite database")

# ── CONSTANTS ─────────────────────────────────────────────
CITIES = ['Mumbai', 'Ahmedabad', 'Bangalore', 'Hyderabad', 'Pune']

AREAS = {
    'Mumbai':    ['Andheri', 'Bandra', 'Dadar', 'Kurla', 'Borivali', 'Thane', 'Mulund', 'Worli'],
    'Ahmedabad': ['Navrangpura', 'Satellite', 'Bopal', 'Maninagar', 'Vastrapur', 'Gota', 'Chandkheda', 'Nikol'],
    'Bangalore': ['Koramangala', 'Indiranagar', 'Whitefield', 'HSR Layout', 'BTM Layout', 'Jayanagar', 'Marathahalli', 'Hebbal'],
    'Hyderabad': ['Banjara Hills', 'Jubilee Hills', 'Gachibowli', 'Madhapur', 'Kondapur', 'Ameerpet', 'Kukatpally', 'Secunderabad'],
    'Pune':      ['Koregaon Park', 'Viman Nagar', 'Hinjewadi', 'Kothrud', 'Aundh', 'Wakad', 'Baner', 'Hadapsar']
}

CUISINES = ['North Indian', 'South Indian', 'Chinese', 'Fast Food', 'Pizza',
            'Biryani', 'Desserts', 'Beverages', 'Continental', 'Street Food']

RESTAURANT_NAMES = [
    'Spice Garden', 'Tandoor House', 'Biryani Blues', 'The Curry Leaf', 'Pizza Point',
    'Dragon Wok', 'Burger Barn', 'Dosa Delight', 'Swad Kitchen', 'Masala Mantra',
    'Kebab King', 'Chai & Snacks', 'The Food Lab', 'Mithas Sweets', 'Urban Tadka',
    'Noodle Street', 'Grill & Chill', 'Thali Express', 'Cafe Bombay', 'Royal Biryani'
]

PAYMENT_METHODS = ['UPI', 'Credit Card', 'Debit Card', 'Cash', 'Wallet']
COMPLAINT_TYPES = ['Late Delivery', 'Wrong Item', 'Missing Item', 'Food Quality',
                   'Rude Rider', 'Packaging Issue', 'App Issue']
VEHICLE_TYPES   = ['Bike', 'Scooter', 'Bicycle']

START_DATE = date(2023, 1, 1)
END_DATE   = date(2024, 12, 31)

def rand_date(start=START_DATE, end=END_DATE):
    return start + timedelta(days=random.randint(0, (end - start).days))

# ── 1. CUSTOMERS (2000) ───────────────────────────────────
print("Generating customers...")
customers = []
for _ in range(2000):
    city = random.choice(CITIES)
    customers.append((
        fake.name(),
        fake.unique.email(),
        fake.phone_number()[:15],
        city,
        random.choice(AREAS[city]),
        random.choice(['Male', 'Female', 'Other']),
        random.randint(18, 60),
        rand_date(date(2021, 1, 1), date(2023, 12, 31)),
        random.random() < 0.2   # 20% premium
    ))

cursor.executemany("""
    INSERT INTO customers (customer_name, email, phone, city, area, gender, age, registered_on, is_premium)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
""", customers)
conn.commit()
print(f"  ✅ {len(customers)} customers inserted")

# ── 2. RESTAURANTS (200) ──────────────────────────────────
print("Generating restaurants...")
restaurants = []
for _ in range(200):
    city = random.choice(CITIES)
    restaurants.append((
        random.choice(RESTAURANT_NAMES) + ' ' + fake.last_name(),
        city,
        random.choice(AREAS[city]),
        random.choice(CUISINES),
        round(random.uniform(2.5, 5.0), 1),
        random.randint(10, 45),
        True,
        rand_date(date(2020, 1, 1), date(2023, 6, 30))
    ))

cursor.executemany("""
    INSERT INTO restaurants (restaurant_name, city, area, cuisine_type, avg_rating, avg_prep_time, is_active, joined_on)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
""", restaurants)
conn.commit()
print(f"  ✅ {len(restaurants)} restaurants inserted")

# ── 3. RIDERS (300) ───────────────────────────────────────
print("Generating riders...")
riders = []
for _ in range(300):
    riders.append((
        fake.name(),
        fake.phone_number()[:15],
        random.choice(CITIES),
        random.choice(VEHICLE_TYPES),
        round(random.uniform(2.5, 5.0), 1),
        rand_date(date(2020, 1, 1), date(2023, 6, 30)),
        True
    ))

cursor.executemany("""
    INSERT INTO riders (rider_name, phone, city, vehicle_type, rating, joined_on, is_active)
    VALUES (%s, %s, %s, %s, %s, %s, %s)
""", riders)
conn.commit()
print(f"  ✅ {len(riders)} riders inserted")

# ── fetch IDs ─────────────────────────────────────────────
cursor.execute("SELECT customer_id, city FROM customers")
customer_rows = cursor.fetchall()

cursor.execute("SELECT restaurant_id, city FROM restaurants")
restaurant_rows = cursor.fetchall()

cursor.execute("SELECT rider_id, city FROM riders")
rider_rows = cursor.fetchall()

# group by city
from collections import defaultdict
cust_by_city = defaultdict(list)
rest_by_city = defaultdict(list)
rider_by_city = defaultdict(list)

for cid, city in customer_rows:   cust_by_city[city].append(cid)
for rid, city in restaurant_rows: rest_by_city[city].append(rid)
for rid, city in rider_rows:      rider_by_city[city].append(rid)

# ── 4. ORDERS (50,000) ────────────────────────────────────
print("Generating 50,000 orders (this may take ~30 seconds)...")
orders = []
BATCH = 5000

for i in range(50000):
    city = random.choice(CITIES)

    cust_list  = cust_by_city[city]
    rest_list  = rest_by_city[city]
    rider_list = rider_by_city.get(city) or rider_rows  # fallback

    if not cust_list or not rest_list:
        city = random.choice(CITIES)
        cust_list  = cust_by_city[city]
        rest_list  = rest_by_city[city]

    customer_id   = random.choice(cust_list)
    restaurant_id = random.choice(rest_list)
    rider_id      = random.choice(rider_list if isinstance(rider_list[0], int) else [r[0] for r in rider_list])

    order_date   = rand_date()
    order_time   = f"{random.randint(0,23):02d}:{random.randint(0,59):02d}:{random.randint(0,59):02d}"
    delivery_min = random.randint(15, 90)
    distance     = round(random.uniform(0.5, 15.0), 1)
    amount       = round(random.uniform(80, 1500), 2)

    # premium customers get slightly higher discounts
    discount     = round(amount * random.uniform(0, 0.25), 2)
    final        = round(amount - discount, 2)
    payment      = random.choice(PAYMENT_METHODS)

    # weighted order status
    status_roll = random.random()
    if status_roll < 0.85:
        status = 'Delivered'
    elif status_roll < 0.95:
        status = 'Cancelled'
    else:
        status = 'Refunded'

    rating = random.randint(1, 5) if status == 'Delivered' and random.random() < 0.7 else None

    orders.append((customer_id, restaurant_id, rider_id, city, order_date, order_time,
                   delivery_min, distance, amount, discount, final, payment, status, rating))

    if (i + 1) % BATCH == 0:
        cursor.executemany("""
            INSERT INTO orders (customer_id, restaurant_id, rider_id, city, order_date, order_time,
                                delivery_time_mins, distance_km, order_amount, discount_applied,
                                final_amount, payment_method, order_status, customer_rating)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, orders[-BATCH:])
        conn.commit()
        print(f"  → {i+1} orders inserted...")

print(f"  ✅ 50,000 orders inserted")

# ── 5. COMPLAINTS (~8% of delivered orders) ───────────────
print("Generating complaints...")
cursor.execute("SELECT order_id, customer_id FROM orders WHERE order_status = 'Delivered'")
delivered = cursor.fetchall()

complaint_sample = random.sample(delivered, int(len(delivered) * 0.08))
complaints = []

for order_id, customer_id in complaint_sample:
    res_status = random.choice(['Resolved', 'Pending', 'Escalated'])
    res_days   = random.randint(1, 10) if res_status == 'Resolved' else None
    refund     = random.random() < 0.3

    complaints.append((
        order_id,
        customer_id,
        random.choice(COMPLAINT_TYPES),
        rand_date(),
        res_status,
        res_days,
        refund
    ))

cursor.executemany("""
    INSERT INTO complaints (order_id, customer_id, complaint_type, complaint_date,
                            resolution_status, resolution_days, refund_issued)
    VALUES (%s, %s, %s, %s, %s, %s, %s)
""", complaints)
conn.commit()
print(f"  ✅ {len(complaints)} complaints inserted")

# ── DONE ──────────────────────────────────────────────────
cursor.close()
conn.close()
print("\n🎉 QuickBite data generation complete!")
print(f"   Customers  : 2,000")
print(f"   Restaurants:   200")
print(f"   Riders     :   300")
print(f"   Orders     : 50,000")
print(f"   Complaints : ~{len(complaints)}")