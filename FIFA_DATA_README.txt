

DATA PREPARATION USING SQL
It is common knowledge that data wrangling/preparation forms an integral part of a data analyst job. According to some experts, a data analyst is likely to spend 60-70% of his/her time preparing data for use. 
Why?
The answer is simple, in most cases our data comes with various errors which could be associated with any of the following; 
•	Spelling errors
•	Duplicate records
•	Outliers
•	Missing values etc
The aforementioned have tendencies to skew the results of our analysis in an incorrect direction and any insights drawn from such analysis will be misleading. Hence the need to clean our data.
The FIFA2021 Dataset was originally gotten from Kaggle and can be accessed here. The dataset contains information about 18,979 football players and 77 columns of the players' statistics and demography in 2021.
For the purpose of this documentation, I will be utilizing the FIFA_dataset provided during  a just concluded datacleaningchallenge.
The data contained information about football players, from their biodata through club information to their abilities and ratings. 
Join me as I take you on this journey highlighting the steps, I took to clean the data
 


Firstly, let me start by pointing out the errors in this dataset
•	Incorrect data types
•	Duplicate entries
•	Errors in spellings and values
•	Irrelevant data 
•	Outliers 

I started out with identifying columns that were compromised thus required cleaning


sp_rename 'dbo.FIFA_DATA_01.Player_Rating', 'Overall_Player_Rating', 'COLUMN'
sp_rename 'dbo.FIFA_DATA_01.playerUrl', 'Player_URL', 'COLUMN'
sp_rename 'dbo.FIFA_DATA_01.photoUrl', 'Photo_URL', 'COLUMN'
   



Next, I moved on to extract the players name from the player_url Column
The reason for this is simple, the player_url housed the correct names of the players, since I am yet to be advanced in sql and unable to write udf to translate the language used in the Longname column, extracting it was the best option.
In order to achieve the extraction, the substring syntax was used

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


Looking out for duplicate records
In order to do this, I wrote the Over and Partition by syntax to rank each individual records based on key columns specified after which some duplicate records were detected.
In as much as we had players with duplicate records, we couldn’t delete them due to that fact that given the dataset, it was possible because a player who is on loan is still tied to his parent club.



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






Cleaning the contract column
This column holds information of players contract start year and contract end year, information for players on loan is also contained.
In order to clean this column, I created three other columns (Contract_Status,	Contract_Start, Contract_End). The Contract_status was to show if the player was an active player, on loan or out of contract/free.

Below is the syntax utilized 














Height Column
Here we can see that there are entry errors, players height were entered using different units of measurement, hence we have to standardize the unit of measurement to clean this column
Using the Try_convert and substring function, I was able to achieve this













Weight Column
Here we can see that there are entry errors, players weight was entered using different units of measurement, hence we have to standardize the unit of measurement to clean this column
Using the Try_convert and substring function, I was able to achieve this
 


















 
Player Value, Wage and Release Clause columns



 

















Skill moves, Injury and Weak Foot ratings
For these columns, I used the LEFT string function to extract the needed values





















 
Hits Column
















 
Joined and position columns



























 

