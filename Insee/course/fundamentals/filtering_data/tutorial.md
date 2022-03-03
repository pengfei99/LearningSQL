---
title: "Filtrer les données"
abstract: "Filtrer les données dans une base de données en utilisant sql"
---

Dans ce tutoriel, nous allons nous intéresser à comment filtrer les données dans une base de données.


# Connecter sur une base de données

Exécuter cette cellule pour connecter sur base de données **north_wind**. Vous devez modifier le login, pwd, db_url.

```python
%load_ext sql
%config SqlMagic.autocommit=False
%config SqlMagic.autolimit=20
%config SqlMagic.displaylimit=20
%sql postgresql://login:pwd@db_url/north_wind
```

# 2 Filtrer les données

Au chapitre 1, nous avons vu comment récupérer des données avec select. Maintenant, vous voudrez peut-être savoir 
comment récupérer uniquement les données qui nous intéressent, mais pas toutes les lignes. Nous pouvons utiliser 
 **where** pour filtrer les données qui satisfont à certaines conditions.

## 2.1 Filtrer les columns numeric

Pour filtrer la colonne de chiffres, nous devons créer une expression booléenne qui a la forme : <nom_colonne> <comparateur> <valeur>  

Les possibles comparateurs :

- égalité : =
- inégalité : !=, ou <>
- supérieur à : >
- inférieur à : <
- supérieur à ou égal : >=
- inférieur à ou égal : <=

