-- FUNCTIONS 

--FUNCTION TO ADD CUSTOMERS
CREATE OR REPLACE FUNCTION add_customer(_a INTEGER, _b VARCHAR, _c VARCHAR, _d VARCHAR, _e VARCHAR)
RETURNS void
LANGUAGE plpgsql
AS $MAIN$ 
BEGIN 
	INSERT INTO customer 
	VALUES(_a, _b, _c, _d, _e);
END;
$MAIN$

SELECT * from customer; 
SELECT add_customer(4, 'Khal', 'Drogo', 'drogo@got.net', '555-123-1234');
SELECT add_customer(5, 'Brienne', 'of Tarth', 'bribri@got.net', '555-123-1234');

--FUNCTION TO ADD PARTS
CREATE OR REPLACE FUNCTION add_part(_a INTEGER, _b VARCHAR, _c NUMERIC(8,2), _d INTEGER)
RETURNS void
LANGUAGE plpgsql
AS $MAIN$ 
BEGIN 
	INSERT INTO "parts_Inventory"
	VALUES(_a, _b, _c, _d);
END;
$MAIN$

SELECT * from "parts_Inventory";
SELECT add_part(3, 'battery', 99.99, 32);
SELECT add_part(4, 'wipers', 15.95, 120);
SELECT add_part(5, 'oil', 38.99, 17);


--FUNCTION TO ADD PARTS INVOICE (JULIA)
--I tried to get this function to do two things at once but I had a really hard time!!!
--This function creates a new parts invoice. 
--I wanted it to take the price from the the parts inventory table and add that to the invoice, multiplied by the amount provided. At some point it started adding the price as NULL. see the original version below. 
--The second thing I wanted it to do was to subtract the quantity of part from the total quantity in the inventory. I think that part it working. 
CREATE OR REPLACE FUNCTION add_part_invoice(pi_id INTEGER, p_id INTEGER, quan INTEGER, i_id INTEGER)
RETURNS void
LANGUAGE plpgsql
AS $MAIN$ 
BEGIN 
	INSERT INTO "part_invoice"
	VALUES(
		pi_id, 
		p_id, 
		quan, 
		NULL, 
		i_id);
	UPDATE "parts_Inventory"
	SET total_quantity = total_quantity - quan
	WHERE "parts_Inventory".parts_id = p_id;
END;
$MAIN$
ABORT

-- original procedure trying to caucluate price as it added parts invoice 
-- BEGIN 
-- 	INSERT INTO "part_invoice"
-- 	VALUES(pi_id, p_id, quan, (
-- 	SELECT "parts_Inventory".price * quan FROM "parts_Inventory" WHERE "parts_Inventory".parts_id = pi_id
-- 	), i_id);
-- END;



-- I made a separate procedure to update the price of the invoice based on the inventory price, 
-- but for some reason it is only referring to the price of the battery(99.99)
CREATE OR REPLACE PROCEDURE update_part_price()
LANGUAGE plpgsql
AS $$
BEGIN 
	UPDATE part_invoice
	SET total_price = "parts_Inventory".price * part_invoice.quantity
	FROM "parts_Inventory"
	FULL JOIN part_invoice AS pi
	ON pi.parts_id = "parts_Inventory".parts_id;
	COMMIT;
END;
$$

CALL update_part_price();

--added lots of invoices as I was testing out the functions. Update price function must be called to add price
SELECT * from "part_invoice";
SELECT add_part_invoice(3, 3, 1, 2);
SELECT add_part_invoice(4, 1, 4, 1);
SELECT add_part_invoice(5, 4, 2, 2);
SELECT add_part_invoice(6, 2, 1, 1);
SELECT add_part_invoice(7, 1, 1, 1);
SELECT add_part_invoice(8, 1, 1, 1);
SELECT add_part_invoice(9, 2, 1, 1);
SELECT add_part_invoice(10, 2, 1, 1);
SELECT add_part_invoice(11, 5, 2, 2);
SELECT add_part_invoice(12, 3, 2, 1);

SELECT * 
from "part_invoice"
full join "parts_Inventory"
on "parts_Inventory".parts_id = "part_invoice".parts_id;



--FUNCTION TO ADD INVOICE
CREATE OR REPLACE FUNCTION add_invoice(i_id INTEGER, s_id INTEGER, c_id INTEGER, cu_id INTEGER, price NUMERIC(8,2))
RETURNS void
LANGUAGE plpgsql
AS $MAIN$ 
BEGIN 
	INSERT INTO "invoice"
	VALUES(i_id, s_id, c_id, cu_id, price);
END;
$MAIN$

SELECT * from "invoice";

