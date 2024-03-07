select *
from PortFolioProject.dbo.NashvilleHousing

--standardize Date Formart

select SaleDateConverted, CONVERT(Date,SaleDate)
from PortFolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)


--populate Property Address Data

select *
from PortFolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.propertyAddress,b.PropertyAddress)
from PortFolioProject.dbo.NashvilleHousing a
JOIN PortFolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is NULL

update a 
SET propertyAddress = ISNULL(a.propertyAddress,b.PropertyAddress)
from PortFolioProject.dbo.NashvilleHousing a
JOIN PortFolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is NULL

--Breaking out Address into individual columns (Address, City, State)

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

from PortFolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(225);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(225);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select *
from PortFolioProject.dbo.NashvilleHousing

select OwnerAddress
from PortFolioProject.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM PortFolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(225);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(225);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(225);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

select *
from PortFolioProject.dbo.NashvilleHousing

--Change Y and N to Yes or No in "sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortFolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'YES'
	 When SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM PortFolioProject.dbo.NashvilleHousing
Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
				   When SoldAsVacant = 'N' THEN 'NO'
				   ELSE SoldAsVacant
				   END

--removing Duplicates

WITH RowNumCTE AS(
Select *,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY
						UniqueID) row_num
FROM PortFolioProject.dbo.NashvilleHousing
--order by ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--Delete Unused Columns

Select *
from PortFolioProject.dbo.NashvilleHousing

Alter Table PortFolioProject.dbo.NashvilleHousing
Drop COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
