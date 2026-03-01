SELECT *FROM PASSENGER;
SELECT *FROM FLIGHT;
SELECT *FROM TICKET;
SELECT *FROM PAYMENT;
SELECT *FROM AIRPORT; 
SELECT *FROM STAFF;
SELECT *FROM LUGGAGE;
SELECT *FROM FLIGHT_DEPARTURES;
SELECT *FROM PHONE_NUMBER;
SELECT *FROM PREFERENCES;
SELECT *FROM SERVICE;

SELECT ticket_id, flight_id FROM ticket WHERE flight_id = 'FL0000001';


desc flight;

--------------------------
-- CREATING AIRPORT TABLE
--------------------------
CREATE TABLE airport (
  airport_id    CHAR(6)        NOT NULL,
  airport_name  VARCHAR2(50)   NOT NULL,
  iata_code     CHAR(3)        NOT NULL,
  country       VARCHAR2(30)   NOT NULL,
  city          VARCHAR2(30)   NOT NULL,
  time_zone     VARCHAR2(50)   NOT NULL,
  CONSTRAINT airport_pk PRIMARY KEY (airport_id)
);
--------------------------
-- CREATING FLIGHT TABLE
--------------------------
CREATE TABLE flight (
  flight_id      CHAR(9)        NOT NULL,
  airline        VARCHAR2(50)   NOT NULL,
  departure_time DATE           NOT NULL,
  arrival_time   DATE           NOT NULL,
  duration       NUMBER
    GENERATED ALWAYS AS ((arrival_time - departure_time) * 24)
    VIRTUAL,
  aircraft_model VARCHAR2(25)   NOT NULL,
  status         VARCHAR2(25)   NOT NULL,
  CONSTRAINT flight_pk PRIMARY KEY (flight_id)
);
--------------------------
-- CREATING PASSENGER TABLE
--------------------------
CREATE TABLE passenger (
  passenger_id         CHAR(9)      NOT NULL,
  passport_no          CHAR(7)      NOT NULL,
  first_name           VARCHAR2(30) NOT NULL,
  middle_name_initial  CHAR(1)      NOT NULL,
  last_name            VARCHAR2(30) NOT NULL,
  date_of_birth        DATE         NOT NULL,
  gender               VARCHAR2(10) NOT NULL,
  nationality          VARCHAR2(30) NOT NULL,
  address_street       VARCHAR2(50),
  address_city         VARCHAR2(30),
  address_zip          CHAR(5),
  email                VARCHAR2(50) NOT NULL,
  CONSTRAINT passenger_pk PRIMARY KEY (passenger_id)
);
---------------------------------------------
-- CREATING VIRTUAL VIEW WITH PASSENGER'S AGE
---------------------------------------------
CREATE OR REPLACE VIEW passenger_with_age AS
SELECT
  p.*,
  TRUNC(MONTHS_BETWEEN(SYSDATE, p.date_of_birth)/12) AS age
