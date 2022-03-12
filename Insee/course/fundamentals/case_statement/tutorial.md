---
title: "Structures conditionnelles"
abstract: "Tests et des structures conditionnelles dans une requete sql"
---

Dans ce tutoriel, nous allons nous découvrir des tests et des structures conditionnelles, qui permettent à un requet de 
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
- 40 à 60 est `MODERATE` 
- moins de 40 est `Cheap`.


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

En fait, nous pouvons omettre la condition de `and freight <= 60` dans la deuxième when clause. Parce que **l'analyseur 
sql traite l'instruction CASE de haut en bas, et la première condition qu'il trouve vraie est celle qu'il utilise 
(et il arrêtera d'évaluer les conditions suivantes)**. Donc, si nous avons un enregistrement avec une valeur de freight
de 83, nous pouvons être certains qu'il sera évalué comme `Expansive` . Bien qu'il soit aussi supérieur à 40, il ne 
sera pas attribué à `MODERATE` car il n'atteindra jamais à cette condition.

En conséquence, la requête ci-dessous affichera le même résultat que celui ci-dessus


```python
%%sql
select order_id, freight, 
case
   when freight > 60 then 'Expansive'
   when freight >=40 then 'MODERATE'
   else 'Cheap'
end 
as price_level
from orders
limit 5;
```

## 4.2 Grouper la sortie de l'opérateur de case

La sortie de l'opérateur de `case` peut être utilisée par l'opérateur `groupe by`, car il ne s'agit pas de résultats agrégés.
La requête ci-dessous montre un exemple sur le `groupe by` par **price_level**

```python
%%sql
select ship_via, 
case
   when freight > 60 then 'Expansive'
   when freight >=40 then 'MODERATE'
   else 'Cheap'
end 
as price_level
from orders
group by ship_via, price_level
order by ship_via
limit 5;
```

Bien que nous puissions accéder au résultat de l'opérateur case, mais dans certains serveurs de base de données 
(par exemple sqlite), l'alias "price_level" ne peut pas être utilisé comme référence dans l'opérateur `groupe by`.

**Nous ne pouvons utiliser que l'index de la position de l'opérateur case. Notez que l'index de la position commence par 1**.

Mais dans postgresql, nous pouvons utiliser les deux. Dans la requête ci-dessus, nous avons utilisé l'alias "price_level"

Dans la requête ci-dessous, nous utilisons l'index de la position dans l'opérateur groupe by. Elle doit renvoyer 
exactement le même résultat que la requête précédente


```python
%%sql
select ship_via, 
case
   when freight > 60 then 'Expansive'
   when freight >=40 then 'MODERATE'
   else 'Cheap'
end 
as price_level
from orders
group by ship_via, 2
order by ship_via
limit 5;
```

## 4.3 Utiliser la valeur de la colonne dans l'opérateur then

Dans l'exemple ci-dessus, dans l'opérateur then, nous avons toujours utilisé une valeur donnée. Nous pouvons également 
utiliser la valeur d'une colonne. Supposons que pour différentes compagnies maritimes, le taux de gain de freight est différent,
par exemple pour 
- pour compagnie 1, le taux est 0,05, 
- pour compagnie 2, le taux est 0,07, 
- pour compagnie 3, le taux est 0,08

```python
%%sql
select order_id, ship_via, freight, 
case
  when ship_via = 1 then freight*0.05
  when ship_via = 2 then freight*0.07
  when ship_via = 3 then freight*0.08
end
as gain
from orders;
```

## 4.4 L'astuce "Zero/Null" pour l'opérateur CASE

L'astuce "Zero/Null" vous permet d'appliquer différents "filtres" pour différentes valeurs agrégées dans une seule 
requête SELECT. Par exemple, si vous souhaitez agréger le gain de chaque compagnie maritime pour chaque année, 
et si vous souhaitez utiliser l'opérateur where, vous devez utiliser trois opérateurs `select`, puis utiliser deux 
jointures internes pour obtenir le résultat. La requête ci-dessous vous montre un exemple


```python
%%sql

with gain_1 as (
select extract(year from shipped_date),
sum(freight*0.05) as ship_1_gain
from orders
where ship_via=1
group by extract(year from shipped_date)),

gain_2 as (
select extract(year from shipped_date),
sum(freight*0.07) as ship_2_gain
from orders
where ship_via=2
group by extract(year from shipped_date)),

gain_3 as (
select extract(year from shipped_date),
sum(freight*0.08) as ship_3_gain
from orders
where ship_via=3
group by extract(year from shipped_date))

select g1.date_part as year, ship_1_gain, ship_2_gain, ship_3_gain 
from gain_1 as g1
join gain_2 as g2
on g1.date_part=g2.date_part
join gain_3 as g3
on g1.date_part=g3.date_part;
```

Si nous utilisons l'astuce "zéro/null", nous pouvons transformer le code ci-dessus en une requête beaucoup plus simple

```python
%%sql

select extract(year from shipped_date) as year,
sum(case when ship_via=1 then freight*0.05 else 0 end ) as ship_1_gain,
sum(case when ship_via=2 then freight*0.07 else 0 end ) as ship_2_gain,
sum(case when ship_via=3 then freight*0.08 else 0 end ) as ship_3_gain
from orders
where shipped_date is not null
group by extract(year from shipped_date);
```
Notez que cette astuce s'applique à tous les opérateurs d'agrégation tels que min, max, count, etc.

## 4.5 Combine condition booléenne dans l'opérateur CASE

Vous pouvez utiliser n'importe quelle **expression booléenne (simple/multiple) dans une instruction CASE, y compris les fonctions et les instructions AND, OR et NOT**.
La requête suivante trouvera le total des commandes expédiées pour chaque entreprise dont les commandes sont expédiées en France

```python
%%sql
select ship_via, 
count(case when (ship_via = 1) and (ship_country='France') then 1 else 0 end) as ship_1_count,
count(case when (ship_via = 2) and (ship_country='France') then 1 else 0 end) as ship_2_count,
count(case when (ship_via = 3) and (ship_country='France') then 1 else 0 end) as ship_3_count
from orders
group by ship_via;
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







