DROP TABLE IF EXISTS client CASCADE;
DROP TABLE IF EXISTS tables CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS orderedDrink;
DROP TABLE IF EXISTS drink;
DROP TABLE IF EXISTS payment;

CREATE TABLE client (
    "token" INTEGER NOT NULL PRIMARY KEY,
    "tableID" INTEGER NOT NULL
);

COMMENT ON TABLE client IS'
    Each client is identified with the unique token `token` which 
    is associated with the table `tableID` when scanning the table 
';

CREATE TABLE tables (
    "tableID" INTEGER NOT NULL PRIMARY KEY,
    "codebar" INTEGER NOT NULL
);

COMMENT ON TABLE tables IS '   
    Table `tableID` is associated with the codebar ´codebar´
';

CREATE TABLE orders (
    "orderID" INTEGER NOT NULL PRIMARY KEY,
    "token" INTEGER NOT NULL,
    "orderTime" TIMESTAMP NOT NULL
);

COMMENT ON TABLE orders IS'
    Order ´orderID´ is made by the client associated with the token 
    ´token´ at the given time `orderTime`
';

CREATE TABLE orderedDrink (
    "orderID" INTEGER NOT NULL,
    "drinkID" INTEGER NOT NULL,
    "qty" INTEGER NOT NULL CONSTRAINT positive_qty CHECK ("qty" > -1),
    PRIMARY KEY("orderID", "drinkID")
);

COMMENT ON TABLE orderedDrink IS'
    OrderedDrink is the quantity ´qty´ of drinks `drinkID` ordered 
    by the order `orderID`
';

CREATE TABLE drink (
    "drinkID" INTEGER PRIMARY KEY,
    "price" FLOAT NOT NULL CONSTRAINT positive_price CHECK ("price" > -1), 
    "name" NAME NOT NULL,
    "description" VARCHAR NOT NULL
);

COMMENT ON TABLE drink IS'
    Drink `drinkID` named `name` is serve at the price `price` and
    have an explain description `description`
';

CREATE TABLE payment (
    "paymentID" INTEGER NOT NULL PRIMARY KEY,
    "token" INTEGER NOT NULL,
    "amountPaid" FLOAT NOT NULL CONSTRAINT positive_amountPaid CHECK ("amountPaid" > -1)
);

COMMENT ON TABLE payment IS'
    Payment `paymentID` is the payment of amout `amountPaid` made by
    the client associated with the token `token`
';

ALTER TABLE client ADD CONSTRAINT fk_client FOREIGN KEY ("tableID") REFERENCES tables("tableID");
ALTER TABLE orders ADD CONSTRAINT fk_orders FOREIGN KEY ("token") REFERENCES client("token");
ALTER TABLE payment ADD CONSTRAINT fk_payment FOREIGN KEY ("token") REFERENCES client("token");
ALTER TABLE orderedDrink ADD CONSTRAINT fk_orderedDrink_order FOREIGN KEY ("orderID") REFERENCES orders("orderID");
ALTER TABLE orderedDrink ADD CONSTRAINT fk_orderedDrink_drink FOREIGN KEY ("drinkID") REFERENCES drink("drinkID");