SELECT add_invoice(3, 2, 1, 5, 20500.00);
SELECT add_invoice(4, 1, 1, 4, 30500.00);








--This inner join displays customers who bought cars and the cars they bought. 
SELECT customer.first_name, customer.last_name, car.make, car.model
FROM customer
INNER JOIN invoice
ON invoice.customer_id = customer.customer_id
INNER JOIN car
ON invoice.car_id = car.car_id
	
--Tried making this into a function or procedure where you can pass a customer id as an argument, 
--but can you make a procedure or function just to show data? This is the error I get:
-- ERROR:  query has no destination for result data
-- HINT:  If you want to discard the results of a SELECT, use PERFORM instead.
-- CONTEXT:  PL/pgSQL function customercar(integer) line 3 at SQL statement
-- SQL state: 42601
CREATE OR REPLACE PROCEDURE customercar(_customer_id INTEGER)
LANGUAGE plpgsql 
AS $$ 
BEGIN
	SELECT customer.first_name, customer.last_name, car.make, car.model
	FROM customer
	INNER JOIN invoice
	ON invoice.customer_id = customer.customer_id
	INNER JOIN car
	ON invoice.car_id = car.car_id
	WHERE customer.customer_id = _customer_id;
	COMMIT;
END;
$$
CALL customercar(1)





--Function for inserting data into car table
CREATE OR REPLACE FUNCTION add_car(_car_id INTEGER, _make VARCHAR, _model VARCHAR, 
								   _year VARCHAR, _price INTEGER, _for_sale boolean)
RETURNS void
LANGUAGE plpgsql 
AS $MAIN$ 
BEGIN
		INSERT INTO "car"
		VALUES(_car_id, _make, _model, _year, _price, _for_sale);
		
END;
$MAIN$

SELECT add_car(3, 'Nissan', 'Rogue', '2021', 27150, FALSE);
SELECT add_car(4, 'Toyota', 'Camry', '2020', 25420, FALSE);


select * from car;



--Function for inserting data into service table
CREATE OR REPLACE FUNCTION add_service(_service_id INTEGER, _name VARCHAR, _cost VARCHAR)
RETURNS void
LANGUAGE plpgsql 
AS $MAIN$ 
BEGIN
		INSERT INTO "service"
		VALUES(_service_id, _name, _cost);
		
END;
$MAIN$

SELECT add_service(3, 'Replace Air Filter', '$30');
SELECT add_service(4, 'Add Antifreeze', '$150');

select * from service;



--Function for inserting data into service_invoice table
CREATE OR REPLACE FUNCTION add_service_invoice(_service_invoice_id INTEGER, _car_id INTEGER, 
											   _service_id INTEGER, _customer_id INTEGER, 
											  _total_price INTEGER)
RETURNS void
LANGUAGE plpgsql 
AS $MAIN$ 
BEGIN
		INSERT INTO "service_invoice"
		VALUES(_service_invoice_id, _car_id, _service_id, _customer_id, _total_price);
		
END;
$MAIN$

SELECT add_service_invoice(3, 3, 3, 3, '30');
SELECT add_service_invoice(4, 4, 4, 4, 150);


select * from service_invoice;



--Function for inserting data into service_ticket table
CREATE OR REPLACE FUNCTION add_service_ticket(_ticket_id INTEGER, _service_invoice_id INTEGER, 
											   _staff_id INTEGER)
RETURNS void
LANGUAGE plpgsql 
AS $MAIN$ 
BEGIN
		INSERT INTO "service_ticket"
		VALUES(_ticket_id , _service_invoice_id, _staff_id);
		
END;
$MAIN$

SELECT add_service_ticket(3, 3, 3);
SELECT add_service_ticket(4, 4, 4);

select * from service_ticket;

--Function for inserting data into staff table
CREATE OR REPLACE FUNCTION add_staff(_staff_id INTEGER, _first_name VARCHAR, 
											   _last_name VARCHAR, _email VARCHAR, 
											  _staff_type VARCHAR)
RETURNS void
LANGUAGE plpgsql 
AS $MAIN$ 
BEGIN
		INSERT INTO "staff"
		VALUES(_staff_id , _first_name, _last_name, _email, _staff_type);
		
END;
$MAIN$

SELECT add_staff(3, 'Sansa', 'Stark', 'sansastarck@example.com', 'Sales');
SELECT add_staff(4, 'Bran', 'Stark', 'branstark@example.com', 'Sales');

select * from staff




CREATE OR REPLACE PROCEDURE discountPrice(
	discount INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE car
	SET price = car.price - discount
	WHERE car.for_sale = False;
	COMMIT;
END;
$$



Call discountPrice(3000);

select * from car;


