
USE Potfolio_Projects
GO

DROP TABLE FIFA_DATASET_01

SELECT *FROM FIFA_DATA_01
ORDER BY Overall_Player_Rating DESC


-----Step 1: we start by renaming the columns

sp_rename 'dbo.FIFA_DATA_01.Player_Rating', 'Overall_Player_Rating', 'COLUMN'
sp_rename 'dbo.FIFA_DATA_01.playerUrl', 'Player_URL', 'COLUMN'
sp_rename 'dbo.FIFA_DATA_01.photoUrl', 'Photo_URL', 'COLUMN'




--Step 2: Extracting Player Names fron Player_URL
---we create a dummy column
ALTER TABLE FIFA_DATA_01
ADD Player_Name VARCHAR (100)

UPDATE FIFA_DATA_01
SET Player_Name = SUBSTRING(Player_URL, 33, len(Player_URL)-1)

---then we update the longname column
UPDATE FIFA_DATA_01
SET LongName = SUBSTRING(Player_Name, 1, CHARINDEX('/',Player_Name)-1)


UPDATE FIFA_DATA_01
SET LongName = 'Christiano Ronaldo'
WHERE Longname LIKE '%-ronaldo-dos-santos-aveiro%'

---Step 3: Change names to Upper case

UPDATE FIFA_DATA_01
SET LongName = UPPER(LongName)


-----Step 4: Checking for Duplicate records
WITH Ran_CTE (LongName, Row_Num)
AS
(

SELECT LongName, ROW_NUMBER() OVER
							(PARTITION BY LongName, Nationality ORDER BY LongName) AS ROW_NUM
				FROM FIFA_DATA_01
)

SELECT LongName, ROW_NUM FROM Ran_CTE
WHERE ROW_NUM >1

---it can be observed that we have duplicate records in our dataset

---Step 5: Fixing Contract Column

---We start by creating additional columns

ALTER TABLE FIFA_DATA_01
ADD Contract_Status VARCHAR (50),
	Contract_Start VARCHAR (50),
	Contract_End VARCHAR (50)
-----Adding values to the Contract Type field

	UPDATE FIFA_DATA_01
	SET Contract_Status = CASE WHEN Contract LIKE '%On Loan%' THEN 'On Loan'
							WHEN Contract LIKE '%Free%' THEN 'No_Active_Contract'
						ELSE 'Active'
						END

-----Separating the years in the Contract field

SELECT Contract, Contract_Status, Joined, SUBSTRING(Contract, 1, 4) AS Join_Year, SUBSTRING(Contract, 8, LEN(Contract)) AS End_Year, Contract_Start
FROM FIFA_DATA_01

---Filling the contract_start year column
UPDATE FIFA_DATA_01 
SET Contract_Start = RIGHT(Joined, 4)

------Filling the contract_end year column 

UPDATE FIFA_DATA_01 
SET Contract_End = CASE
						WHEN Contract LIKE '%Loan%' THEN SUBSTRING(Contract, 8, CHARINDEX(' ', Contract)+1)
						ELSE RIGHT(Contract, 4)
						END 
 sp_rename 'dbo.FIAF_DATA_01.Contract', 'Contract_Status', 'COLUMN'

-----Cleaning the Height column
sp_rename 'dbo.FIFA_DATA_01.Height','Player_Height(cm)' ,'COLUMN'

---Here we use the case statement to convert and substring to select specific aspect of values in the column

---Updating the height column 

