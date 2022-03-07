---
title: "Fonctions d'agrégation, groupage"
abstract: "Grouper plusieurs lignes entre elles sur des critères précis, et calculer des expressions sur certaines colonnes particulières de ces lignes"
---

Dans ce tutoriel, nous allons nous intéresser à comment grouper plusieurs lignes, et faire d'agrégation dans une base de données.


# Connecter sur une base de données

Exécuter cette cellule pour connecter sur base de données **north_wind**. Vous devez modifier le login, pwd, db_url.

```python
%load_ext sql
%config SqlMagic.autocommit=False
%config SqlMagic.autolimit=20
%config SqlMagic.displaylimit=20
%sql postgresql://login:pwd@db_url/north_wind
```

# 3. Fonctions d'agrégation, groupage 

L'agrégation de données (également appelée windows, rolling up, summarizing, ou grouping data) crée une sorte de total à partir d'un certain nombre d'enregistrements. **Sum, min, max, count, and average** sont des opérations d'agrégation courantes. Dans SQL, vous pouvez regrouper ces totaux sur n'importe quelle colonne spécifiée, ce qui vous permet de contrôler facilement la portée de ces agrégations.


La syntaxe du select avec fonction d'agrégation


```sql
SELECT [DISTINCT] [nom_de_table.]nom_de_colonne | * | expression [AS alias_de_colonne], ...
    FROM nom_de_table [AS alias_de_table]
   [WHERE predicat]
   [GROUP  BY liste_de_colonne_a_grouper]
   [HAVING condition_sur_les_groupes]
   [ORDER  BY nom_de_colonne [ASC |  DESC], ...

```

## 3.1 Grouping records


Compter le nombre d'enregistrements dans une table est la fonction d'agrégation la plus simple et la plus courante en SQL. La requête ci-dessous compte le nombre total de commandes de commandes de table

```python
%%sql

select count(*) as order_number from orders
```

Nous pouvons également ajouter une condition pour compter le nombre d'enregistrements de certains groupes, ci-dessous la requête compte le nombre de commandes expédiées via la société 1.

```python
%%sql
select count(*) as order_number from orders where ship_via=1;
```

Mais nous avons trop d'enregistrements, que se passe-t-il si nous voulons séparer le décompte par année

```python
%%sql
select extract(year from shipped_date) as year, 
       count(*) as order_number 
from orders 
where ship_via=1 
group by extract(year from shipped_date);
```

La sortie de la requête ci-dessus devient soudainement plus parlant. Nous voyons maintenant le nombre de commandes par année. `None` signifie que certains enregistrements n'ont pas de valeur dans la colonne ship_date



### 3.1.1 Regroupement à l'aide de plusieurs colonnes

Nous pouvons regrouper les données en utilisant plusieurs colonnes. Reprenons l'exemple ci-dessus, mais cette fois nous voulons plus de précision, nous allons regrouper les données par année et par mois. Exécutez la requête ci-dessous


```python
%%sql
select extract(year from shipped_date) as year, 
       extract(month from shipped_date) as month, 
       count(*) as order_number 
from orders 
where ship_via=1 
group by extract(year from shipped_date), 
         extract(month from shipped_date);
```

