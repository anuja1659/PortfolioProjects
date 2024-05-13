SELECT * FROM NashvilleHousing;

--Standardize Date format

Select SaleDate, SaleDateConverted
from NashvilleHousing;

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate);

ALTER table NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate);


--Populate Property Address Data
Select * from NashvilleHousing
--where PropertyAddress is null
order by ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID,
b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) AS MergedPropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE a 
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID] <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

--breaking out address into individual columns(address, city, state)
 select PropertyAddress
 from NashvilleHousing;

 select 
 SUBSTRING(PropertyAddress, 1, 
 CHARINDEX(',',PropertyAddress)) as Address,
  SUBSTRING(PropertyAddress, 
 CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from NashvilleHousing;

ALTER table NashvilleHousing
ADD PropertySplitAddress Varchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, 
 CHARINDEX(',',PropertyAddress)-1) ;

ALTER table NashvilleHousing
ADD PropertySplitCity Varchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, 
 CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress));


 select OwnerAddress
 from NashvilleHousing;

 Select 
 PARSENAME(Replace(OwnerAddress,',','.'),3),
 PARSENAME(Replace(OwnerAddress,',','.'),2),
 PARSENAME(Replace(OwnerAddress,',','.'),1)
 from NashvilleHousing;

 ALTER table NashvilleHousing
ADD OwnerSplitAddress Varchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3) ;

ALTER table NashvilleHousing
ADD OwnerSplitCity Varchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2);

ALTER table NashvilleHousing
ADD OwnerSplitState Varchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1);

Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from NashvilleHousing;

--change Y and N to Yes and No in 'Sold as Vacant' field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2;

select SoldAsVacant
, CASE When SoldAsVacant = 'Y' then 'YES'
       When SoldAsVacant = 'N' then 'No'
       Else SoldAsVacant
       END
from NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'YES'
       When SoldAsVacant = 'N' then 'No'
       Else SoldAsVacant
       END;

-- remove duplicates

WITH RowNumCTE as (
Select *,
     ROW_NUMBER() OVER(
     PARTITION by ParcelID,
                  PropertyAddress,
                  SalePrice,
                  SaleDate,
                  LegalReference
                  ORDER by 
                      UniqueID
                      ) row_num
from NashvilleHousing)
--order by ParcelID;
Select * 
from RowNumCTE
where row_num > 1
Order by PropertyAddress;


--Delete unused Columns

Select * from NashvilleHousing;

Alter table NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

Alter table NashvilleHousing
DROP COLUMN SaleDate ;



