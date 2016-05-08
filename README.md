# LINGI2172-Databases
Authors Powell Jonathan & Lemaire Jérôme


Hints to connect to PostgreSQL database with default settings

$ psql -d MyDatabaseName -h localhost -p 5432 -U postgres


### Step 3 ###

Install django and django-query-builder with python3:

$ pip3 install django

$ pip3 install django-query-builder

Create first a PostgresSQL database named 'M4Step3Database'
Or use your own database but change the connection to it in 'setting.py'

Set the django settings and database:

$ python3 manage.py makemigrations TheAutomatedCafe

$ python3 manage.py migrate

Check if the database correctly set with our models in models.py:

$ python3 manage.py inspectdb

Populate (and reset) the database:
"One table is still in use by a client (no payment yet)"

$ python3 populate.py

Play the scenario

$ python3 scenario.py
