from step3 import acquireTable
from step3 import orderDrinks
from step3 import issueTicket
from step3 import payTable

scannedCodeBar = 548961

token = acquireTable(scannedCodeBar)

drinkOrdered = [{'drink':'Sparkling water', 'qty':1}]
orderDrinks(token, drinkOrdered)

ticket = issueTicket(token)
print(ticket)

orderDrinks(token, drinkOrdered)

amount = 3
payTable(token,amount)
