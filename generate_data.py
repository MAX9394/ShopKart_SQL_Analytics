import csv, random
from datetime import date, timedelta
random.seed(42)

FIRST = ["Aarav","Vivaan","Aditya","Arjun","Sai","Reyansh","Krishna","Ishaan","Rohan","Kabir","Ananya","Diya","Aadhya","Myra","Sara","Ira","Priya","Neha","Pooja","Rahul","Amit","Sneha","Vikram","Karan","Manish","Divya","Kavya","Riya","Sharma","Nisha","Ravi","Suresh","Deepak","Anil","Sunita","Meera","Kunal","Varun","Aditi","Tanvi","Ritu","Mohit","Sahil","Nikhil","Pavan","Harsh","Shreya","Anjali","Kirti","Farhan"]
LAST = ["Sharma","Verma","Gupta","Mehta","Patel","Reddy","Iyer","Nair","Singh","Kumar","Das","Khan","Mishra","Joshi","Chopra","Agarwal","Banerjee","Choudhury","Desai","Pillai","Yadav","Thakur","Pandey","Rao","Kulkarni","Saxena","Trivedi","Menon","Bhatt","Chauhan"]
CITIES = ["Mumbai","Delhi","Bengaluru","Hyderabad","Chennai","Kolkata","Pune","Ahmedabad","Jaipur","Lucknow","Kanpur","Nagpur","Indore","Bhopal","Surat","Patna","Ludhiana","Agra","Nashik","Kochi"]
TIERS = ["Silver","Gold","Platinum"]
TIER_W = [0.6,0.3,0.1]

def rand_date(start, end):
    d = start + timedelta(days=random.randint(0,(end-start).days))
    return d.isoformat()

today = date(2026,10,5)
signup_start = date(2024,10,6)
order_start = date(2025,10,6)

# customers.csv
with open("data/customers.csv","w",newline="",encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["customer_id","name","email","city","tier","signup_date"])
    used_emails=set()
    for i in range(1,501):
        fn = random.choice(FIRST); ln = random.choice(LAST)
        name = f"{fn} {ln}"
        base = f"{fn.lower()}.{ln.lower()}{i}"
        email = base+"@gmail.com"
        # ensure unique
        while email in used_emails:
            email = base+f"{random.randint(1,99)}@gmail.com"
        used_emails.add(email)
        city = "" if random.random()<0.05 else random.choice(CITIES)
        tier = random.choices(TIERS,TIER_W)[0]
        sd = rand_date(signup_start,today)
        w.writerow([i,name,email,city,tier,sd])

# products.csv
CATS = {
 "Electronics": [("boAt BassHeads Earphones",1499),("Mi Redmi Note 13",16999),("HP Laptop 15s",58990),("Samsung 43in TV",32999),("Noise Smartwatch",2999),("JBL Flip Speaker",8999),("Logitech Mouse",795),("SanDisk 128GB Pendrive",1199),("Philips Trimmer",1895),("Mi Powerbank 20000mAh",2199)],
 "Fashion": [("Roadster Cotton Tshirt",499),("Levis Slim Jeans",1999),("Biba Kurti",1299),("Nike Running Shoes",3495),("H&M Dress",1499),("Puma Sneakers",2799),("FabIndia Saree",2499),("Allen Solly Shirt",1599),("Zara Handbag",2299),("Bata Slippers",399)],
 "Grocery": [("Aashirvaad Atta 10kg",485),("Tata Salt 1kg",28),("Fortune Oil 5L",725),("Maggi 12pack",168),("Amul Ghee 1L",650),("Daawat Basmati 5kg",899),("Parle Biscuits Combo",199),("Tata Tea 1kg",540),("Sugar 5kg",240),("Dry Fruits Mix 1kg",999)],
 "Home": [("Milton Bottle 1L",899),("Prestige Cooker 5L",1895),("Wakefit Bedsheet",999),("Philips LED Bulb Pack",649),("Nilkamal Chair",1499),("Borosil Dinner Set",2499),("Dyson V8 Clone Vacuum",7999),("Wall Clock Ajanta",599),("Cello Storage Box",499),("Havells Iron",1299)],
 "Beauty": [("Lakme Lipstick",550),("Mamaearth Facewash",349),("Nivea Cream",299),("Loreal Shampoo",499),("Himalaya Kajal",199),("Maybelline Foundation",649),("Dove Soap Pack",249),("Biotique Serum",799),("Garnier Hair Colour",229),("Vaseline Lotion",399)],
}
with open("data/products.csv","w",newline="",encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["product_id","name","category","price","cost"])
    pid=1
    for cat,items in CATS.items():
        for nm,price in items:
            cost = int(price*random.uniform(0.6,0.85))
            w.writerow([pid,nm,cat,price,cost])
            pid+=1

# orders.csv with COD higher fail rate
PAY = ["UPI","Card","COD","NetBanking"]
PAY_W = [0.45,0.20,0.25,0.10]
with open("data/orders.csv","w",newline="",encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["order_id","customer_id","order_date","status","payment_mode"])
    for oid in range(1,1501):
        cid = random.randint(1,500)
        od = rand_date(order_start,today)
        pm = random.choices(PAY,PAY_W)[0]
        fail_p = 0.25 if pm=="COD" else 0.09
        r = random.random()
        if r < fail_p*0.67:
            st="Cancelled"
        elif r < fail_p:
            st="Returned"
        else:
            # adjust to ~85/10/5 overall; fallback delivered
            st="Delivered"
        # force overall distribution approx: re-balance by random tweak
        w.writerow([oid,cid,od,st,pm])

# order_items.csv 2500 rows, 1-3 per order
pairs=set()
rows=[]
# 1 per order first
for oid in range(1,1501):
    pid = random.randint(1,50)
    qty = random.choices([1,2,3,4,5],[0.6,0.25,0.08,0.05,0.02])[0]
    disc = random.choices([0,5,10,15,20,30,40,50],[0.4,0.2,0.15,0.1,0.07,0.05,0.02,0.01])[0]
    rows.append((oid,pid,qty,disc))
# extra 1000
for _ in range(1000):
    oid = random.randint(1,1500)
    pid = random.randint(1,50)
    qty = random.choices([1,2,3,4],[0.65,0.25,0.07,0.03])[0]
    disc = random.choices([0,5,10,15,20,30],[0.45,0.2,0.15,0.1,0.06,0.04])[0]
    rows.append((oid,pid,qty,disc))
random.shuffle(rows)
with open("data/order_items.csv","w",newline="",encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["order_item_id","order_id","product_id","qty","discount_pct"])
    for idx,r in enumerate(rows,1):
        w.writerow([idx,r[0],r[1],r[2],r[3]])
print(f"done: customers 500, products 50, orders 1500, items {len(rows)}")
