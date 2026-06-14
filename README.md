# 🍔 QuickBite — Food Delivery Operations Analytics

A end-to-end data analytics project simulating a food delivery platform 
operating across 5 Indian cities. Built with MySQL for data storage and 
querying, and Power BI for business intelligence dashboards.

---

## 📌 Project Overview

**QuickBite** is a fictional food delivery company operating in:
**Mumbai | Ahmedabad | Bangalore | Hyderabad | Pune**

This project covers the full data analytics workflow:
- Database design & schema creation
- Synthetic data generation (50,000 orders)
- SQL business analysis (25 queries)
- Interactive Power BI dashboard (4 pages)

---

## 🗄️ Database Schema

**5 tables | MySQL**

| Table | Rows | Description |
|-------|------|-------------|
| customers | 2,000 | Customer profiles across 5 cities |
| restaurants | 200 | Restaurant details and cuisine types |
| riders | 300 | Delivery rider profiles |
| orders | 50,000 | Core fact table with all order details |
| complaints | ~3,400 | Complaints linked to delivered orders |

---

## 📊 SQL Analysis — 25 Business Queries

### Category 1 — Revenue Analysis
- Total revenue by city
- Monthly revenue trend
- Revenue by cuisine type
- Discount impact on revenue
- Top 10 highest revenue restaurants

### Category 2 — City & Delivery Performance
- Order volume and cancellation rate by city
- Average delivery time by city
- Average customer rating by city
- Payment method preference by city
- Revenue per km by city

### Category 3 — Rider Performance
- Top 10 best rated riders
- Rider performance by vehicle type
- Riders with most complaints
- Delivery time vs distance buckets
- Late deliveries by city

### Category 4 — Customer Behaviour
- Repeat customers and lifetime value
- Premium vs non-premium comparison
- Peak ordering hours
- Customer age group analysis
- Gender-wise ordering pattern

### Category 5 — Complaint Analysis
- Complaint breakdown by type
- Resolution performance
- Complaints by city
- Restaurants with most complaints
- Monthly complaint trend

---

## 📈 Power BI Dashboard — 4 Pages

| Page | Key Visuals |
|------|-------------|
| Revenue Overview | Total revenue KPIs, revenue by city, monthly trend, cuisine split, payment methods |
| City & Delivery Performance | Avg delivery time, order status by city, customer ratings, distance analysis |
| Customer Behaviour | Age group orders, premium vs regular, peak hours, top 10 customers by spend |
| Complaint Analysis | Complaint types, resolution status, city-wise complaints, monthly trend |

---

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| MySQL 8.0 | Database design, data storage, SQL analysis |
| Python (Faker, mysql-connector) | Synthetic data generation |
| Power BI Desktop | Interactive dashboard |
| VS Code | Development environment |
| Git & GitHub | Version control |

---

## 📁 Project Structure
QuickBite-Analytics/

│

├── schema.sql              # Database schema — all 5 tables

├── generate_data.py        # Python script to generate 50,000 rows

├── analysis_queries.sql    # 25 SQL business queries

└── dashboard.pbix          # Power BI dashboard file

---

## 🚀 How to Run

1. Run `schema.sql` in MySQL Workbench to create the database
2. Run `python generate_data.py` to populate all tables
3. Open `analysis_queries.sql` in MySQL Workbench to explore queries
4. Open `dashboard.pbix` in Power BI Desktop (connect to your local MySQL)

---

## 👤 Author

**Aryan Chauhan** — Aspiring Data Analyst  
B.Tech Computer Science & Design | GCET, CVM University  
