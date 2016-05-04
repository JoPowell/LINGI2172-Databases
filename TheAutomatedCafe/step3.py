from querybuilder.query import Query
from django.db import connection
from django.conf import settings


query = Query().from_table('tables')
print(query.select())
print(query.get_sql())

def AcquireTable(codeBar):
   # Get the tableID coresponding to the codebar
	query = Query().from_table('tables').where(codebar=codeBar)
	table = query.select()
	tableID = table[0]['tableID']
	print(tableID)
	# Add in the client relation the table and the token
   

res = AcquireTable(548961)
