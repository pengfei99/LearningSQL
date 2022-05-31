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

## Left (outer) join

Dans certains cas, nous pouvons souhaiter joindre les tables "customers" et "orders" et voir toutes les lignes de 
clients, même si certains clients n'ont jamais passé de commande. Nous pouvons accomplir cela avec un LEFT JOIN.


### Left (outer) inclusive join

Par défaut, la **left (outer) join** est inclusive, ce qui signifie que tous les membres de la 
table de gauche sont inclus dans la table de résultats.

```python
%%sql

select order_id, c.customer_id,
order_date,
phone
from customers c
left join orders o
on c.customer_id= o.customer_id
limit 5;
```

### Left (outer) exclusive join

Il est également courant d'utiliser LEFT JOIN pour vérifier s'il y a les enregistrements "orphelins" 
qui n'ont pas de parent, ou inversement un parent qui n'a pas d'enfant (par exemple, des commandes qui n'ont pas 
de clients ou des clients qui n'ont pas de commandes).

La requête ci-dessous montre tous les clients qui n'ont aucune commande, en utilisant le filtre **order_id is null**.

Dans la table de résultat, vous pouvez remarquer que tous les champs (colonnes) provenant de la table `ORDERS` sont 
nuls, car les deux clients (e.g. PARIS et FISSA) n'ont jamais passé de commande. Par conséquent, il n'y avait pas de 
lignes correspondantes dans table `ORDERS` à joindre.

```python
%%sql

select c.customer_id, o.*
from customers c
left join orders o
on c.customer_id=o.customer_id
where order_id is null
```

### Right join
La jointure droite est similaire à la jointure gauche. Si vous inversez l'ordre des tables dans la jointure gauche, 
une jointure gauche peut simuler le comportement de la jointure droite.


Cependant, le **RIGHT JOIN est rarement utilisé et doit être évité**. Vous devez vous en tenir à la convention et 
préférer l'utilisation de LEFT JOIN, et placer la table qui contient "tous les enregistrements" sur le côté gauche 
de l'opérateur de jointure.


### Full outer join

Il existe également un opérateur de **jointure externe complète** appelé "OUTER JOIN" qui inclut tous les 
enregistrements des deux tables. Il **fait simultanément un LEFT JOIN et un RIGHT JOIN, et peut avoir des 
enregistrements nuls dans les deux tables**. Il peut être utile de rechercher simultanément des 
enregistrements orphelins dans les deux directions dans une seule requête, mais cela est également rarement 
utilisé.

## Joindre plusieurs tables

Les tables peuvent avoir des relations avec plusieurs tables. Par exemple, une table donnée 
peut être l'enfant de plusieurs tables parent, et une table peut être le parent d'une table mais 
l'enfant d'une autre.


Vérifions notre base de données, nous pouvons observer la relation entre **order_details et orders**. Et nous 
pouvons inclure une autre table **products** qui rendra order_details plus significatif. Notez que la 
table `order_details` a une colonne `order_id`, qui correspond à une commande dans la table `orders`, et une colonne `product_id`, qui correspond à un produit dans la table `products`.

La requête ci-dessous jointe les trois tables ensemble (i.e. order_details, orders, products). Notez qu'après 
l'opérateur from, nous avons deux opérateurs de jointure interne, l'ordre peut être modifié et le résultat est le même.

```python
%%sql

select od.*, o.*, p.*
FROM order_details as od
inner join orders as o on od.order_id=o.order_id
inner join products as p on od.product_id=p.product_id 
limit 5;
```

Nous avons fusionné ces trois tables, nous pouvons maintenant utiliser les champs des trois tables pour créer 
des expressions. Si nous voulons trouver le revenu pour chaque commande, nous pouvons multiplier la colonne 
`quantity` de la table `order_details` et la colonne `unit_price` de la table `products`, même si ces champs existent 
dans deux tables distinctes (qui n'ont pas de relation directe).


```python
%%sql

select od.order_id, p.product_id, od.quantity,  p.unit_price, od.quantity*p.unit_price as total_revenue
FROM order_details as od
inner join orders as o on od.order_id=o.order_id
inner join products as p on od.product_id=p.product_id 
limit 5;
```

## Regroupement dans les jointures

Dans la section ci-dessus, nous avons utilisé la jointure pour calculer les revenus de chaque commande. 
Supposons maintenant que nous voulions trouver le revenu total par client. Avec l'expérience précédente, nous 
savons que nous devons suivre les étapes suivantes :
1. rejoignez les trois tables et calculez les revenus pour chaque commande
2. grouper les revenus de chaque commande par client et agrégé tous les revenus appartiennent à meme client.

```python
%%sql

select c.customer_id,
contact_name AS customer_name,
sum(quantity*unit_price) as total_revenue
from orders as o
inner join customers as c on c.customer_id=o.customer_id
inner join order_details as od on od.order_id=o.order_id
group by c.customer_id, customer_name
limit 5;
```

Maintenant, nous voulons voir les revenus de tous les clients, même pour le client qui n'a aucune commande.

```python
%%sql

select c.customer_id,
contact_name AS customer_name,
sum(quantity*unit_price) as total_revenue
from customers as c
left join orders as o on c.customer_id=o.customer_id
left join order_details as od on od.order_id=o.order_id
group by c.customer_id, customer_name
limit 5;
```

Notez que nous avons remplacé les deux `inner join` par `left join`. Parce que si nous avons seulement changé le 
premier, la deuxième inner join exclura le client qui n'a aucune commande même si la jointure interne ne se produit 
pas directement sur les tables `customers` et `order_details`.

En effet, les valeurs nulles produites par la première left join ne peuvent pas être jointes en interne avec la table 
`order_details`. **Toutes les valeurs nulles seront toujours filtrées dans une jointure interne. Seulement LEFT JOIN 
tolère les valeurs nulles.**

Nous pouvons filtrer le client qui n'a jamais passé de commande en ajoutant un filtre `where o.order_id is null`. 

```python
%%sql

select c.customer_id,
contact_name AS customer_name,
sum(quantity*unit_price) as total_revenue
from customers as c
left join orders as o on c.customer_id=o.customer_id
left join order_details as od on od.order_id=o.order_id
where o.order_id is null
group by c.customer_id, customer_name
limit 5;
```

Essayez de modifier la deuxième left join en inner join dans la requête ci-dessus et vérifiez la sortie

### Replace null 

Supposons que nous voulions que les valeurs par défaut de `total_revenue` soient définies sur 0 au lieu de null s'il 
n'y a pas de ventes. Nous pouvons accomplir cela simplement avec la fonction coalesce() que nous avons apprise auparavant.


```python
%%sql

select c.customer_id,
contact_name AS customer_name,
coalesce(sum(quantity*unit_price),0) as total_revenue
from customers as c
left join orders as o on c.customer_id=o.customer_id
left join order_details as od on od.order_id=o.order_id
where o.order_id is null
group by c.customer_id, customer_name
limit 5;
```

## Exercices

### Questions de compréhension

- Pourquoi dit-on des listes et des tuples que ce sont des conteneurs ?


Si les réponses à ces questions ne sont pas encore claires, n'hésitez pas à revenir au tutoriel, ou bien à tester par vous-même dans une cellule.

### Exercice 

#### Q1. We have a table called Shippers in our database. Try to return all the fields from all the shippers







