from step3 import acquireTable
from step3 import orderDrinks
from step3 import issueTicket
from step3 import payTable
from step3 import ticketToString

scannedCodeBar = 548961

token = acquireTable(scannedCodeBar)

#drinkOrdered = [{'drink':'Milk-shake', 'qty':1},{'drink':'Green Tea', 'qty':3},{'drink':'Sparkling Water', 'qty':1}]
drinkOrdered = [{'drink':'Sparkling Water', 'qty':1}]
orderDrinks(token, drinkOrdered)

ticket = issueTicket(token)

print(ticketToString(ticket))

orderDrinks(token, drinkOrdered)


amount = 3
payTable(token,amount)
