/*

Cleaning Data in SQL Queries

*/

Select *
From Nashville_Housing_Data.Nashville_Housing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select str_to_date(saledate, "%M %d, %Y") saleDateConverted
From Nashville_Housing_Data.Nashville_Housing;


Update Nashville_Housing_Data.Nashville_Housing
SET SaleDate = str_to_date(saledate, "%M %d, %Y");

-- If it doesn't Update properly

ALTER TABLE Nashville_Housing_Data.Nashville_Housing
Add SaleDateConverted Date;

Update Nashville_Housing_Data.Nashville_Housing
SET SaleDateConverted = cast(saledate as Date);

Select SaleDate from Nashville_Housing_Data.Nashville_Housing order by SaleDate desc;
Select SaleDateConverted from Nashville_Housing_Data.Nashville_Housing order by SaleDate desc;


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From Nashville_Housing_Data.Nashville_Housing
-- Where PropertyAddress is null
order by ParcelID;

Select PropertyAddress
From Nashville_Housing_Data.Nashville_Housing
-- Where PropertyAddress is null;


-- As there is no null Property address
-- Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
-- From Nashville_Housing_Data.Nashville_Housing a
-- JOIN Nashville_Housing_Data.Nashville_Housing b
-- 	on a.ParcelID = b.ParcelID
-- 	AND a.UniqueID <> b.UniqueID
-- Where a.PropertyAddress is null;


-- Update a
-- SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
-- From Nashville_Housing_Data.Nashville_Housing a
-- JOIN Nashville_Housing_Data.Nashville_Housing b
-- 	on a.ParcelID = b.ParcelID
-- 	AND a.[UniqueID ] <> b.[UniqueID ]
-- Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From Nashville_Housing_Data.Nashville_Housing
-- Where PropertyAddress is null
-- order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress)) as Address
From Nashville_Housing_Data.Nashville_Housing


ALTER TABLE Nashville_Housing_Data.Nashville_Housing
Add PropertySplitAddress Nvarchar(255);

Update Nashville_Housing_Data.Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1 );


ALTER TABLE Nashville_Housing_Data.Nashville_Housing
Add PropertySplitCity Nvarchar(255);

Update Nashville_Housing_Data.Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress));


Select *
From Nashville_Housing_Data.Nashville_Housing;


Select OwnerAddress
From Nashville_Housing_Data.Nashville_Housing;


Select
SUBSTRING_INDEX(OwnerAddress, ',', 1)
,SUBSTRING_INDEX(SUBSTRING(OwnerAddress, LOCATE(',', OwnerAddress)+1 ), ',', 1)
,SUBSTRING(SUBSTRING(OwnerAddress, LOCATE(',', OwnerAddress)+1 ), locate(',', SUBSTRING(OwnerAddress, LOCATE(',', OwnerAddress)+1 ))+1) 
From Nashville_Housing_Data.Nashville_Housing;


ALTER TABLE Nashville_Housing_Data.Nashville_Housing
Add OwnerSplitAddress Nvarchar(255);

Update Nashville_Housing_Data.Nashville_Housing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);


ALTER TABLE Nashville_Housing_Data.Nashville_Housing
Add OwnerSplitCity Nvarchar(255);

Update Nashville_Housing_Data.Nashville_Housing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING(OwnerAddress, LOCATE(',', OwnerAddress)+1 ), ',', 1);


ALTER TABLE Nashville_Housing_Data.Nashville_Housing
Add OwnerSplitState Nvarchar(255);

Update Nashville_Housing_Data.Nashville_Housing
SET OwnerSplitState = SUBSTRING(SUBSTRING(OwnerAddress, LOCATE(',', OwnerAddress)+1 ), locate(',', SUBSTRING(OwnerAddress, LOCATE(',', OwnerAddress)+1 ))+1);


Select *
From Nashville_Housing_Data.Nashville_Housing;



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville_Housing_Data.Nashville_Housing
Group by SoldAsVacant
order by 2;


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Nashville_Housing_Data.Nashville_Housing;


Update Nashville_Housing_Data.Nashville_Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

delete from Nashville_Housing_Data.Nashville_Housing 
where ParcelID in
(WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Nashville_Housing_Data.Nashville_Housing
-- order by ParcelID
)
select ParcelID
From RowNumCTE
Where row_num > 1);
-- Order by PropertyAddress;

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Nashville_Housing_Data.Nashville_Housing
-- order by ParcelID
)
select *
From RowNumCTE
Where row_num > 1;


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From Nashville_Housing_Data.Nashville_Housing;


ALTER TABLE Nashville_Housing_Data.Nashville_Housing
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress, 
DROP COLUMN SaleDate;



-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