FROM passenger p;
-----------------------------------
-- RETRIEVIN PASSENGER (FN, LN, AGE)
-----------------------------------
SELECT first_name, last_name, age
FROM passenger_with_age;
--------------------------
-- CREATING TICKET TABLE
--------------------------
CREATE TABLE ticket (
  ticket_id      CHAR(8)       NOT NULL,
  class          VARCHAR2(25)  NOT NULL,
  ticket_date    DATE          NOT NULL,
  ticket_time    DATE          NOT NULL,
  price          NUMBER(7,2)   NOT NULL,
  seat_number    VARCHAR2(4)   NOT NULL,
  gate           VARCHAR2(5)   NOT NULL,
  boarding_time  DATE          NOT NULL,
  passenger_id   CHAR(9)       NOT NULL,
  flight_id      CHAR(9)       NOT NULL,
  payment_id     CHAR(12),
  CONSTRAINT ticket_pk           PRIMARY KEY (ticket_id),
  CONSTRAINT uq_ticket_payment   UNIQUE (payment_id),
  CONSTRAINT fk_ticket_passenger FOREIGN KEY (passenger_id)
    REFERENCES passenger (passenger_id),
  CONSTRAINT fk_ticket_flight    FOREIGN KEY (flight_id)
    REFERENCES flight (flight_id)
);
--------------------------
-- CREATING PAYMENT TABLE
--------------------------
CREATE TABLE payment (
  payment_id      CHAR(12)      NOT NULL,
  amount          NUMBER(7,2)   NOT NULL,
  method          VARCHAR2(25)  NOT NULL,
  date_of_payment DATE          NOT NULL,
  ticket_id       CHAR(8)       NOT NULL,
  CONSTRAINT payment_pk         PRIMARY KEY (payment_id),
  CONSTRAINT uq_payment_ticket  UNIQUE (ticket_id),
  CONSTRAINT fk_payment_ticket  FOREIGN KEY (ticket_id)
    REFERENCES ticket (ticket_id)
);
------------------------------
-- CREATING PHONE_NUMBER TABLE
------------------------------
CREATE TABLE phone_number (
  passenger_id CHAR(9)      NOT NULL,
  phone_number VARCHAR2(15) NOT NULL,
  CONSTRAINT phone_number_pk    PRIMARY KEY (passenger_id, phone_number),
  CONSTRAINT fk_phone_passenger FOREIGN KEY (passenger_id)
    REFERENCES passenger (passenger_id)
);
------------------------------
-- CREATING PREFERENCES TABLE
------------------------------
CREATE TABLE preferences (
  passenger_id CHAR(9)      NOT NULL,
  preference   VARCHAR2(30) NOT NULL,
  CONSTRAINT preferences_pk     PRIMARY KEY (passenger_id, preference),
  CONSTRAINT fk_pref_passenger  FOREIGN KEY (passenger_id)
    REFERENCES passenger (passenger_id)
);
------------------------
-- CREATING STAFF TABLE
------------------------
CREATE TABLE staff (
  staff_id         CHAR(9)      NOT NULL,
  first_name       VARCHAR2(30) NOT NULL,
  last_name        VARCHAR2(30) NOT NULL,
  email            VARCHAR2(50) NOT NULL,
  phone            VARCHAR2(15) NOT NULL,
  role             VARCHAR2(30) NOT NULL,
  flight_id        CHAR(9)      NOT NULL,
  CONSTRAINT staff_pk        PRIMARY KEY (staff_id),
  CONSTRAINT fk_staff_flight FOREIGN KEY (flight_id)
    REFERENCES flight (flight_id)
);
-----------------------------------
-- CREATING FLIGHT_DEPARTURES TABLE
-----------------------------------
CREATE TABLE flight_departures (
  airport_id CHAR(6)  NOT NULL,
  flight_id  CHAR(9)  NOT NULL,
  CONSTRAINT flight_departures_pk PRIMARY KEY (airport_id, flight_id),
  CONSTRAINT fk_fd_airport        FOREIGN KEY (airport_id)
    REFERENCES airport (airport_id),
  CONSTRAINT fk_fd_flight         FOREIGN KEY (flight_id)
    REFERENCES flight (flight_id)
);
-------------------------
-- CREATING LUGGAGE TABLE
-------------------------
CREATE TABLE luggage (
  luggage_id    CHAR(9)       NOT NULL,
  ticket_id     CHAR(8)       NOT NULL,
  passenger_id  CHAR(9)       NOT NULL,
  tag_number    CHAR(16)      NOT NULL,
  weight        NUMBER(5,2)   NOT NULL,
  type          VARCHAR2(25)  NOT NULL,
  color         VARCHAR2(25)  NOT NULL,
  is_fragile    CHAR(1)       NOT NULL,
  is_overweight CHAR(1)       NOT NULL,
  status        VARCHAR2(25)  NOT NULL,
  CONSTRAINT luggage_pk         PRIMARY KEY (luggage_id),
  CONSTRAINT fk_lug_ticket      FOREIGN KEY (ticket_id)
    REFERENCES ticket (ticket_id),
  CONSTRAINT fk_lug_passenger   FOREIGN KEY (passenger_id)
    REFERENCES passenger (passenger_id)
);

