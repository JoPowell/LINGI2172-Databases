/*
*
*   Reset 
*
*/

-- Function
DROP FUNCTION IF EXISTS is_table_free(tableid INTEGER);
DROP FUNCTION IF EXISTS is_valid_token(tokenclient INTEGER) CASCADE;

-- Senario Function
DROP FUNCTION IF EXISTS AcquireTable(code INTEGER);
DROP FUNCTION IF EXISTS OrderDrinks(tokenclient INTEGER, orders orderList[]);
DROP FUNCTION IF EXISTS IssueTicket(tokenclient INTEGER);
DROP FUNCTION IF EXISTS PayTable(tokenclient INTEGER, paid float);

-- Trigger
DROP trigger IF EXISTS before_insert_clients on clients;

-- Trigger Function
DROP FUNCTION IF EXISTS before_insert_clients();

-- Type
DROP TYPE IF EXISTS orderList;
DROP TYPE IF EXISTS ordernameList;

-- VIEW

DROP VIEW IF EXISTS bill;

/*
*
* Definition TYPE
*
*/

/* Type for the couple (drinkname, qty) 
CREATE TYPE orderList AS (drink Name, qty int);
*/

CREATE TYPE ordernameList AS (drinkname NAME, qty int);


--Type for the couple (drinkid, qty)
CREATE TYPE orderList AS (drink int, qty int);




/*
*
*       Others functions
*
*/



/*
*
* @Pre :  
* @Post : Return true if the table with tableid is free and if not false 
*
* Algo : The table is free if the number of client sitting at the table equals the number of payment at the table
*
*/
CREATE OR REPLACE FUNCTION is_table_free(tableid INTEGER) RETURNS BOOLEAN AS $is_table_free$
    DECLARE
        number_client_payed int;
        number_client_sitting int;
    BEGIN

         -- Number of client sitting at the table
        SELECT COUNT(tableid) INTO number_client_sitting FROM clients WHERE clients.table = tableid;

        
        -- Number of client payed at the table
        SELECT COUNT(*) INTO number_client_payed FROM clients
            JOIN (SELECT * FROM payments)
                C ON C.token = clients.token
        WHERE clients.table = tableid;

        IF number_client_payed IS NULL OR number_client_sitting IS NULL THEN
            RAISE EXCEPTION 'Table with id % not exist ', clients.table;
        END IF;

        IF number_client_payed = number_client_sitting THEN
            RETURN TRUE;
        END IF;

        RETURN FALSE;
    END;
$is_table_free$ LANGUAGE plpgsql;




/*
*
* @Pre :  
* @Post : Return true if the table with tableid is free and the token is valid for this table
*     if not false 
*
*/
CREATE OR REPLACE FUNCTION is_valid_token(tokenclient INTEGER) RETURNS BOOLEAN AS $is_valid_token$
    DECLARE
    ispaid BOOLEAN;
        tableID INTEGER;
    BEGIN

    IF tokenclient IS NULL THEN
        RAISE EXCEPTION 'invalid token';
    END IF; 
    
    -- Get table of client
    SELECT clients.table INTO tableID FROM clients where token=tokenclient;

    IF tableID IS NULL THEN
        RETURN FALSE;
    END IF;
        
        -- Verify if the table is free
    IF is_table_free(tableID) IS FALSE THEN
        -- Verify if the client has already paid
        SELECT COUNT(*) = 1 INTO ispaid FROM payments WHERE token = tokenclient;
        If ispaid IS FALSE THEN
            RETURN TRUE;
        END IF;
    END IF;

        RETURN FALSE;

    END;
$is_valid_token$ LANGUAGE plpgsql;




/*
*
*
*        Checking function data before insert  (TRIGGER)
*
*/
CREATE FUNCTION before_insert_clients() RETURNS trigger AS $before_insert_clients$
    BEGIN
        -- Check tableID
        IF NEW.table IS NULL THEN
            RAISE EXCEPTION 'table can not be NULL';
        END IF;

        -- Check if the table is free
        IF is_table_free(NEW.table) IS FALSE THEN
            RAISE EXCEPTION 'The table % is not free',New.table;
        END IF;


        RETURN NEW;
    END;
$before_insert_clients$ LANGUAGE plpgsql;




/*
* 
*       Checking : Trigger BEFORE of INSERT data
* 
*/
CREATE TRIGGER before_insert_clients BEFORE INSERT ON clients
    FOR EACH ROW EXECUTE PROCEDURE before_insert_clients();




/*
*
*   Definition view
*
*
*/

-- All drink no payed
CREATE VIEW bill AS
SELECT clients.token, ordereddrink.drink, ordereddrink.qty, drinks.price, drinks.name 
FROM clients, orders,ordereddrink, drinks 
WHERE clients.token = orders.token AND is_valid_token(orders.token) 
AND orders.orderid = ordereddrink.order AND ordereddrink.drink = drinks.drinkid;




/*
*
*       Senario Functions
*
*/


