-- Prepare the data for date informaion -- (Table1)
SELECT 
[DateKey]
      ,[FullDateAlternateKey] as Date
      ,[EnglishDayNameOfWeek] as Day
      ,[WeekNumberOfYear] as WeekNr
      ,[EnglishMonthName] as Month
      , LEFT([EnglishMonthName],3) as MonthAbrv
      ,[MonthNumberOfYear] as MonthNo
      ,[CalendarYear] as Year
  FROM [AdventureWorksDW2019].[dbo].[DimDate]
  WHERE [CalendarYear] >= 2019

-- Prepare customer data with a city -- (Table2)
SELECT
c.[CustomerKey] as CustomerKey
      ,c.[FirstName] as FirstName
      ,c.[LastName] as LastName
      , (c.[FirstName] +' ' + c.[LastName]) as FullName
      ,CASE WHEN c.[Gender] ='M' THEN 'Male'
      WHEN c.[Gender] ='F' THEN 'FEMALE' 
      END as Gender
      ,c.[DateFirstPurchase] as PurchaseDate
      ,g.[city] as City
  FROM [AdventureWorksDW2019].[dbo].[DimCustomer] as c
  LEFT JOIN  [AdventureWorksDW2019].[dbo].[DimGeography] as g 
  ON c.GeographyKey=g.GeographyKey
  
-- Prepare product data -- (Table3)
SELECT 
[ProductKey]
      ,p.[ProductAlternateKey] as ProductCode
      ,p.[EnglishProductName] as ProductName
      ,ps.EnglishProductSubcategoryName as ProductSubcat
      ,pc.EnglishProductCategoryName as ProductCat
      ,p.[Color] as Color
      ,p.[Size] as Size
      ,p.[ProductLine] as ProductLine
      ,p.[ModelName] as ModalName
      ,p.[EnglishDescription] as Description
      ,isnull(p.[Status],'Outdated') as Status
  FROM [AdventureWorksDW2019].[dbo].[DimProduct] as p 
  LEFT JOIN [AdventureWorksDW2019].[dbo].[DimProductSubcategory] as ps ON p.[ProductSubcategoryKey]=ps.[ProductSubcategoryKey]
  LEFT JOIN [AdventureWorksDW2019].[dbo].[DimProductCategory] as pc ON ps.[ProductCategoryKey]=pc.[ProductCategoryKey]
  WHERE pc.EnglishProductCategoryName is not Null
  ORDER BY p.ProductKey ASC

-- Prepare order date --
SELECT 
[ProductKey]
      ,[OrderDateKey]
      ,[DueDateKey]
      ,[ShipDateKey]
      ,[CustomerKey]
      ,[SalesOrderNumber]
      ,[SalesAmount]
  FROM [AdventureWorksDW2019].[dbo].[FactInternetSales]
  WHERE LEFT (OrderDateKey,4) >= Year(GETDATE())-2  -- latest 2 Year
  ORDER BY OrderDateKey ASC