ALTER TABLE luggage
DROP CONSTRAINT luggage_pk;

ALTER TABLE luggage
ADD CONSTRAINT pk_luggage
PRIMARY KEY (luggage_id, ticket_id);


-------------------------
-- CREATING SERVICE TABLE
-------------------------
CREATE TABLE service (
  passenger_id CHAR(9)      NOT NULL,
  flight_id    CHAR(9)      NOT NULL,
  staff_id     CHAR(9)      NOT NULL,
  service_type VARCHAR2(30) NOT NULL,
  service_time DATE         NOT NULL,
  CONSTRAINT service_pk PRIMARY KEY (passenger_id, flight_id, staff_id),
  CONSTRAINT fk_service_passenger FOREIGN KEY (passenger_id)
    REFERENCES passenger (passenger_id),
  CONSTRAINT fk_service_flight    FOREIGN KEY (flight_id)
    REFERENCES flight (flight_id),
  CONSTRAINT fk_service_staff     FOREIGN KEY (staff_id)
    REFERENCES staff (staff_id)
);


-----------------------------
-- INSERTING INTO AIRPORT TABLE
-----------------------------
INSERT INTO airport VALUES
  ('AP0001','Dubai International','DXB','United Arab Emirates','Dubai','Asia/Dubai');
INSERT INTO airport VALUES
  ('AP0002','Heathrow Airport','LHR','United Kingdom','London','Europe/London');
-----------------------------
-- INSERTING INTO FLIGHT TABLE
-----------------------------  
INSERT INTO flight (flight_id, airline, departure_time, arrival_time, aircraft_model, status) VALUES
  ('FL0000001','Emirates', TO_DATE('2025-05-01 08:00','YYYY-MM-DD HH24:MI'),
                  TO_DATE('2025-05-01 12:00','YYYY-MM-DD HH24:MI'),
                  'Boeing 777','Scheduled');
INSERT INTO flight (flight_id, airline, departure_time, arrival_time, aircraft_model, status) VALUES
  ('FL0000002','British Airways', TO_DATE('2025-05-02 09:00','YYYY-MM-DD HH24:MI'),
                         TO_DATE('2025-05-02 19:00','YYYY-MM-DD HH24:MI'),
                         'Airbus A380','Scheduled');
---------------------------------
-- INSERTING INTO PASSENGER TABLE --> ONE MORE DATA IS NEEDED!
---------------------------------
INSERT INTO passenger (passenger_id, passport_no, first_name, middle_name_initial, last_name,
                       date_of_birth, gender, nationality, address_street, address_city, address_zip, email) VALUES
  ('PA0000001','A123456','Alice','B','Smith',
   TO_DATE('1995-01-15','YYYY-MM-DD'),'Female','American',
   '123 Main St','New York','10001','alice.smith@example.com');
---------------------------------
-- INSERTING INTO TICKET TABLE --> ONE MORE DATA IS NEEDED!
---------------------------------
INSERT INTO ticket (ticket_id, class, ticket_date, ticket_time, price,
                    seat_number, gate, boarding_time, passenger_id, flight_id, payment_id) VALUES
  ('TK000001','Economy',TO_DATE('2025-04-20','YYYY-MM-DD'),
   TO_DATE('2025-04-20 15:30','YYYY-MM-DD HH24:MI'),1200.50,
   '12A','A1',TO_DATE('2025-05-01 07:30','YYYY-MM-DD HH24:MI'),
   'PA0000001','FL0000001','PMT000000001');
