require "sqlite3"

# Open a database
filename = File.expand_path "example.db", __dir__
File.delete filename if File.exist? filename # reset each time we run
db = SQLite3::Database.new filename
db.results_as_hash = true              # => true

# Create a database
rows = db.execute <<-SQL  # => []
  CREATE TABLE fruits(
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    name     VARCHAR(31),
    quantity INT
  );
SQL
db.execute <<-SQL  # => []
  CREATE TABLE sales(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fruit_id INTEGER,
    customer_id INTEGER,
    created_at DATETIME
  );
SQL
db.execute <<-SQL  # => []
  CREATE TABLE customers(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR(63)
  );
SQL
db.execute <<-SQL
  CREATE VIEW orders AS
    SELECT customers.name, fruits.name, sales.created_at
    FROM fruits
    INNER JOIN sales     ON fruits.id         = sales.fruit_id
    INNER JOIN customers ON sales.customer_id = customers.id;
SQL


db.execute "INSERT INTO fruits(name, quantity) VALUES (?, ?);", ['apples', 6]    # => []
db.execute "INSERT INTO fruits(name, quantity) VALUES (?, ?);", ['oranges', 12]  # => []
db.execute "INSERT INTO fruits(name, quantity) VALUES (?, ?);", ['bananas', 18]  # => []

db.execute "INSERT INTO customers(name) VALUES (?);", ['Jeff']     # => []
db.execute "INSERT INTO customers(name) VALUES (?);", ['Violet']   # => []
db.execute "INSERT INTO customers(name) VALUES (?);", ['Vincent']  # => []

db.execute 'INSERT INTO sales(fruit_id, customer_id, created_at) VALUES(1, 2, CURRENT_TIMESTAMP);'
db.execute 'INSERT INTO sales(fruit_id, customer_id, created_at) VALUES(3, 2, CURRENT_TIMESTAMP);'
db.execute 'INSERT INTO sales(fruit_id, customer_id, created_at) VALUES(1, 3, CURRENT_TIMESTAMP);'

join_results = db.execute '
  SELECT customers.name, fruits.name, sales.created_at
  FROM fruits
  INNER JOIN sales     ON fruits.id         = sales.fruit_id
  INNER JOIN customers ON sales.customer_id = customers.id;
'
view_results = db.execute 'SELECT * FROM orders;'


