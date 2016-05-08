#!/usr/bin/python2.4
#coding: utf8
#
#

import psycopg2


##################### Connection to the database #####################

try:
    conn = psycopg2.connect("dbname='base' user='postgres' host='localhost' password=''")
except:
    print ("I am unable to connect to the database")



cur = conn.cursor()


##################### Acquire table #####################

cur.callproc('AcquireTable', [635614])

token = cur.fetchone()[0]
print(token)


################# Order spakling water ##################


queryOrderOneSpaklingWater = "SELECT OrderDrinks("+str(token)+", ARRAY[('6',1)] :: orderList[]);"

queryOrderOneother = "SELECT OrderDrinks("+str(token)+", ARRAY[('4',1)] :: orderList[]);"


cur.execute(queryOrderOneSpaklingWater)
order = cur.fetchone()[0]
print'order n°{}'.format(order)


#################### Looks bill ####################

cur.callproc('IssueTicket', [token])
bill = cur.fetchall()[0]

print 'bill {0}'.format(bill)




############# Order sparkling water ##############

cur.execute(queryOrderOneSpaklingWater)
order = cur.fetchone()[0]
print('order n°{}').format(order)

cur.execute(queryOrderOneother)
order = cur.fetchone()[0]
print('order n°{}').format(order)

cur.callproc('IssueTicket', [token])
bill = cur.fetchall()[0]

amount = bill[0]
drinks = bill[1]
print 'amount {0}'.format(amount)
print 'drinks {0}'.format(drinks)




############# Pay and realese table ##############

cur.callproc('PayTable', [token, '13.23'])

conn.commit()

#####################  Close donnection to the database #####################

cur.close()
conn.close()