---------------------------------
-- INSERTING INTO PAYMENT TABLE --> ONE MORE DATA IS NEEDED!
---------------------------------
INSERT INTO payment VALUES
  ('PMT000000001',1200.50,'Credit Card',TO_DATE('2025-04-20','YYYY-MM-DD'),'TK000001');
-----------------------------------
-- INSERTING INTO PHONE_NUMBER TABLE --> ONE MORE DATA IS NEEDED!
-----------------------------------
INSERT INTO phone_number VALUES ('PA0000001','+971501234567');
-----------------------------------
-- INSERTING INTO PREFERENCES TABLE 
-----------------------------------
INSERT INTO preferences  VALUES ('PA0000001','Vegetarian');
INSERT INTO preferences  VALUES('PA0000001','Window Seat');
-----------------------------
-- INSERTING INTO STAFF TABLE 
-----------------------------
INSERT INTO staff VALUES
  ('ST0000001','John','Doe','john.doe@emirates.com','+971509876543','Pilot','FL0000001');
INSERT INTO staff VALUES
  ('ST0000002','Jane','Doe','jane.doe@emirates.com','+971509876544','Attendant','FL0000001');
-----------------------------------------
-- INSERTING INTO FLIGHT_DEPARTURES TABLE 
-----------------------------------------
INSERT INTO flight_departures VALUES
  ('AP0001','FL0000001');
INSERT INTO flight_departures VALUES
  ('AP0002','FL0000002');
-------------------------------
-- INSERTING INTO LUGGAGE TABLE 
-------------------------------
INSERT INTO luggage VALUES
  ('LG0000001','TK000001','PA0000001','TAG000000000001',23.5,'Checked','Black','N','N','Loaded');
INSERT INTO luggage VALUES
  ('LG0000002','TK000001','PA0000001','TAG000000000002',8.0 ,'Carry-on','Red','N','N','In Transit');
-----------------------------------
-- INSERTING INTO SERVICE TABLE --> ONE MORE DATA IS NEEDED!
-----------------------------------
INSERT INTO service VALUES
  ('PA0000001','FL0000001','ST0000002','Meal Delivery',TO_DATE('2025-05-01 09:30','YYYY-MM-DD HH24:MI'));
  
  
-----------------------------------------------
-- INSERT + UPDATE + DELETE INTO AIRPORT TABLE 
-----------------------------------------------
INSERT INTO airport VALUES 
    ('AP0003','Changi Airport','SIN','Singapore','Singapore','Asia/Singapore');
UPDATE airport
  SET city = 'Singapore City'
  WHERE airport_id = 'AP0003';
DELETE FROM airport
  WHERE airport_id = 'AP0003';
-----------------------------------------------
-- INSERT + UPDATE + DELETE INTO FLIGHT TABLE 
-----------------------------------------------
ALTER TABLE flight
  DROP COLUMN duration;
ALTER TABLE flight
  ADD (
    duration NUMBER
      GENERATED ALWAYS AS ((arrival_time - departure_time) * 24)
      VIRTUAL
  );
INSERT INTO flight
  (flight_id, airline, departure_time, arrival_time, aircraft_model, status)
    VALUES
    ('FL0000003', 'Qantas',
        TO_DATE('2025-05-10 14:00','YYYY-MM-DD HH24:MI'),
        TO_DATE('2025-05-10 22:00','YYYY-MM-DD HH24:MI'),
        'Boeing 787','Scheduled');
UPDATE flight
  SET status = 'Delayed'
  WHERE flight_id = 'FL0000003';
DELETE FROM flight
  WHERE flight_id = 'FL0000003';
-------------------------------------------------
-- INSERT + UPDATE + DELETE INTO PASSENGER TABLE 
-------------------------------------------------
ALTER TABLE passenger
  MODIFY (address_zip VARCHAR2(10));
