
USE Portfolio_Projects_01
GO

--Bismillah

----Fitness Data Cleaning
----Converting columns to correct data types
----dealing with missing data in original price column
----Extracting values from texts in columns
-----fixing column names

select [Current Price], Cast([Current Price] as Float), try_convert(Decimal (10,2), [Current Price])
from fitness_data


----current price column
update fitness_data
set [Current Price] = try_convert(decimal (10,2), [Current Price])

----original price
update fitness_data
set [Original_Price] = try_convert(decimal (10,2), [Original_Price])

---ratings column
update fitness_data
set [Rating] = try_convert(decimal (10,1), [Rating])

-----populating the original price column

select brand, [Current Price], [original price], [Discount Percentage]
from Fitness_Data
where [Discount Percentage] = 0 and [Current Price] is not null and [original price] is null 

update Fitness_Data
set [Original Price]= [Current Price]
where [Discount Percentage] = 0 and [Current Price] is not null and [original price] is null


select brand, [Current Price], [original price], [Discount Percentage]
from Fitness_Data
where [Current Price] is not null and [original price] is not null


select * from Fitness_Data

------extracting values 

select [display size], Left([Display size], 4)
from Fitness_Data
where [Display Size]  like '% %'

update Fitness_Data
set [Display Size]= Left([Display size], 4)
where [Display Size]  like '% %'

-----cleaning the weight column

select [Weight], CASE 
					when [weight] like '%-%' then left([weight], 7)
					when [weight] like '%+%' then left([weight],2)+ '+'
					when [weight] like '%<=%' then left([weight],5)
					end
from Fitness_Data
where [Weight]  like '% %'


update Fitness_Data
set [Weight] = CASE 
					when [weight] like '%-%' then left([weight], 7)
					when [weight] like '%+%' then left([weight],2)+ '+'
					when [weight] like '%<=%' then left([weight],5)
					end
from Fitness_Data
where [Weight]  like '% %'

select distinct [weight]
from Fitness_Data

select * from Fitness_Data

---correcting column names

sp_rename 'dbo.Fitness_data.Current Price','Current_Price', 'COLUMN'
sp_rename 'dbo.Fitness_data.Original Price','Original_Price', 'COLUMN'
sp_rename 'dbo.Fitness_data.Discount Percentage','Discount[%]', 'COLUMN'
sp_rename 'dbo.Fitness_data.Number OF Ratings','Ratings_Count', 'COLUMN'
sp_rename 'dbo.Fitness_data.Model Name','Device_Model', 'COLUMN'
sp_rename 'dbo.Fitness_data.Dial Shape','Device_Shape', 'COLUMN'
sp_rename 'dbo.Fitness_data.Strap Color','Strap_Color', 'COLUMN'
sp_rename 'dbo.Fitness_data.Strap Material','Strap_Material', 'COLUMN'
sp_rename 'dbo.Fitness_data.Battery Life (Days)','Battery_Life[Days]', 'COLUMN'
sp_rename 'dbo.Fitness_data.Display Size','Display_Size["]', 'COLUMN'
sp_rename 'dbo.Fitness_data.Weight','Weight[kg]', 'COLUMN'


select brand, Device_Model
from Fitness_Data
where device_model like '%+%'