Alternativement, nous pouvons utiliser des **positions ordinales au lieu des noms de colonne** dans GROUP BY. Les positions ordinales correspondent à la position numérique de chaque élément dans l'instruction SELECT. Ainsi, au lieu d'écrire **extract(year from shipped_date), extract(month from shipped_date)**, nous pourrions plutôt le faire **GROUP BY 1, 2** (remarque, **l'indice commence par 1 et non par 0** ). La requête ci-dessous est un exemple

```python
%%sql
select extract(year from shipped_date) as year, 
        extract(month from shipped_date) as month, 
        count(*) as order_number 
from orders
where ship_via=1 
group by 1, 2;
```

## 3.2 Trier les enregistrements

Notez que la colonne année et mois dans l'exemple ci-dessus n'est pas dans un ordre naturel auquel nous nous attendrions. Pour les mettre dans l'ordre, nous pouvons utiliser l'opérateur `ORDER BY`, que vous pouvez placer à la fin d'une instruction SQL après n'importe quel **WHERE** et **GROUP BY**.


Essayons d'abord de classer le résultat par mois

```python
%%sql
select extract(year from shipped_date) as year, 
       extract(month from shipped_date) as month, 
       count(*) as order_number 
from orders 
where ship_via=1 
group by 1, 2 
order by month;
```


La requête ci-dessus trie le résultat final par mois, nous pouvons remarquer que l'ordre de l'année est cassé dans le résultat. Nous devons donc d'abord trier par année puis par mois.

```python
%%sql
select extract(year from shipped_date) as year, 
extract(month from shipped_date) as month, 
count(*) as order_number 
from orders
where ship_via=1 
group by 1, 2
order by year, month
limit 5;
```

Vous pouvez remarquer que par défaut, l'ordre de tri est en ordre croissant. Si vous souhaitez plutôt trier par ordre décroissant, vous devez appliquer l'opérateur DESC au classement de l'année pour faire apparaître les enregistrements les plus récents en haut des résultats. Vérifiez la sortie de la requête ci-dessous


```python
%%sql
select extract(year from shipped_date) as year, 
     extract(month from shipped_date) as month, 
     count(*) as order_number
from orders 
where ship_via=1 
group by 1, 2 
order by year desc, month;
```

## 3.3 Fonctions d'agrégation

Nous avons déjà utilisé la fonction COUNT(*) pour compter les enregistrements. Mais il existe d'autres fonctions d'agrégation, notamment
- SUM() 
- MIN()  
- MAX()   
- AVG()

### 3.3.1 count

Si vous spécifiez une colonne au lieu d'un astérisque, il comptera le nombre de valeurs **non nulles** dans cette colonne. Par exemple, nous pouvons prendre un décompte de ship_date, qui comptera le nombre de valeurs non nulles. Comparez le résultat avec la sortie de

```sql
select count(*) as order_number from orders
```
Vous avez pu remarquer qu'ils sont différents, c'est parce que la colonne ship_data contient des valeurs nulles.

```python
%%sql
select count(shipped_date) as records_count from orders;
```

### 3.3.2 Average

La colonne freight indique le coût de la livraison. Si vous vouliez trouver le coût de livraison moyen pour chaque mois
de 1997, vous pouvez filtrer les années 1997, regrouper par mois et effectuer une moyenne sur la colonne freight



```python
%%sql
select extract(month from shipped_date) as month, 
      avg(freight) 
from orders 
where extract(year from shipped_date)=1997
group by month;
```
Vous pouvez remarquer que le résultat ci-dessus a trop de précision, vous pouvez utiliser la fonction round() pour omettre certaines précisions.

TL;DR

Le type de données d'origine de la colonne fret est réel et non flottant, nous ne pouvons donc pas utiliser round() directement dessus. Nous devons d'abord convertir real en float, puis appliquer round()

```python
%%sql
select extract(month from shipped_date) as month, 
       round(avg(freight):: numeric(16,2),2) 
from orders 
where extract(year from shipped_date)=1997 
group by month;
```

### 3.3.3 SUM

SUM() est une autre opération d'agrégation courante. Pour trouver la somme des frais de livraison de chaque mois de 
l'année 1997, exécutez la requête ci-dessous :

```python
%%sql
select extract(month from shipped_date) as month, 
       sum(freight) as total_freight 
from orders 
where extract(year from shipped_date)=1997 
group by month;
```

### 3.3.4 plusieurs fonctions d'agrégation dans une requête

Il n'y a **aucune limite quant au nombre d'opérations d'agrégation que vous pouvez utiliser dans une seule requête**.
La requête ci-dessous peut trouver le total_freight, max_freight et avg_freight pour chaque mois de l'année 1997 dans une seule requête.

```python
%%sql
select extract(month from shipped_date) as month,
sum(freight) as total_freight,
max(freight) as max_freight,
avg(freight) as avg_freight
from orders
where extract(year from shipped_date)=1997
group by month;
```

### 3.3.5 Utiliser where pour obtenir des agrégations spécifiques

Nous pouvons obtenir des agrégations très **spécifiques en tirant parti de WHERE**. Si vous vouliez le coût total de 
livraison par an de toutes les commandes expédiées par la société 1, il vous suffirait de filtrer sur ship_via=1. 
La requête ci-dessous ne comptera que les frais de livraison des commandes expédiées par la société 1.

```python
%%sql
select extract(year from shipped_date) as year,
sum(freight) as total_number1_freight
from orders
where extract(year from shipped_date)>=1996 and ship_via=1
group by year;
```

## 3.4 Le clause having

Nous pouvons utiliser **where** pour filtrer les lignes qui satisfont à certaines conditions. Mais nous ne pouvons 
pas l'utiliser pour filtrer les valeurs agrégées.

**Le fonctionnement de l'agrégation est que le serveur de DB traite ligne par ligne, trouvant ceux qu'il souhaite 
conserver en fonction de la condition WHERE. Après, il analyse les enregistrements sur GROUP BY et exécute toutes 
les fonctions d'agrégation, telles que SUM(). Si nous voulions filtrer sur la valeur SUM(), nous aurions besoin que 
le filtre ait lieu après le calcul de SUM().**

Pour filtrer la valeur agrégée, nous devons utiliser **HAVING**. HAVING est l'équivalent de WHERE pour les valeurs agrégé. 
Le mot-clé WHERE filtre les enregistrements individuels, mais HAVING filtre les agrégations.

La requête ci-dessous ne retourne que les lignes qui ont avg(freight)>30

```sql
select extract(month from shipped_date) as month,
avg(freight) as avg_freight
from orders
where extract(year from shipped_date)=1997
group by month
having avg_freight>30;
```
Notez que la requête ci-dessus ne s'exécutera pas dans postgres. Parce que **certaines plates-formes (y compris Oracle, 
Postgresql)** ne prennent pas en charge les alias dans l'instruction HAVING (tout comme GROUP BY). Cela signifie que 
vous devez spécifier à nouveau la fonction d'agrégation dans l'instruction HAVING.