INSERT INTO passenger (
  passenger_id, passport_no, first_name, middle_name_initial,
  last_name, date_of_birth, gender, nationality,
  address_street, address_city, address_zip, email
) VALUES (
  'PA0000002','B765432','Bob','C','Jones',
  TO_DATE('1990-07-20','YYYY-MM-DD'),'Male','British',
  '456 Elm St','London','SW1A1AA','bob.jones@example.co.uk'
);
UPDATE passenger
   SET address_city = 'London Borough'
 WHERE passenger_id = 'PA0000002';

DELETE FROM passenger
  WHERE passenger_id = 'PA0000002';
-------------------------------------------------
-- INSERT + UPDATE + DELETE INTO PAYMENT TABLE 
-------------------------------------------------
INSERT INTO flight
  (flight_id, airline, departure_time, arrival_time, aircraft_model, status)
VALUES
  ('FL0000003', 'Qantas',
   TO_DATE('2025-05-10 14:00','YYYY-MM-DD HH24:MI'),
   TO_DATE('2025-05-10 22:00','YYYY-MM-DD HH24:MI'),
   'Boeing 787','Scheduled');
INSERT INTO passenger
  (passenger_id, passport_no, first_name, middle_name_initial, last_name,
   date_of_birth, gender, nationality, address_street, address_city, address_zip, email)
VALUES
  ('PA0000002','B765432','Bob','C','Jones',
   TO_DATE('1990-07-20','YYYY-MM-DD'),'Male','British',
   '456 Elm St','London Borough','SW1A1AA','bob.jones@example.co.uk');
INSERT INTO ticket
  (ticket_id, class, ticket_date, ticket_time,
   price, seat_number, gate, boarding_time,
   passenger_id, flight_id, payment_id)
VALUES
  ('TK000002','Business',
   TO_DATE('2025-05-01','YYYY-MM-DD'),
   TO_DATE('2025-05-01 10:00','YYYY-MM-DD HH24:MI'),
   2500.00,'2B','B2',
   TO_DATE('2025-05-01 09:30','YYYY-MM-DD HH24:MI'),
   'PA0000002','FL0000003','PMT000000002');
INSERT INTO payment
  (payment_id, amount, method, date_of_payment, ticket_id)
VALUES
  ('PMT000000002',2500.00,'Cash',
   TO_DATE('2025-05-01','YYYY-MM-DD'),
   'TK000002');

UPDATE payment
   SET method = 'Debit Card'
 WHERE payment_id = 'PMT000000002';

DELETE FROM payment
 WHERE payment_id = 'PMT000000002';

DELETE FROM ticket
 WHERE ticket_id = 'TK000002';

DELETE FROM passenger
 WHERE passenger_id = 'PA0000002';

COMMIT;
---------------------------------------------------
-- INSERT + UPDATE + DELETE INTO PHONE_NUMBER TABLE 
---------------------------------------------------
INSERT INTO phone_number VALUES ('PA0000001','+971501112233');
UPDATE phone_number
  SET phone_number = '+971501445566'
  WHERE passenger_id='PA0000001' AND phone_number='+971501112233';
DELETE FROM phone_number
  WHERE passenger_id='PA0000001' AND phone_number='+971501445566';
---------------------------------------------------
-- INSERT + UPDATE + DELETE INTO PREFERENCES TABLE 
---------------------------------------------------
INSERT INTO preferences VALUES ('PA0000001','Aisle Seat');
UPDATE preferences
  SET preference = 'Quiet Zone'
  WHERE passenger_id='PA0000001' AND preference='Aisle Seat';
DELETE FROM preferences
  WHERE passenger_id='PA0000001' AND preference='Quiet Zone';
---------------------------------------------------
-- INSERT + UPDATE + DELETE INTO STAFF TABLE 
---------------------------------------------------
INSERT INTO staff VALUES ('ST0000003','Ahmed','Ali','ahmed.ali@qantas.com','+971501998877','Pilot','FL0000002');
UPDATE staff
  SET role = 'Senior Pilot'
  WHERE staff_id = 'ST0000003';
