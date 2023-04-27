USE Data_Cleaning_Proj
GO



----Judging by the data we have, some columns have to be cleaned

------Location, Date,  and Price

----Date column

ALTER TABLE space_missions
ADD Launch_Year VARCHAR (10) ,
	Launch_Month VARCHAR (20)

SELECT Date, YEAR(Date) as launch_year
FROM space_missions

UPDATE space_missions
SET Launch_Year = YEAR(Date)


------Launch Month

SELECT Date, MONTH(Date) as Launch_Month
FROM space_missions

UPDATE space_missions
SET Launch_Month = MONTH(Date)

SELECT Launch_month, CASE 
						WHEN Launch_Month = 1 THEN 'Jan'
						WHEN Launch_Month = 2 THEN 'Feb'
						WHEN Launch_Month = 3 THEN 'Mar'
						WHEN Launch_Month = 4 THEN 'Apr'
						WHEN Launch_Month = 5 THEN 'May'
						WHEN Launch_Month = 6 THEN 'Jun'
						WHEN Launch_Month = 7 THEN 'Jul'
						WHEN Launch_Month = 8 THEN 'Aug'
						WHEN Launch_Month = 9 THEN 'Sep'
						WHEN Launch_Month = 10 THEN 'Oct'
						WHEN Launch_Month = 11 THEN 'Nov'
						WHEN Launch_Month = 12 THEN 'Dec'
						end as MMonth
			FROM space_missions

UPDATE space_missions
SET Launch_Month = CASE 
						WHEN Launch_Month = 1 THEN 'Jan'
						WHEN Launch_Month = 2 THEN 'Feb'
						WHEN Launch_Month = 3 THEN 'Mar'
						WHEN Launch_Month = 4 THEN 'Apr'
						WHEN Launch_Month = 5 THEN 'May'
						WHEN Launch_Month = 6 THEN 'Jun'
						WHEN Launch_Month = 7 THEN 'Jul'
						WHEN Launch_Month = 8 THEN 'Aug'
						WHEN Launch_Month = 9 THEN 'Sep'
						WHEN Launch_Month = 10 THEN 'Oct'
						WHEN Launch_Month = 11 THEN 'Nov'
						WHEN Launch_Month = 12 THEN 'Dec'
						end

SELECT Location, Date, Launch_Year, Launch_month
FROM space_missions

-----Location, here we break the location column into three parts, Launch_site, State and country

ALTER TABLE space_missions
ADD Launch_Add VARCHAR (100)
Launch_Site VARCHAR (100),
	Launch_State VARCHAR (20),
	Country VARCHAR (20)


SELECT Location, PARSENAME(REPLACE(Location, ',', '.'),4) AS Launch_Add,
				PARSENAME(REPLACE(Location, ',', '.'),3) AS Launch_Site,
				PARSENAME(REPLACE(Location, ',', '.'),2)AS Launch_State,
				PARSENAME(REPLACE(Location, ',', '.'),1) AS Country
		FROM space_missions

UPDATE space_missions
SET  Launch_Add = PARSENAME(REPLACE(Location, ',', '.'),4),
	Launch_Site = PARSENAME(REPLACE(Location, ',', '.'),3),
	Launch_State = PARSENAME(REPLACE(Location, ',', '.'),2),
	Country = PARSENAME(REPLACE(Location, ',', '.'),1)


ALTER TABLE space_missions
ADD Launch_Address VARCHAR (255)

UPDATE space_missions
SET Launch_Address = CONCAT(Launch_add, Launch_Site)

----at this point the we observe there are null values in some columns due to the numbe rof split they require

SELECT LEFT(location, 40) as Launch_Add,
SUBSTRING(location, 43, 6) as Launch_State,
RIGHT(location, 3) as Country 
FROM space_missions
WHERE Launch_State IS  NULL

UPDATE space_missions
SET Launch_Address = LEFT(location, 40), 
	Launch_State = SUBSTRING(location, 43, 6),
	Country = RIGHT(location, 3)  
FROM space_missions
WHERE Launch_State IS NULL and Country IS NULL

