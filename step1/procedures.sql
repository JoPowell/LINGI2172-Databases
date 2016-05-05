/*
*
*   Reset 
*
*/

-- Function
DROP FUNCTION IF EXISTS is_table_free(tableid INTEGER);
DROP FUNCTION IF EXISTS is_valid_token(tokenclient INTEGER);

-- Senario Function
DROP FUNCTION IF EXISTS AcquireTable(code INTEGER);
DROP FUNCTION IF EXISTS OrderDrinks(tokenclient INTEGER, orders orderList[]);
-- Trigger
DROP trigger IF EXISTS before_insert_clients on clients;

-- Trigger Function
DROP FUNCTION IF EXISTS before_insert_clients();

-- Type
DROP TYPE IF EXISTS orderList;


/*
*
* Definition TYPE
*
*/

/* Type for the couple (drinkname, qty) 
CREATE TYPE orderList AS (drink Name, qty int);
*/

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

        -- génération d'un nouveau token avec serial


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
        tablechoose INTEGER;
    BEGIN
        
        SELECT tableid INTO tablechoose FROM tables WHERE codebar = code;

        IF tablechoose IS NULL THEN
            RAISE EXCEPTION 'the table with the code bar % not exist',codebar;
        END IF;

        
        INSERT INTO clients ("table") VALUES (tablechoose);

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
            RAISE NOTICE 'Client % ordered the Drink ID = % - % cl', tokenclient, cmd.drink, cmd.qty;
            INSERT INTO orderedDrink("order", "drink", "qty") VALUES (orderid, cmd.drink, cmd.qty);

        END LOOP;
    
        RETURN orderid;
    END;
$OrderDrinks$ LANGUAGE plpgsql;


/*
*
*
* Scénario test 
*
*
*/

DO $$
DECLARE
    clientID int;
    clientOrder int;
BEGIN
    SELECT AcquireTable(635614) INTO clientID;
    RAISE NOTICE 'value :%', clientID; 
    
    SELECT OrderDrinks(clientID, ARRAY[(1,1),(3,4)] :: orderList[]) INTO clientOrder;
    RAISE NOTICE 'orderclient %', clientOrder;
    /*
    * Autres tableid à tester 
    *
    SELECT AcquireTable(736894) INTO clientID;
    RAISE NOTICE 'value :%', clientID; 
    
    SELECT AcquireTable(548961) INTO clientID;
    RAISE NOTICE 'value :%', clientID; 
    */
END $$;

