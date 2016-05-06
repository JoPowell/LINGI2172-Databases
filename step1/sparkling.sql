-- Order sparkling water 2 times and pay

DO $$
DECLARE
    client int;
    order int;
BEGIN
    SELECT AcquireTable('736894') INTO client;

    SELECT OrderDrinks(client, ARRAY[(6,1)] :: orderList[]) INTO order;
    SELECT * FROM IssueTicket(client) INTO amount, listorder;
    RAISE NOTICE 'amount : % € listorder : %', amount, listorder;
    SELECT OrderDrinks(client, ARRAY[(6,1)] :: orderList[]) INTO order;
    PERFORM PayTable(client, 4);
END; 
$$ language plpgsql;
