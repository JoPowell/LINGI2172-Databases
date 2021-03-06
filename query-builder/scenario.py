from step3 import acquireTable
from step3 import orderDrinks
from step3 import issueTicket
from step3 import payTable
from step3 import ticketToString

scannedCodeBar = 548961

#Acquire table with code bare 548961
token = acquireTable(scannedCodeBar)

#First sparkling order
drinkOrdered = [{'drink':'Sparkling Water', 'qty':1}]
orderDrinks(token, drinkOrdered)

# IssueTicket
ticket = issueTicket(token)

# Print ticketToString
print(ticketToString(ticket))

#Second sparkling order
orderDrinks(token, drinkOrdered)

#Pay and release table
amount = 3
payTable(token,amount)
