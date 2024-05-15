-- FUNCTION :


-- PROCEDURE FOR CUSTOMER REGISTRATION ----

CREATE OR REPLACE PROCEDURE register_customer (
    email      IN   VARCHAR,
    fname      IN   VARCHAR,
    lname      IN   VARCHAR,
    password   IN   VARCHAR
)
language plpgsql
as $$
BEGIN
    INSERT INTO f2c_user VALUES (
        email,
        fname,
        lname,
        password,
        0
    );

    INSERT INTO customer VALUES (
        email,
		fname ||' '|| lname
    );

end;
$$;

select * from customer ;
call register_customer('gagan','snjndsj','skjdfbdsfkj','skjs');
--------------------------------------------------------------------------------

-- PROCEDURE FOR FARMER REGISTRATION

CREATE OR REPLACE PROCEDURE register_farmer (
    email             IN   VARCHAR,
    fname             IN   VARCHAR,
    lname             IN   VARCHAR,
    password          IN   VARCHAR
) 
language plpgsql
as $$
BEGIN
    INSERT INTO f2c_user VALUES (
        email,
        fname,
        lname,
        password,
        1
    );

    INSERT INTO farmer VALUES (
        email,
        'TRUE AND HONEST FARMER',
        0,
        0,
		fname ||' '|| lname
    );
end;
$$;

-------------------------------------------------------------------------------

-- PROCEDURE TO ADD CONTACT DETAILS --------------

CREATE OR REPLACE PROCEDURE add_contact_details (
    user_id      IN   VARCHAR,
    street1      IN   VARCHAR,
    street2      IN   VARCHAR,
    city         IN   VARCHAR,
    state        IN   VARCHAR,
    country      IN   VARCHAR,
    zipcode      IN   INTEGER,
    phone        IN   VARCHAR

)
language plpgsql
as $$
BEGIN
    INSERT INTO contact_detail(user_id ,street1,street2,city,state,country,zipcode,phone,IS_DEFAULT) VALUES (
        user_id,
        street1,
        street2,
        city,
        state,
        country,
        zipcode,
        phone,
        1
    );

END;
$$;

----------------------------------------------------------------------------------------------------
-- PROCEDURE TO ADD_PRODUCT TO THE PRODUCTS

CREATE OR REPLACE PROCEDURE add_product (
    name           VARCHAR,
    farmer_id       VARCHAR,
    price           NUMERIC,
    category_id    INTEGER,
    description      VARCHAR,
    available_units    INTEGER,
    carrier_phone     INTEGER
) 
language plpgsql
as $$
BEGIN
    INSERT INTO product(name,farmer_id,price,rating,review_count,category_id, description, available_units,in_stock,carrier_phone) VALUES (
        name,
        farmer_id,
        price,
        0,
        0,
        category_id,
        description,
        available_units,
        1,
        carrier_phone
    );
end;
$$;

--------------------------------------------------------------------------------------------

-- FUNCTION TO ADD HIS MACHINERY DETAILS OF A FARMER 

