from __future__ import unicode_literals

import os
os.environ['DJANGO_SETTINGS_MODULE'] = 'TheAutomatedCafe.settings'

from django.db import models

# Relation Client
#  Each client is identified with the unique token `token` which 
#  is associated with the table `tableID` when scanning the table 
class Client(models.Model):
    tableid = models.ForeignKey('Tables', on_delete=models.CASCADE) #Set foreign key

    class Meta:
        db_table = 'client'
        app_label = 'TheAutomatedCafe'

# Relation Drink
#  Drink `drinkID` named `name` is serve at the price `price` and
#  have an explain description `description`
class Drink(models.Model):
    price = models.FloatField()
    name = models.TextField()
    description = models.TextField()

    class Meta:
        db_table = 'drink'
        app_label = 'TheAutomatedCafe'
        
# Relation Ordereddrink
#  OrderedDrink is the quantity ´qty´ of drinks `drinkID` ordered 
#  by the order `orderID`
class Ordereddrink(models.Model):
    orderid = models.ForeignKey('Orders', on_delete=models.CASCADE) #Set foreign key
    drinkid = models.ForeignKey('Drink', on_delete=models.CASCADE)  #Set foreign key
    qty = models.IntegerField()

    class Meta:
        db_table = 'ordereddrink'
        unique_together = (('orderid', 'drinkid'),) #Set primary key
        app_label = 'TheAutomatedCafe'
        
# Relation Orders
#  Order ´orderID´ is made by the client associated with the token 
#  ´token´ at the given time `orderTime`
class Orders(models.Model):
    token = models.ForeignKey('Client', on_delete=models.CASCADE) #Set foreign key
    ordertime = models.DateTimeField(db_column='orderTime')

    class Meta:
        db_table = 'orders'
        app_label = 'TheAutomatedCafe'

# Relation Payment
#  Payment `paymentID` is the payment of amout `amountPaid` made by
#  the client associated with the token `token`
class Payment(models.Model):
    token = models.ForeignKey(Client, on_delete=models.CASCADE) #Set foreign key
    amountpaid = models.FloatField(db_column='amountPaid')
    
    class Meta:
        db_table = 'payment'
        app_label = 'TheAutomatedCafe'

# Relation Tables
#  Table `tableID` is associated with the codebar ´codebar´
class Tables(models.Model):
    codebar = models.IntegerField()

    class Meta:
        db_table = 'tables'
        app_label = 'TheAutomatedCafe'
