-- Cleaning data in SQL Queries

select *
from PortfolioProject..NashvilleHousing

-- Standardize date format

select SaleDateConverted, convert(date,SaleDate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)


-- Populate Property Address data

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address
, substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))


select *
from PortfolioProject..NashvilleHousing


select OwnerAddress
from PortfolioProject..NashvilleHousing


select 
parsename(replace(OwnerAddress, ',', '.'), 3)
, parsename(replace(OwnerAddress, ',', '.'), 2)
, parsename(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)

select *
from PortfolioProject..NashvilleHousing



-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end



-- Remove duplicates

with RowNumCTE as (
select *,
	row_number() over (
	partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by
					UniqueID
					) row_num
					
from PortfolioProject..NashvilleHousing

)

select *
from RowNumCTE
where row_num > 1
order by PropertyAddress



-- Delete Unused Columns

select *
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing 
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject..NashvilleHousing 
drop column SaleDate

