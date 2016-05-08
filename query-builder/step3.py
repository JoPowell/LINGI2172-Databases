import os
os.environ['DJANGO_SETTINGS_MODULE'] = 'TheAutomatedCafe.settings'
import django
django.setup()

from querybuilder.query import Query
from querybuilder.tables import Table
from TheAutomatedCafe.models import *
from django.utils import timezone

##############
### Utils ###
##############

# Return the ticket as a string
def ticketToString(ticket) :
   totalAmount = ticket[0]
   header = '\t\t TheAutomatedCafe \t\t\n'
   drinks = 'Qty\tDrink      \t\tPrice\tTotal\n'
   iterTicket = iter(ticket)
   next(iterTicket) # Ignore totalAmount
   for bill in iterTicket :
      drink = str(bill['qty'])+'\t'+bill['name']+'\t\t'+str(bill['priceU'])+'\t'+str(bill['priceT'])+'\n'
      drinks = drinks + drink
   line ='--------------------------------------------\n'
   total = '\t\t\tTotal to pay : '+str(totalAmount)
 
   return header + drinks + line + total

# A table is free if every tokens associated with a table is found in the payment table
def freeTable(tableid) :
   # Get all client tokens associated to the table (id) and count them
   query = Query().from_table('client').where(tableid_id=tableid)
   # SELECT * FROM client WEHRE tableid_id = tableid
   client = query.select()
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

# Create the ticket for each drink ordered.
def makeTicket(qty, name, priceU, priceT, myTicket) :
   # New ticket, myTicket is null
   if not myTicket :
      myTicket.append({'qty':qty, 'name':name, 'priceU':priceU, 'priceT':priceT})
      return myTicket
   else :
      for i in range(0, len(myTicket)) :
         # The drink is already in the tickect, need to update prices
         if myTicket[i]['name'] == name and myTicket[i]['priceU'] == priceU :
            oldPriceT = myTicket[i]['priceT']
            oldQty = myTicket[i]['qty']
            myTicket[i] = {'qty':(oldQty + qty), 'name':name, 'priceU':priceU, 'priceT':(oldPriceT + priceT)}
            break
         # The drink is not in the tickect, we simply add it
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
	# SELECT * FROM tables WEHRE codebar = codeBar
	table = query.select()
	if not table:
	   raise ValueError('Invalid codebar')
	else:
	   tableID = table[0]['id']
	   isFree = freeTable(tableID)
	   # The table is free, we can issue a new token
	   if freeTable(tableID):
	      client = Client(tableid_id=tableID)
	      # INSERT INTO client (id, tableid_id) VALUES (id, tableID)
	      client.save()
	      print('Hello dear customer, please make an order.')
	      return client.id
	   # The table is not free !
	   else:
	      raise ValueError('This table is occupied, please find an other table')
   
def orderDrinks(token, newOrder): #newOrder = [{'drink':theDrink, 'qty':theQty}, ... ]
   if isValidToken(token) :
      # Save the new order
      clientToken = Client.objects.get(id=token) # "Client" instance (foreign key)
      order = Orders(ordertime = timezone.now(), token = clientToken )
      # INSERT INTO orders (ordertime, token) VALUES (id, tableID)
      order.save()
      # Save the ordered drinks
      for myOrder in newOrder :
         query = Query().from_table('drink').where(name=myOrder['drink'])
         # SELECT * FROM drink WHERE name=myOrder['drink']
         client = query.select()
         try:
            drinkID = client[0]['id']
         # Empty result for the query, no drink such that name
         except IndexError:
            raise ValueError('The drink your order for do not exist !')
         orderedDrink = Ordereddrink(orderid_id=order.id, drinkid_id=drinkID, qty=myOrder['qty'])
          # INSERT INTO ordereddrink (orderid_id, drinkid, qty) VALUES (order.id, drinkID, myOrder['qty'])
         orderedDrink.save()
      print("Your order is placed.")
      return order.id
   else :
      raise ValueError('The token is not a valid token to order drinks !')

def issueTicket(token) :  #output [totalAmount, {'qty':theQty, 'drink':theDrink, 'priceU':theUprice, 'priceT":theTprice}, ...]
   if isValidToken(token) :
      query = Query().from_table('orders').where(token_id=token)
      # SELECT * FROM orders WHERE token_id=token
      orders = query.select()
      orderedDrinks = list();
      totalAmount = 0
      # For each order id we get each drink order in ordereddrink
      for order in orders :
         query = Query().from_table('ordereddrink').where(orderid_id=order['id'])
         # SELECT * FROM ordereddrink WHERE orderid_id=order['id']
         ordered = query.select()
         for drink in ordered :
            query = Query().from_table('drink').where(id=drink['drinkid_id'])
            # SELECT * FROM drink WHERE id=drink['drinkid_id']
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
   # If token valid 
   if isValidToken(token) :
      # The Amount due is the first elem of the ticket list
      myTicket = issueTicket(token)
      totalAmount = myTicket[0]
      # Check if the payment is acceptable
      if (amount >= totalAmount) :
         clientToken = Client.objects.get(id=token) # "Client" instance (foreign key)
         payment = Payment(amountpaid=amount, token=clientToken)
         # INSERT INTO payment (amountpaid, token) VALUES (amount, clientToken)
         payment.save()
         print('Thank you dear client, hope to see you soon !')
      else :
         raise ValueError('The amount should be equal or greater to amount due for that table !')
   else :
      raise ValueError('The token is not a valid token to make a payment !')