CREATE OR REPLACE FUNCTION add_machinery(
    farmer_id VARCHAR(255),
    name VARCHAR(255),
    description TEXT,
    available BOOLEAN DEFAULT TRUE
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Machinery (farmer_id, name, description, available)
    VALUES (farmer_id, name, description, available);
END;
$$ LANGUAGE plpgsql;

SELECT ADD_MACHINERY('SUNUL','TRACTOR','NICE ONE');

SELECT * FROM MACHINERY;

----------------------------------------------------------------------------------------------

-- FUNCTION TO BORROW MACHINERY FROM A FARMER -----

CREATE OR REPLACE FUNCTION borrow_machinery(
    farmer_id_param VARCHAR,
    machinery_id_param INT
)
RETURNS VOID
AS $$
DECLARE
    borrowed_date_param TIMESTAMP := CURRENT_TIMESTAMP;
    returned_date_param TIMESTAMP := NULL; -- Initially set as NULL
    owner_id_param VARCHAR;
BEGIN
    -- Retrieve the owner_id from the Machinery table
    SELECT farmer_id INTO owner_id_param
    FROM Machinery
    WHERE machinery_id = machinery_id_param;

    -- Insert a new row into the Borrower_details table
    INSERT INTO Borrower_details (borrower_id, machinery_id, owner_id, borrowed_date, returned_date)
    VALUES (farmer_id_param, machinery_id_param, owner_id_param, borrowed_date_param, returned_date_param);
END;
$$ LANGUAGE plpgsql;


select borrow_machinery('SUNUL',1)
select * from borrower_details;
DELETE FROM BORROWER_DETAILS
select * from machinery

--------------------------------------------------------------------------------------

-- FUNCTION TO RETURN BORROWED_MACHINERY ----------------

CREATE OR REPLACE FUNCTION return_machinery(
    farmer_id_param VARCHAR,
    machinery_id_param INT
)
RETURNS VOID
AS $$
BEGIN
    -- Update the returned_date to the current date and time
    UPDATE Borrower_details
    SET returned_date = CURRENT_TIMESTAMP
    WHERE borrower_id = farmer_id_param
    AND machinery_id = machinery_id_param
    AND returned_date IS NULL; -- Only update if the machinery hasn't been returned yet
END;
$$ LANGUAGE plpgsql;

select return_machinery('SUNULuu',1);


----------------------------------------------------------------------------------

-- PROCEDURE TO ADD PRODUCTS TO CART ----------------------------

CREATE OR REPLACE PROCEDURE add_to_shopping_cart (
    buyer_id     IN   VARCHAR,
    product_id   IN   INTEGER
)
language plpgsql
as $$
BEGIN
    INSERT INTO shopping_cart VALUES (
        buyer_id,
        current_date
    );

    INSERT INTO product_shoppingcart VALUES (
        product_id,
        buyer_id
    );

END;
$$;
--------------------------------------------------------------------------------------------------------

-- PROCEDURE TO ADD MULTIPLE PRODUCTS AT A TIME TO CART ------------------

CREATE OR REPLACE PROCEDURE add_MULTIPLE_to_shopping_cart (
    buyer_id     IN   VARCHAR,
    product_ids  IN   INTEGER[]
)
LANGUAGE plpgsql
AS $$
DECLARE
    product_id_var INTEGER;
BEGIN
    -- Insert a new row into the shopping_cart table for the buyer
    INSERT INTO shopping_cart (customer_id, date_added)
    VALUES (buyer_id, current_date);

    -- Loop through the array of product IDs and insert each one into the product_shoppingcart table
    FOREACH product_id_var IN ARRAY product_ids LOOP
        INSERT INTO product_shoppingcart (product_id, customer_id)
        VALUES (product_id_var, buyer_id);
    END LOOP;
END;
$$;



---------------------------------------------------------------------------------------------

-- FUNCTION TO PLACE ORDER FROM THE CART ------

CREATE OR REPLACE PROCEDURE place_order (
    buyer_id_param       IN   VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
	order_id_param         INTEGER;
    address_id_var        INTEGER;
    total_price_var       NUMERIC := 0;
    curr_price_var        NUMERIC;
    total_qty_var         INTEGER := 0;
    available_units_var   INTEGER;
    shipping_price_var    NUMERIC := 10;
    product_id_var        INTEGER;
	 product_row          RECORD;
BEGIN
	 SELECT address_id
    INTO address_id_var
    FROM contact_detail
    WHERE user_id = buyer_id_param
    AND is_default = 1;
	
    FOR product_row IN
        SELECT product_id
        FROM product_shoppingcart
        WHERE customer_id = buyer_id_param
    LOOP
		INSERT INTO f2c_order (customer_id, total_price, order_date, shipping_price,delivery_address_id,delivery_date, order_status, quantity)
    	VALUES (buyer_id_param, total_price_var, CURRENT_DATE, 10,address_id_var, CURRENT_DATE, 'p', total_qty_var)
    	RETURNING order_id INTO order_id_param;
	
        SELECT price, available_units
        INTO curr_price_var, available_units_var
        FROM product
        WHERE product_id = product_row.product_id;

        IF available_units_var > 0 THEN
            total_price_var := total_price_var + curr_price_var;
            total_qty_var := total_qty_var + 1;
            INSERT INTO order_product (order_id, product_id)
            VALUES (order_id_param, product_row.product_id);
        END IF;
		    total_price_var := total_price_var + shipping_price_var + 10;

    -- Update the total_price for the generated order
		UPDATE f2c_order
		SET total_price = total_price_var
		WHERE order_id = order_id_param;

		UPDATE f2c_order
		SET quantity = total_qty_var
		WHERE order_id = order_id_param;
    END LOOP;
	
END;
$$;
--------------------------------------------------------------------------------------------------------

-- PROCEDURE TO GIVE REVIEW FOR A PRODUCT --------------------

CREATE OR REPLACE PROCEDURE give_review (
    product_id   IN   INTEGER,
    customer_id    IN   VARCHAR,
    review       IN   VARCHAR,
    rating       IN    NUMERIC(2, 1)
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO review(product_id,customer_id,review,rating,review_date) VALUES(product_id,customer_id,review,rating,CURRENT_DATE);
END;
$$;

-----------------------------------------------------------------------------------------------------------