UPDATE FIFA_DATA_01
SET [Player_Height(cm)] = CASE 
							WHEN [Player_Height(cm)] LIKE '%''%"' THEN
							TRY_CONVERT(DECIMAL(10,2), SUBSTRING([Player_Height(cm)], 1, CHARINDEX('''', [Player_Height(cm)])-1))*30.48+
							TRY_CONVERT(DECIMAL(10,2), SUBSTRING([Player_Height(cm)], CHARINDEX('''', [Player_Height(cm)])+1, LEN([Player_Height(cm)])-CHARINDEX('''', [Player_Height(cm)])-1))*2.54 
							WHEN [Player_Height(cm)] LIKE '%"' THEN TRY_CONVERT(DECIMAL (10,2), SUBSTRING([Player_Height(cm)], 1, LEN([Player_Height(cm)])-2))*2.54
							ELSE
							TRY_CONVERT(DECIMAL(10,2),SUBSTRING([Player_Height(cm)], 1, LEN([Player_Height(cm)])-2)) 
				END
			
----Reducing the number of digits after the decimal
UPDATE FIFA_DATA_01
SET [Player_Height(cm)] = SUBSTRING([Player_Height(cm)],1,6)


----Cleaning the weight column

 ----renaming the Weight column
 sp_rename 'dbo.FIFA_DATA_01.Weight', 'Player_Weight(kg)', 'COLUMN'
 
 UPDATE FIFA_DATA_01
 SET [Player_Weight(kg)] = CASE
				WHEN [Player_Weight(kg)] LIKE '%lbs%' THEN
				TRY_CONVERT(DECIMAL(6,2), SUBSTRING([Player_Weight(kg)], 1, LEN([Player_Weight(kg)])-3))*0.45359237
				
				ELSE
				TRY_CONVERT(DECIMAL(6,2),SUBSTRING([Player_Weight(kg)], 1, LEN([Player_Weight(kg)])-2))
				END

----Reducing the number of decimals/ characters in the column

UPDATE FIFA_DATA_01
SET [Player_Weight(kg)] = SUBSTRING([Player_Weight(kg)], 1, 5)


 
 ----Cleaning the value column
 ----first we create a dummy column called Player Value or P_Value
ALTER TABLE FIFA_DATA_01
ADD P_Value VARCHAR (50)

----then we eliminate the preceeding charcaters before the numbers by using a substring and case statement
UPDATE FIFA_DATA_01
SET P_Value = CASE WHEN Value LIKE '%M%'  THEN  SUBSTRING(Value, 4, LEN(Value)-1)
					WHEN Value LIKE  '%K%' THEN  SUBSTRING(Value, 4, LEN(Value)-1)
				ELSE SUBSTRING(Value, 4, LEN(Value))
				END
----Thirdly we run our conversion using try_convert while also using a case statement to specify what should be done at specific instances
SELECT Value, P_Value, 
					CASE 
						WHEN P_Value LIKE '%M%' THEN TRY_CONVERT(DECIMAL(10,2), REPLACE(P_Value, 'M', ''))*1000000
						WHEN P_Value LIKE '%K%' THEN TRY_CONVERT(DECIMAL(10,2), REPLACE(P_Value,'K', ''))*1000
						
						ELSE P_Value
						END AS VValue
				FROM FIFA_DATA_01
----now that the above syntax works, we will then update the value field

UPDATE FIFA_DATASET_01
SET Value = CASE 
						WHEN P_Value LIKE '%M%' THEN TRY_CONVERT(DECIMAL(10,2), REPLACE(P_Value, 'M', ''))*1000000
						WHEN P_Value LIKE '%K%' THEN TRY_CONVERT(DECIMAL(10,2), REPLACE(P_Value,'K', ''))*1000
						ELSE P_Value
					END 

sp_rename 'dbo.FIFA_DATA_01.Value', 'Player_Value', 'COLUMN'

-----Wage Column
 ----Just lik earlier, we create a dummy column
 ALTER TABLE FIFA_DATA_01
 ADD WWage VARCHAR (50)

 --Test extraction using select statement
  SELECT Wage, SUBSTRING([Player_Wage], 4, LEN([Player_Wage]))
					FROM FIFA_DATA_01
					--WHERE Wage NOT LIKE '%K%'
----implement extraction
 UPDATE FIFA_DATA_01
 SET WWage =   SUBSTRING([Player_Wage], 4, LEN([Player_Wage]))
					
----writing our test conversion syntax
					SELECT Wage, CASE 
									WHEN WWage LIKE '%K%' THEN TRY_CONVERT(DECIMAL (10,2), REPLACE(WWage, 'K', ' ')) * 1000
									ELSE WWage
									END AS Player_Wage
					FROM FIFA_DATASET_01
----Now that our syntax has worked we can proceed to update the Wage Column
					
UPDATE FIFA_DATA_01
 SET [Player_Wage] = CASE 
					WHEN WWage LIKE '%K%' THEN TRY_CONVERT(DECIMAL (10,2), REPLACE(WWage, 'K', ' ')) * 1000
					ELSE WWage
					END
sp_rename 'dbo.FIFA_DATA_01.Wage', 'Player_Wage', 'COLUMN'

-----Release Clause Column ---As usual we create our dummy column
ALTER TABLE FIFA_DATA_01
ADD PRC VARCHAR (50)
---Now we test our substring syntax for extraction
SELECT [Release Clause],  SUBSTRING([Release Clause], 4, LEN([Release Clause]))
FROM FIFA_DATA_01
WHERE [Release Clause] NOT LIKE '%M%'

----here we populate the newly created column with data
UPDATE FIFA_DATA_01
SET PRC = SUBSTRING([Release Clause], 4, LEN([Release Clause]))

----Now we run our conversion and test

SELECT [Release Clause],PRC, CASE
								WHEN PRC LIKE '%M%' THEN TRY_CONVERT(DECIMAL (10,2),REPLACE(PRC, 'M', ''))*1000000
								WHEN PRC LIKE '%K%' THEN TRY_CONVERT(DECIMAL (10,2),REPLACE(PRC, 'K', ''))*1000
								ELSE PRC						END AS PlayerRC
FROM FIFA_DATA_01
---Now that our syntax is working properly, we can now update the release clause column
 sp_rename 'dbo.FIFA_DATA_01.Release Clause', 'Player_Release_Clause(€)','COLUMN'

UPDATE FIFA_DATA_01
SET [Player_Release_Clause(€)] = CASE 
									WHEN PRC LIKE '%M%' THEN TRY_CONVERT(DECIMAL (10,2), REPLACE(PRC, 'M', ''))*1000000
									WHEN PRC LIKE '%K%' THEN TRY_CONVERT(DECIMAL (10,2), REPLACE(PRC, 'K', ''))*1000
									ELSE PRC
									END


----cleaning the W F and SM columns
--- W F
SELECT [W F], LEFT([W F], 1)
FROM FIFA_DATA_01

UPDATE FIFA_DATA_01
SET [W F] = LEFT([W F], 1)

---SM

SELECT SM, LEFT(SM, 1)
FROM FIFA_DATA_01

UPDATE FIFA_DATA_01
SET [SM] = LEFT(SM, 1)

----IR
SELECT IR, LEFT(IR, 1)
FROM FIFA_DATA_01

UPDATE FIFA_DATA_01
SET IR = LEFT(IR, 1)


----Cleaning the HIts Column

SELECT  Hits FROM FIFA_DATA_01
--WHERE Hits LIKE '%K%'
 
 ----this cleaned the hits column

UPDATE FIFA_DATA_01
SET Hits = TRY_CONVERT(DECIMAL (10,1), SUBSTRING(Hits, 1, CHARINDEX('K', Hits)-1))*1000
WHERE Hits LIKE '%K%'

-----Removing the decimals by extracting integers only
SELECT Hits, LEFT(Hits,4)  
FROM FIFA_DATA_01
WHERE Hits LIKE '%.%'

UPDATE FIFA_DATA_01
SET Hits = LEFT(Hits,4)
WHERE Hits LIKE '%.%'


-----Cleaning positions column, replacing , with -

SELECT Positions --REPLACE(Positions, ',', '-') AS PPositions
FROM FIFA_DATA_01

UPDATE FIFA_DATA_01
SET Positions = REPLACE(Positions, ',', '-')


