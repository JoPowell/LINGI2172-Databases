﻿DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS tables CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS orderedDrink;
DROP TABLE IF EXISTS drinks;
DROP TABLE IF EXISTS payments;

CREATE TABLE clients (
    "token" serial NOT NULL PRIMARY KEY, --serial
    "table" INTEGER NOT NULL
);

COMMENT ON TABLE clients IS'
    Each client is identified with the unique token `token` which 
    is associated with the table `table` when scanning the table 
';

CREATE TABLE tables (
    "tableid" INTEGER NOT NULL PRIMARY KEY,
    "codebar" INTEGER NOT NULL
);

COMMENT ON TABLE tables IS '   
    Table `tableid` is associated with the codebar ´codebar´
';

CREATE TABLE orders (
    "orderid" serial NOT NULL PRIMARY KEY, -- auto set in insert
    "token" INTEGER NOT NULL,
    "ordertime" TIMESTAMP NOT NULL
);

COMMENT ON TABLE orders IS'
    Order ´orderid´ is made by the client associated with the token 
    ´token´ at the given time `orderTime`
';

CREATE TABLE orderedDrink (
    "order" INTEGER NOT NULL,
    "drink" INTEGER NOT NULL,
    "qty" INTEGER NOT NULL CONSTRAINT positive_qty CHECK ("qty" > -1),
    PRIMARY KEY("order", "drink")
);

COMMENT ON TABLE orderedDrink IS'
    OrderedDrink is the quantity ´qty´ of drinks `drink` ordered 
    by the order `order`
';

CREATE TABLE drinks (
    "drinkid" INTEGER PRIMARY KEY,
    "price" FLOAT NOT NULL CONSTRAINT positive_price CHECK ("price" > -1), 
    "name" NAME NOT NULL,
    "description" VARCHAR NOT NULL 
);

COMMENT ON TABLE drinks IS'
    Drink `drink` named `name` is serve at the price `price` and
    have an explain description `description`
';

CREATE TABLE payments (
    "paymentid" serial NOT NULL PRIMARY KEY, -- auto set in insert
    "token" INTEGER NOT NULL,
    "amountPaid" FLOAT NOT NULL CONSTRAINT positive_amountPaid CHECK ("amountPaid" > -1)
);

COMMENT ON TABLE payments IS'
    Payment `paymentid` is the payment of amout `amountPaid` made by
    the client associated with the token `token`
';

ALTER TABLE clients ADD CONSTRAINT fk_clients FOREIGN KEY ("table") REFERENCES tables("tableid");
ALTER TABLE orders ADD CONSTRAINT fk_orders FOREIGN KEY ("token") REFERENCES clients("token");
ALTER TABLE payments ADD CONSTRAINT fk_payments FOREIGN KEY ("token") REFERENCES clients("token");
ALTER TABLE orderedDrink ADD CONSTRAINT fk_orderedDrink_order FOREIGN KEY ("order") REFERENCES orders("orderid");
ALTER TABLE orderedDrink ADD CONSTRAINT fk_orderedDrink_drink FOREIGN KEY ("drink") REFERENCES drinks("drinkid");