SELECT * FROM space_missions
WHERE Price <> ' '

-----checking through for duplicate records

WITH space_CTE 
AS (

SELECT Company, Location, Date, Rocket, Mission, RocketStatus, MissionStatus, Country, Launch_Address,

ROW_NUMBER () OVER (
				PARTITION BY Company, Location, Date, Rocket, Mission, RocketStatus, MissionStatus, Country, Launch_Address
				ORDER BY Country) as Row_Num
FROM space_missions
)
SELECT * FROM space_CTE
WHERE  Row_num >1 

ALTER TABLE space_missions
DROP COLUMN Row_Num 

UPDATE space_missions
SET Row_num = ROW_NUMBER () OVER (
				PARTITION BY Company, Location, Date, Rocket, Mission, RocketStatus, MissionStatus, Country, Launch_Address
				ORDER BY Country)

----Here we can observe we have supplicate records

----deleting duplicate records


WITH space_CTE 
AS (

SELECT Company, Location, Date, Rocket, Mission, RocketStatus, MissionStatus, Country, Launch_Address,

ROW_NUMBER () OVER (
				PARTITION BY Company, Location, Date, Rocket, Mission, RocketStatus, MissionStatus, Country, Launch_Address
				ORDER BY Country) as Row_Num
FROM space_missions
)

DELETE FROM space_missions
where row_num >1

----Removing non-essential columns

ALTER TABLE space_missions
DROP COLUMN Launch_Site, Launch_Add

----cleaning the price column

select price 
from space_missions
where price <> ' '
--where price like '%,%'
ORDER BY price DESC


-----using this syntax, it was observed that the figures were rounded up thus skewing the result of the analysis	
SELECT Price, CASE 
					WHEN Price LIKE '%,%' AND Price LIKE '%.%' THEN TRY_CONVERT(DECIMAL (10,2), SUBSTRING(Price, 1, CHARINDEX(',', price)-1))*1000000 +  
					TRY_CONVERT(DECIMAL (10,0), SUBSTRING(Price,3, CHARINDEX('.', price)-1)) *100000
					WHEN Price LIKE '%.%' AND Price <> '%,%' THEN 
					TRY_CONVERT(DECIMAL (10,0), SUBSTRING(Price, 1, CHARINDEX('.', price)-1))*1000000 + 
					TRY_CONVERT(DECIMAL (10,0), RIGHT(Price, LEN(Price)-CHARINDEX('.', price))) *100000
					ELSE
						TRY_CONVERT(DECIMAL (10,0), SUBSTRING(Price, 1, LEN(Price))) *1000000
					END as Amount
				FROM space_missions
				--where price not like '%,%' and price like '%.%'
				where price <> ' '

----SYNTAX TO CORRECT THE PRICE COLUMN

SELECT Price, CASE 
					WHEN Price LIKE '%,%' AND Price LIKE '%.%' THEN TRY_CONVERT(DECIMAL (10,0), SUBSTRING(Price, 1, CHARINDEX(',', price)-1))*1000000
					WHEN Price LIKE '%.%' AND Price <> '%,%' THEN TRY_CONVERT(DECIMAL(10,0), SUBSTRING(Price, 1, CHARINDEX('.', price)-1))*1000000 
					ELSE
						TRY_CONVERT(DECIMAL (10,0), SUBSTRING(Price, 1, LEN(Price))) *1000000
				END AS Amount_Spent, 
			CASE 
					WHEN Price LIKE '%,%' AND Price LIKE '%.%' THEN TRY_CONVERT(DECIMAL (10,0), SUBSTRING(Price,3, CHARINDEX('.', price)-1)) *100000
					WHEN Price LIKE '%.%' AND Price <> '%,%' THEN TRY_CONVERT(DECIMAL (10,0), RIGHT(Price, LEN(Price)-CHARINDEX('.', price))) *100000
					END AS Ammount
					--concat(Amount_Spent, Ammount)
				FROM space_missions
WHERE price <> ' '

