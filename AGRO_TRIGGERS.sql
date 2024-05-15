-- TRIGGERS :
-------------------------------------------------------------------------------
-- Trigger for borrowing machinery

CREATE OR REPLACE FUNCTION update_machinery_on_borrower()
RETURNS TRIGGER AS $$
BEGIN
    -- Decrement the available column when machinery is borrowed
    UPDATE Machinery
    SET available = FALSE
    WHERE machinery_id = NEW.machinery_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER machinery_borrower_trigger
AFTER INSERT ON Borrower_details
FOR EACH ROW
EXECUTE FUNCTION update_machinery_on_borrower();

---------------------------------------------------------------------------------------

-- Trigger for returning machinery

CREATE OR REPLACE FUNCTION update_machinery_on_return()
RETURNS TRIGGER AS $$
BEGIN
    -- Increment the available column when machinery is returned
    UPDATE Machinery
    SET available = TRUE
    WHERE machinery_id = OLD.machinery_id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER machinery_return_trigger
AFTER UPDATE OF returned_date ON Borrower_details
FOR EACH ROW
WHEN (OLD.returned_date IS NULL AND NEW.returned_date IS NOT NULL)
EXECUTE FUNCTION update_machinery_on_return();

------------------------------------------------------------------------------------------
-- TRIGGER TO UPDATE PRODUCT_RATING -------------------

CREATE OR REPLACE FUNCTION update_product_rating()
RETURNS TRIGGER AS $$
DECLARE
    new_rating NUMERIC(2, 1);
    review_count_old INTEGER;
BEGIN
    -- Get the current review count from the product table
    SELECT review_count INTO review_count_old
    FROM product
    WHERE product_id = NEW.product_id;

    -- Calculate the new product rating and update the product table
    new_rating := NEW.rating;
    UPDATE product
    SET rating = ((rating * review_count_old) + new_rating) / (review_count_old + 1),
        review_count = review_count_old + 1
    WHERE product_id = NEW.product_id;

    RETURN NEW; -- Required for the trigger to proceed
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_product_rating
AFTER INSERT ON review
FOR EACH ROW
EXECUTE FUNCTION update_product_rating();

----------------------------------------------------------------------------------------------------

-- TRIGGER TO UPDATE FARMER_RATING----------------------------------

CREATE OR REPLACE FUNCTION update_farmer_rating()
RETURNS TRIGGER AS $$
DECLARE
    new_rating NUMERIC(2, 1);
    seller_id_to_update VARCHAR(255);
BEGIN
    -- Get the new rating from the new review row
    new_rating := NEW.rating;
    
    -- Get the seller ID associated with the product in the review
    SELECT farmer_id INTO seller_id_to_update
    FROM product
    WHERE product_id = NEW.product_id;

    -- Update the seller's average rating and rating count
    UPDATE farmer
    SET average_rating = ((average_rating * rating_count) + new_rating) / (rating_count + 1),
        rating_count = rating_count + 1
    WHERE farmer_id = seller_id_to_update;

    RETURN NEW; -- Required for the trigger to proceed
END;
$$ LANGUAGE plpgsql;

CREATE or replace TRIGGER update_farmer_rating
AFTER INSERT OR UPDATE OF rating ON review
FOR EACH ROW
EXECUTE FUNCTION update_seller_rating();

DROP  FUNCTION update_farmer_rating;
DROP TRIGGER update_farmer_rating ON PRODUCT;
-----------------------------------------------------------------------------------------------------
-- TRIGGERS UPDATES THE AVAILABLE UNITS IN THE PRODUCT TABLE AFTER ORDER PLACED-----------

CREATE OR REPLACE FUNCTION adjust_product_stock()
RETURNS TRIGGER AS $$
BEGIN
    -- Reduce stock when a product is purchased
    UPDATE product
    SET available_units = available_units - 1
    WHERE product_id = NEW.product_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER adjust_product_stock
AFTER INSERT OR UPDATE ON order_product
FOR EACH ROW
WHEN (NEW.order_id IS NOT NULL)
EXECUTE FUNCTION adjust_product_stock();

