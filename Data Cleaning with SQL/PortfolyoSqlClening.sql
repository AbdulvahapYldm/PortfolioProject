
SELECT * FROM PortfolioProject.dbo.[NashvilleHousing ];
--OR
SELECT * FROM [NashvilleHousing ]


--ADD NEW COLUMNS AND CONVERT DATE FORMAT
SELECT SaleDate,CONVERT(date,SaleDate)
FROM PortfolioProject.dbo.[NashvilleHousing ];

ALTER TABLE [NashvilleHousing ]
ADD SaleDateConvert Date;

UPDATE [NashvilleHousing ] SET SaleDateConvert=CONVERT(Date,SaleDate);
SELECT SaleDate,SaleDateConvert FROM [NashvilleHousing ];


--FIND NULL ROWS
SELECT *
FROM PortfolioProject.dbo.[NashvilleHousing ] 
WHERE PropertyAddress IS NULL 

--LET'S CHECK IF THERE ARE TWO ADDRESSES AND ID'S
SELECT ParcelID,PropertyAddress, COUNT(*) AS MoreThanOne
FROM [NashvilleHousing ]
GROUP BY ParcelID, PropertyAddress
HAVING COUNT(*) > 1

--LET'S FIND THE ROWS WITH DIFFERENT UNIQUE IDS AND THE SAME VALUES
SELECT A.UniqueID ,A.ParcelID,A.PropertyAddress,B.UniqueID ,B.ParcelID,B.PropertyAddress 
FROM PortfolioProject.dbo.[NashvilleHousing ] AS A
JOIN PortfolioProject.dbo.[NashvilleHousing ] AS B
	ON A.ParcelID=B.ParcelID
	AND A.[UniqueID ]<>B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

--NOW LET'S UPDATE THE MISSING INFORMATION
UPDATE A
SET PropertyAddress=ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProject.dbo.[NashvilleHousing ] AS A
JOIN PortfolioProject.dbo.[NashvilleHousing ] AS B
	ON A.ParcelID=B.ParcelID
	AND A.[UniqueID ]<>B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

--LET'S CHECK THE MISSING INFORMATION QUICKLY AFTER UPDATE
SELECT PropertyAddress FROM [NashvilleHousing ] WHERE PropertyAddress IS NULL

--EDITING THE PropertyAddress
SELECT PropertyAddress FROM PortfolioProject.dbo.[NashvilleHousing ]

--SEPARATING ADDRESS AND CITY INFORMATION
SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address ,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City 
FROM PortfolioProject.dbo.[NashvilleHousing ]

--LET'S PHYSICALLY UPDATE THE INFORMATION WE HAVE SEPARATED.
ALTER TABLE [NashvilleHousing ]
ADD PropertySplitAddress NVARCHAR(255);

UPDATE [NashvilleHousing ] SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE [NashvilleHousing ]
ADD PropertySplitCity NVARCHAR(255);

UPDATE [NashvilleHousing ] SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

--LET'S QUICKLY TAKE A LOOK AT THE NEW COLUMN WE CREATED AND ITS VALUES.
SELECT  PropertySplitAddress,PropertySplitCity FROM [NashvilleHousing ];

--EDITING THE OWNERADDRESS
SELECT Owneraddress
FROM PortfolioProject.dbo.[NashvilleHousing ]

--LET'S DO A QUICK PREVIEW AND THEN UPDATE IT PHYSICALLY
SELECT 
PARSENAME(REPLACE(Owneraddress,',','.'),3) AS OwnerSplitAddress,
PARSENAME(REPLACE(Owneraddress,',','.'),2) AS OwnerSplitCity,
PARSENAME(REPLACE(Owneraddress,',','.'),1) AS OwnerSplitState
FROM PortfolioProject.dbo.[NashvilleHousing ]


ALTER TABLE [NashvilleHousing ]
ADD OwnerSplitAddress NVARCHAR(255);
UPDATE [NashvilleHousing ] SET OwnerSplitAddress =PARSENAME(REPLACE(Owneraddress,',','.'),3);

ALTER TABLE [NashvilleHousing ]
ADD OwnerSplitCity NVARCHAR(255);
UPDATE [NashvilleHousing ] SET OwnerSplitCity =PARSENAME(REPLACE(Owneraddress,',','.'),2);

ALTER TABLE [NashvilleHousing ]
ADD OwnerSplitState NVARCHAR(255);
UPDATE [NashvilleHousing ] SET OwnerSplitState  =PARSENAME(REPLACE(Owneraddress,',','.'),1);

SELECT OwnerSplitAddress,OwnerSplitCity,OwnerSplitState FROM [NashvilleHousing ]

--WE WILL QUICKLY LOOK AT THE VALUE ABBREVIATIONS IN THE SoldAsVacant COLUMN 
--AND THEN PHYSICALLY CORRECT THE ABBREVIATIONS

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.[NashvilleHousing ]
GROUP BY SoldAsVacant
ORDER BY 2 DESC
--
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.[NashvilleHousing ]
--
UPDATE [NashvilleHousing ]
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--FIND DUPLICATES AND THEN DALETE DUPLICATE
SELECT ParcelID, PropertyAddress,SaleDate,SalePrice,LegalReference ,COUNT(*) AS Duplicates
FROM PortfolioProject.dbo.[NashvilleHousing ]
GROUP BY ParcelID, PropertyAddress,SaleDate,SalePrice,LegalReference
HAVING COUNT(*) > 1;

--OR
--FIND DUPLICATES
WITH DuplicatesCTE AS 
(
    SELECT *,
	ROW_NUMBER() OVER 
	(PARTITION BY ParcelID, PropertyAddress,SaleDate,SalePrice,LegalReference ORDER BY UniqueID) AS Duplicates
FROM PortfolioProject.dbo.[NashvilleHousing ]
)
SELECT *FROM DuplicatesCTE
WHERE Duplicates>1
ORDER BY PropertyAddress

--DALETE DUPLICATE
WITH DuplicatesCTE AS 
(
    SELECT *,
	ROW_NUMBER() OVER 
	(PARTITION BY ParcelID, PropertyAddress,SaleDate,SalePrice,LegalReference ORDER BY UniqueID) AS Duplicates
FROM PortfolioProject.dbo.[NashvilleHousing ]
)
DELETE FROM DuplicatesCTE
WHERE Duplicates>1

--NOW LET'S QUICKLY LOOK AT THE NEW COLUMNS WE CREATED AND ALL THE VALUES WE CHANGE
SELECT * FROM PortfolioProject.dbo.[NashvilleHousing ]

--NOW DELETE OLD COLUMNS AND UNNECESSARY COLUMNS
ALTER TABLE PortfolioProject.dbo.[NashvilleHousing ]
DROP COLUMN PropertyAddress,SaleDate,OwnerAddress,TaxDistrict

--LAST LOOK :)
SELECT * FROM PortfolioProject.dbo.[NashvilleHousing ]
