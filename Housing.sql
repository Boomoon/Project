--------------------- CLEANING DATA USING SQL --------------------- 

-- Check whether there are missing values for propertyAddress or not
SELECT * from demo.dbo.home 
WHERE propertyAddress is null;

-- One ParcelID can have multiple uniqueIDs, so the propertyAddress should not be null
-- We should consider two columns which are uniqueID and parcelID, in order to do that we need to use self join
SELECT a.uniqueID, a.parcelID, a.propertyAddress, b.uniqueID, b.parcelID, b.propertyAddress, isnull(a.propertyAddress,b.propertyAddress) as updatedPropertyAddress
FROM demo.dbo.home as a
JOIN demo.dbo.home as b
ON a.parcelID=b.parcelID and a.uniqueID <> b.uniqueID
WHERE a.propertyAddress is null;

-- Replace Null propertyAddress with the correct value
UPDATE a 
SET propertyAddress = isnull(a.propertyAddress,b.propertyaddress)
    FROM demo.dbo.home as a
JOIN demo.dbo.home as b
ON a.parcelID=b.parcelID and a.uniqueID <> b.uniqueID
WHERE a.propertyAddress is null;

-- Reheck whether there are missing values for propertyAddress or not
SELECT * from demo.dbo.home 
WHERE propertyAddress is null;

-- Breaking propert address into address and city (1808  FOX CHASE DR, GOODLETTSVILLE -> 1808  FOX CHASE DR and GOODLETTSVILLE)
SELECT propertyAddress, 
substring(propertyAddress,1,charindex(',',propertyAddress)-1) as Address,
substring(propertyAddress,charindex(',',propertyAddress)+1,len(propertyAddress)) as City
FROM demo.dbo.home;

-- Add two new columns 1)Address 2)City
    ALTER TABLE demo.dbo.home
    ADD propSplitAddress varchar(255);

    UPDATE demo.dbo.home
    SET propSplitAddress = substring(propertyAddress,1,charindex(',',propertyAddress)-1);

    ALTER TABLE demo.dbo.home
    ADD propSplitCity varchar(255);

    UPDATE demo.dbo.home
    SET propSplitCity = substring(propertyAddress,charindex(',',propertyAddress)+1,len(propertyAddress));

-- Split ownerAddress (1808  FOX CHASE DR, GOODLETTSVILLE, TN --> 1808  FOX CHASE DR and GOODLETTSVILLE and TN)
SELECT OwnerAddress,
PARSENAME(replace(OwnerAddress,',','.'),3) as Address,
PARSENAME(replace(OwnerAddress,',','.'),2) as City,
PARSENAME(replace(OwnerAddress,',','.'),1) as State
FROM demo.dbo.home

-- Add three new columns
    ALTER TABLE demo.dbo.home
    ADD ownerSplitAddress NVARCHAR(255);

    UPDATE demo.dbo.home
    SET ownerSplitAddress=parsename(REPLACE(OwnerAddress,',','.'),3)

    ALTER TABLE demo.dbo.home
    ADD ownerSplitCity NVARCHAR(255);

    UPDATE demo.dbo.home
    SET ownerSplitCity=parsename(REPLACE(OwnerAddress,',','.'),2)


    ALTER TABLE demo.dbo.home
    ADD ownerSplitState NVARCHAR(255);

    UPDATE demo.dbo.home
    SET ownerSplitState =parsename(REPLACE(OwnerAddress,',','.'),1)


-- Count how many soldAsVacant are filled incorrectly
SELECT soldAsVacant, count(*) 
FROM demo.dbo.home
GROUP BY soldAsVacant

-- Change Y to Yes and N to No in SoldAsVacant
SELECT soldAsVacant,
CASE WHEN soldAsVacant ='Y' THEN 'YES'
     WHEN soldAsVacant ='N' THEN 'NO'
     ELSE soldAsVacant
     END as updatedValue
FROM demo.dbo.home

-- Update the value Y to Yes and N to No
UPDATE demo.dbo.home
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
      WHEN SoldAsVacant = 'N' THEN 'NO'
      ELSE SoldAsVacant
      END

-- Finding duplicate data (Using partition by to find the duplicate value - if the data is duplicated indexNo will be added)
SELECT * 
FROM
    (SELECT *,(row_number() over (Partition BY ParcelID,propertyAddress,saleprice,saledate,legalreference 
                            ORDER BY UniqueID)) as indexNo
    from demo.dbo.home) as subquery
WHERE subquery.indexNo >1;

-- DROP duplicated data rows
DELETE subquery
    FROM
        (SELECT *,(row_number() over (Partition BY ParcelID,propertyAddress,saleprice,saledate,legalreference 
                                ORDER BY UniqueID)) as indexNo
        from demo.dbo.home) as subquery
    WHERE subquery.indexNo >1;

-- Backup table before dropping or deleting the raw data
SELECT * into homeBackup from demo.dbo.housing;

-- Remove unused column
ALTER TABLE demo.dbo.home
DROP COLUMN owneraddress, taxdistrict, propertyaddress

-- Find the average price per Acreage in each city each day
SELECT SaleDate, propSplitCity,
AVG(CAST(AVG(totalValue)/AVG(Acreage) as decimal(16,2))) OVER (PARTITION BY saleDate, propSplitCity) as averagePrice
FROM demo.dbo.home
WHERE totalValue is not null
GROUP BY SaleDate, propSplitCity
ORDER by saledate, propSplitCity;

-- Find the number of house in each owner city
SELECT ownerSplitCity,(count(*)) as countHouse
FROM demo.dbo.home
WHERE ownerSplitCity is not null
GROUP BY ownerSplitcity
-- Using union all to add another row regarding total house in every cities
UNION ALL
select ' SUM' , count(ownerSplitCity)
FROM demo.dbo.home
WHERE ownerSplitCity is not null
