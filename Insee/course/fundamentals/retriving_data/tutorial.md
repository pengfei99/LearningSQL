---
title: "Recuperation de données"
abstract: "Recuperation de données dans un base de données en utilisant sql"
---

Dans ce tutoriel, nous allons nous intéresser à comment recuperere de données dans un base de données.

## Introduction SQL

SQL est un langage qui a été développé dans les années 60, sur les bases théoriques du `Dr Codd`, dans le but de 
dialoguer avec les grandes banques de données. Les premières versions utilisables ont été développées par IBM et 
Oracle (à l'époque Relational Software) dans les années 70. Il a été adopté comme une norme ISO en 1987, et depuis 
plusieurs révisions se sont succédées : SQL-89, SQL-92, SQL-99, SQL:2003 et SQL:2008. La version sous laquelle nous 
vivons actuellement est **SQL:2011**, adoptée en décemnbre 2011.


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
**Select** est le requete le plus utilise pour extraire des données d'une table La forme la plus simple de la commande 
select est la suivante.

```text
SELECT [DISTINCT] [nom_de_table.]nom_de_colonne | * | expression [AS alias_de_colonne], ...
    FROM nom_de_table [AS alias_de_table]
   [WHERE predicat]
   [ORDER  BY nom_de_colonne [ASC |  DESC], ...
```

Par exemple, le requete ci-dessous extraire tous les columns et lignes de table customers. Comme on a mentione avant,
sql n'est pas **case-sensitive**, so the two select will output exactly the same result

```python
%%sql
select * from customers limit 5;
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

Créez 4 listes portant les noms des 4 saisons, contenant chacune les noms des mois associés (les mois de changement de saison seront attribués à la saison précédente). Puis créez une liste `saisons` contenant les 4 listes. Essayez de prévoir ce que vont renvoyer (type de l'objet, nombre d'éléments et contenu) les instructions suivantes, puis vérifiez le. 

- `saisons`
- `saisons[0]`
- `saisons[0][0]`
- `saisons[1][-1]`
- `saisons[2][:3]`
- `saisons[1][1:2] + saisons[-1][3:]`
- `saisons[2:]`
- `saisons + saisons[0]`
- `saisons[3][::]`
- `saisons[3][::-1]`
- `saisons * 3`


```python
# Testez votre réponse dans cette cellule

```


```python
#  la solution
%load -r 3-41 solutions.py
```

### Exercice

En ajoutant, supprimant et modifiant des éléments, nettoyez la liste suivante pour qu'elle contienne les notes de musique "do re mi fa sol la si" dans le bon ordre.

`l = ["do", "re", "re", "re", "fa", "sol", "solsi", "la"]`


```python
# Testez votre réponse dans cette cellule

```


```python
# Exécuter cette cellule pour afficher la solution
%load -r 45-56 solutions.py
```

### Exercice

Proposez deux méthodes pour inverser la liste `["une", "liste", "quelconque"]`. Quelle est la différence majeure entre les deux méthodes ?


```python
# Testez votre réponse dans cette cellule

```


```python
# Exécuter cette cellule pour afficher la solution
%load -r 60-75 solutions.py
```

### Exercice

Nous avons vu que l'instruction `ma_liste.pop(i)` supprimait le i-ème élément de la liste `ma_liste`. A l'aide de la documentation Python ou d'une recherche sur Google, déterminez le comportement par défaut de cette méthode, c'est à dire ce qu'il se passe lorsqu'on ne donne aucun paramètre à la fonction `pop`. Vérifiez que vous observez bien ce comportement à l'aide d'un exemple de votre choix.


```python
# Testez votre réponse dans cette cellule

```


```python
# Exécuter cette cellule pour afficher la solution
%load -r 79-81 solutions.py
```

### Exercice

Il existe beaucoup d'autres méthodes *built-in* pour les listes que celles que nous avons déjà vues. Par exemple : `min` et `max`. Vérifiez leur comportement : 
- sur une liste composée uniquement d'objets numériques (`int` et `float`) ;
- sur une liste composée uniquement de chaînes de caractères ;
- sur une liste composée d'un mélange d'objets numériques et textuels.


```python
# Testez votre réponse dans cette cellule

```


```python
# Exécuter cette cellule pour afficher la solution
%load -r 85-91 solutions.py
```

### Exercice

Essayer de créer une liste vide. Vérifiez son type. Quel intérêt cela pourrait-il avoir ?


```python
# Testez votre réponse dans cette cellule

```


```python
# Exécuter cette cellule pour afficher la solution
%load -r 95-107 solutions.py
```

### Exercice

Dans le tutoriel, nous avons vu les fonctions `list` et `tuple` qui permettent de passer d'un type à l'autre. En réalité, le fonctionnement de ces fonctions est plus subtil : le code `list(mon_objet)` renvoie la "version liste" de cet objet, de la même manière par exemple que `str(3)` renvoie `'3'`, c'est à dire la version *string* de l'entier `3`.

A l'aide de la fonction `list`, trouver les "versions liste" des objets suivants :
- le tuple `a = (1, 2, 3)` ;
- la chaîne de caractères `b = "bonjour"` ;
- l'entier `c = 5`


```python
# Testez votre réponse dans cette cellule

```


```python
# Exécuter cette cellule pour afficher la solution
%load -r 111-125 solutions.py
```

### Exercice

Nous avons vu que les tuples avaient la particularité d'être non-modifiables. Mais est-ce que cette propriété se transfère de manière récursive ? Par exemple, est-ce qu'une liste contenue dans un tuple est-elle même non-modifiable ? Vérifiez à l'aide d'un exemple de votre choix.


```python
# Testez votre réponse dans cette cellule

```


```python
# Exécuter cette cellule pour afficher la solution
%load -r 129-134 solutions.py
```

### Exercice

Lisez la partie concernant l'agrégation et la dissociation de séquences dans la [documentation Python](https://docs.python.org/fr/3/tutorial/datastructures.html#tuples-and-sequences). La dissociation est une propriété souvent utilisée en pratique. Vérifiez qu'elle fonctionne sur les différents objets séquentiels que nous avons vus jusqu'à maintenant (chaînes de caractères, listes et tuples).


```python
# Testez votre réponse dans cette cellule

```


```python
# Exécuter cette cellule pour afficher la solution
%load -r 138-145 solutions.py
```


```python

```


# 1. Retrieving Data with SQL

## 1.1 Use select to retrieve data


