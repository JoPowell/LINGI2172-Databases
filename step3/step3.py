import os
os.environ['DJANGO_SETTINGS_MODULE'] = 'TheAutomatedCafe.settings'
import django
django.setup()

from querybuilder.query import Query
from querybuilder.tables import Table
from TheAutomatedCafe.models import *
from django.utils import timezone

#	print(query.get_sql())

##############
### Utils ###
##############
# Return the ticket as a string
def ticketToString(ticket) :
   totalAmount = ticket.pop(0)
   header = '\t\t TheAutomatedCafe \t\t\n'
   drinks = 'Qty\tDrink      \t\tPrice\tTotal\n'
   for bill in ticket :
      drink = str(bill['qty'])+'\t'+bill['name']+'\t\t'+str(bill['priceU'])+'\t'+str(bill['priceT'])+'\n'
      drinks = drinks + drink
   line ='--------------------------------------------\n'
   total = '\t\t\tTotal to pay : '+str(totalAmount)
 
   return header + drinks + line + total


# A table is free if every tokens associated with a table is found in the payment table
def freeTable(tableid) :
   # Get all client tokens associated to the table (id) and count them
   query = Query().from_table('client').where(tableid_id=tableid)
   client = query.select() #SELECT * FROM client WHRE tableid_id = tableid
   clientCount = query.count()
   
   # Count when a payment has been done with the client token
   paymentCount = 0
   for token in client :
      query = Query().from_table('payment').where(token_id=token['id'])
      payment = query.select()
      if payment:
         paymentCount = paymentCount + 1
   return clientCount == paymentCount

# The token is valid to use if it exist and therefore stored in the client relation and not yet use to pay
def isValidToken(token) : 
    query = Query().from_table('client').where(id=token)
    client = query.select() #SELECT * FROM client WHRE id = token
    paymentToken = Query().from_table('payment').where(token_id=token).count()
    return (len(client) > 0 and paymentToken < 1)

def makeTicket(qty, name, priceU, priceT, myTicket) :
   if not myTicket :
      myTicket.append({'qty':qty, 'name':name, 'priceU':priceU, 'priceT':priceT})
      return myTicket
   else :
      for i in range(0, len(myTicket)) :
         if myTicket[i]['name'] == name and myTicket[i]['priceU'] == priceU :
            oldPriceT = myTicket[i]['priceT']
            oldQty = myTicket[i]['qty']
            myTicket[i] = {'qty':(oldQty + qty), 'name':name, 'priceU':priceU, 'priceT':(oldPriceT + priceT)}
            break
         else :
            if i == (len(myTicket) - 1) :
               myTicket.append({'qty':qty, 'name':name, 'priceU':priceU, 'priceT':priceT})
      return myTicket

######################
### Main procedure ###
######################

def acquireTable(codeBar) :
   # Get the tableID coresponding to the codebar
	query = Query().from_table('tables').where(codebar=codeBar)
	table = query.select()
	if not table:
	   raise ValueError('Invalid codebar')
	else:
	   tableID = table[0]['id']
	   isFree = freeTable(tableID)
	   if freeTable(tableID): # The table is free, we can issue a new token
	      client = Client(tableid_id=tableID) 
	      client.save() #INSERT INTO client (id, tableid_id) VALUES (id, tableID)
	      print('Hello dear customer, please make an order.')
	      return client.id
	   else: # The table is not free !
	      raise ValueError('This table is occupied, please find an other table')
   
def orderDrinks(token, newOrder): #newOrder = [{'drink':theDrink, 'qty':theQty}, ... ]
   if isValidToken(token) :
      # Save the new order
      clientToken = Client.objects.get(id=token) # "Client" instance (foreign key)
      order = Orders(ordertime = timezone.now(), token = clientToken ) #INSERT INTO orders (ordertime, token) VALUES (id, tableID)
      order.save()
      # Save the ordered drinks
      for myOrder in newOrder :
         query = Query().from_table('drink').where(name=myOrder['drink'])
         client = query.select()
         drinkID = client[0]['id']
         orderedDrink = Ordereddrink(orderid_id=order.id, drinkid_id=drinkID, qty=myOrder['qty'])
         orderedDrink.save()
      print("Your order is placed.")
      return order.id
   else :
      raise ValueError('The token is not a valid token to order drinks !')

def issueTicket(token) :  #output [totalAmount, {'qty':theQty, 'drink':theDrink, 'priceU':theUprice, 'priceT":theTprice}, ...]
   if isValidToken(token) :
      query = Query().from_table('orders').where(token_id=token)
      orders = query.select()
      orderedDrinks = list();
      totalAmount = 0
      for order in orders :
         query = Query().from_table('ordereddrink').where(orderid_id=order['id'])
         ordered = query.select()
         for drink in ordered :
            query = Query().from_table('drink').where(id=drink['drinkid_id'])
            myDrink = query.select()
            qty = drink['qty']
            priceU = myDrink[0]['price']
            priceT = (qty * priceU)
            totalAmount = totalAmount + priceT
            name = myDrink[0]['name']
            orderedDrinks = makeTicket(qty, name, priceU, priceT, orderedDrinks)
      return [totalAmount] + orderedDrinks
   else :
      raise ValueError('The token is not a valid token to print ticket !')

def payTable(token, amount) :
   if isValidToken(token) :
      myTicket = issueTicket(token)
      totalAmount = myTicket[0]
      if (amount >= totalAmount) :
         clientToken = Client.objects.get(id=token) # "Client" instance (foreign key)
         payment = Payment(amountpaid=amount, token=clientToken)
         payment.save()
         print('Thank you dear client, hope to see you soon !')
      else :
         raise ValueError('The amount should be equal or greater to amount due for that table !')
   else :
      raise ValueError('The token is not a valid token to make a payment !')
