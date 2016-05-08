DELETE FROM payments CASCADE;
DELETE FROM orderedDrink CASCADE;
DELETE FROM orders CASCADE;
DELETE FROM clients CASCADE;
DELETE FROM tables CASCADE;
DELETE FROM drinks CASCADE;

ALTER SEQUENCE clients_token_seq RESTART;
ALTER SEQUENCE orders_orderid_seq RESTART;
ALTER SEQUENCE payments_paymentid_seq RESTART;

INSERT INTO tables ("tableid", "codebar") VALUES
  (1, 548961), (2,736894), (3, 635614);


INSERT INTO drinks ("drinkid", "price", "name", "description") VALUES
  (1, 2.75, 'Black-Coffee', 'Brewed drink prepared from roasted coffee beans, which are the seeds of berries from the Coffea plant.'),
  (2, 3.60, 'Milk-shake', 'Cold beverage which is usually made from milk, ice cream, or iced milk, and flavorings or sweeteners such as butterscotch, caramel sauce, chocolate sauce, or fruit syrup.'),
  (3, 2.00, 'Beer-pressure', 'The production of beer is called brewing, which involves the fermentation of starches, mainly derived from cereal grains most commonly malted barley'),
  (4, 1.23, 'Still-Water', 'Transparent fluid which forms the world s streams, lakes, oceans and rain, and is the major constituent of the fluids of organisms.'),
  (5, 3.27, 'Green-Tea', 'Aromatic beverage commonly prepared by pouring hot or boiling water over cured leaves of the Camellia sinensis.'),
  (6, 1.50, 'Sparkling-water','Water into which carbon dioxide gas under pressure has been dissolved.');