-------------------------------------------------------------------------------------------------------------
-- TRIGGER EMPTY CART AFTER PLACING ORDER --------------------

CREATE OR REPLACE FUNCTION remove_items_from_cart()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM product_shoppingcart
    WHERE customer_id = NEW.customer_id;
    
    RETURN NEW; -- This is necessary for the trigger to proceed
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER remove_items_from_cart
AFTER INSERT ON f2c_order
FOR EACH ROW
EXECUTE FUNCTION remove_items_from_cart();
----------------------------------------------------------------------------------------------------------------------------
-- TRIGGER TO ASSIGN FARMER ROLE FOR NEW REGISTERS 

CREATE OR REPLACE FUNCTION grant_permissions_to_farmer()
RETURNS TRIGGER AS $$
DECLARE
    farmer_email VARCHAR;
    farmer_password VARCHAR;
BEGIN
    -- Get the email and password of the new farmer from f2c_user table
    SELECT email, password INTO farmer_email, farmer_password
    FROM f2c_user
    WHERE email = NEW.email;

    -- Create a role for the new farmer
    EXECUTE format('CREATE ROLE %I LOGIN PASSWORD %L', NEW.email, farmer_password);

    -- Grant permissions to the farmer role
    EXECUTE format('GRANT UPDATE ON TABLE f2c_user TO %I', NEW.email);
    EXECUTE format('GRANT SELECT, UPDATE ON TABLE contact_detail TO %I', NEW.email);
    EXECUTE format('GRANT SELECT ON TABLE f2c_order, order_product TO %I', NEW.email);
    EXECUTE format('GRANT SELECT ON TABLE review TO %I', NEW.email);
    EXECUTE format('GRANT SELECT, UPDATE ON TABLE Machinery TO %I', NEW.email);
    EXECUTE format('GRANT SELECT ON TABLE BORROWER_DETAILS TO %I', NEW.email);
    EXECUTE format('GRANT SELECT, UPDATE ON TABLE product TO %I', NEW.email);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER grant_permissions_to_farmer_trigger
AFTER INSERT ON farmer
FOR EACH ROW
EXECUTE FUNCTION grant_permissions_to_farmer();

drop function grant_permissions_to_farmer;
drop trigger grant_permissions_to_farmer_trigger on farmer;

----------------------------------------------------------------------------------------------------------------
-- TRIGGER TO ASSIGN CUSTOMER  ROLE FOR NEW REGISTERS

CREATE OR REPLACE FUNCTION grant_permissions_to_customer()
RETURNS TRIGGER AS $$
DECLARE
    customer_email VARCHAR;
    customer_password VARCHAR;
BEGIN
    -- Get the email and password of the customer from f2c_user table
    SELECT email, password INTO customer_email, customer_password
    FROM f2c_user
    WHERE email = NEW.email;

    -- Create a role for the customer
    EXECUTE format('CREATE ROLE %I LOGIN PASSWORD %L', NEW.email, customer_password);

    -- Grant permissions to the customer role
    EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE shopping_cart TO %I', NEW.email);
    EXECUTE format('GRANT SELECT ON TABLE product TO %I', NEW.email);
    EXECUTE format('GRANT SELECT ON TABLE customer TO %I', NEW.email);
    EXECUTE format('GRANT SELECT, INSERT ON TABLE f2c_order TO %I', NEW.email);
    EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE review TO %I', NEW.email);
    EXECUTE format('GRANT SELECT ON TABLE customer_order_history TO %I', NEW.email);
    EXECUTE format('GRANT SELECT ON TABLE popular_products TO %I', NEW.email);
    EXECUTE format('GRANT SELECT ON TABLE product_categories TO %I', NEW.email);
    EXECUTE format('GRANT SELECT, UPDATE ON TABLE contact_detail TO %I', NEW.email);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER grant_permissions_to_customer_trigger
AFTER INSERT ON f2c_user
FOR EACH ROW
WHEN (NEW.user_type = 0) -- Assuming user_type 0 corresponds to customers
EXECUTE FUNCTION grant_permissions_to_customer();

drop function grant_permissions_to_customer;
drop trigger grant_permissions_to_customer_trigger on f2c_user;
