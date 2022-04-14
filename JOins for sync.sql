USE [Sync]
GO
/****** Object:  StoredProcedure [dbo].[getObjects]    Script Date: 3/30/2022 9:05:31 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Maria Fernanda Gomez Ibarra >
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[getObjects]
	-- Add the parameters for the stored procedure here
@Central varchar(max) = null,
@Action varchar(max) =null,
    @output VARCHAR(max) output
AS
BEGIN
    --  se puede mandar  la tabla padre para  no hacerlo manual 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
set @output =(
 
	 select
	CASE

				WHEN  @Action =  'Products' then 
				'left join ['+@Central+'].[Products].[BranchProducts] as bp on p.Id =  bp.ProductId  and bp.Visible = 1
				'
					WHEN  @Action =  'ProductImages' then 
				'left join  ['+@Central+'].Products.BranchProducts as bp on p.productId =  bp.ProductId  and bp.Visible = 1
				'
				WHEN  @Action = 'ProductCosts' then

				'left join ['+@Central+'].[Products].[BranchProductCostPrices] as bp on p.Id =  bp.ProductCostId
				left join ['+@Central+'].Products.Products as pp on pp.id =  p.productId
				inner join  ['+@Central+'].Products.BranchProducts as bps on  pp.id = bps.ProductId and bp.BranchId = bps.BranchId and bp.Visible = 1 and bps.Visible=1
				'

				when @Action = 'ProductPrices' then 
					'left join ['+@Central+'].[Products].[BranchProductPrices] as bp on p.Id =  bp.ProductPriceId
					left join ['+@Central+'].Products.Products as pp on pp.id =  p.productId
					inner join  ['+@Central+'].Products.BranchProducts as bps on  pp.id = bps.ProductId and bp.BranchId = bps.BranchId and bp.Visible = 1 and bps.Visible=1
				'

				when @Action  = 'ProductTaxs' then 
					'left join ['+@Central+'].[Products].[BranchProductTaxs] as bp on p.Id =  bp.ProductTaxId
					left join ['+@Central+'].Products.Products as pp on pp.id =  p.productId
					inner join  ['+@Central+'].Products.BranchProducts as bps on  pp.id = bps.ProductId and bp.BranchId = bps.BranchId and bp.Visible = 1 and bps.Visible=1  and bp.Activo =1
				'

				when @Action = 'ProductStocks' then 
				
					'left join ['+@Central+'].[Products].[BranchProductStocks]as bp on p.Id =  bp.ProductStockId 
					left join ['+@Central+'].Products.Products as pp on pp.id =  p.productId
					inner join  ['+@Central+'].Products.BranchProducts as bps on  pp.id = bps.ProductId and bp.BranchId = bps.BranchId and bp.Visible = 1 and bps.Visible=1
				'

					when @Action  = 'ProductDiscounts' then 
					'left join ['+@Central+'].[Products].BranchProductDiscounts as bp on p.Id =  bp.ProductDiscountId
				left join ['+@Central+'].Products.Products as pp on pp.id =  p.productId
				inner join  ['+@Central+'].Products.BranchProducts as bps on  pp.id = bps.ProductId and bp.BranchId = bps.BranchId and bp.Visible = 1 and bps.Visible=1
				'

				when @Action = 'Providers' then 
				'left join ['+@Central+'].[Providers].[BranchProviders] as bp on p.Id = bp.ProviderId and bp.visible=1'

				when @Action = 'ProviderAditionalEmails'then
				'left join ['+@Central+'].Providers.BranchProviders as bp on p.providerId =  bp.providerId'

				 when @Action = 'ProviderProductCategories'then
				'inner join ['+@Central+'].Providers.BranchProviderProductCategories  as bp on p.id =  bp.providerProductCategoryId and bp.Visible = 1'

					 when @Action = 'BranchProviderSchedules'then
				'left join ['+@Central+'].Providers.BranchProviders as bp on p.branchProviderId =  bp.Id and bp.visible=1'

				when @Action = 'InventoryProduct'then
				' left join  ['+@Central+'].[Configuration].Inventory as pp on p.InventoryId =  pp.Id left join  ['+@Central+'].Products.BranchProducts as bp on p.ProductId =  bp.ProductId and bp.Visible=1'

				when @Action = 'Promotions' then 
				'left join  ['+@Central+'].[Promotions].[BranchPromotions] as bp on p.id =  bp.PromotionId and bp.Visible = 1'

				when @Action = 'PromotionGroupProducts' then 
				'left join ['+@Central+'].[Promotions].PromotionGroups as pg on p.PromotionGroupId = pg.Id
				 left join ['+@Central+'].[Promotions].[BranchPromotions] as bp on pg.PromotionId = bp.promotionId and bp.Visible = 1'

				 when @Action = 'PromotionGroups' then 
				'left join ['+@Central+'].[Promotions].[BranchPromotions] as bp on p.PromotionId = bp.promotionId and bp.Visible = 1'

				
				 when @Action = 'PromotionGroupCategories' then 
				'left join ['+@Central+'].[Promotions].PromotionGroups as pg on p.PromotionGroupId = pg.Id
				 left join ['+@Central+'].[Promotions].[BranchPromotions] as bp on pg.PromotionId = bp.promotionId'

				 				
				 when @Action = 'promotionDays' then 
				'left join ['+@Central+'].[Promotions].[BranchPromotions] as bp on p.PromotionId = bp.promotionId and bp.Visible =1'

				 when @Action = 'BranchProviderProductCategorySchedules' then 
				'left join ['+@Central+'].Providers.BranchProviderProductCategories  as bp on p.BranchProviderProductCategoryId =   bp.id and bp.Visible = 1  and p.Visible = 1 '


				 when @Action = 'Goals' then 
				'left join ['+@Central+'].[Goals].[BranchGoals] as bp  on p.id =  bp.GoalId'

				
				 when @Action = 'GoalByProducts' then 
				'left join  ['+@Central+'].[Goals].[BranchGoals] as bg  on p.GoalId =  bg.GoalId
				left join  ['+@Central+'].Products.branchProducts as bp on p.productId = bp.productId and bp.visible=1 and bg.branchId = bp.branchId'

				
				 when @Action = 'CentralizedPurchaseOrderDetails' then 
				'left join ['+@Central+'].Purchases.CentralizedPurchaseOrders  as bp on p.CentralizedPurchaseOrderId = bp.Id and bp.BranchId =p.BranchId'

				when @Action = 'ProductProviders' then  
				'left join  ['+@Central+'].Products.BranchProducts as bp on p.ProductId =  bp.ProductId and bp.Visible = 1'

				
				when @Action = 'HistoricProductPrices' then 
				'left join ['+@Central+'].[Products].[BranchProductPrices] as bp on p.ProductPriceId =  bp.ProductPriceId
					left join ['+@Central+'].Products.Products as pp on pp.id =  p.productId
					inner join  ['+@Central+'].Products.BranchProducts as bps on  pp.id = bps.ProductId and bp.BranchId = bps.BranchId and bp.Visible = 1 and bps.Visible=1'

						when @Action = 'Event' then 
				'left join ['+@Central+'].[Event].[BranchEvent] as bp on p.id =  bp.EventId and bp.Visible = 1'

				
				when @Action = 'ProductBarCodes' then 
				'left join  ['+@Central+'].Products.BranchProducts as bp on p.ProductId =  bp.ProductId and bp.Visible = 1'

				when @Action = 'EmpleadoPuestos' then 
				'left join ['+@Central+'].[Empleados].[Empleados] as bp on p.EmpleadoId =  bp.Id and p.Eliminado = 0 '

				when @Action ='PromotionDiscounts' then
				'left join ['+@Central+'].[Promotions].[BranchPromotions] as bp on p.promotionId = bp.promotionId and bp.visible=1'
	else ''
	
	
	end 
	)
END