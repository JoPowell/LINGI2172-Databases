import os
os.environ['DJANGO_SETTINGS_MODULE'] = 'TheAutomatedCafe.settings'
import django
django.setup()

from querybuilder.query import Query
from querybuilder.tables import Table
from TheAutomatedCafe.models import *

#	print(query.get_sql())

##############
### Utiles ###
##############

# A table is free if every tokens associated with a table is found in the payment table
def freeTable(tableid):
   # Get all client tokens associated to the table (id) and count them
   query = Query().from_table('client').where(tableid_id=tableid)
   client = query.select() #SELECT * FROM client WHRE tableid_id = tableid
   clientCount = query.count()
   
   # Count when a payment has been done with the client token
   paymentCount = 0
   for token in client:
      query = Query().from_table('payment').where(token_id=token['id'])
      payment = query.select()
      if payment:
         paymentCount = paymentCount + 1
   return clientCount == paymentCount

# The token is valid to use if it exist and so stored in the client relation and not yet use to pay
def isValidToken(token): 
    query = Query().from_table('client').where(id=token)
    client = query.select() 
    paymentToken = Query().from_table('payment').where(token_id=token).count()
    return (len(client) > 0 and paymentToken < 1)

######################
### Main procedure ###
######################

def acquireTable(codeBar):
   # Get the tableID coresponding to the codebar
	query = Query().from_table('tables').where(codebar=codeBar)
	table = query.select()
	if not table:
	   raise ValueError('Invalid codebar')
	else:
	   tableID = table[0]['id']
	   isFree = freeTable(tableID)
	   if freeTable(tableID): # The table is free, we can issue a new token
	      client = Client(tableid_id=tableID) #INSERT INTO client (id, tableid_id) VALUES (id, tableID)
	      client.save()
	      print('Hello dear customer, please make an order')
	      return client.id
	   else: # The table is not free !
	      raise ValueError('This table is occupied, please find an other table')
   

def orderDrinks(token, newOrder): #newOrder = [{drink:theDrink, qty:theQty}, ... ]
   if isValidToken(token) :
      return
   return
   
acquireTable(548961)