DELETE FROM staff
  WHERE staff_id = 'ST0000003';
--------------------------------------------------------
-- INSERT + UPDATE + DELETE INTO FLIGHT_DEPARTURES TABLE ---> UPDATE IS NEEDED
--------------------------------------------------------
INSERT INTO flight_departures VALUES ('AP0001','FL0000002');
DELETE FROM flight_departures
 WHERE airport_id = 'AP0002'
   AND flight_id  = 'FL0000002';

INSERT INTO flight_departures (airport_id, flight_id) VALUES ('AP0002','FL0000002');
--------------------------------------------------------
-- INSERT + UPDATE + DELETE INTO LUGGAGGE TABLE 
--------------------------------------------------------
INSERT INTO luggage (luggage_id, ticket_id, passenger_id, tag_number, weight, type, color, is_fragile, is_overweight, status) 
          VALUES ('LG0000003', 'TK000001', 'PA0000001', 'TAG000000000003', 15.0, 'Checked', 'Blue', 'N', 'N', 'In Transit');
UPDATE luggage
  SET status = 'Delivered'
  WHERE luggage_id = 'LG0000003';
DELETE FROM luggage
  WHERE luggage_id = 'LG0000003';
--------------------------------------------------------
-- INSERT + UPDATE + DELETE INTO SERVICE (ternary) TABLE 
--------------------------------------------------------
INSERT INTO service VALUES ('PA0000001','FL0000001','ST0000001','Safety Demo',TO_DATE('2025-05-01 08:15','YYYY-MM-DD HH24:MI'));
UPDATE service
  SET service_type = 'Extended Safety Demo'
  WHERE passenger_id='PA0000001' AND flight_id='FL0000001' AND staff_id='ST0000001';
DELETE FROM service
  WHERE passenger_id='PA0000001' AND flight_id='FL0000001' AND staff_id='ST0000001';
  
---------------------------------------

--------------------------
-- INSERTING TO ALL TABLES 
--------------------------
INSERT INTO flight (flight_id, airline, departure_time, arrival_time, aircraft_model, status) VALUES
  ('FL0000004','NoAir', TO_DATE('2025-05-04 06:00','YYYY-MM-DD HH24:MI'),
                   TO_DATE('2025-05-04 08:00','YYYY-MM-DD HH24:MI'),
                   'ModelY','Scheduled');

INSERT INTO airport (airport_id, airport_name, iata_code, country, city, time_zone) VALUES
  ('AP0003','Changi Airport'     ,'SIN','Singapore'            ,'Singapore','Asia/Singapore');
  
INSERT INTO flight (
  flight_id, airline, departure_time, arrival_time, aircraft_model, status
) VALUES (
  'FL0000005',
  'Qantas',
  TO_DATE('2025-05-11 09:00','YYYY-MM-DD HH24:MI'),
  TO_DATE('2025-05-11 17:00','YYYY-MM-DD HH24:MI'),
  'Boeing 787',
  'Scheduled'
);

INSERT INTO flight (
  flight_id, airline, departure_time, arrival_time, aircraft_model, status
) VALUES (
  'FL0000006',
  'Singapore Airlines',
  TO_DATE('2025-05-12 14:30','YYYY-MM-DD HH24:MI'),
  TO_DATE('2025-05-12 22:00','YYYY-MM-DD HH24:MI'),
  'Airbus A350',
  'Scheduled'
);

INSERT INTO flight (
  flight_id, airline, departure_time, arrival_time, aircraft_model, status
) VALUES (
  'FL0000007',
  'Cathay Pacific',
  TO_DATE('2025-05-13 07:15','YYYY-MM-DD HH24:MI'),
  TO_DATE('2025-05-13 15:45','YYYY-MM-DD HH24:MI'),
  'Boeing 777',
  'Scheduled'
);

