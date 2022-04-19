---
title: "Recuperation de données"
abstract: "Recuperation de données dans une base de données en utilisant sql"
---

Dans ce tutoriel, nous allons nous intéresser à comment recupere de données dans une base de données.

## Introduction SQL

SQL est un langage qui a été développé dans les années 60, sur les bases théoriques du `Dr Codd`, dans le but de 
dialoguer avec les grandes banques de données. Les premières versions utilisables ont été développées par IBM et 
Oracle (à l'époque Relational Software) dans les années 70. Il a été adopté comme une norme ISO en 1987, et depuis 
plusieurs révisions se sont succédées : SQL-89, SQL-92, SQL-99, SQL:2003 et SQL:2008. La version sous laquelle nous 
vivons actuellement est **SQL:2011**, adoptée en décembre 2011.


Malgré les efforts de standardisation, les différents serveurs des bases de données ont développé leur propre SQL.
Ces différences peuvent apparaître à trois niveaux :

- Le serveur ne supporte pas certaines fonctionnalités, et les instructions SQL correspondantes n’ont pas été implémentées ;

- Les types de données ne correspondent pas toujours en syntaxe d’un serveur à l’autre, ou certains serveurs supportent des types de données différents, ou encore ont leur propre syntaxe de déclaration (c'est notamment le cas pour les dates) ;

- Certaines fonctions n’ont tout simplement pas la même syntaxe d'un serveur à l'autre.

**SQL n'est pas case sensitive, donc vous pouvez ignore la majuscule et miniscule**

### Connecter sur une base de données

Exécuter cette cellule pour connecter sur base de données **north_wind**. Vous devez modifier le login, pwd, db_url.

```python
%load_ext sql
%config SqlMagic.autocommit=False
%config SqlMagic.autolimit=20
%config SqlMagic.displaylimit=20
%sql postgresql://login:pwd@db_url/north_wind
```

## Extraire des données 
**Select** est la requête, le plus utilise pour extraire des données d'une table La forme la plus simple de la commande 
select est la suivante.

```text
SELECT [DISTINCT] [nom_de_table.]nom_de_colonne | * | expression [AS alias_de_colonne], ...
    FROM nom_de_table [AS alias_de_table]
   [WHERE predicat]
   [ORDER  BY nom_de_colonne [ASC |  DESC], ...
```

Par exemple, la requête ci-dessous extraire tous les columns et lignes de table customers. Comme nous avons mentionné avant,
sql n'est pas **case-sensitive**, donc les deux requêtes devent retourne exactement la meme réponse.

Dans la requête, le "*" signifie tous les columns et **customers** est le nom de table que nous voulons interroger.

```python
%%sql
select * from customers limit 5;
```

```python
%%sql
SELECT * FROM CUSTOMERS LIMIT 5;
```

Essayer de récupérer le contenu de la table produits

```python
%%sql


```

### 1.1.1 Sélectionner des colonnes spécifiques

Nous pouvons également donner des noms de colonne pour récupérer des données à partir de colonnes spécifiques. 
La commande ci-dessous ne récupère que les données de la colonne product_id et quantity_per_unit.

```python
%%sql
select product_id, quantity_per_unit from products;
```

### 1.1.2 Effectuer des opérations sur les colonnes sélectionnées

Nous pouvons également effectuer des opérations (e.g. des opérateurs mathématiques (+, -,*,/,%), 
des opérateurs de texte (||, ), des opérateurs SQL (count(),
ronde, etc.), etc.) sur une colonne.

Par exemple, supposons que le taux de taxe d'un produit est de 15 %, la commande ci-dessous obtiendra non seulement le 
prix, mais également la taxe du produit

```python
%%sql
select product_id, unit_price, unit_price*0.15 as tax from products;
```

Notez qu'à l'intérieur d'une opération, **vous ne pouvez pas utiliser le résultat qui est calculé au même niveau**. 
Par exemple, la requête ci-dessous est erronée, car tax est calculé en même temps que total_price. Et il n'y a aucune 
garantie que le calcul de taxe se terminera avant total_price. Donc total_price ne peut pas utiliser la taxe comme 
argument d'entrée.

```python
%%sql

select product_id, unit_price, unit_price*0.15 as tax, unit_price+tax as total_price from products;
```

La requête ci-dessous renverra correctement le resultat de total_price

```python
%%sql
select product_id, unit_price, unit_price*1.15 as total_price from products limit 5;
```

**Remarque, n'utilisez pas d'espace dans le nom de la colonne, l'alias ou quoi que ce soit, utilisez _ à la place. Parce que sql considère l'espace comme délimiteur de string.**

### 1.1.3 Opérations multiples sur les colonnes sélectionnées

Nous pouvons également combiner plusieurs opérations sur une colonne. La requête ci-dessous obtient le prix total, 
mais ne conserve que deux chiffres après la virgule. Pour l'instant, vous n'avez pas besoin de comprendre **:: numeric(16,2)**.
C'est pour la conversion de type, car le type de la colonne d'origine est réel, mais la fonction round ne prend que 
float comme argument. Nous devons donc convertir le type.


```python
%%sql
select product_id, unit_price, round((unit_price*1.15):: numeric(16,2),2) as total_price from products limit 5;
```

### 1.1.4 Renommer la colonne de sortie

Dans l'exemple ci-dessus, les colonnes unit_price et total_price prêtent à confusion. Nous voulons donc les renommer en **UNTAXED_PRICE et TAXED_PRICE**.

```python
%%sql
select product_id, unit_price as UNTAXED_PRICE, unit_price*1.15 as TAXED_PRICE from products limit 5;
```

## 1.2 Concaténation de texte

Nous avons vu l'opérateur arithmétique ci-dessus, nous pouvons également appliquer l'opérateur de texte sur les colonnes.

Par exemple, vous pouvez concaténer les champs CONTACT_NAME, city et country de la table CUSTOMERS ainsi que mettre 
une virgule et un espace entre eux pour créer une valeur LOCATION

Le **||** est l'opérateur de concaténation de texte, il peut concaténer deux string à une. La requête ci-dessous utilise 
deux opérateurs de concaténation pour concaténer trois string (c'est-à-dire ville , ', ' et pays).

Notez que certains serveurs de base de données font la différence entre " et ' (par exemple, postgresql). 
Utilisez ' si vous le pouvez lorsque vous spécifiez des string dans l'instruction sql, cela peut éviter de nombreuses erreurs inattendues

```python
%%sql
select CONTACT_NAME, city || ', '|| country from customers limit 5;
```

Nous pouvons concaténer autant de chaînes que vous le souhaitez. Dans l'exemple ci-dessous, nous utilisons sept string pour créer une adresse complète.
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


Si les réponses à ces questions ne sont pas encore claires, n'hésitez pas à revenir au tutoriel, ou bien à tester par vous-même dans une cellule.

### Exercice 

#### Q1. We have a table called Shippers in our database. Try to return all the fields from all the shippers







