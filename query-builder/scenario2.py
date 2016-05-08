from step3 import acquireTable
from step3 import orderDrinks
from step3 import issueTicket
from step3 import payTable
from step3 import ticketToString

scannedCodeBar = 736894

token = acquireTable(scannedCodeBar)

drinkOrdered = [{'drink':'Milk-shake', 'qty':1},{'drink':'Green Tea', 'qty':3},{'drink':'Sparkling Water', 'qty':1}]
orderDrinks(token, drinkOrdered)

ticket = issueTicket(token)

print(ticketToString(ticket))

drinkOrdered = [{'drink':'Still Water', 'qty':1},{'drink':'Green Tea', 'qty':2},{'drink':'Beer pressure', 'qty':4}]

orderDrinks(token, drinkOrdered)

ticket = issueTicket(token)

print(ticketToString(ticket))

amount = ticket[0]
payTable(token,amount)
