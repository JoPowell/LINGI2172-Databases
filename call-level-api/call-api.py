#!/usr/bin/python2.4
#
# Small script to show PostgreSQL and Pyscopg together
#

import psycopg2


# Return the ticket as a string
def ticketToString(ticket) :
   totalAmount = ticket[0]
   header = '\n\t TheAutomatedCafe \t\t\n\n'
   drinks = 'Drink     \t\tQty\n\n'
   drinkIter = ticket[1].split(',')
   for i in range(0,len(drinkIter)) :
      if ((i % 2) == 0) : # This is a name
         name = drinkIter[i].split('(')[1]
         drinks = drinks + name + '\t\t'
      else : # This is a qty
         qty = drinkIter[i].split(')')[0]
         drinks = drinks + qty +'\n'
   line ='---------------------------------\n'
   total = '\t\tTotal to pay : '+str(totalAmount)+'\n'
 
   return header + drinks + line + total



##################### Connection to the database #####################

try:
    conn = psycopg2.connect("dbname='M4Database' user='postgres' host='localhost' password='16chalor9'")
except:
    print("I am unable to connect to the database")


cur = conn.cursor()


##################### Acquire table #####################

cur.callproc('AcquireTable', [635614])

token = cur.fetchone()[0]

################# Order spakling water ##################


queryOrderOneSpaklingWater = "SELECT OrderDrinks("+str(token)+", ARRAY[('6',1)] :: orderList[]);"
order = "SELECT OrderDrinks("+str(token)+", ARRAY[('4',1)] :: orderList[]);"

cur.execute(queryOrderOneSpaklingWater)
cur.execute(order)
order = cur.fetchone()[0]

#################### Looks bill ####################

cur.callproc('IssueTicket', [token])
bill = cur.fetchone()
print(ticketToString(bill))

############# Order sparkling water ##############

cur.execute(queryOrderOneSpaklingWater)
order = cur.fetchone()[0]

############# Pay and realese table ##############

cur.callproc('PayTable', [token, '4.23'])

conn.commit()

#####################  Close donnection to the database #####################

cur.close()
conn.close()

