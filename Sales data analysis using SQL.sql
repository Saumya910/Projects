

--cleaning data in sql queries
--------------------------------
select *
from PortfolioProjects.dbo.Nashvilehousing

------------------------------------------------------------------------------------------------------------------------------------------------------------

--standardize data format

--select SaleDate, CONVERT(date,SaleDate)
--from PortfolioProjects.dbo.Nashvilehousing

--update PortfolioProjects.dbo.Nashvilehousing
--set SaleDate=CONVERT(date,SaleDate)


alter table PortfolioProjects.dbo.Nashvilehousing
add saledateconverted date;

update PortfolioProjects.dbo.Nashvilehousing
set saledateconverted = CONVERT(date,SaleDate)

select saledateconverted, CONVERT(date,SaleDate),SaleDate
from PortfolioProjects.dbo.Nashvilehousing

----------------------------------------------------------------------------------------------------------------------------------------------------------------

--populate property address data


select PropertyAddress 
from PortfolioProjects.dbo.Nashvilehousing
where PropertyAddress is null

select *
from PortfolioProjects.dbo.Nashvilehousing
where PropertyAddress is null

select *
from PortfolioProjects.dbo.Nashvilehousing
--where PropertyAddress is null
order by ParcelID 


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProjects.dbo.Nashvilehousing a
join PortfolioProjects.dbo.Nashvilehousing b
     on a.ParcelID=b.ParcelID
	 and a.UniqueID<>b.UniqueID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProjects.dbo.Nashvilehousing a
join PortfolioProjects.dbo.Nashvilehousing b
     on a.ParcelID=b.ParcelID
	 and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProjects.dbo.Nashvilehousing a
join PortfolioProjects.dbo.Nashvilehousing b
     on a.ParcelID=b.ParcelID
	 and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress) 
from PortfolioProjects.dbo.Nashvilehousing a
join PortfolioProjects.dbo.Nashvilehousing b
     on a.ParcelID=b.ParcelID
	 and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------------------------------------------------

--breaking out address into individual columns (address, city, state)

select PropertyAddress 
from PortfolioProjects.dbo.Nashvilehousing

select 
substring (PropertyAddress, 1, charindex(',',PropertyAddress)-1) as Address,
substring (PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress)) as City
from PortfolioProjects.dbo.Nashvilehousing

alter table PortfolioProjects.dbo.Nashvilehousing
add PropertySplitAddress Nvarchar(255);

update PortfolioProjects.dbo.Nashvilehousing
set PropertySplitAddress = substring (PropertyAddress, 1, charindex(',',PropertyAddress)-1)

alter table PortfolioProjects.dbo.Nashvilehousing
add PropertySplitCity Nvarchar(255);

update PortfolioProjects.dbo.Nashvilehousing
set PropertySplitCity = substring (PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress))


select *
from PortfolioProjects.dbo.Nashvilehousing

-- same for owners address but in a much simpler way is as follows-

select OwnerAddress
from PortfolioProjects.dbo.Nashvilehousing

select OwnerAddress,
PARSENAME(Replace(OwnerAddress, ',','.'), 3),
PARSENAME(Replace(OwnerAddress, ',','.'), 2),
PARSENAME(Replace(OwnerAddress, ',','.'), 1)
from PortfolioProjects.dbo.Nashvilehousing

alter table PortfolioProjects.dbo.Nashvilehousing
add OwnerySplitAddress Nvarchar(255);

update PortfolioProjects.dbo.Nashvilehousing
set OwnerySplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'), 3)

alter table PortfolioProjects.dbo.Nashvilehousing
add OwnerSplitCity Nvarchar(255);

update PortfolioProjects.dbo.Nashvilehousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'), 2)

alter table PortfolioProjects.dbo.Nashvilehousing
add OwnerSplitState Nvarchar(255);

update PortfolioProjects.dbo.Nashvilehousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'), 1)

select *
from PortfolioProjects.dbo.Nashvilehousing

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to yes and No in "Sold as Vacant" Field

select distinct(SoldAsVacant)
from PortfolioProjects.dbo.Nashvilehousing

select distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProjects.dbo.Nashvilehousing
Group by SoldAsVacant
Order by SoldAsVacant

select distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProjects.dbo.Nashvilehousing
Group by SoldAsVacant
Order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' Then 'Yes'
     when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant
	 end
from PortfolioProjects.dbo.Nashvilehousing

update Nashvilehousing
set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'Yes'
     when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant
	 end
from PortfolioProjects.dbo.Nashvilehousing

---------------------------------------------------------------------------------------------------------------------------------------------------------------------

--remove duplicates

with RowNumCTE as(
select *,
ROW_NUMBER() over (
partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
order by UniqueID ) as row_num
from PortfolioProjects.dbo.Nashvilehousing
--order by ParcelID
)
--select *
--from RowNumCTE
--Where row_num > 1
--order by PropertyAddress

Delete
from RowNumCTE
Where row_num > 1

----------------------------------------------------------------------------------------------------------------------------------------------------

--delete unused columns

select *
from PortfolioProjects.dbo.Nashvilehousing

alter table PortfolioProjects.dbo.Nashvilehousing
drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

----------------------------------------------------------------------------------------------------------------------------------------------------
--getting property of highest price


select *
from PortfolioProjects..Nashvilehousing
where TotalValue = (select Max(TotalValue) from
						PortfolioProjects..Nashvilehousing)



----------------------------------------------------------------------------------------------------------------------------------------------------

--average price of land for different cities


select PropertySplitCity, AVG(LandValue/Acreage) as AveragePriceOfLand
from PortfolioProjects..Nashvilehousing
where LandValue is not null
Group by PropertySplitCity
order by AveragePriceOfLand


----------------------------------------------------------------------------------------------------------------------------------------------------

--No of properties having different no of rooms in all cities

select PropertySplitCity, Bedrooms as NoOfBedrooms, Count(UniqueID) as NoOfProperties
from PortfolioProjects..Nashvilehousing
where Bedrooms is Not Null
Group by Bedrooms, PropertySplitCity
order by Bedrooms