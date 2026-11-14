INSERT INTO users (name,email,phone,address) SELECT 'Alice Johnson','alice@example.com','555-0101','Demo Street 1' WHERE NOT EXISTS (SELECT 1 FROM users WHERE email='alice@example.com');
INSERT INTO users (name,email,phone,address) SELECT 'Bob Smith','bob@example.com','555-0102','Demo Street 2' WHERE NOT EXISTS (SELECT 1 FROM users WHERE email='bob@example.com');
INSERT INTO users (name,email,phone,address) SELECT 'Charlie Brown','charlie@example.com','555-0103','Demo Street 3' WHERE NOT EXISTS (SELECT 1 FROM users WHERE email='charlie@example.com');
