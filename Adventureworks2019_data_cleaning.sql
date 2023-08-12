use adventureworks2019
go



-----tables to work with from our DB
-----Sales. Sales Order Header 
-----Sales.Sales Order-Detail 
-----Sales.Customer
-----Sales.Sales_Person
-----Sales.SalesTerritory
-----Production.Product
-----Purchasing.Purchase-Order Header
-----Purchasing.Vendor
-----Purchasing.Purchase-Order Detail
-----Production.Work-Order

 -----data cleaning process
----we will check through for the following anormalies
-------missing values
-------duplicate records
-------outliers
-------expand columns where necessary (e.g date colums)
-------put figures in standard format (rounding them up to two decimal places)

-----for clarity and understanding we will be renaming some tables

select * from sales.SalesOrderHeader
select * from sales.SalesOrderDetail
select * from sales.customer

----order validation table

---checking through for missing values

select * from sales.SalesOrderDetail
---where salesOrderID = ' ' or salesorderdetailid = ' ' or carriertrackingnumber like '% %'
	----	 or orderqty = ' ' or productid = ' ' or unitprice = ' ' 

-----no missing values
---checking for null values
select distinct salesorderid, carriertrackingnumber 
from sales.SalesOrderDetail
where carriertrackingnumber is null 
group by salesorderid, carriertrackingnumber

----here we observe that some selected orders do not have tracking numbers

----here we can see we have null values
----dropping unused columns

-----checking for duplicates

with dup_cte 
as 
( 
	select salesorderid, carriertrackingnumber, productid, unitprice, linetotal
						,row_number () over (partition by salesorderid, productid order by salesorderid) as rank_
	from sales.SalesOrderDetail
	group by salesorderid, carriertrackingnumber, productid, unitprice, linetotal 
)

	select * from dup_cte
	where rank_ > 1
	order by 1

----the result from the cte shows there are no duplicate records in the table

-----checking for outliers

select min(unitprice) as min_price,  max(unitprice) as max_price
from sales.SalesOrderDetail

select * from sales.SalesOrderDetail
where unitprice >= 3000

------standardizing number to two decimal places
select salesorderid, unitprice, round(unitprice, 2) as Product_price
from sales.SalesOrderDetail

update sales.SalesOrderDetail
set unitprice = round(unitprice, 2) 

update sales.salesorderdetail
set ModifiedDate = left ([ModifiedDate], 10) 


select left ([ModifiedDate], 11) from sales.SalesOrderDetail


------sales order header table

select * from sales.SalesOrderHeader

----standardizing columns to 2 decimal places

update sales.SalesOrderHeader
set [SubTotal] = round([SubTotal], 2)

update sales.SalesOrderHeader
set [TaxAmt] = round([TaxAmt], 2)
    ,[Freight] = round([Freight], 2)

----checking length of columns

select salesorderid, revisionnumber, [status], [PurchaseOrderNumber] 
		,[AccountNumber], len([AccountNumber]), [CustomerID], [SalesPersonID]
from sales.SalesOrderHeader
where len([AccountNumber]) = 14

----checking for missing values

select * from sales.SalesOrderHeader
where SalesOrderID = ' ' or OrderDate = ' ' or SalesOrderNumber = ' ' or PurchaseOrderNumber = ' '
		or CustomerID = ' ' or SalesPersonID = ' ' or ShipMethodID = ' ' or TotalDue = ' '

----- no missing values

---- checking for nulls
select * from sales.SalesOrderHeader
where  SalesPersonID is null 

select * from sales.SalesOrderHeader
---we discover that some records have null values in salesPersonID and PurchaseOrderNumber columns



update sales.SalesOrderHeader
set SalesPersonID = 289
where TerritoryID = 10 and SalesPersonID is null

update sales.SalesOrderHeader
set SalesPersonID = 288
where TerritoryID = 8 and SalesPersonID is null

update sales.SalesOrderHeader
set SalesPersonID = 290
where TerritoryID = 7 and SalesPersonID is null

update sales.SalesOrderHeader
set SalesPersonID = 279
where TerritoryID = 5 and SalesPersonID is null

update sales.SalesOrderHeader
set SalesPersonID = 275
where TerritoryID = 2 and SalesPersonID is null


		-
------splitting and standardizing date columns
alter table sales.salesorderheader 
add Order_Date date
	,Order_Month varchar (20)
	,Order_Year varchar (20)
	,Due_date date
	,Ship_Date date
	
------populating newly created columns with data

update sales.SalesOrderHeader
set Order_Date = cast(left(OrderDate, 11) as date)
	,Order_month = month(cast(left(OrderDate, 11) as date))
	,Order_year = year(cast(left(OrderDate, 11) as date))
	,Due_Date  = cast(left(DueDate, 11) as date)
	,Ship_Date = cast(left(ShipDate, 11) as date)
	
update sales.salesorderheader
set Order_month = case when Order_month = 1 then 'Jan'
						When Order_month = 2 then 'Feb'
						When Order_month = 3 then 'Mar'
						When Order_month = 4 then 'Apr'
						When Order_month = 5 then 'May'
						When Order_month = 6 then 'Jun'
						When Order_month = 7 then 'Jul'
						When Order_month = 8 then 'Aug'
						When Order_month = 9 then 'Sep'
						When Order_month = 10 then 'Oct'
						When Order_month = 11 then 'Nov'
						When Order_month = 12 then 'Dec'
						End

