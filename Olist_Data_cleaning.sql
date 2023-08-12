
use Olist_Portfolio_Project
go


-----checking the customers table for anormalies

----look out for empty fields
select * from Olist_customers
where customer_city = ' ' or customer_unique_id = ' ' or customer_zip_code_prefix = ' ' or customer_city = ' ' or customer_state = ' '

-----no missing data in our customers table

---looking out for incorrect spellings
select distinct customer_unique_id
from Olist_customers

-----looking out fo duplicate records using the ranking method
-----with this method, each recored is ranked and based on specified fields with which they are partioned, the duplicate records have 
------rank values greater than 1

with rank_cte(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, 
							customer_state, rank_)
as
(
select *, row_number () over(
							partition by customer_unique_id  order by  customer_unique_id) as rank_
from olist_customers
)

select * from rank_cte
where rank_ >1


----duplicate records were found and deleted by replacing the select keyword with delete in the syntax above



update olist_customers
				set cus_state = case when customer_state = 'AC' THEN 'Acre' 

									WHEN customer_state = 'AL' THEN 'Alagoas'

									WHEN customer_state = 'AP' THEN 'Amapa' 

									WHEN customer_state = 'AM' THEN 'Amazonas'

									WHEN customer_state = 'BA' THEN 'Bahia' 

									WHEN customer_state = 'CE' THEN 'Ceara'

									WHEN customer_state = '"DE' THEN 'Distrito_Federal' 

									WHEN customer_state = 'ES' THEN 'Espirito_Santo'

									WHEN customer_state = 'GO' THEN 'Goias' 

									WHEN customer_state = 'MA' THEN 'Maranhao'

									WHEN customer_state = 'MT' THEN 'Mato_Grosso'

									WHEN customer_state = 'MS' THEN 'Mato_Grosso_do_Sul'

									WHEN customer_state = 'MG' THEN 'Minas_Gerais'

									WHEN customer_state = 'PA' THEN 'Para'

									WHEN customer_state = 'PB' THEN 'Paraiba'

									WHEN customer_state = 'PR' THEN 'Parana'

									WHEN customer_state = '"PE"' THEN 'Pernambuco'

									WHEN customer_state = 'PI' THEN 'Paul'

									WHEN customer_state = 'RJ' THEN 'Rio_de_Janeiro'

									WHEN customer_state = 'RN' THEN 'Rio_Grande_do_Norte'

									WHEN customer_state = 'RS' THEN 'Rio_Grande_do_Sul'

									WHEN customer_state = 'RO' THEN 'Rondonia' 

									WHEN customer_state = 'RR' THEN 'Roraima'

									WHEN customer_state = 'SC' THEN 'Santa_Catarina'

									WHEN customer_state = 'SP' THEN 'Sao_Paulo'

									WHEN customer_state = 'SE' THEN 'Sergipe' 

									WHEN customer_state = 'TO' THEN 'Tocantins'
									ELSE customer_state
									END

-----geolocation table

select distinct geolocation_city from olist_geolocation
-------correcting the geolocation values

select geolocation_lat, abs(geolocation_lat) as geo_lat, geolocation_lng, abs(geolocation_lng) as geo_lng
from olist_geolocation

update olist_geolocation
set geolocation_lat = abs(geolocation_lat)
	,geolocation_lng = abs(geolocation_lng)

---checking through for missing values

select * from olist_geolocation
where geolocation_city = ' ' or geolocation_lat = ' ' or geolocation_lng = ' ' or geolocation_state = ' ' or geolocation_zip_code_prefix = ' '
----no missing values


----checking through for duplicates

select *, row_number () over (partition by geolocation_zip_code_prefix, geolocation_lng, geolocation_lat, geolocation_state, geolocation_city
			order by geolocation_zip_code_prefix) as rank_
	from olist_geolocation

----duplicate records are allowed for this field, explanation in cleaning documentation

