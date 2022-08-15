/* cleaning data */


SELECT * from portfolioProject.dbo.NationalHousing

===================================================================================== 

-- standerising date format 

select SaleDate, CONVERT(date, SaleDate) 
from portfolioProject.dbo.NationalHousing


select SaleDate 
from  portfolioProject.dbo.NationalHousing

alter table portfolioProject.dbo.NationalHousing
add DateConverted Date; 

update portfolioProject.dbo.NationalHousing 
set DateConverted = CONVERT(date, SaleDate)


select SaleDate, DateConverted 
from portfolioProject.dbo.NationalHousing

=====================================================================================  
/*working on property address
*/ 

select * 
from portfolioProject.dbo.NationalHousing
where PropertyAddress is Null 

select PropertyAddress 
from portfolioProject.dbo.NationalHousing
where PropertyAddress is null 

select * 
from portfolioProject.dbo.NationalHousing
where PropertyAddress is null 


select * 
from portfolioProject.dbo.NationalHousing
order by ParcelID 

-- breaking down property address 

select a.[UniqueID ],  a.ParcelID, a.PropertyAddress, b.[UniqueID ],   b.ParcelID, b.PropertyAddress 
from portfolioProject.dbo.NationalHousing a
join portfolioProject.dbo.NationalHousing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
from portfolioProject.dbo.NationalHousing a
join portfolioProject.dbo.NationalHousing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from portfolioProject.dbo.NationalHousing a
join portfolioProject.dbo.NationalHousing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

/*updating proerperty address 
*/ 
update a 
set PropertyAddress= ISNULL(a.PropertyAddress, b.PropertyAddress) 
from portfolioProject.dbo.NationalHousing a
join portfolioProject.dbo.NationalHousing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 



select PropertyAddress 
from portfolioProject.dbo.NationalHousing
--where PropertyAddress is null 
--order by ParcelID 



select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address 
from portfolioProject.dbo.NationalHousing

select 
SUBSTRING (PropertyAddress, 1, 10) 
from portfolioProject.dbo.NationalHousing


select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address, 
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len (PropertyAddress)) as Town
from portfolioProject.dbo.NationalHousing

select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as address, 
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len (PropertyAddress)) as town 
from portfolioProject.dbo.NationalHousing
order by LEN(PropertyAddress) 


/*adding new column for addrss and town
*/

alter table portfolioProject.dbo.NationalHousing
add PropertySplitAddress nvarchar (255)

select * from 
portfolioProject.dbo.NationalHousing

update portfolioProject.dbo.NationalHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


select * from 
portfolioProject.dbo.NationalHousing




alter table portfolioProject.dbo.NationalHousing
add PropertySplitCity nvarchar (255)

select * from 
portfolioProject.dbo.NationalHousing


update portfolioProject.dbo.NationalHousing
set PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))



/*working on owner address

*/ 

select OwnerAddress from 
portfolioProject.dbo.NationalHousing


select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as address, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as city, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as state
from portfolioProject.dbo.NationalHousing




/*adding and updating owner address, city and state
*/ 

alter table portfolioProject.dbo.NationalHousing
add OwnerSplitAddress nvarchar (255)

alter table portfolioProject.dbo.NationalHousing
add OwnerSplitCity nvarchar (255)


alter table portfolioProject.dbo.NationalHousing
add OwnerSplitState nvarchar (255)



update portfolioProject.dbo.NationalHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


update portfolioProject.dbo.NationalHousing
set OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 


update portfolioProject.dbo.NationalHousing
set OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


select * from 
portfolioProject.dbo.NationalHousing


=====================================================================================

/*change entries in column SoldAsVacant from Y to Yes N to No
*/

select distinct (SoldAsVacant), count (SoldAsVacant) as Number  
from portfolioProject.dbo.NationalHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from portfolioProject.dbo.NationalHousing 
order by 1

update portfolioProject.dbo.NationalHousing 
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


select distinct (SoldAsVacant), count (SoldAsVacant) as Number  
from portfolioProject.dbo.NationalHousing
group by SoldAsVacant
order by 2


=====================================================================================

/*removing duplicates */

/*selecting the duplicate rows */
with RowNumCTE as (
select *,  
	row_number()  over(
	partition by ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
				 UniqueID
				 ) row_num
				 
from portfolioProject.dbo.NationalHousing
--order by ParcelID
)
select * from RowNumCTE  
where row_num > 1
order by PropertyAddress 


/*deleting the duplicate rows */
with RowNumCTE as (
select *,  
	row_number()  over(
	partition by ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
				 UniqueID
				 ) row_num
				 
from portfolioProject.dbo.NationalHousing
--order by ParcelID
)
delete 
from RowNumCTE  
where row_num > 1

======================================

/* Deleting unused column */ 

select * 
from portfolioProject.dbo.NationalHousing

alter table portfolioProject.dbo.NationalHousing
drop column SaleDate 


select * 
from portfolioProject.dbo.NationalHousing