-----checking through for duplicate order transactions

with ord_cte 
as
(
	select SalesOrderID, Order_Date, Due_Date, Ship_Date, SalesOrderNumber, PurchaseOrderNumber, AccountNumber 
			,CustomerID, row_number () over (partition by SalesOrderID, SalesOrderNumber, PurchaseOrderNumber, AccountNumber 
			,CustomerID  order by SalesOrderID) as Ranks
	from sales.SalesOrderHeader
	group by SalesOrderID, SalesOrderNumber, PurchaseOrderNumber, AccountNumber 
			,CustomerID, Order_Date, Due_Date, Ship_Date
)
	select * from ord_cte
	where ranks >1

	----there are no duplicate orders in the table

-----Sales.Customer table

select * from sales.Customer

----check length
select *, Len(AccountNumber) as Lenn
from sales.Customer
where Len(AccountNumber) >10

----here lengths are even

select * from sales.Customer
where PersonID is null

-----------Sales.Sales_Person

select * from sales.SalesPerson

----standardizing columns

update sales.SalesPerson
set SalesYTD = round([SalesYTD], 2)

update sales.SalesPerson
set SalesLastYear = round([SalesLastYear], 2)



-----Production.Product
----checking for nulls
select * from Production.Product
where productnumber is null
order by 1

select distinct [class], count([class]) 
from Production.product
group by [class]

select count (*) from production.product
where [class] is null

-----modifying date related columns

select distinct safetystocklevel from Production.product

alter table production.product
add Sales_Start_Date date
	,Sales_Start_Month varchar (20)
	,Sales_Start_Year varchar (20)

update production.product
set Sales_Start_Date = cast(left([SellStartDate], 11) as date)
	,sales_Start_Month = month(cast(left([SellStartDate], 11) as date))
	,Sales_Start_Year = Year(cast(left([SellStartDate], 11) as date))

update production.product
set sales_start_month = case 
						when Sales_Start_Month = 1 then 'Jan'
						When Sales_Start_Month = 2 then 'Feb'
						When Sales_Start_Month = 3 then 'Mar'
						When Sales_Start_Month = 4 then 'Apr'
						When Sales_Start_Month = 5 then 'May'
						When Sales_Start_Month = 6 then 'Jun'
						When Sales_Start_Month = 7 then 'Jul'
						When Sales_Start_Month = 8 then 'Aug'
						When Sales_Start_Month = 9 then 'Sep'
						When Sales_Start_Month = 10 then 'Oct'
						When Sales_Start_Month = 11 then 'Nov'
						When Sales_Start_Month = 12 then 'Dec'
						End

select Size from production.product
where size <> 'null'

select distinct color from production.product
select distinct reorderpoint from production.product

select * from production.product
where size is not null


-----Purchasing.Purchase-Order Header
-----Purchasing.Vendor
-----Purchasing.Purchase-Order Detail
-----Production.Work-Order


select * from sales.SalesOrderHeader

select orderdate, convert(date, orderdate)
from sales.SalesOrderHeader

select * from Purchasing.PurchaseOrderHeader

------standardizing columns

update Purchasing.PurchaseOrderHeader
set OrderDate = left(ShipDate, 11)


update  Purchasing.PurchaseOrderHeader
set SubTotal = round(subtotal, 2)

update  Purchasing.PurchaseOrderHeader
set TaxAmt = round(TaxAmt, 2)

update  Purchasing.PurchaseOrderHeader
set Freight = round(Freight, 2)



------looking our for null and missing values

select * from Purchasing.PurchaseOrderHeader
where  coalesce (PurchaseOrderID, RevisionNumber, [Status], EmployeeId, VendorID, 
					ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight, TotalDue) = ' '

select * from Purchasing.PurchaseOrderHeader
where  coalesce (PurchaseOrderID, RevisionNumber, [Status], EmployeeId, VendorID, 
					ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight, TotalDue) is null

----we have no null or missing values

-------checking for duplicate records

with dup_cte

as
(
select *, row_number () over (partition by PurchaseOrderID order by PurchaseOrderID) rank_

from Purchasing.PurchaseOrderHeader
)

select * from dup_cte
where rank_ >1


select * from Purchasing.PurchaseOrderHeader
group by PurchaseOrderID, RevisionNumber, [Status], EmployeeId, VendorID, 
					ShipMethodID, OrderDate, ShipDate, SubTotal, TaxAmt, Freight, TotalDue, 
					ModifiedDate, Date_Ordered, Year_Ordered, Month_ordered
having count(*) >1


----here we discover we have no duplicate record

select * from Purchasing.ProductVendor
order by 2 desc

select distinct BusinessEntityID, count(BusinessEntityID) from Purchasing.ProductVendor
group by BusinessEntityID
order by 2 desc

-----sales.salesperson
select * from sales.SalesPerson
where TerritoryID is null
select * from sales.SalesTerritory

update sales.salesperson
set TerritoryID = 3
where BusinessEntityID = '274' or BusinessEntityID = '287'
	
update sales.salesperson
set TerritoryID = 9
where BusinessEntityID = '285' 
						