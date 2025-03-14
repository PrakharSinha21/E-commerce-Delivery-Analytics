-- E-commerce delivery analytics

--Create table
drop table if exists ecom;
create table ecom
	(
	Order_ID varchar(50) primary key,
    Customer_ID varchar(75),
	Platform varchar(50),
	Order_Date_Time TIME,
	Delivery_Time_Minutes int,
	Product_Category varchar(150),
	Order_Value_INR decimal(10,2),
	Customer_Feedback varchar(75),
	Service_Rating int,
	Delivery_Delay boolean,
	Refund_Requested boolean
	);
select * from ecom;

select distinct platform from ecom;

select *
from ecom
where customer_id is null;  --This how we check if there is any null value in column


select order_id,count(*) as duplicate_count
from ecom
group by 1
having count(*) >1;        --To check if there is any duplicate value


--Data Analysis
--Q1.How many unique customers have placed orders?
select count(distinct customer_id)
from ecom;


--Q2.What is the total number of orders placed?
select count(distinct order_id)
from ecom;


--Q3.What is the average order value?
select avg(order_value_inr)
from ecom;


--Q4.What are the top 5 most frequently ordered products?
SELECT Product_Category,count(*) as order_count
FROM ecom
group by 1
order by 2 desc
limit 5;


--Q5.Which customers have placed the highest number of orders?
select customer_id,count(*) as order_count
from ecom
group by 1
order by 2 desc 
limit 10;


--Q6.What percentage of orders are from returning customers vs. new customers?
with customer_orders 
as
(
	select customer_id,count(*) as order_count
	from ecom
	group by 1
),
customer_classification as
(
	select 
	count(case when order_count = 1 then 1 end) as new_customer,
	count(case when order_count>1 then 1 end) as returning_customer
	from customer_orders
)
select 
(new_customer * 100)/(new_customer + returning_customer)as new_customer_percentage,
(returning_customer * 100)/(new_customer + returning_customer)as returning_customer_percentage
from customer_classification;



--Q7.What is the average delivery time for all orders?
select avg(Delivery_Time_Minutes) as avg_delivery_time
from ecom;


--Q8.Which PLATFORM has the fastest average delivery time?
select Platform, avg(delivery_time_minutes) as fastest
from ecom
group by 1
order by 2 desc;


--Q9.How many orders were delivered on time vs. delayed?
SELECT 
	CASE WHEN Delivery_Delay = 'No' then 'On Time'
	else 'Delayed'
	end as Delivery_status,
	count(*) as order_count
from ecom
group by 1
order by 1 desc;


--Q10.Which product has the highest late delivery rates?
with late_deliveries
as 
(
	select Product_Category , count(*) as late_count
	from ecom
	where Delivery_Delay ='Yes'
	group by 1
),
total_order 
as
(
	select product_category , count(*) as total_count
	from ecom
	group by 1
)
select t.Product_Category,
	   (l.late_count * 100)/t.total_count as late_delivery_rate
from total_order t
join late_deliveries l
on t.product_category = l.Product_Category
order by 2 desc
limit 1;



--Q11.What is the correlation between order value and delivery time?
SELECT CORR(order_value_inr,Delivery_Time_Minutes) as correlation_coff
from ecom;

/*If correlation_coefficient is:
Close to +1 → Strong positive correlation (higher order value = longer delivery time).
Close to -1 → Strong negative correlation (higher order value = faster delivery).
Close to 0 → No strong relationship.*/


--Q12.What percentage of orders were refund requested due to late delivery?
select
	(count(case when Refund_Requested = 'Yes' and Delivery_Delay= 'Yes' then 1 end) * 100)
	/count(*) as Refund_requested_due_to_late_delivery
from ecom;



--Q13.How does delivery time vary by product category?
select Product_Category, round(avg(Delivery_Time_Minutes),2)
from ecom
group by 1
order by 2 desc;


--Q14.What is the revenue contribution of the top 10 customers?
select customer_id,
		round((sum(Order_Value_INR)*100)/(select sum(Order_Value_INR) from ecom)*100,2) as revenue_percentage
from ecom
group by customer_id
order by sum(Order_Value_INR) desc
limit 10;




--Q15.What are the top-selling product categories by revenue?
select Product_Category,sum(Order_Value_INR) as total_revenue
from ecom
group by 1
order by 2 desc;




--Q16.What is the refund rate, and how much revenue is lost due to refunds?
SELECT 
	(SUM(CASE WHEN Refund_Requested ='Yes' then 1 else 0 end)*100/ count(*)) as refund_rate,
	sum(case when Refund_Requested ='Yes' then order_value_inr else 0 end ) as revenue_lost
from ecom;




--Q17.Which product categories experience the most refunds?
select Product_Category,count(*) as refund_count
from ecom
where Refund_Requested = 'Yes'
group by 1
order by 2 desc;



--End



