

-- EXEC [GoMartAdmin].[dbo].[SyncObjects_AdminToBranch] @paramBranchId = 295, @paramBranchIp= '10.4.137.12';   PROd



--- primera sync ----

-- Authorizations
-- Catalogs
-- Permission
-- Auth
-- Products
-- Configuration
-- Permission

------------------------




------------------------------------------------------------------------------------------------------------------------

select * from [GoMartAdmin].Logs.Sync where  id >12331


select* from [sync].[dbo].[LastSync] 

select* from [sync].[dbo].[LastSync_Cancun] 

select*  from [sync].[Logs].[Errors] --where BranchId = 341
-----------------------------------------------------------------------------------------------------------------------


select * from Organization.Catalogs.Branches
select * from  [10.0.1.46].[GoMartBranch].Catalogs.Branches
select * from  [10.0.1.44].[GoMartBranch].Catalogs.Branches
select * from  [10.1.2.211].[GoMartBranch].Catalogs.Branches
select * from  [10.1.2.212].[GoMartBranch].Catalogs.Branches

-------------------------------------Principales-----------------------------------------------------------------------------------


select * from [GoMartAdmin].[Authorizations].[AuthorizationLevels]-----------------------------------------------
select * from  [10.0.1.46].[GoMartBranch].[Authorizations].[AuthorizationLevels]


select * from [GoMartAdmin].[Catalogs].[ProductCategories]-----------------------------------------------
select * from  [10.0.1.46].[GoMartBranch].[Catalogs].[ProductCategories]



select * from [GoMartAdmin].[Catalogs].[ProductSubcategories]------------------------------------------------
select * from  [10.0.1.46].[GoMartBranch].[Catalogs].[ProductSubcategories]



select * from [GoMartAdmin].[Catalogs].[ProductSegment]-----------------------------------------------
select * from  [10.0.1.46].[GoMartBranch].[Catalogs].[ProductSegment]


select * from [GoMartAdmin].[Catalogs].[SaleCommissions]-----------------------------------------------
select * from  [10.0.1.46].[GoMartBranch].[Catalogs].[SaleCommissions]


select * from [GoMartAdmin].[Catalogs].[SatTransferTaxOptions]-----------------------------------------------
select * from  [10.0.1.46].[GoMartBranch].[Catalogs].[SatTransferTaxOptions]


select * from [GoMartAdmin].[Catalogs].[PromotionStatus]-----------------------------------------------
select * from  [10.0.1.46].[GoMartBranch].[Catalogs].[PromotionStatus]




select * from [GoMartAdmin].[Permission].[MenuItems] -----------------------------------------------
select * from  [10.0.1.46].[GoMartBranch].[Permission].[MenuItems] 




select * from [GoMartAdmin].[Auth].[CustomAccess]-----------------------------------------------
select * from  [10.0.1.46].[GoMartBranch].[Auth].[CustomAccess] 



select * from [GoMartAdmin].[Products].ProductClassifications -----------------------------------------------
select * from  [10.0.1.46].[GoMartBranch].[Products].ProductClassifications


select * from [GoMartAdmin].[Products].DecreaseTypes -----------------------------------------------
select * from  [10.0.1.46].[GoMartBranch].[Products].DecreaseTypes


-------------------------------------------------------------------------------------------------------------
select * from [GoMartAdmin].[Products].RecordTypes
select * from [10.0.1.46].[GoMartBranch].[Products].RecordTypes



select * from [GoMartAdmin].[Auth].[Roles]  
select * from [10.0.1.46].[GoMartBranch].[Auth].[Roles] 



select * from [GoMartAdmin].[Permission].[RoleCustomAccess]
select * from [10.0.1.46].[GoMartBranch].[Permission].[RoleCustomAccess]


select * from [GoMartAdmin].[Permission].[RoleMenuItems]
select * from [10.0.1.46].[GoMartBranch].[Permission].[RoleMenuItems]


-------------------------------------------------------------------------------------------------------------



