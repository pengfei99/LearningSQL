BEGIN TRANSACTION;
CREATE TABLE PRODUCT (PRODUCT_ID serial PRIMARY KEY, DESCRIPTION TEXT, PRICE DECIMAL);
INSERT INTO PRODUCT VALUES(1,'Copper',7.5099999999999997868);
INSERT INTO PRODUCT VALUES(2,'Aluminum',2.580000000000000071);
INSERT INTO PRODUCT VALUES(3,'Silver',15);
INSERT INTO PRODUCT VALUES(4,'Steel',12.310000000000000496);
INSERT INTO PRODUCT VALUES(5,'Bronze',4);
INSERT INTO PRODUCT VALUES(6,'Duralumin',7.5999999999999996447);
INSERT INTO PRODUCT VALUES(7,'Solder',14.160000000000000142);
INSERT INTO PRODUCT VALUES(8,'Stellite',13.310000000000000497);
INSERT INTO PRODUCT VALUES(9,'Brass',4.75);
CREATE TABLE CUSTOMER (CUSTOMER_ID serial PRIMARY KEY NOT NULL, NAME TEXT NOT NULL, REGION TEXT, STREET_ADDRESS TEXT, CITY TEXT, STATE TEXT, ZIP INTEGER);
INSERT INTO CUSTOMER VALUES(1,'LITE Industrial','Southwest','729 Ravine Way','Irving','TX',75014);
INSERT INTO CUSTOMER VALUES(2,'Rex Tooling Inc','Southwest','6129 Collie Blvd','Dallas','TX',75201);
INSERT INTO CUSTOMER VALUES(3,'Re-Barre Construction','Southwest','9043 Windy Dr','Irving','TX',75032);
INSERT INTO CUSTOMER VALUES(4,'Prairie Construction','Southwest','264 Long Rd','Moore','OK',62104);
INSERT INTO CUSTOMER VALUES(5,'Marsh Lane Metal Works','Southeast','9143 Marsh Ln','Avondale','LA',79782);
CREATE TABLE CUSTOMER_ORDER (ORDER_ID serial PRIMARY KEY NOT NULL, ORDER_DATE DATE NOT NULL, SHIP_DATE DATE, CUSTOMER_ID INTEGER REFERENCES CUSTOMER (CUSTOMER_ID) NOT NULL, PRODUCT_ID INTEGER REFERENCES PRODUCT (PRODUCT_ID) NOT NULL, ORDER_QTY INTEGER NOT NULL, SHIPPED BOOLEAN NOT NULL DEFAULT (0::boolean));
INSERT INTO CUSTOMER_ORDER VALUES(1,'2015-05-15','2015-05-18',1,1,450,'false');
INSERT INTO CUSTOMER_ORDER VALUES(2,'2015-05-18','2015-05-21',3,2,600,'false');
INSERT INTO CUSTOMER_ORDER VALUES(3,'2015-05-20','2015-05-23',3,5,300,'false');
INSERT INTO CUSTOMER_ORDER VALUES(4,'2015-05-18','2015-05-22',5,4,375,'false');
INSERT INTO CUSTOMER_ORDER VALUES(5,'2015-05-17','2015-05-20',3,2,500,'false');
CREATE VIEW BEHIND_SCHEDULE AS SELECT * FROM CUSTOMER_ORDER

WHERE SHIP_DATE < date('now')
AND SHIPPED = 'false';
CREATE VIEW CUSTOMER_REVENUE AS SELECT NAME, SUM(ORDER_QTY * PRICE) AS REVENUE FROM CUSTOMER INNER JOIN CUSTOMER_ORDER ON CUSTOMER.CUSTOMER_ID = CUSTOMER_ORDER.CUSTOMER_ID INNER JOIN PRODUCT ON PRODUCT.PRODUCT_ID = CUSTOMER_ORDER.PRODUCT_ID GROUP BY NAME;
COMMIT;