---Alternative syntax using left to run the extraction
SELECT Price, CASE 
					WHEN Price LIKE '%,%' AND Price LIKE '%.%' THEN TRY_CONVERT(DECIMAL (10,0), SUBSTRING(Price, 1, CHARINDEX(',', price)-1))*1000000
					WHEN Price LIKE '%.%' AND Price <> '%,%' THEN TRY_CONVERT(DECIMAL(10,0), SUBSTRING(Price, 1, CHARINDEX('.', price)-1))*1000000 
					ELSE
						TRY_CONVERT(DECIMAL (10,0), SUBSTRING(Price, 1, LEN(Price))) *1000000
				END AS Amount_Spent, 
			CASE 
					WHEN Price LIKE '%,%' AND Price LIKE '%.%' THEN TRY_CONVERT(DECIMAL (10,0), RIGHT(Price,LEN(Price)-CHARINDEX(',', price))) *100000
					WHEN Price LIKE '%.%' AND Price <> '%,%' THEN TRY_CONVERT(DECIMAL (10,0), RIGHT(Price, LEN(Price)-CHARINDEX('.', price))) *100000
					END AS Ammount
					--concat(Amount_Spent, Ammount)
				FROM space_missions
WHERE price <> ' '



ALTER TABLE space_missions
ADD Amount_spent DECIMAL (10)
	
UPDATE space_missions
	SET Amount_spent = CASE 
					WHEN Price LIKE '%,%' AND Price LIKE '%.%' THEN TRY_CONVERT(DECIMAL (10,2), SUBSTRING(Price, 1, CHARINDEX(',', price)-1))*1000000 +  
					TRY_CONVERT(DECIMAL (10,0), SUBSTRING(Price,3, CHARINDEX('.', price)-1)) *100000
					WHEN Price LIKE '%.%' AND Price <> '%,%' THEN 
					TRY_CONVERT(DECIMAL (10,0), SUBSTRING(Price, 1, CHARINDEX('.', price)-1))*1000000 + 
					TRY_CONVERT(DECIMAL (10,0), RIGHT(Price, LEN(Price)-CHARINDEX('.', price))) *100000
					ELSE
						TRY_CONVERT(DECIMAL (10,0), SUBSTRING(Price, 1, LEN(Price))) *1000000
					END 
				where price <> ' '

SELECT* FROM space_missions
where price <> ' '

----setting default value 0 for missions whose cost are unknown
UPDATE space_missions
SET [Amount_Spent($)] = CASE 
							WHEN [Amount_Spent($)] IS NULL THEN 0
							ELSE [Amount_Spent($)]
							END

----Renaming and removing unnecessary columns

sp_rename 'dbo.space_missions.Location', 'Launch_Site', 'COLUMN'

UPDATE space_missions
SET launch_site = Launch_Address

ALTER TABLE space_missions
DROP COLUMN Launch_address

ALTER TABLE space_missions
ADD Launch_Hour VARCHAR (20)

UPDATE space_missions
SET Launch_Hour = LEFT(Time, 2)

ALTER TABLE space_missions
ADD Launch_Time VARCHAR (20)

UPDATE space_missions
SET Launch_Time = CASE 
						WHEN Launch_Hour BETWEEN 07 and  18  THEN 'Day'
						ELSE 'Night'
						END 
					WHERE launch_Hour <> ' '


SELECT Time, Launch_Hour, CASE 
						WHEN Launch_Hour BETWEEN 07 and  18  THEN 'Day'
						ELSE 'Night'
						END as Launch_Time
				FROM space_missions
				WHERE launch_Hour <> ' '

ALTER TABLE space_missions
DROP COLUMN Launch_Hour

	select *
	FROM space_missions

UPDATE space_missions
SET Price = Amount_Spent



ALTER TABLE space_missions
DROP COLUMN Amount_spent

sp_rename 'dbo.space_missions.Amount_Spent', 'Amount_Spent($)', 'COLUMN'

---Trimiming to remove spaces within the column
UPDATE space_missions
SET Country = LTRIM(Country)

SELECT * FROM space_missions