La requête ci-dessous est un exemple, dans l'expression booléenne le nom de la colonne est order_date 
(nous extrayons l'année de la date), le comparateur est =, la valeur est 1996 Cette requête ne doit renvoyer que 
les enregistrements où order_date est égal à 1996

```python
%%sql
select * from orders where extract(year from order_date)=1996 limit 5
```

Que se passe-t-il si je veux obtenir tous les enregistrements où l'année n'est pas égale à 2010. Il existe deux 
manières possibles (!= ou <>) d'exprimer l'inégalité. La plupart des serveurs de base de données tels que Mysql, 
Postgresql, SQLite, etc. prennent en charge les deux. Cependant, certains serveurs de base de données tels que 
**Microsoft Access et IBM DB2 ne prennent en charge que <>**.

```python
%%sql
select * from orders where extract(year from order_date)!=1996 limit 5
```


la requête ci-dessous doit retourner le même résultat que celle ci-dessus

```python
%%sql
select * from orders where extract(year from order_date)<>1996 limit 5
```

Nous pouvons également qualifier des plages inclusives à l'aide **BETWEEN**, comme indiqué ici 
("inclusif" signifie que 1996 et 1997 sont inclus dans la plage) :

```python
%%sql
select *
from orders
where extract(year from order_date) between 1996 and 1997
limit 5
```


## 2.2 Combining multiple filtering condition


### 2.2.1 And operator

Nous pouvons exprimer la plage "between and" avec une autre expression. Par exemple, pour l'année doit être supérieure ou 
égale à 2005 et inférieure ou égale à 2010, nous pouvons utiliser deux filtres et combiner le résultat des deux 
filtres avec un **and**.

La requête ci-dessous doit renvoyer exactement le même résultat que la requête ci-dessus

```python
%%sql
select *
from orders
where extract(year from order_date) >= 1996 and extract(year from order_date)<= 1997
limit 5
```

Notez que le "between and" exprime une plage inclusive, pour une plage non inclusive, nous ne pouvons pas l'utiliser. 
De ce fait, évaluer le **and** de deux filtres devient très utile. La requête ci-dessous renvoie les commandes dont 
la date_commande > 1996 et < 1998.


```python
%%sql
select *
from orders
where extract(year from order_date) > 1996 and extract(year from order_date)< 1998
limit 5
```

### 2.2.2 Or operator

L'opérateur OR renverra l'enregistrement si au moins un des critères est vrai pour l'enregistrement. Par exemple, 
si nous ne voulions que les commandes avec les mois 3, 6, 9 ou 12, nous pouvons utiliser la requête ci-dessous :

```python
%%sql
select * from orders
where extract(month from order_date)=3
or extract(month from order_date)=6
or extract(month from order_date)=9
or extract(month from order_date)=12
limit 5;
```

### 2.2.3 In operator

Dans l'exemple ci-dessus, nous avons testé la colonne **month** avec une liste de valeurs possibles. Dans ce genre de 
situation, nous pouvons utiliser l'opérateur **in**.

```python
%%sql
select * from orders
where extract(month from order_date) in (3,6,9,12)
limit 5;
```

Nous pouvons également exprimer la négation dans l'opérateur **in** en ajoutant **not** devant l'opérateur.

```python
%%sql
select * from orders
where extract(month from order_date) not in (3,6,9,12)
limit 5;
```

### 2.2.4 Arithmetic operators

Nous pouvons remarquer que 3,6,9,12 peuvent tous être divisés par 3. Nous pouvons donc également utiliser un autre 
moyen d'obtenir les mêmes enregistrements que les exemples ci-dessus.

Notez que certaines bases de données telles que **Oracle** ne prennent pas en charge l'opérateur de **%**. Il utilise 
 la fonction MOD() à la place.

```python
%%sql
select * from orders
where cast(extract(month from order_date) as integer ) %3=0
limit 5;
```

## 2.3 Filtrage des colonnes de texte

=, AND, OR, and IN statements with text. However, when using text, you must wrap literals (or text values you specify) in single quotes.

Les règles de qualification des champs de texte suivent la même structure, bien qu'il existe des petites différences. 
Vous pouvez utiliser les instructions =, AND, OR et IN avec du texte. Cependant, lorsque vous utilisez du texte, 
vous devez placer les littéraux (ou les valeurs de texte que vous spécifiez) entre guillemets simples.

Sinon, le serveur de base de données considérera le texte sans guillemets comme nom de colonne. Même si certains 
serveurs de base de données prennent en charge les guillemets doubles, nous vous suggérons fortement d'utiliser 
toujours les guillemets simples comme bonne pratique



```python
%%sql
SELECT * FROM orders
WHERE ship_city = 'Paris'
limit 5;
```

Notez que postgresql ne prend pas en charge les guillemets doubles. Donc, la requête ci-dessous renverra une erreur 
dans postgresql. Cela fonctionne pour Mysql ou Sqlite.


```python
%%sql
SELECT * FROM orders
WHERE ship_city = "Paris"
limit 5;
```

La règle des guillemets simples s'applique à toutes les opérations de texte. Par exemple, la requête ci-dessous 
renverra une erreur, car paris n'est pas dans un **''**

```python
%%sql
SELECT * FROM orders
WHERE ship_city = Paris
limit 5;

```

Nous pouvons également utiliser la valeur de text dans d'autres opérations de filtrage. La requête ci-dessous renverra 
toutes les lignes indiquant que ship_city est Paris, Londres ou Madrid.

```python
%%sql
SELECT * FROM orders
WHERE ship_city in ('Paris','London','Madrid')
limit 5;

```

## 2.4 Autres fonctions utiles

### 2.4.1 Filtrer les text en utilisant opérateur length

L'opérateur de longueur peut obtenir la longueur d'un champ de texte. Par exemple, la requête ci-dessous filtrera 
toutes les lignes dont la longueur ship_country est <=2 (par exemple, Royaume-Uni).

```python
%%sql
SELECT * FROM orders
WHERE length(ship_country) <= 2
limit 5

```

### 2.4.2 Filtrage de texte générique avec opérateur like

Une autre opération courante consiste à utiliser des caractères génériques avec LIKE suivi d'une expression régulière, 
dans l'expression régulière :

- % : signifie n'importe quel nombre de caractères
- _ : signifie n'importe quel caractère unique.
- Tout autre caractère est interprété littéralement.

Donc, si vous vouliez trouver toutes les commandes dont ship_country commence par la lettre "C", vous exécuteriez la 
requête ci-dessous pour trouver tous les text commence par "C" et suivi de n'importe quel caractère

```python
%%sql
select * from orders
where ship_country like 'C%'
limit 5;

```

Si vous voulez trouver tout le texte qui a un "C" comme premier caractère et un "n" comme troisième caractère, vous 
pouvez exécuter la requête ci-dessous.

**Notez que le text à l'intérieur de '' est case sensitive contrairement à le text dans la requête**. Essayez de 
changer la requête ci-dessous en 'C_N' et voyez ce qui se passe.

```python
%%sql
select * from orders
where ship_country like 'C_n%'
limit 5;

```


## 2.5 Traitement de valeur null

Vous avez peut-être remarqué que dans les commandes de table, la colonne ship_region contient des valeurs nulles. 
Un null est une valeur qui n'a pas de valeur. C'est l'absence complète de tout contenu. C'est un état vide.

Dans sql, les valeurs Null ne peuvent pas être comparé avec un **=**. Vous devez utiliser les instructions **IS NULL** 
ou **IS NOT NULL** pour identifier les valeurs nulles


La requête ci-dessous renvoie toutes les lignes pour lesquelles snow_depth est null

```python
%%sql
select * from orders
where ship_region is null
limit 5;
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