Par exemple, pour exécuter la requête ci-dessus dans postgres, vous devez écrire la requête comme ci-dessous

```python
%%sql
select extract(month from shipped_date) as month,
avg(freight) as avg_freight
from orders
where extract(year from shipped_date)=1997
group by month
having avg(freight)>30;
```


## 3.5 Obtenir les enregistrements distinct

Il n'est pas rare de vouloir un ensemble de valeurs distincts à partir d'une column. Vous pouvez utiliser **distinct()** 
ou **distinct** pour obtenir des valeurs distinctes d'une colonne.

Les deux requêtes ci-dessous renvoient le même résultat.

```python 
%%sql
select distinct(customer_id) from orders limit 5;
```


```python 
%%sql
select distinct customer_id from orders limit 5;
```
 
Nous savons qu'il y a 830 enregistrements dans la table `orders`. Mais supposons que nous voulions obtenir une 
liste distincte des valeurs de customer_id, comment pouvons-nous l'obtenir ? Nous pouvons combiner la fonction 
d'agrégation avec distinct. La requête ci-dessous est un exemple

```python
%%sql
select count(distinct(customer_id)) from orders;
```

Nous pouvons appliquer l'opérateur `distinct` sur plusieurs colonnes. La requête ci-dessous est un exemple.

```python
%%sql
select distinct customer_id, ship_via from orders limit 5;
```

Mais lorsque nous appliquons distinct sur plusieurs colonnes, **nous ne pouvons plus utiliser la version distinct()**. 
Essayez la requête ci-dessous, vous remarquerez qu'elle regroupera toutes les colonnes dans () en tant qu'ensemble.

```python
%%sql
select distinct(customer_id, ship_via) from orders limit 5;
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







