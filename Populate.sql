INSERT INTO tables ("tableID", "codebar") VALUES
  (1, 548961), (2,736894), (3, 635614);

INSERT INTO client ("token", "tableID") VALUES
  (478,1), (479, 2), (480, 3);

INSERT INTO drink ("drinkID", "price", "name", "description") VALUES
  (1, 2.75, 'Coffee', 'Brewed drink prepared from roasted coffee beans, which are the seeds of berries from the Coffea plant.'),
  (2, 3.60, 'Milk-shake', 'Cold beverage which is usually made from milk, ice cream, or iced milk, and flavorings or sweeteners such as butterscotch, caramel sauce, chocolate sauce, or fruit syrup.'),
  (3, 2.00, 'Beer', 'The production of beer is called brewing, which involves the fermentation of starches, mainly derived from cereal grains—most commonly malted barley'),
  (4, 1.23, 'Water', 'Transparent fluid which forms the world s streams, lakes, oceans and rain, and is the major constituent of the fluids of organisms.'),
  (5, 3.27, 'Tea', 'Aromatic beverage commonly prepared by pouring hot or boiling water over cured leaves of the Camellia sinensis.');

INSERT INTO orders ("orderID", "token", "orderTime") VALUES
  (1, 478, '1999-01-08 04:05:06'),
  (2, 478, '1999-02-14 04:55:15'),
  (3, 479, '2014-01-13 13:12:48'),
  (4, 479, '2015-08-07 20:37:02');

INSERT INTO orderedDrink ("orderID", "drinkID", "qty") VALUES
  (1, 2, 1),
  (2, 1, 1),
  (3, 5, 5),
  (4, 3, 3),
  (4, 4, 1);

INSERT INTO payment ("paymentID", "token", "amountPaid") VALUES
  (1, 478, 6.35),
  (2, 479, 16.35);