INSERT INTO passenger (
  passenger_id, passport_no, first_name, middle_name_initial, last_name,
  date_of_birth, gender, nationality, address_street, address_city, address_zip, email
) VALUES
  ('PA0000002','B234567','Bob'  ,'B','Brown'   , TO_DATE('1985-02-02','YYYY-MM-DD'),
    'Male'  ,'United Kingdom'       ,'456 Oak Rd','London','00002','bob@example.co.uk');
INSERT INTO passenger (
  passenger_id, passport_no, first_name, middle_name_initial, last_name,
  date_of_birth, gender, nationality, address_street, address_city, address_zip, email
) VALUES
  ('PA0000003','C345678','Carol','C','Clark'   , TO_DATE('1992-03-03','YYYY-MM-DD'),
    'Female','United Arab Emirates','789 Maple Ave','Dubai','00003','carol@example.com');
    
INSERT INTO phone_number (passenger_id, phone_number) VALUES
  ('PA0000001','+971500000001');
INSERT INTO phone_number (passenger_id, phone_number) VALUES
  ('PA0000003','+971500000003');
  
INSERT INTO ticket (ticket_id, class, ticket_date, ticket_time, price, seat_number, gate, boarding_time, passenger_id, flight_id, payment_id) VALUES
  ('TK000002','Business',TO_DATE('2025-04-21','YYYY-MM-DD'), TO_DATE('2025-04-21 16:00','YYYY-MM-DD HH24:MI'), 200.00, '1B' , 'B2', TO_DATE('2025-05-02 08:00','YYYY-MM-DD HH24:MI'),'PA0000001','FL0000002','PMT000000002');
INSERT INTO ticket (ticket_id, class, ticket_date, ticket_time, price, seat_number, gate, boarding_time, passenger_id, flight_id, payment_id) VALUES
  ('TK000003','First',   TO_DATE('2025-04-22','YYYY-MM-DD'), TO_DATE('2025-04-22 17:00','YYYY-MM-DD HH24:MI'),  50.00, '1C' , 'C3', TO_DATE('2025-05-03 09:00','YYYY-MM-DD HH24:MI'),'PA0000001','FL0000003','PMT000000003');
INSERT INTO ticket (ticket_id, class, ticket_date, ticket_time, price, seat_number, gate, boarding_time, passenger_id, flight_id, payment_id) VALUES
  ('TK000004','Economy', TO_DATE('2025-04-23','YYYY-MM-DD'), TO_DATE('2025-04-23 18:00','YYYY-MM-DD HH24:MI'), 150.00, '22D', 'D4', TO_DATE('2025-05-04 10:00','YYYY-MM-DD HH24:MI'),'PA0000002','FL0000001','PMT000000004');
INSERT INTO ticket (ticket_id, class, ticket_date, ticket_time, price, seat_number, gate, boarding_time, passenger_id, flight_id, payment_id) VALUES
  ('TK000005','Economy', TO_DATE('2025-04-24','YYYY-MM-DD'), TO_DATE('2025-04-24 19:00','YYYY-MM-DD HH24:MI'), 120.00, '23E', 'E5', TO_DATE('2025-05-05 11:00','YYYY-MM-DD HH24:MI'),'PA0000003','FL0000001','PMT000000005');
  
INSERT INTO payment (payment_id, amount, method, date_of_payment, ticket_id) VALUES
  ('PMT000000002', 200.00, 'Cash', TO_DATE('2025-04-21','YYYY-MM-DD'), 'TK000002');
INSERT INTO payment (payment_id, amount, method, date_of_payment, ticket_id) VALUES
  ('PMT000000003',  50.00, 'Card', TO_DATE('2025-04-22','YYYY-MM-DD'), 'TK000003');
INSERT INTO payment (payment_id, amount, method, date_of_payment, ticket_id) VALUES
  ('PMT000000004', 150.00, 'Cash', TO_DATE('2025-04-23','YYYY-MM-DD'), 'TK000004');