select  * from [GoMartAdmin].Configuration.BranchDaysAverageSale
select * from  [10.0.1.46].[GoMartBranch].Configuration.BranchDaysAverageSale


----------------------------------------------Productos---------------------------------------------------------------



select * from [GoMartAdmin].[Products].units
select * from [10.0.1.46].[GoMartBranch].[Products].units 



select * from [GoMartAdmin].[Products].[Products] as p left join [GoMartAdmin].[Products].BranchProducts as bp on p.id = bp.ProductId where bp.BranchId = 341
select * from [10.0.1.46].[GoMartBranch].[Products].[Products] 



select * from [GoMartAdmin].[Products].[ProductImages] as p left join [GoMartAdmin].Products.BranchProducts as bp on p.productId =  bp.ProductId  and bp.Visible = 1 where bp.BranchId = 341
select * from [10.0.1.46].[GoMartBranch].[Products].[ProductImages] 



SELECT *FROM GoMartAdmin.Products.ProductCosts as p
	left join [GoMartAdmin].[Products].[BranchProductCostPrices] as bp on p.Id =  bp.ProductCostId   
	left join [GoMartAdmin].Products.Products as pp on pp.id =  p.productId  
	inner join  [GoMartAdmin].Products.BranchProducts as bps on  pp.id = bps.ProductId and bp.BranchId = bps.BranchId and bp.Visible = 1 where bp.BranchId= 397    

select * from [10.0.1.46].[GoMartBranch].[Products].[ProductCosts] 
 



SELECT *FROM GoMartAdmin.Products.ProductPrices as p
                    left join GoMartAdmin.[Products].[BranchProductPrices] as bp on p.Id =  bp.ProductPriceId
					left join GoMartAdmin.Products.Products as pp on pp.id =  p.productId
					inner join  GoMartAdmin.Products.BranchProducts as bps on  pp.id = bps.ProductId and bp.BranchId = bps.BranchId and bp.Visible = 1 and bps.Visible=1 where bp.BranchId= 397    

select * from [10.0.1.46].[GoMartBranch].[Products].[ProductPrices] 




SELECT *FROM GoMartAdmin.Products.ProductTaxs as p
                    left join GoMartAdmin.[Products].[BranchProductTaxs] as bp on p.Id =  bp.ProductTaxId
					left join GoMartAdmin.Products.Products as pp on pp.id =  p.productId
					inner join  GoMartAdmin.Products.BranchProducts as bps on  pp.id = bps.ProductId and bp.BranchId = bps.BranchId and bp.Visible = 1 and bps.Visible=1 where bp.BranchId= 397    

select * from [10.0.1.46].[GoMartBranch].[Products].[ProductTaxs] 
select * from  [10.0.1.44].[GoMartBranch].[Products].ProductTaxs 
select * from  [10.1.2.211].[GoMartBranch].[Products].ProductTaxs 
select * from  [10.1.2.212].[GoMartBranch].[Products].ProductTaxs  



select * from [GoMartAdmin].[Products].[ProductStocks] as p
                    left join [GoMartAdmin].[Products].[BranchProductStocks]as bp on p.Id =  bp.ProductStockId 
					left join [GoMartAdmin].Products.Products as pp on pp.id =  p.productId
					inner join  [GoMartAdmin].Products.BranchProducts as bps on  pp.id = bps.ProductId and bp.BranchId = bps.BranchId and bp.Visible = 1 and bps.Visible=1 where bp.branchId =341

select * from [10.0.1.46].[GoMartBranch].[Products].[ProductStocks] 
select * from  [10.0.1.44].[GoMartBranch].[Products].ProductStocks 
select * from  [10.1.2.211].[GoMartBranch].[Products].ProductStocks 
select * from  [10.1.2.212].[GoMartBranch].[Products].ProductStocks 


---------------------------------------------------------Recipes ---------------------------------------------------------


select * from [GoMartAdmin].Recipes.Recipes  as p
select * from [10.4.137.12].[GoMartBranch].Recipes.Recipes 

