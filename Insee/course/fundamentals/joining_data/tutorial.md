---
title: "Jointure de données"
abstract: "Jointure de données dans une base de données en utilisant sql"
---

Dans ce tutoriel, nous allons nous intéresser à comment joindre de données dans une base de données.

## Les relations entre les tables
Avant de parler de jointure, nous devons comprendre les relations entre les tables. Il existe trois types de relations :

- un à un : un enregistrement dans une table est lié à un enregistrement dans une autre table.
- un-à-plusieurs : un enregistrement dans une table est lié à plusieurs enregistrements dans une autre table.
- plusieurs à plusieurs : plusieurs enregistrements d'une table sont liés à plusieurs enregistrements d'une autre table.

**La gestion d'une relation un-à-un ou d'une relation un-à-plusieurs peut être effectuée en ajoutant la clé primaire 
d'une table dans l'autre table en tant que clé étrangère.** Pour réunir les deux tables, nous devons utiliser 
la jointure sur la clé primaire et la clé étrangère.

## Connecter sur une base de données

Exécuter cette cellule pour connecter sur base de données **north_wind**. Vous devez modifier le login, pwd, db_url.

```python
%load_ext sql
%config SqlMagic.autocommit=False
%config SqlMagic.autolimit=20
%config SqlMagic.displaylimit=20
%sql postgresql://login:pwd@db_url/north_wind
```

## Un example de relation un-à-plusieurs

Regardons les colonnes des tables **CUSTOMERs** et **ORDERS**, et vous remarquerez qu'il s'agit d'une relation 
un-à-plusieurs. Parce qu'un client peut avoir plusieurs commandes en cours.

```python
%%sql
SELECT * FROM CUSTOMERS LIMIT 5;
```
```python
%%sql
select * from ORDERS limit 5;
```

Vous pouvez remarquer dans la table CUSTOMERS, le customer_id est la **clé primaire**. Dans la table ORDERS, customer_id est la **clé étrangère.**

## Types de jointure

Il existe sept types de jointure courants, vous pouvez les vérifier dans la figure ci-dessous. Nous en discuterons un par un

![sql_join_type_chart](https://raw.githubusercontent.com/pengfei99/LearningSQL/main/Oreilly_getting_started_with_sql/img/sql_join_type_chart.png) 

```python
%%sql
select product_id, quantity_per_unit from products;
```

## Pourquoi normalisons-nous les données ?

Vous vous demandez peut-être pourquoi nous séparons les données dans des tableaux et les fusionnons ?

- Parce que grâce à la normalisation, nous pouvons stocker les données efficacement, pas de doublons signifie moins d'erreurs et facile à entretenir.
- Fusionnez des tables ensemble peut créer des vues plus descriptives des données. Et ça peut faciliter l'analyse des données.

## Présentation des relations entre les tables

Dans ce tutoriel, nous allons apprendre à fusionner différentes tables. En conséquence, la relation entre les tables devient importante. Ci-dessous la figure
montre la relation entre les tables dans notre base de données de test.

![northwind_schema](https://raw.githubusercontent.com/pengfei99/LearningSQL/main/SQL_practice_problems/img/northwind_schema.PNG)

## Inner join

**L'INNER JOIN nous permet de fusionner deux tables ensemble**. Mais si nous allons fusionner des tables, 
nous devons définir un point commun entre les deux afin d'aligner les enregistrements des deux tables. Autrement dit,
nous devons **identifier une ou plusieurs colonnes communes entre les deux tables**.

En général, dans une relation un-à-plusieurs, les colonnes communes sont **la clé primaire du un** et **la clé étrangère
du plusieurs**. Dans notre cas, pour la table CUSTOMERS et ORDERS, la colonne commune est **customer_id**

Imaginons que nous voulions savoir comment contacter le client qui a passé la commande par téléphone. Mais vous 
pouvez remarquer qu'il n'y a pas d'informations sur le téléphone dans la table ORDERS. Nous devons donc joindre la 
table CUSTOMERS et ORDERS pour obtenir le numéro de téléphone. La requête ci-dessous est un exemple de **Inner join.**


```python
%%sql

select order_id, customers.customer_id,
order_date,
phone
from customers
inner join orders
on customers.customer_id= orders.customer_id
limit 5;
```

Dans la requête sql ci-dessus, la première chose que vous pouvez remarquer est que nous devons utiliser une syntaxe 
explicite **customers.customer_id** ou **orders.customer_id**. Parce que cette colonne existe dans les deux tables. 
Si nous ne spécifions pas explicitement le nom de la table, le serveur de base de données ne peut pas déterminer 
quelle table doit être utilisée. Pour le nom de colonne qui n'existe que dans une seule table (par exemple, phone, order_date), 
nous n'avons pas besoin de spécifier le nom de la table.

Apres l'instruction **FROM est l'endroit où nous exécutons notre INNER JOIN**. Nous spécifions que nous tirons de la 
table `CUSTOMERS` et que nous la joignons en interne avec `ORDERS` , et que le point commun entre les deux tables se 
trouve dans la colonne `CUSTOMER_ID`.


Remarque importante : **avec INNER JOIN , tous les enregistrements qui n'ont pas de valeur jointe commune dans les 
deux tables seront exclus**. Si un client n'a pas de commande, il sera exclu de la table fusionnée.

Si nous voulons inclure tous les enregistrements de la table CUSTOMERS, nous devons utiliser un LEFT JOIN

### Alias de nom de table

The explicite table name could be very annoying if the table name is extremely long. In that case, we can use an alias 
to replace the full table name. In below query, we use `c` as alias of the table `customers`, and `o` as alias of the 
table `orders`. As a result, we can use `c.customer_id` to replace `customers.customer_id`. 


```python
%%sql

select order_id, c.customer_id,
order_date,
phone
from customers c
inner join orders o
on c.customer_id= o.customer_id
limit 5;
```

### Alias with wildcard

We can use * after a table name alias as wildcard to select all columns of a table. In below query, we use o.* to select all columns of table ORDERS


```python
%%sql

select o.*, c.*
from customers c
inner join orders o
on c.customer_id= o.customer_id
limit 5;
```

## 1.2 Left join



```python
%%sql
select CONTACT_NAME, city || ', '|| country from customers limit 5;
```



```python
%%sql

```
## Exercices

### Questions de compréhension

- Pourquoi dit-on des listes et des tuples que ce sont des conteneurs ?


Si les réponses à ces questions ne sont pas encore claires, n'hésitez pas à revenir au tutoriel, ou bien à tester par vous-même dans une cellule.

### Exercice 

#### Q1. We have a table called Shippers in our database. Try to return all the fields from all the shippers