INSERT INTO payment (payment_id, amount, method, date_of_payment, ticket_id) VALUES
  ('PMT000000005', 120.00, 'Card', TO_DATE('2025-04-24','YYYY-MM-DD'), 'TK000005');
  
INSERT INTO staff (staff_id, first_name, last_name, email, phone, role, flight_id) VALUES
  ('ST0000003','Jim',  'Beam', 'jim@example.com',  '+971500000012','Crew', 'FL0000002');

INSERT INTO flight_departures (airport_id, flight_id) VALUES
  ('AP0002','FL0000003');
  
INSERT INTO passenger (
  passenger_id, passport_no, first_name, middle_name_initial, last_name,
  date_of_birth, gender, nationality, address_street, address_city, address_zip, email
) VALUES (
  'PA0001001','G123456','Grace','G','Green',
  TO_DATE('1991-06-06','YYYY-MM-DD'),'Female','British',
  '12 King Rd','London','W1A1AB','grace.green@example.co.uk'
);

INSERT INTO passenger (
  passenger_id, passport_no, first_name, middle_name_initial, last_name,
  date_of_birth, gender, nationality, address_street, address_city, address_zip, email
) VALUES (
  'PA0001002','H234567','Harry','H','Hill',
  TO_DATE('1989-07-07','YYYY-MM-DD'),'Male','British',
  '34 Queen St','London','W1A1AC','harry.hill@example.co.uk'
);


----------------------------
-- QUERIES
----------------------------

--Equi-Join
SELECT p.first_name, t.ticket_id
  FROM passenger p
  JOIN ticket t
    ON p.passenger_id = t.passenger_id;
    
--Natural Join
SELECT *
  FROM passenger
  NATURAL JOIN ticket;
  
--Outer Join
SELECT f.flight_id, t.ticket_id
  FROM flight f
  LEFT OUTER JOIN ticket t
    ON f.flight_id = t.flight_id;
    
--Self-Join
SELECT p1.passenger_id AS p1_id, p1.first_name AS p1_name,
       p2.passenger_id AS p2_id, p2.first_name AS p2_name
  FROM passenger p1
  JOIN passenger p2
    ON p1.address_city = p2.address_city
   AND p1.passenger_id <> p2.passenger_id;
   
--Subquery
SELECT flight_id, duration
  FROM flight
 WHERE duration > (
   SELECT AVG(duration)
     FROM flight
 );
 
 --HAVING
SELECT passenger_id, COUNT(*) AS cnt
  FROM ticket
 GROUP BY passenger_id
HAVING COUNT(*) > (
    SELECT AVG(cnt)
      FROM (
        SELECT passenger_id, COUNT(*) AS cnt
          FROM ticket
         GROUP BY passenger_id
      )
);

--IN
SELECT staff_id, role
  FROM staff
 WHERE flight_id IN (
   SELECT flight_id
     FROM flight_departures
    WHERE airport_id = 'AP0001'
 );
 
--IN
SELECT DISTINCT p.passenger_id, p.first_name
  FROM passenger p
 WHERE p.nationality IN (
   SELECT country
     FROM airport
 );
 
--nested subqueries
SELECT *
  FROM payment
 WHERE amount > (
   SELECT AVG(amount)
     FROM payment
    WHERE ticket_id IN (
      SELECT ticket_id
        FROM ticket
       WHERE flight_id = (
         SELECT flight_id
           FROM flight
          WHERE airline = 'Emirates'
       )
    )
 );
 
--LEFT OUTER JOIN
SELECT 
  p.passenger_id, 
  p.first_name, 
  pn.phone_number
FROM passenger p
LEFT OUTER JOIN phone_number pn
  ON p.passenger_id = pn.passenger_id;
  
--RIGHT OUTER JOIN
SELECT 
  pn.phone_number, 
  p.passenger_id, 
  p.first_name
FROM phone_number pn
RIGHT OUTER JOIN passenger p
  ON pn.passenger_id = p.passenger_id;

