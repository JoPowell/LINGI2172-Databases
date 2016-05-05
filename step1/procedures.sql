/*
*
*   Reset 
*
*/

DROP FUNCTION IF EXISTS is_table_free(tableid INTEGER);
DROP trigger IF EXISTS before_insert_clients on clients;
DROP FUNCTION IF EXISTS before_insert_clients();

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
    
    /*
    * Autres tableid à tester 
    *
    SELECT AcquireTable(736894) INTO clientID;
    RAISE NOTICE 'value :%', clientID; 
    
    SELECT AcquireTable(548961) INTO clientID;
    RAISE NOTICE 'value :%', clientID; 
    */
END $$;