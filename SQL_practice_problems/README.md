# SQL practice problems

## 0 Source data

In this tutorial, we will use **Northwind** as our sample database. The Northwind database is a sample database that was
originally created by Microsoft and used as the basis for their tutorials in a variety of database products for decades.
The Northwind database contains the sales data for a fictitious company called “Northwind Traders,” which imports and
exports specialty foods from around the world. The Northwind database is an excellent tutorial schema for a
small-business ERP, with customers, orders, inventory, purchasing, suppliers, shipping, employees, and single-entry
accounting. The Northwind database has since been ported to a variety of non-Microsoft databases including PostgreSQL.

Below figure shows the schema of the database 

![northwind_schema](https://raw.githubusercontent.com/pengfei99/LearningSQL/main/SQL_practice_problems/img/northwind_schema.PNG)

## 1.1 Setup database

```postgresql
-- login to postgres sever and enter below command with root
CREATE DATABASE northwind;

-- check the created database
\l

-- Switch to the Northwind database.
\c northwind

-- create custom account
create user pliu with encrypted password 'northwind';

-- grant access of northwind db to user pliu
grant all privileges on database northwind to pliu;

-- List users and their roles
\du
```

## 1.2 Load data

Go to path/to/database then run below commands

```shell
# this will create all the tables with corresponding schema 
psql -U pliu northwind < northwind_ddl.sql

# this will populate table with actual data
psql -U pliu northwind < northwind_data.sql

# connect to the db
psql -U pliu -h localhost -p 5432 -d northwind

```

## 1.3 Check the database

```postgresql
-- connect to db northwind
\c northwind

-- show all available tables in the db, d stands for display
\dt

-- List available schema
\dn

-- describe a table such as a column, type
\d table_name

-- List available views
\dv

-- show data of a table
select *
from shippers
limit 5;
```

# 2. Use client to connect to the database

There are many ways to connect to a database by using python. Based on your target database, the **python db API**
engine should be chosen carefully. Here is a list that I recommend:

- Microsoft SQL Server : pyodbc
- Oracle MySQL : mysqlclient
- Oracle : cx_Oracle
- PostgreSQL : psycopg2

**SQLAlchemy** is a toolkit that resides one level higher than the python db API. In another word, your code in
SQLAlchemy will be parsed, then executed by the python db API. The advantage is that you write the same logic for any
database that has a python db API which can be used by SQLAlchemy. SQLAlchemy also provides a variety of features:

- Object-relational mapping (ORM)
- Query constructions
- Caching
- Eager loading
- ETC.

**SQLAlchemy** can use any other driver that supports **python database API 2.0**, note the above four
(e.g. pyodbc, psycopg2, etc.) all implements python database API 2.0.

As in this tutorial, we use a postgresql server, below we only show how to connect to a postgresql server via python.

## 2.1 Using psycopg2

### 2.1.1 Installing psycopg2

#### Compile the package via source

Note if you do "pip install psycopg2" this will try to download the source and compile it, so it requires some system
dependencies (postgresql development tool package) to compile the source. You need to install below system requirements
to be able to compile it

```shell
# for ubuntu
sudo apt install libpq-dev python3-dev

# for centos 7
# You need to change the name based on your postgres server version, below example use postgres 11
$ sudo yum install postgresql11-devel
```

#### Install the binary version

```shell
pip install psycopg2-binary
```

## 2.2 Using SQLAlchemy

### 2.2.1 Install SQLAlchemy

```shell
pip install sqlalchemy
```

### 2.2.2 Connect to a database

As I explained before, SQLAlchemy can connect to various databases. Below are some examples:

- PostgreSQL: postgresql://<login>:<pwd>@<host>:<port>/<db_name>
  example: postgresql://scott:tiger@localhost/mydatabase

- MySQL: mysql://<login>:<pwd>@<host>:<port>/<db_name>
  example: mysql://scott:tiger@localhost/foo

- Oracle: oracle://<login>:<pwd>@<host>:<port>/<db_name>
  example oracle://scott:tiger@127.0.0.1:1521/sidname

- SQL Server: mssql+pyodbc://scott:tiger@mydsn

- SQLite: sqlite:///<path_to_sqlite_db>
  example: sqlite:///foo.db

## 2.3 Jupyter SQL magic function
Magic functions are pre-defined functions(“magics”) in Jupyter kernel that executes supplied commands. In our case, we 
use ipython-sql magic function. Jupyter magic functions allow you to replace a boilerplate code snippets with more
concise one. You can compare the below example with above code to see the difference.


**Note the sql magic function is only wrapper that calls SQLAlchemy to run the sql queries, without the underlying SQLAlchemy
it will not work. Thus if the database is supported by SQLAlchemy, then we can use the magic function to query it.** 
For instance, we can use it to connect to a trino, presto, etc.

There are two kinds of magics 
- line-oriented : prefaced with %
  
- cell-oriented prefaced with %%. 

### 2.3.1 Install ipython-sql
```shell
pip install ipython-sql
```

### configure ipython-sql

1. Load the ipython-sql library, 
   
```jupyter
%load_ext sql
%config SqlMagic.autocommit=False # for engines that do not support autommit
```

2. Pass connection string in SQLAlchemy format to the %sql function

```jupyter
%sql postgresql://pliu:northwind@127.0.0.1:5432/northwind
```

If connection string is not provided and connection has not been made yet, ipython-sql tries to get connection 
information from **DATABASE_URL** environment variable. You can export environment variable DATABASE_URL in ~/.bashrc 
in case your connection information is static. **%env** is another magic function that sets environment variables.

```jupyter
%env DATABASE_URL=postgresql://pliu:northwind@127.0.0.1:5432/northwind
```
### Multiple SQL engines
In case of multiple SQL engines, and you want to combine data from them you can pass connection string with 
each query of the magic function in cell-mode. It means the below sql connection only works for the code inside the cell

```jupyter
%%sql presto://user@localhost:8080/system
```

#Appendix Other interesting thing to read

Pandasql: Use pure sql to work with pandas data frame
https://www.analyticsvidhya.com/blog/2021/07/pandasql-best-way-to-run-sql-queries-and-codes-in-jupyter-notebook-using-python/