/*
* FUNCTION : AcquireTable
* DESC : invoked by the smartphone app when scanning a table code bar
* IN : a table bar code
* OUT : a client toke 
* @PRE : The table must be free to aquire the table
* @POST: The table is no longer free
* @POST: Issued token can be used for ordering drinks
*/
CREATE OR REPLACE FUNCTION AcquireTable(code int) RETURNS int AS $AcquireTable$
    DECLARE
        tableselected INTEGER;
    BEGIN
        
        SELECT tableid INTO tableselected FROM tables WHERE codebar = code;

        IF tableselected IS NULL THEN
            RAISE EXCEPTION 'the table with the code bar % not exist',codebar;
        END IF;

        
        INSERT INTO clients ("table") VALUES (tableselected);

        -- RETURN the client token
        RETURN currval('clients_token_seq');

    END;
$AcquireTable$ LANGUAGE plpgsql;




/*
* FUNCTION : OrderDrinks
* DESC: invoked when the user presses the “order” button in the ordering screen IN: a client token
* IN: a list of (drink, qty) taken from the screen form
* OUT: theuniquenumberofthecreatedorder
* @PRE: theclienttokenisvalidandcorrespondstoanoccupiedtable
* @POST: the order is created, its number is the one returned
*
*/
CREATE OR REPLACE FUNCTION OrderDrinks(tokenclient int, orders orderList[]) RETURNS int AS $OrderDrinks$
    DECLARE
        orderid int;
        cmd orderList;
    BEGIN
    
        -- Verify token validity
    IF is_valid_token(tokenclient) IS FALSE THEN
        RAISE EXCEPTION 'Token is invalid';
    END IF;
    
    -- Verify the order
        IF orders IS NULL THEN
            RAISE EXCEPTION 'you have to order anything';
        END IF;

        -- Create order in clients tables
        INSERT INTO orders ("token", "ordertime") VALUES (tokenclient, now());

    -- Create orderedDrink from orders
    orderid := currval('orders_orderid_seq');
        FOREACH cmd IN ARRAY orders
        LOOP
            RAISE NOTICE 'Client % ordered the Drink ID = %  X %', tokenclient, cmd.drink, cmd.qty;
            INSERT INTO orderedDrink("order", "drink", "qty") VALUES (orderid, cmd.drink, cmd.qty);

        END LOOP;
    
        RETURN orderid;
    END;
$OrderDrinks$ LANGUAGE plpgsql;




/*
* FUNCTION : IssueTicket
* DESC : Invoked when the user asks for looking at the table summary and due amount
* @OUT : The ticket to be paid, with a summary of orders and total amount to pay
* @PRE : The client token is valid and corresponds to an occupied table
* @POST: Issued ticket corresponds to all (and only) ordered drinks at that table
*/
CREATE OR REPLACE FUNCTION IssueTicket(tokenclient INTEGER, OUT total_amount float, OUT listorder ordernamelist[])  AS $$
    DECLARE
        bill_record record;
    BEGIN
            -- Verify token
        IF is_valid_token(tokenclient) IS FALSE THEN
            RAISE EXCEPTION 'The client token % is INVALID', tokenclient;
        END IF;

    SELECT SUM(bill.price * bill.qty) INTO total_amount FROM bill WHERE bill.token = tokenclient;

    IF total_amount IS NULL THEN
        RAISE EXCEPTION 'The client token % has not drink', tokenclient;
    END IF;

    -- Create list order
    listorder = NULL;
    FOR bill_record in SELECT bill.name, SUM(bill.qty) as qty from bill where bill.token = tokenclient group by bill.name LOOP
    RAISE NOTICE 'add list :(%,%)', bill_record.name, bill_record.qty;
    listorder  = listorder || ARRAY[(bill_record.name,bill_record.qty)] :: ordernamelist[];
    END LOOP;
    RAISE NOTICE 'orderlist : %', listorder;
    END;
$$ LANGUAGE plpgsql;




/*
* FUNCTION : PayTable
* DESC: invoked by the smartphone on confirmation from the payment gateway (we
*            ignore security on purpose here; a real app would never expose such an
*            API, of course). IN: a client token IN: an amount paid
* OUT:
* PRE: the client token is valid and corresponds to an occupied table
* PRE: the input amount is greater or equal to the amount due for that table 
* POST: the table is released
* POST: the client token can no longer be used for ordering
*/
CREATE OR REPLACE FUNCTION PayTable(tokenclient int, paid float) RETURNS VOID AS $PayTable$
     DECLARE
    amountdue float;
    BEGIN

        -- Verify tokenclient 
        IF is_valid_token(tokenclient) IS FALSE THEN
        RAISE EXCEPTION 'token % is invalid', tokenclient;
        END IF;

    -- Verify if good paid
    SELECT SUM(bill.price * bill.qty) INTO amountdue FROM bill WHERE bill.token = tokenclient;

    IF amountdue > paid IS TRUE THEN
        RAISE EXCEPTION 'you have not paid enough, you must pay at least %', amountdue;
    END IF;
    
        -- RELEASE TABLE (If the client as paid, the table is considered as released)
        INSERT INTO payments ("token", "amountPaid") VALUES (tokenclient, paid);

        RETURN;
    END;
$PayTable$ LANGUAGE plpgsql;



