import os
os.environ['DJANGO_SETTINGS_MODULE'] = 'TheAutomatedCafe.settings'
import django
django.setup()

from TheAutomatedCafe.models import *
from django.utils import timezone

#Clean tables
Tables.objects.all().delete()
Client.objects.all().delete()
Drink.objects.all().delete()
Orders.objects.all().delete()
Drink.objects.all().delete()
Ordereddrink.objects.all().delete()

#Fill table Tables
codebars = [548961, 736894, 635614]

for i in codebars:
	table = Tables(codebar = i)
	table.save()

#Fill table Client
tableID1 = Tables.objects.get(codebar=548961)
tableID2 = Tables.objects.get(codebar=736894)
tableID3 = Tables.objects.get(codebar=635614)
tableIDs = [tableID1, tableID2, tableID3]

for i in tableIDs:
	client = Client(tableid = i)
	client.save()
	
#Fill table Drink
prices = [2.75, 3.60, 2.00, 1.23, 3.27, 1.50]
names = ['Black Coffee', 'Milk-shake', 'Beer pressure', 'Still Water', 'Green Tea', 'Sparkling Water']
descriptions = ['Brewed drink prepared from roasted coffee beans, which are the seeds of berries from the Coffea plant.','Cold beverage which is usually made from milk, ice cream, or iced milk, and flavorings or sweeteners such as butterscotch, caramel sauce, chocolate sauce, or fruit syrup.', 'The production of beer is called brewing, which involves the fermentation of starches, mainly derived from cereal grains most commonly malted barley', 'Transparent fluid which forms the world s streams, lakes, oceans and rain, and is the major constituent of the fluids of organisms.', 'Aromatic beverage commonly prepared by pouring hot or boiling water over cured leaves of the Camellia sinensis.', 'Sparkling water','Water into which carbon dioxide gas under pressure has been dissolved.']

for i in range(0, len(prices)):
	drink = Drink(price = prices[i], name = names[i], description = descriptions[i])
	drink.save()
	
#Fill table Orders
token1 = Client.objects.get(tableid=tableID1)
token2 = Client.objects.get(tableid=tableID2)
token3 = Client.objects.get(tableid=tableID3)
date1 = timezone.now()
date2 = timezone.now()
date3 = timezone.now()
date4 = timezone.now()
orderTimes = [date1, date2, date3, date4]
tokens = [token1, token1, token2, token2]

for i in range(0, len(orderTimes)):
	orders = Orders(token = tokens[i], ordertime = orderTimes[i])
	orders.save()
	
#Fill table OrderedDrink
orderID1 = Orders.objects.get(ordertime=date1)
orderID2 = Orders.objects.get(ordertime=date2)
orderID3 = Orders.objects.get(ordertime=date3)
orderID4 = Orders.objects.get(ordertime=date4)
coffeeID = Drink.objects.get(name='Black Coffee')
milkshakeID = Drink.objects.get(name='Milk-shake')
beerID = Drink.objects.get(name='Beer pressure')
waterID = Drink.objects.get(name='Still Water')
teaID = Drink.objects.get(name='Green Tea')
ordersIDs = [orderID1, orderID2, orderID3, orderID4, orderID4]
drinkIDs = [milkshakeID, coffeeID, teaID, beerID, waterID]
qtys = [1, 1, 5, 3, 1]

for i in range(0, len(qtys)):
	orderedDrink = Ordereddrink(orderid = ordersIDs[i], drinkid = drinkIDs[i], qty = qtys[i])
	orderedDrink.save()

#Fill table Payment
tokens =  [token1, token2] # Client (token3) on table codebar 635614 is still using the table
amountPaids = [6.35, 16.35]

for i in range(0, len(tokens)):
	payment = Payment(token = tokens[i], amountpaid = amountPaids[i])
	payment.save()
