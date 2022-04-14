
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

	delete from [Sync].[Logs].SyncPending where SyncDate <= GETDATE();

	SET @countObjects-=1;
	end

