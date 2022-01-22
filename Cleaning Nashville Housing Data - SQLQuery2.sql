-- Cleaning Data in SQL queries

SELECT * 
FROM NashvilleHousing.dbo.NashvilleHousing;

--Changing date format from one to the other
SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM NashvilleHousing.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)


--Populate Property Address Data

SELECT PropertyAddress 
FROM NashvilleHousing.dbo.NashvilleHousing;

--finding null values within property address

SELECT *
FROM NashvilleHousing.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL;

--There are records/rows with null values. However, these null values within the property address are property address with duplicate
--parcel ids, but unique IDs. As such, we will do a self join to be able to pupulate these null values mapping with parcel id to pupulate property address 
--where null. 

SELECT a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousing.dbo.NashvilleHousing a
JOIN NashvilleHousing.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

-- Now given that the two table have been joined by the parcel ID and Unique IDs, we can use ISNULL function to pupulate a.propertyaddress with
--b.property address (since it's not null).
SELECT a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing.dbo.NashvilleHousing a
JOIN NashvilleHousing.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--Now that ISNULL function has been used to populate the missing property addresses. The alia table a. needs to be updated with the 
--ISNULL(a.PropertyAddress, b.PropertyAddress), otherwise we will still be showing null values within the a.propertyaddress columns
-- but with add "unnamed' column created as a result of the IS NULL function created. 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing.dbo.NashvilleHousing a
JOIN NashvilleHousing.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--Now, when we run our original query, we should be getting zero results
SELECT a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing.dbo.NashvilleHousing a
JOIN NashvilleHousing.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


--- BREAKING OUT THE PROPERTY ADDRESS INTO INDIVIDUAL COLUMNS (STREET, CITY, STATE), from its original form where all 
-- were combined. 
SELECT PropertyAddress
FROM NashvilleHousing.dbo.NashvilleHousing

--When we observe the original dataset within the propertyaddress column there's one delimiter (separator) in all the address
-- in this case a comma (,) was used. For us to able to break the address down, we will be using a substring (to extracts some characters from a string)
-- and character index charindex ( to find the position of a substring or expression in a given string.)

SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)) AS Street, 
CHARINDEX(',', PropertyAddress)
FROM NashvilleHousing.dbo.NashvilleHousing

-- Address contains (,) at the end, to remove the address we need to modify the query less the position
SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1) AS Street,
CHARINDEX(',', PropertyAddress)
FROM NashvilleHousing.dbo.NashvilleHousing

--Separating the City
SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1) AS Street,
	SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Street
FROM NashvilleHousing.dbo.NashvilleHousing

--- Now we have to alter table to add the two newly created columns/variables 

ALTER TABLE NashvilleHousing
ADD PropertyStreet NVARCHAR(200);

UPDATE NashvilleHousing
SET PropertyStreet = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
ADD PropertyCity NVARCHAR(200);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--check newly created columns
SELECT * 
FROM NashvilleHousing;


--- BREAKING OUT THE OWNER ADDRESS INTO INDIVIDUAL COLUMNS (STREET, CITY, STATE), from its original form where all 
-- were combined, using PARSENAME this time.
SELECT OwnerAddress
FROM NashvilleHousing.dbo.NashvilleHousing

SELECT
PARSENAME(OwnerAddress, 1)
FROM NashvilleHousing.dbo.NashvilleHousing

--Nothing changed with the above query, given that PARSENAME is only useful with period (.) not (,). Let modify the query to replace
-- (,) with (.):

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing.dbo.NashvilleHousing

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1), 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
FROM NashvilleHousing.dbo.NashvilleHousing

--- The ParseName worked but it worked backward, needs to rearrange after 
SELECT
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing.dbo.NashvilleHousing

--- Now we need to add the newly created columns
ALTER TABLE NashvilleHousing
ADD OwnerStreet NVARCHAR(200);

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


ALTER TABLE NashvilleHousing
ADD OwnerCity NVARCHAR(200);

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerState NVARCHAR(200);

UPDATE NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

--Check Newly Created Columns
SELECT * 
FROM 
NashvilleHousing

--SoldAsVacant currently has 4 distinct variables, that needs to be fixed. 
SELECT DISTINCT (SoldAsVacant)
FROM  NashvilleHousing.dbo.NashvilleHousing

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM  NashvilleHousing.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant) DESC


-- Finding Y and N, and Replacing with Yes and No in SoldAsVacant Column using CASE statement
SELECT SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	     END
FROM  NashvilleHousing.dbo.NashvilleHousing

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM  NashvilleHousing.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant) DESC

--still out there based on the above query, that's because we need to update the column to accept the changes made. 
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				   WHEN SoldAsVacant = 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END

-- Now, should work per the query below: 
SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM  NashvilleHousing.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant) DESC


---REMOVING DEUPLICATES (ITS NOT A STANDARD PRACTISE TO DELET DATA IN DBMS)
SELECT*, 
	ROW_NUMBER()OVER(
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID)
				 row_num
FROM  NashvilleHousing.dbo.NashvilleHousing
ORDER BY ParcelID

--Now creating a CTE based on our query above
---CTE was introduced in SQL Server 2005, the common table expression (CTE) 
--- is a temporary named result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement. 

WITH RowNumCTE AS(
SELECT*, 
	ROW_NUMBER()OVER(
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID)
				 row_num
FROM  NashvilleHousing.dbo.NashvilleHousing
)
SELECT 
--DISTINCT(row_num),
COUNT(row_num)
FROM RowNumCTE
GROUP BY row_num

-- There appears to 104 duplicates, row 2 based on the query above. 
-- Now let's check those duplicates 

WITH RowNumCTE AS(
SELECT*, 
	ROW_NUMBER()OVER(
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID)
				 row_num
FROM  NashvilleHousing.dbo.NashvilleHousing
)
SELECT* 
--DISTINCT(row_num),
--COUNT(row_num)
FROM RowNumCTE
WHERE row_num = 2
ORDER BY PropertyAddress

--- Now let's delete the duplicates found (the 104 rows)
WITH RowNumCTE AS(
SELECT*, 
	ROW_NUMBER()OVER(
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID)
				 row_num
FROM  NashvilleHousing.dbo.NashvilleHousing
)
DELETE 
--DISTINCT(row_num),
--COUNT(row_num)
FROM RowNumCTE
WHERE row_num = 2
--ORDER BY PropertyAddress

--- Double checking to see if duplicates were indeed deleted. 
WITH RowNumCTE AS(
SELECT*, 
	ROW_NUMBER()OVER(
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID)
				 row_num
FROM  NashvilleHousing.dbo.NashvilleHousing
)
SELECT* 
--DISTINCT(row_num),
--COUNT(row_num)
FROM RowNumCTE
WHERE row_num = 2
ORDER BY PropertyAddress

-- No records found. Great!!


--DELETING USED COLUMNS - again not a standard practice to delete info in any database!!
SELECT *
FROM NashvilleHousing.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress

ALTER TABLE NashvilleHousing.dbo.NashvilleHousing
DROP COLUMN SaleDate