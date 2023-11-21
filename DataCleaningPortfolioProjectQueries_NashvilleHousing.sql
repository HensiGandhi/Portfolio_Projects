/*

Cleaning Data in SQL Queries

*/

Select *
From Portfolio_Project..NashvilleHousing


--Standardize Data Format

Select SaleDate, Convert(date, SaleDate)
From Portfolio_Project..NashvilleHousing


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted
From Portfolio_Project..NashvilleHousing


--Populate Property Address Data

Select *
From Portfolio_Project.dbo.NashvilleHousing 
--where propertyAddress is  null 
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null



-- Breaking out Address into Individual Columns(Address,City,States)

Select PropertyAddress
From Portfolio_Project.dbo.NashvilleHousing 
--where propertyAddress is  null 
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress) ) as Address

From Portfolio_Project.dbo.NashvilleHousing 



Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress) ) 


Select *
From Portfolio_Project..NashvilleHousing

Select OwnerAddress
From Portfolio_Project..NashvilleHousing


Select
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
From Portfolio_Project..NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
Set OwnerSplitAddress= PARSENAME(Replace(OwnerAddress,',','.'),3)


Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)


Select *
From Portfolio_Project..NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsvacant), Count(SoldAsvacant)
From Portfolio_Project..NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant
, Case WHEN SoldAsVacant = 'Y' then 'Yes'
	WHEN SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END 
From Portfolio_Project..NashvilleHousing



Update NashvilleHousing
SET SoldAsVacant = Case WHEN SoldAsVacant = 'Y' then 'Yes'
	WHEN SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END 



--Remove the duplicates


with RowNumCTE AS (
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					uniqueID
					) row_num
							
From Portfolio_Project..NashvilleHousing
--order by ParcelID
)

Select *
--Delete
From RowNumCTE
where row_num > 1
order by PropertyAddress


Select *
From Portfolio_Project..NashvilleHousing


-- Delete Unused Columns


Alter Table Portfolio_Project..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

