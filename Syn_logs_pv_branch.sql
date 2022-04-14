USE [Sync]
GO
/****** Object:  StoredProcedure [dbo].[SyncObjects_SyncToBranch]    Script Date: 3/30/2022 9:04:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SyncObjects_SyncToBranch]
@paramBranchId BIGINT =null,
@paramBranchIp varchar(max) =null,
@databaseName varchar(max) = null
AS
begin
DEclare @merge varchar(max);


 set @merge =	'Exec(''
			MERGE  ['+@databaseName+'].[Logs].[SyncPending] AS TARGET
				USING [Sync].[Logs].[SyncPending] AS SOURCE 
				ON (TARGET.Id = SOURCE.Id) 

				WHEN MATCHED AND TARGET.id <> SOURCE.id
				THEN UPDATE SET TARGET.TableName = SOURCE.TableName, TARGET.Field = SOURCE.Field ,TARGET.Action = SOURCE.Action, TARGET.schemaName =  SOURCE.schemaName 

				WHEN NOT MATCHED BY TARGET 
				THEN 
				INSERT ( TableName, Field,Action,Visible,InsertDate, InsertUserId,SchemaName,SyncDate)
				VALUES ( SOURCE.TableName, SOURCE.Field, SOURCE.Action,SOURCE.Visible, SOURCE.InsertDate, SOURCE.InsertUserId, SOURCE.schemaName,GETDATE()); '') AT ['+ @paramBranchIp + ']'

				select @merge
   EXECUTE (@merge);
    select ' sync to branch'

	 -- se actualiza la tabla de pendientes solo para la sigfuiente vuelta .. y se elimina el log 
		--DECLARE @maximo INT  = (SELECT MAX(id) FROM [SyncLab].[Logs].[SyncPending]);
		--UPDATE  [SyncLab].[dbo].[LastSync] SET [SyncPendingId] = @maximo	WHERE branchId = @paramBranchId; 
			--delete from  [SyncLab].[Logs].[SyncPending];
	end