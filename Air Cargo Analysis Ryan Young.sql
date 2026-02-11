create database Air_Cargo;
use Air_Cargo;
select * from customer;
select * from passengers_on_flights;
select * from routes;
select * from ticket_details;

## 2.	Write a query to create a route_details table using suitable data types for the fields, such as route_id, flight_num, origin_airport, destination_airport, aircraft_id, and distance_miles. Implement the check constraint for the flight number and unique constraint for the route_id fields. Also, make sure that the distance miles field is greater than 0. 

create table route_details(
route_id int unique not null,
flight_num bigint not null,
origin_airport varchar(5) not null,
destination_airport varchar(5) not null,
aircraft_id varchar(20) not null,
distance_miles bigint not null

constraint check_dist check (distance_miles > 0)
);
drop table route_details;
 
## 3. Write a query to display all the passengers (customers) who have travelled in routes 01 to 25. Take data from the passengers_on_flights table.

select p.customer_id, p.route_id, c.first_name, c.last_name 
from passengers_on_flights as p
join customer as c
on p.customer_id = c.customer_id
where route_id <=25
order by route_id;

## 4. Write a query to identify the number of passengers and total revenue in business class from the ticket_details table.

select sum(no_of_tickets) as tickets_sold, sum(price_per_ticket) as total_sales
from ticket_details
where class_id = 'Bussiness';

## 5. Write a query to display the full name of the customer by extracting the first name and last name from the customer table.

select concat(First_name, " ", last_name) as Full_name
from customer;

## 6. Write a query to extract the customers who have registered and booked a ticket. Use data from the customer and ticket_details tables.
select distinct t.customer_id, c.first_name, c.last_name
from ticket_details as t
inner join customer as c
on t.customer_id = c.customer_id
order by customer_id;

## 7. Write a query to identify the customer’s first name and last name based on their customer ID and brand (Emirates) from the ticket_details table.

select t.customer_id, c.first_name, c.last_name, t.brand
from ticket_details as t
inner join customer as c 
on t.customer_id = c.customer_id
order by brand;

## 8. Write a query to identify the customers who have travelled by Economy Plus class using Group By and Having clause on the passengers_on_flights table. 

select customer_id, class_id
from passengers_on_flights
group by class_id, customer_id
having class_id = "Economy Plus";

## 9. Write a query to identify whether the revenue has crossed 10000 using the IF clause on the ticket_details table.

select if(sum(Price_per_Ticket) > 10000, "Total Revenue is greater than $10,000", "Total Revenue is less than $10,000")
from ticket_details;

## 10. Write a query to create and grant access to a new user to perform operations on a database.

create user 'rysyoung123'@'localhost' identified by 'password1';
grant all privileges on Air_Cargo.* TO 'rysyoung123'@'localhost';

drop user 'rysyoung123'@'localhost';

## 11. Write a query to find the maximum ticket price for each class using window functions on the ticket_details table. 

select class_id, max(price_per_ticket) as max_price
from ticket_details
group by class_id;

## 12. Write a query to extract the passengers whose route ID is 4 by improving the speed and performance of the passengers_on_flights table.

create index route_4 on passengers_on_flights(route_id);
select * from passengers_on_flights
where route_id = 4;

drop index route_4 on passengers_on_flights;

## 13. For the route ID 4, write a query to view the execution plan of the passengers_on_flights table.

select * from passengers_on_flights
where route_id = 4;

## 14.	Write a query to calculate the total price of all tickets booked by a customer across different aircraft IDs using rollup function. 

select ifnull(customer_id, 'Total') as customer_id, ifnull(aircraft_id, "All Aircraft") as aircraft_id, sum(price_per_ticket) as Total_Price
from ticket_details
group by customer_id, aircraft_id with rollup
order by customer_id, aircraft_id;


## 15. Write a query to create a view with only business class customers along with the brand of airlines. 

select t.customer_id, c.first_name, c.last_name, t.brand
from ticket_details as t
inner join customer as c 
on t.customer_id = c.customer_id
where class_id = 'Bussiness';

## 16. Write a query to create a stored procedure to get the details of all passengers flying between a range of routes defined in run time. Also, return an error message if the table doesn't exist.

delimiter //
create procedure passengerdetails (in start_route INT, end_route INT)
Begin
	select p.customer_id, c.first_name, c.last_name, p.route_id
	from passengers_on_flights as p
	inner join customer as c
	on p.customer_id = c.customer_id
	where p.route_id between start_route and end_route;
End //
delimiter ;

call passengerdetails(4, 10);

## 17. Write a query to create a stored procedure that extracts all the details from the routes table where the travelled distance is more than 2000 miles.

delimiter //
create procedure routedetails ()
Begin
	select * from routes
    where distance_miles > 2000;
End //
delimiter ;

call routedetails();

## 18. Write a query to create a stored procedure that groups the distance travelled by each flight into three categories. The categories are, short distance travel (SDT) for >=0 AND <= 2000 miles, intermediate distance travel (IDT) for >2000 AND <=6500, and long-distance travel (LDT) for >6500.

delimiter //
create procedure route_categories()
Begin
	Select *,
		case 
			when distance_miles between 0 and 2000 then 'Short Distance'
			when distance_miles between 2000 and 6500 then 'Intermediate Distance'
			when distance_miles > 6500 then 'Long distance'
		End as distance_group
	from routes
    order by distance_group;
End //
delimiter ;

call route_categories();

## 19.	Write a query to extract ticket purchase date, customer ID, class ID and specify if the complimentary services are provided for the specific class using a stored function in stored procedure on the ticket_details table. 
# Condition: 
#  ●	If the class is Business and Economy Plus, then complimentary services are given as Yes, else it is No


delimiter //
create procedure ticket_extract()
Begin
	Select customer_id, p_date, class_id,
		case 
			when class_id = 'Bussiness' then 'Yes'
			when class_id = 'Economy Plus' then 'Yes'
			else 'No'
		End as complimentary_services_provided
	from ticket_details
    order by customer_id;
End //
delimiter ;

call ticket_extract();

## 20. Write a query to extract the first record of the customer whose last name ends with Scott using a cursor from the customer table.

delimiter //
create procedure customer_scott()
begin
declare var_first_name varchar(50);
declare var_last_name varchar(50);
declare var_customer_id bigint;
declare var_dob varchar(20);
declare var_gender char(1);

declare finish int default 0;

declare cust_cursor cursor for 
select first_name, last_name, customer_id, date_of_birth, gender from customer
where last_name like 'Scott';


declare continue handler for not found set finish = 1;

open cust_cursor;

fetch cust_cursor into var_first_name, var_last_name, var_customer_id, var_dob, var_gender;

select var_first_name as FirstName, var_last_name as LastName, var_customer_id as ID, var_dob as DateofBirth, var_gender as Gender;

close cust_cursor;
end //
delimiter ;

call customer_scott();