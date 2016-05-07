#!/usr/bin/python2.4
#
# Small script to show PostgreSQL and Pyscopg together
#

import psycopg2


##################### Connection to the database #####################

try:
    conn = psycopg2.connect("dbname='base' user='dbuser' host='localhost' password=''")
except:
    print "I am unable to connect to the database"


cur = conn.cursor()


##################### Acquire table #####################

cur.callproc('AcquireTable', [635614])

token = cur.fetchone()[0]
print(token)

################# Order spakling water ##################


queryOrderOneSpaklingWater = "SELECT OrderDrinks("+str(token)+", ARRAY[('6',1)] :: orderList[]);"


cur.execute(queryOrderOneSpaklingWater)
order = cur.fetchone()[0]
print('order n°')
print(order)

#################### Looks bill ####################

cur.callproc('IssueTicket', [token])
bill = cur.fetchone()[0]

print(bill)


############# Order sparkling water ##############

cur.execute(queryOrderOneSpaklingWater)
order = cur.fetchone()[0]
print('order n°')
print(order)


############# Pay and realese table ##############

cur.callproc('PayTable', [token, '3.23'])

conn.commit()

#####################  Close donnection to the database #####################

cur.close()
conn.close()


