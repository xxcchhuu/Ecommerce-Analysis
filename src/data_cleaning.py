import pandas as pd
from pathlib import Path

# Project paths
BASE_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = BASE_DIR / "data" / "raw"
PROCESSED_DIR = BASE_DIR / "data" / "processed"

PROCESSED_DIR.mkdir(parents=True, exist_ok=True)


# --------------------------------------------------
# 1. Customers
# --------------------------------------------------

customers = pd.read_csv(
    RAW_DIR / "olist_customers_dataset.csv"
)

customers = customers.drop_duplicates()

customers.to_csv(
    PROCESSED_DIR / "customers_clean.csv",
    index=False
)


# --------------------------------------------------
# 2. Orders
# --------------------------------------------------

orders = pd.read_csv(
    RAW_DIR / "olist_orders_dataset.csv"
)

# Convert date columns to datetime
date_columns = [
    "order_purchase_timestamp",
    "order_approved_at",
    "order_delivered_carrier_date",
    "order_delivered_customer_date",
    "order_estimated_delivery_date"
]

for column in date_columns:
    orders[column] = pd.to_datetime(
        orders[column],
        errors="coerce"
    )

orders = orders.drop_duplicates()

orders.to_csv(
    PROCESSED_DIR / "orders_clean.csv",
    index=False
)


# --------------------------------------------------
# 3. Order Items
# --------------------------------------------------

order_items = pd.read_csv(
    RAW_DIR / "olist_order_items_dataset.csv"
)

order_items["shipping_limit_date"] = pd.to_datetime(
    order_items["shipping_limit_date"],
    errors="coerce"
)

order_items = order_items.drop_duplicates()

order_items.to_csv(
    PROCESSED_DIR / "order_items_clean.csv",
    index=False
)


# --------------------------------------------------
# 4. Payments
# --------------------------------------------------

payments = pd.read_csv(
    RAW_DIR / "olist_order_payments_dataset.csv"
)

payments = payments.drop_duplicates()

payments.to_csv(
    PROCESSED_DIR / "payments_clean.csv",
    index=False
)


# --------------------------------------------------
# 5. Reviews
# --------------------------------------------------

reviews = pd.read_csv(
    RAW_DIR / "olist_order_reviews_dataset.csv"
)

reviews["review_creation_date"] = pd.to_datetime(
    reviews["review_creation_date"],
    errors="coerce"
)

reviews["review_answer_timestamp"] = pd.to_datetime(
    reviews["review_answer_timestamp"],
    errors="coerce"
)

# Replace missing text with a standard value
reviews["review_comment_title"] = reviews[
    "review_comment_title"
].fillna("No comment")

reviews["review_comment_message"] = reviews[
    "review_comment_message"
].fillna("No comment")

reviews = reviews.drop_duplicates()

reviews.to_csv(
    PROCESSED_DIR / "reviews_clean.csv",
    index=False,
    encoding="utf-8"
)


# --------------------------------------------------
# 6. Products
# --------------------------------------------------

products = pd.read_csv(
    RAW_DIR / "olist_products_dataset.csv"
)

# Missing category
products["product_category_name"] = products[
    "product_category_name"
].fillna("unknown")

products = products.drop_duplicates()

products.to_csv(
    PROCESSED_DIR / "products_clean.csv",
    index=False
)


# --------------------------------------------------
# 7. Sellers
# --------------------------------------------------

sellers = pd.read_csv(
    RAW_DIR / "olist_sellers_dataset.csv"
)

sellers = sellers.drop_duplicates()

sellers.to_csv(
    PROCESSED_DIR / "sellers_clean.csv",
    index=False
)


# --------------------------------------------------
# 8. Geolocation
# --------------------------------------------------

geolocation = pd.read_csv(
    RAW_DIR / "olist_geolocation_dataset.csv"
)

# Remove exact duplicate rows
geolocation = geolocation.drop_duplicates()

geolocation.to_csv(
    PROCESSED_DIR / "geolocation_clean.csv",
    index=False
)


# --------------------------------------------------
# 9. Category Translation
# --------------------------------------------------

category_translation = pd.read_csv(
    RAW_DIR / "product_category_name_translation.csv"
)

category_translation = category_translation.drop_duplicates()

category_translation.to_csv(
    PROCESSED_DIR / "category_translation_clean.csv",
    index=False
)


# --------------------------------------------------
# Completion message
# --------------------------------------------------

print("\n" + "=" * 60)
print("DATA CLEANING COMPLETED")
print("=" * 60)

print(f"\nProcessed files saved to:")
print(PROCESSED_DIR)

print("\nFiles created:")

for file in PROCESSED_DIR.iterdir():
    print(f" - {file.name}")