select * from [GoMartAdmin].Recipes.RecipeTypes  as p
select * from [10.4.137.12].[GoMartBranch].Recipes.RecipeTypes 



----------------------------------------------Proveedores---------------------------------------------------------------


select * from [GoMartAdmin].Providers.Providers as p
select * from [10.0.1.46].[GoMartBranch].Providers.Providers 



select p.* from [GoMartAdmin].Providers.ProviderProductCategories as p 
inner join [GoMartAdmin].Providers.BranchProviderProductCategories  as bp on p.id =  bp.providerProductCategoryId and bp.Visible = 1 where bp.branchId= 397 

select*from [GoMartAdmin].Providers.BranchProviderProductCategories where BranchId = 397

select p.* from [GoMartAdmin].Providers.BranchProviderProductCategorySchedules as p 
left join [GoMartAdmin].Providers.BranchProviderProductCategories  as bp on p.BranchProviderProductCategoryId =  bp.id  and p.Visible = 1 where BranchId = 397


SELECT* FROM GoMartAdmin.Providers.ProviderProductCategories as p 
	left join [GoMartAdmin].Providers.BranchProviderProductCategories  as bp on p.id =  bp.providerProductCategoryId  where bp.BranchId = 341



-------------------------------------------------------Promociones------------------------------------------------------------

select * from [GoMartAdmin].[Promotions].[PromotionOfferTypes]
select * from [10.0.1.46].[GoMartBranch].[Promotions].[PromotionOfferTypes]
select * from [10.0.1.44].[GoMartBranch].[Promotions].[PromotionOfferTypes]
select * from  [10.1.2.211].[GoMartBranch].[Promotions].[PromotionOfferTypes]
select * from  [10.1.2.212].[GoMartBranch].[Promotions].[PromotionOfferTypes]



select * from [GoMartAdmin].[Promotions].[PromotionGroups]as p left join [GoMartAdmin].[Promotions].[BranchPromotions] as bp on p.PromotionId = bp.promotionId where bp.branchId = 341
select * from [10.0.1.46].[GoMartBranch].[Promotions].[PromotionGroups]
select * from [10.0.1.44].[GoMartBranch].[Promotions].[PromotionGroups]
select * from  [10.1.2.211].[GoMartBranch].[Promotions].[PromotionGroups]
select * from  [10.1.2.212].[GoMartBranch].[Promotions].[PromotionGroups]


select * from [GoMartAdmin].[Promotions].PromotionGroupProducts as p
left join [GoMartAdmin].[Promotions].PromotionGroups as pg on p.PromotionGroupId = pg.Id
				 left join [GoMartAdmin].[Promotions].[BranchPromotions] as bp on pg.PromotionId = bp.promotionId where bp.branchId = 341

	select * from [GoMartAdmin].[Promotions].promotions where branchId = 341	
	
select * from [GoMartAdmin].[Promotions].[BranchPromotions]where branchId = 341

select * from [10.0.1.46].[GoMartBranch].[Promotions].promotions
select * from [10.0.1.44].[GoMartBranch].[Promotions].promotions
select * from  [10.1.2.211].[GoMartBranch].[Promotions].[PromotionOfferTypes]
select * from  [10.1.2.212].[GoMartBranch].[Promotions].[PromotionOfferTypes]

select * from [GoMartAdmin].[Promotions].PromotionDiscounts as p 
left join [GoMartAdmin].[Promotions].[BranchPromotions] as bp on p.promotionId = bp.promotionId and bp.visible=1 where bp.branchId =291

select * from [10.0.1.44].[GoMartBranch].[Promotions].PromotionDiscounts


select * from [GoMartAdmin].[Goals].[GoalByProducts] as p
left join [GoMartAdmin].[Promotions].[BranchPromotions] as bp on p.promotionId = bp.promotionId and bp.visible=1 where bp.branchId =291

