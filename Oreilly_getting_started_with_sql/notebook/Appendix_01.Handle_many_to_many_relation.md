# Handle Many-to-Many Relationships: 

# 1. What is a many to many relationships?

Let’s say we are creating a database for a university (which is an example I’ve used often). We capture details about students who attend classes, among other things. The rules are:

A student can be enrolled in multiple classes at a time (for example, they may have three or four classes per semester).
A class can have many students (for example, there may be 20 students in one class). This means a student has many classes, and a class has many students.

We can’t add the primary key of one table into the other, or both because this only stores a single relationship, and we need many.

We couldn’t do this:

|Student_ID|Class_ID|Student_Name|
|--------|--------|------------|
|1	|3, 5, 9	|John |
|2	|1, 4, 5, 9	|Debbie|

This would mean we have one column for storing multiple values(against 1st normal forme), which is very hard for maintenance and querying.

We also couldn’t have many columns for class ID values, as this would get messy and create a limit on the number of relationships.

|Student_ID	| Class_ID_1 |Class_ID_2 |Class_ID_3| Student_Name|
|-----------|------------|----------|----------|----------|
|1	|3	|5	|9	|John|
|2	|1	|4	|5	|Debbie|

# 2. how do we implement Many-to-Many Relationships in a data base?

We use a concept called a **joining table or a bridging table**.

**A joining table is a table that sits between the two other tables of a many-to-many relationship. Its purpose is to store a record for each of the combinations of these other two tables**. Two importate things about the joining table:
1. **columns**: Normally the joining table will have two columns which are the primary key of the two tables. (If the primary key is multiple columns, you just add the extra column accordingly.)
2. **name**: The name of the joining table is important. The simplest way is to combine the name of two table (e.g. the joining table for student and class should call student_class). But if you can have a more descriptive name, that tells user more about what the table is, use it. 


## 2.1 An example
If we retake the above example, to implement the above many-to-many relation, we can create a new table called **class_enrolment**, that stores two columns: one for each of the primary keys from the other table.

The class_enrolment table:

|Student_ID	| Class_ID |
|1	|3|
|1	|5|
|1	|9|
|2	|1|
|2	|4|
|2	|5|
|2	|9|


The Student table:

|Student_ID | Student_name |
|1 | John|
|2 | Debbie|

The Class table:

|Class_ID| Class_name|
|1	| English|
|2	|Maths|
|3	|Spanish|
|4	|Biology|
|5	|Science|
|6	|Programming|
|7	|Law|
|8	|Commerce|
|9	|Physical Education|

Having our data structure in this way makes it easier to add more relationships between tables and to update our students and classes without impacting the relationships between them.