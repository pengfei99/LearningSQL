---
title: "Structures conditionnelles"
abstract: "Tests et des structures conditionnelles dans une requete sql"
---

Dans ce tutoriel, nous allons nous découvir des tests et des structures conditionnelles, qui permettent à un requet de 
prendre des décisions de manière automatisée.

## Connecter sur une base de données

Exécuter cette cellule pour connecter sur base de données **north_wind**. Vous devez modifier le login, pwd, db_url.

```python
%load_ext sql
%config SqlMagic.autocommit=False
%config SqlMagic.autolimit=20
%config SqlMagic.displaylimit=20
%sql postgresql://login:pwd@db_url/north_wind
```


## Instruction Case

Une instruction CASE nous permet de mapper une ou plusieurs conditions à une valeur correspondante pour chaque condition. 
Vous commencez une instruction CASE par le mot cle **CASE** et vous la terminez par un mot cle **END**.

Entre les mot-clés **CASE ... END** , vous spécifiez chaque condition avec un WHEN [condition] THEN [value] , 
où la [condition] et la [value] correspondante sont fournies par vous. Après avoir spécifié les paires 
condition-valeur, vous pouvez avoir une valeur fourre-tout par défaut si aucune des conditions n'est remplie, 
qui est spécifiée avec mot-clés **ELSE**.

La requête ci-dessous est un exemple, nous catégorisons le freight dans des differents catégories, où toute
freight 
- supérieure à 60 est `Expansive` 
- 40 à 60 est « MODÉRÉE » 
- moins de 40 est « Bon marché ».


```python
%%sql
select order_id, freight, 
case
   when freight > 60 then 'Expansive'
   when freight >=40 and freight <=60 then 'MODERATE'
   else 'Cheap'
end 
as price_level
from orders
limit 5;
```

## 4.1 L'ordre est important dans la declaration de Case

In the second We can actually omit the  freight <=60 condition in the second when clause. Becaue the sql parser processes a CASE statement from top to bottom, and the first condition it finds true is the one it uses (and it will stop evaluating subsequent conditions). So if we have a record with a freight value of 83, we can be certain it will be evaluated as 'HIGH'. Although it is greater than 40, it will not be assigned 'MODERATE' because it will not get to that point.

### 1.1.1 Select specific columns

We can also give column names to retrieve data from specific columns. Below command only retrieves data of column 
product_id and quantity_per_unit.

```python
%%sql
select product_id, quantity_per_unit from products;
```

### 1.1.2 Do operations on selected columns

We can also perform operations (e.g. mathematical operators(+,-,*,/,%), text operators(||, ),sql operators(count(), 
round, etc.), etc.) on a column.

For example, suppose the tax rate of a product is 15%, below command will get not only the price, but also the tax of 
the product

```python
%%sql
select product_id, unit_price, unit_price*0.15 as tax from products;
```

Note, inside one operation, **you can not use the result that is calculated at the same level**, for example below query is wrong, because
tax is calculated at the same time of total_price. And there is no guaranty that the tax will finish before total_price. So total_price
can not use tax as input argument.

```python
%%sql

select product_id, unit_price, unit_price*0.15 as tax, unit_price+tax as total_price from products;
```

Below query will return the total_price correctly

```python
%%sql
select product_id, unit_price, unit_price*1.15 as total_price from products limit 5;
```

**Note, don't use space in column name, alias or whatever, use _ instead. Because sql consider space as delimiter of string.**

### 1.1.3 Multiple operations on selected columns

We can also combine multi operations on a column. Below query get the total price but only keeps two digits after. 
For now, you don't need to understand the **:: numeric(16,2)**. That's for type casting, because origin column 
type is real, but function round only takes float as argument. So we need to convert the type.

```python
%%sql
select product_id, unit_price, round((unit_price*1.15):: numeric(16,2),2) as total_price from products limit 5;
```

### 1.1.4 Rename output column

In the above example, the column unit_price and total_price are confusing. So we want to rename them as **UNTAXED_PRICE and TAXED_PRICE**.

```python
%%sql
select product_id, unit_price as UNTAXED_PRICE, unit_price*1.15 as TAXED_PRICE from products limit 5;
```

## 1.2 Text concatenation

We have seen arithmetic operator above, we can also apply text operator on columns. For instance, you can concatenate the address, city and country fields from the CUSTOMERS table as well as put a comma and space between them to create a LOCATION value

The **||** is the text concatenation operator, it can concatenate two string to one. Below query uses two concatenation operator to concatenate
three string (i.e. city , ', ' and country).

Note certain database server do make difference between " and ' (e.g. postgresql). Use ' if you can when you specify strings in sql statement, this can avoid many unexpected errors

```python
%%sql
select CONTACT_NAME, city || ', '|| country from customers limit 5;
```

We can concatenate as much string as you want, below example we use seven string to build a complete address.
```python
%%sql
SELECT CONTACT_NAME,
address || ', ' || city || ', '|| country AS SHIP_ADDRESS
FROM CUSTOMERS limit 5;
```


```python
%%sql

```


```python
%%sql

```
## Exercices

### Questions de compréhension

- Pourquoi dit-on des listes et des tuples que ce sont des conteneurs ?
- Quel est le point commun entre les listes et les chaînes de caractères ?
- Comment est enregistré l'ordre des éléments dans une séquence en Python ?
- Quelle est la différence fondamentale entre une liste et un tuple ?
- Dans quel cas aura-t-on plutôt intérêt à utiliser un tuple qu'une liste ?
- Peut-on avoir des éléments de types différents (ex : `int` et `string`) dans une même liste ? Dans un même tuple ?

Si les réponses à ces questions ne sont pas encore claires, n'hésitez pas à revenir au tutoriel, ou bien à tester par vous-même dans une cellule.

### Exercice 

#### Q1. We have a table called Shippers in our database. Try to return all the fields from all the shippers