select * from [GoMartAdmin].[Goals].[GoalByProducts] as p 
left join [GoMartAdmin].[Goals].[BranchGoals] as bg  on p.GoalId =  bg.GoalId
left join [GoMartAdmin].Products.branchProducts as bp on p.productId = bp.productId and bp.visible=1 and bg.branchId = bp.branchId where bp.branchId =291

-----------------------------------------------------------------------------------------------------------------
--EXEC [GoMartAdmin].[dbo].[SyncObjects_AdminToBranch] @paramBranchId = 341, @paramBranchIp= '10.0.1.46';  


-- EXEC [Organization].[dbo].[SyncObjects_AdminToBranch] @paramBranchId = 291, @paramBranchIp= '10.0.1.44';  
--EXEC [Organization].[dbo].[SyncObjects_AdminToBranch] @paramBranchId = 341, @paramBranchIp= '10.0.1.46';  

--EXEC [empleados].[dbo].[SyncObjects_AdminToBranch] @paramBranchId = 341, @paramBranchIp= '10.0.1.46';  

	-- DECLARE @createTable NVARCHAR(MAX)= 'EXEC (''drop TABLE [GoMartBranch].dbo.SourceObjectSync'') AT [10.1.2.212]'; 
	-- EXECUTE (@createTable);

    -- DBCC CHECKIDENT ('[sync].Logs.Errors', RESEED, 0)

---------------------------------------------Job-----------------------------------------------------------------

	DECLARE @countObjects INT;
	DECLARE @countBranch INT;
	DECLARE @lastSync INT;

	SET @countObjects =
	(
	SELECT COUNT(Id)
	FROM [Sync].[dbo].[LastSync]
	);

	WHILE @countObjects > 0
	   BEGIN

	--Synchronize the target table with refreshed data from source table


	set @lastSync= (SELECT [SyncPendingId]FROM [Sync].[dbo].[LastSync]where [Id] = @countObjects)

	MERGE [Sync].[Logs].[SyncPending] AS TARGET
	USING  [GoMartAdmin].[Logs].[Sync] AS SOURCE 
	ON (TARGET.Id = SOURCE.Id) 
	--When records are matched, update the records if there is any change
	WHEN MATCHED AND TARGET.id <> SOURCE.id
	THEN UPDATE SET TARGET.TableName = SOURCE.TableName, TARGET.Field = SOURCE.Field ,TARGET.Action = SOURCE.Action 
	--When no records are matched, insert the incoming records from source table to target table
	WHEN NOT MATCHED BY TARGET AND SOURCE.Id > @lastSync
	THEN 
		INSERT (Id, TableName, Field,Action,Visible,InsertDate, InsertUserId,SchemaName )
	VALUES (SOURCE.Id, SOURCE.TableName, SOURCE.Field, SOURCE.Action,SOURCE.Visible, SOURCE.InsertDate, SOURCE.InsertUserId, SOURCE.SchemaName);


	
	declare @branchId INT = (SELECT BranchId FROM [Sync].[dbo].[LastSync]where [Id] = @countObjects);
	declare @branchIp varchar(max)= (SELECT BranchIp FROM [Sync].[dbo].[LastSync]where [Id] = @countObjects);

	EXEC [GoMartAdmin].[dbo].[SyncObjects_AdminToBranch] @paramBranchId = @branchId, @paramBranchIp= @branchIp;  

	delete from [sync].[Logs].SyncPending where SyncDate <= GETDATE();

	SET @countObjects-=1;
	end


-- ----Lab
-- 10.0.2.45,49170
-- corpogas
-- B9r@j=RJbY0010


-- -- lab prod 
-- 10.0.7.11
-- corpogas
-- B9r@j=RJbY0010


-- -------dev
-- 10.0.2.12,49170

-- apiestacion
-- S1m3l4s3

-- -----------qa

-- 10.0.2.15,49170
-- corpogas
-- B9r@j=RJbY0010

-- --------prod

-- sso.corpogas.com.mx,49172
-- corpogas
-- B9r@j=RJbY0010

-- ------------