update olist_geolocation
set geolocation_city = replace(geolocation_city, '''', ' ')
where geolocation_city like '%''%'


select * from olist_geolocation
where geolocation_city like '%''%'


select * from olist_geolocation
where geolocation_city like '%...%'

update olist_geolocation
set geolocation_city = substring(geolocation_city, 4, charindex('...', geolocation_city)+20)
where geolocation_city like '%...%'


select geolocation_city, substring(geolocation_city, 4, charindex('...', geolocation_city)+20)
from olist_geolocation
where geolocation_city like '%...%'

update olist_geolocation
SET geolocation_city TRANSLATE(geolocation_city, 'ддзйнуталт', 'aaceiouoaeo')
WHERE  LIKE '%[ддзйнуталт]%'

select distinct geolocation_city ---, replace( 'д', 'a', geolocation_city) ---replace('д' зйнутал'
from olist_geolocation
--WHERE geolocation_city LIKE '%[д]%'

update olist_geolocation
				set geo_state = case when geolocation_state = 'AC' THEN 'Acre' 

									WHEN geolocation_state = 'AL' THEN 'Alagoas'

									WHEN geolocation_state = 'AP' THEN 'Amapa' 

									WHEN geolocation_state = 'AM' THEN 'Amazonas'

									WHEN geolocation_state = 'BA' THEN 'Bahia' 

									WHEN geolocation_state = 'CE' THEN 'Ceara'

									WHEN geolocation_state = '"DE' THEN 'Distrito_Federal' 

									WHEN geolocation_state = 'ES' THEN 'Espirito_Santo'

									WHEN geolocation_state = 'GO' THEN 'Goias' 

									WHEN geolocation_state = 'MA' THEN 'Maranhao'

									WHEN geolocation_state = 'MT' THEN 'Mato_Grosso'

									WHEN geolocation_state = 'MS' THEN 'Mato_Grosso_do_Sul'

									WHEN geolocation_state = 'MG' THEN 'Minas_Gerais'

									WHEN geolocation_state = 'PA' THEN 'Para'

									WHEN geolocation_state = 'PB' THEN 'Paraiba'

									WHEN geolocation_state = 'PR' THEN 'Parana'

									WHEN geolocation_state = '"PE"' THEN 'Pernambuco'

									WHEN geolocation_state = 'PI' THEN 'Paul'

									WHEN geolocation_state = 'RJ' THEN 'Rio_de_Janeiro'

									WHEN geolocation_state = 'RN' THEN 'Rio_Grande_do_Norte'

									WHEN geolocation_state = 'RS' THEN 'Rio_Grande_do_Sul'

									WHEN geolocation_state = 'RO' THEN 'Rondonia' 

									WHEN geolocation_state = 'RR' THEN 'Roraima'

									WHEN geolocation_state = 'SC' THEN 'Santa_Catarina'

									WHEN geolocation_state = 'SP' THEN 'Sao_Paulo'

									WHEN geolocation_state = 'SE' THEN 'Sergipe' 

									WHEN geolocation_state = 'TO' THEN 'Tocantins'
									ELSE geolocation_state
									END










-----order items table

select * from olist_order_items
---here we check for outliers
-----duplicate transactions
----split shipping limit date column
-----create additional column for month, year and quarter (this enables us show changes over time)

-----outliers
select min(price), max(price), min(freight_value), max(freight_value)
from  olist_order_items


-----duplicate transactions
with order_cte(order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value, rank_)
as
(
select *, ROW_NUMBER() over(partition by order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value
					order by order_id) as rank_
				from olist_order_items

	)

select * from order_cte
where rank_ >1

-----no duplicate transaction
----expanding the shipping_limit_date column

alter table olist_order_items
add shipping_year varchar (20)
	,shipping_month varchar (20)
	,shipping_quarter int
	,shipping_time varchar (20)
		
update olist_order_items
set shipping_year = year(shipping_limit_date)
	,shipping_month = month(shipping_limit_date)
	,shipping_time = right(shipping_limit_date, 8)

	----shippping quarter column
update olist_order_items
set shipping_quarter = case when shipping_month <=3 then 1
							when shipping_month >3 and shipping_month <=6 then 2
							when shipping_month >6 and shipping_month <=9 then 3
							when shipping_month >9 and shipping_month <=12 then 4
							end
----shipping_month using proper month descripton

update olist_order_items
set shipping_month = CASE 
						WHEN shipping_Month = 1 THEN 'Jan'
						WHEN shipping_Month = 2 THEN 'Feb'
						WHEN shipping_Month = 3 THEN 'Mar'
						WHEN shipping_Month = 4 THEN 'Apr'
						WHEN shipping_Month = 5 THEN 'May'
						WHEN shipping_Month = 6 THEN 'Jun'
						WHEN shipping_Month = 7 THEN 'Jul'
						WHEN shipping_Month = 8 THEN 'Aug'
						WHEN shipping_Month = 9 THEN 'Sep'
						WHEN shipping_Month = 10 THEN 'Oct'
						WHEN shipping_Month = 11 THEN 'Nov'
						WHEN shipping_Month = 12 THEN 'Dec'
						end

select left(shipping_limit_date, 10)
from olist_order_items

update olist_order_items
set shipping_limit_date = left(shipping_limit_date, 10)


-----order payment table
---here we check for outliers
-----duplicate transactions
-----missing values

-----outliers
select min(Payment_value), max(Payment_value)----, min(freight_value), max(freight_value)
from  olist_order_payments

select distinct payment_sequential
from olist_order_payments

----checking throu for missing values
select *				
from olist_order_payments
where order_id = ' ' or payment_sequential = ' ' or payment_type = ' ' or payment_installments = ' ' or payment_value = ' '
 ----no missing values

-----checking through for duplicate records
with order_pymt_cte(order_id, payment_sequential, payment_type, payment_installments, payment_value, rank_)
as
(
select *, row_number () over(partition by order_id, payment_sequential, payment_type, payment_installments, payment_value
						order by order_id) as rank_
			from olist_order_payments
)

select * from order_pymt_cte
--where rank_ >1

----no duplicate transactions

-----orders table
---here we check for outliers
-----duplicate transactions
-----missing values
-----creating additional tables to hold dates and time

---here we check for missing values
select * from olist_orders
where order_status = 'unavailable' and order_approved_at = ' ' or order_delivered_carrier_date = ' ' or order_delivered_customer_date = ' ' 
								or order_estimated_delivery_date = ' '
select * from olist_orders
where order_status = 'invoiced' and order_delivered_carrier_date = ' ' and order_delivered_customer_date = ' ' 

alter table olist_orders
add order_purchase_date date
	,order_purchase_year varchar (10)
	,order_purchase_month varchar (10)
	,order_purchase_quarter varchar (10)

----filling them with data
select order_purchase_timestamp,  left(order_purchase_timestamp, 10) as order_date, year(order_purchase_timestamp)
from olist_orders


update olist_orders
set order_purchase_date = left(order_purchase_timestamp, 10)
	,order_purchase_year = year(order_purchase_timestamp)
	,order_purchase_month = month(order_purchase_timestamp)

update olist_orders
set order_purchase_quarter = case when order_purchase_month <=3 then 1
							when order_purchase_month >3 and order_purchase_month <=6 then 2
							when order_purchase_month >6 and order_purchase_month <=9 then 3
							when order_purchase_month >9 and order_purchase_month <=12 then 4
							end
update olist_orders
set order_purchase_month = case  WHEN order_purchase_month = 1 THEN 'Jan'
						WHEN order_purchase_month = 2 THEN 'Feb'
						WHEN order_purchase_month = 3 THEN 'Mar'
						WHEN order_purchase_month = 4 THEN 'Apr'
						WHEN order_purchase_month = 5 THEN 'May'
						WHEN order_purchase_month = 6 THEN 'Jun'
						WHEN order_purchase_month = 7 THEN 'Jul'
						WHEN order_purchase_month = 8 THEN 'Aug'
						WHEN order_purchase_month = 9 THEN 'Sep'
						WHEN order_purchase_month = 10 THEN 'Oct'
						WHEN order_purchase_month = 11 THEN 'Nov'
						WHEN order_purchase_month = 12 THEN 'Dec'
						end


----checking for duplicate transactions
with order_check_cte(customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date
						,order_estimated_delivery_date, rank_)
as
(
		select customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date
						,order_estimated_delivery_date, row_number () over (partition by customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date
						,order_estimated_delivery_date order by customer_id) as rank_
		from olist_orders

)

select customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date
						,order_estimated_delivery_date, rank_ 
from order_check_cte
where rank_ >1


-----there are no duplicate transactions in the order table

select * from olist_orders
alter table olist_orders
add order_time varchar (10)

update olist_orders
set order_time = right(order_purchase_timestamp, 8)

update olist_orders
set order_purchase_timestamp = left(order_purchase_timestamp, 10)

select distinct order_status from olist_orders

-----products table
select * from olist_products
select distinct product_category_name from olist_products

select distinct product_id from olist_products

---checking through products table for missing values
 select * from olist_products
 where product_id = ' ' or product_category_name = ' ' or product_name_lenght = ' ' or product_description_lenght = ' '
						or product_photos_qty = ' ' 

----here we can observe that some rows have missing values 
----they are: (or product_weight_g, product_length_cm, product_height_cm, product_width_cm, 2rows)
------ (product_category_name, product_name_lenght, product_description_lenght, product_photos_qty  610 rows)



------checking for duplicates in the products table

with product_cte(product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, 
					product_weight_g, product_length_cm, product_height_cm, product_width_cm, rank_)
as
(
		select product_id, product_category_name, product_name_lenght,product_description_lenght, product_photos_qty, 
					product_weight_g, product_length_cm, product_height_cm, product_width_cm, row_number () over (partition by product_id, product_category_name, product_name_lenght,product_description_lenght, product_photos_qty, 
					product_weight_g, product_length_cm, product_height_cm, product_width_cm order by product_id) as rank_
		from olist_products

)

select product_id, product_category_name, product_name_lenght,product_description_lenght, product_photos_qty, 
					product_weight_g, product_length_cm, product_height_cm, product_width_cm, rank_ 
from product_cte
where rank_ >1

-----there are no duplicate records in the products table

------sellers table
---here we check for outliers
-----duplicate transactions
-----missing values

select * from olist_sellers

select distinct seller_id from olist_sellers
select distinct seller_zip_code_prefix from olist_sellers
select distinct seller_city from olist_sellers
select distinct seller_state from olist_sellers

-----missing values
select * from olist_sellers
where seller_id = ' ' or seller_zip_code_prefix = ' ' or seller_city = ' ' or seller_state = ' '

----no missing values

-----checking for duplicate seller details
with seller_cte(seller_id, seller_zip_code_prefix, seller_city, seller_state, rank_)
as
(
		select seller_id, seller_zip_code_prefix, seller_city, seller_state,
				row_number () over (partition by seller_id, seller_zip_code_prefix, seller_city, seller_state 
				order by seller_id) as rank_
		from olist_sellers

)

select seller_id, seller_zip_code_prefix, seller_city, seller_state, rank_ 
from seller_cte
where rank_ >1
----------------------------
----no duplicate seller information

----product translation table
select * from olist_producttranslation
order by 1 asc
select distinct product_category_name from olist_products
where product_category_name != ' '
order by 1 asc


select* from Olist_reviews
where review_score = ' '

select distinct review_score, count(review_score) from Olist_reviews
group by review_score
order by 1 desc


