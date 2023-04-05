Select *
From PortfolioProject.DBO.NashvillHousing


-- Standardlize Date Format
SELECT	SaleDateConvert, CONVERT (date, SaleDate)
FROM PortfolioProject.DBO.NashvillHousing

Update PortfolioProject.DBO.NashvillHousing
set SaleDate = CONVERT (date, SaleDate)

-- Add Colums SaleDateConvert and set value SaleDateConvert = CONVERT(date, SaleDate)

ALter Table PortfolioProject.DBO.NashvillHousing
ADD SaleDateConvert date;

Update PortfolioProject.DBO.NashvillHousing
Set SaleDateConvert = CONVERT(date, SaleDate)



-- Populate Property Address data where is Null

SELECT	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.DBO.NashvillHousing a
Join PortfolioProject.dbo.NashvillHousing b
on a.ParcelID = b.ParcelID  and a.[UniqueID ] <> b.[UniqueID ]
--  UniqueID Different beetween a and b to select the different records have the same parceID
where a.PropertyAddress is Null

-- Instead of PropertyAddress = Null by using PrepertyAdress have the same ParceId

Update a
-- Table a Not PortfolioProject.dbo.NashvillHousing because
-- UPDATE statement references the table "PortfolioProject.DBO.NashvillHousing" twice,
-- once as the target of the UPDATE operation, and once as a source in the JOIN clause. 
-- Since both instances of the table have the same name, SQL Server cannot tell which one to use.
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.DBO.NashvillHousing a
Join PortfolioProject.dbo.NashvillHousing b
on a.ParcelID = b.ParcelID  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is Null



-- Breaking out Address into columns Detail - Address, city, state

-- Property Address
SELECT 
    LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1) AS Address_Detail,
	-- = Substring(PropertyAddress, 1 , CHARINDEX(',', PropertyAddress) -1)
    LTRIM(Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))) AS City
	--the purpose of LEN(PropertyAddress) in the SUBSTRING() expression is to ensure that the entire  
	--remaining portion of the  string is included in the substring, regardless of its length.
FROM PortfolioProject.dbo.NashvillHousing

-- Add 2 column PropertyAddressDetail ,PropertyCity and Set value for them

ALter Table PortfolioProject.DBO.NashvillHousing
ADD PropertyAddressDetail nvarchar(255),
PropertyCity nvarchar(255)
go
;

Update PortfolioProject.DBO.NashvillHousing
Set PropertyAddressDetail = LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1) ,
PropertyCity = LTRIM(Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)))

-- Owner Address

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) As State
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2) As City
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) As AddressDetail
From PortfolioProject.DBO.NashvillHousing

-- Add 3 column wnerAddressDetail ,OwnerCityand and OwnerState ; Set value for them

ALter Table PortfolioProject.DBO.NashvillHousing
ADD OwnerAddressDetail nvarchar(255),
OwnerCity nvarchar(255),
OwnerState nvarchar(255)
go
;

Update PortfolioProject.DBO.NashvillHousing
Set OwnerAddressDetail = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



-- Clean the field "SoldAsVacant" . Convet Y/N to YES/NO in this field 

Select distinct(SoldAsVacant), count(SoldAsVacant) as quantity
From PortfolioProject.DBO.NashvillHousing
group by SoldAsVacant
order by quantity 
-- Rerutn 4 value : Y , N , Yes, No and Quantity of them, Order by quantity  ASC

Select 
Case When SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 End
From PortfolioProject.DBO.NashvillHousing

Update PortfolioProject.DBO.NashvillHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 End



-- Remove Duplicate Row have the same value in the columns : 
-- ParcelID, PropertyAddress, SalePrice, SaleDate, and LegalReference


with RowNumCTE as (
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
-- ROW_NUMBER function is a SQL ranking function that assigns a sequential rank number to each new record in a partition.
-- When the SQL Server ROW NUMBER function detects two identical values in the same partition, it assigns different rank numbers to both.
-- The rank number will be determined by the sequence in which they are displayed.
-- In this case, Row Number" assigns a row number "row_num" to each row. 
-- If the rows have the same values in all 5 columns 
-- ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference, 
-- then the row_num will be different. In other words, 
-- if the rows are duplicates, then the row_num will be different
From PortfolioProject.DBO.NashvillHousing

)

-- Delete the rows have row_num > 1 - DELETE DUPLICATE
-- Because in this case, row_num have many value : 1 and value > 1
-- the values > 1 indicate example 2, 3, ...
-- mean the row is duplicated for the 2 times , 3 times, ...

-- SELECT *  
DELETE
From RowNumCTE
Where row_num > 1
-- order by PropertyAddress



-- Delete unused columns . Example you not use SaleDate, OwnerAddress

Alter table PortfolioProject.DBO.NashvillHousing
drop column SaleDate , OwnerAddress

