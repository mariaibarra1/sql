USE [Empleados]
GO
/****** Object:  StoredProcedure [dbo].[SyncObjects_AdmintoBranch]    Script Date: 4/7/2022 8:53:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[SyncObjects_AdmintoBranch]
	@paramBranchId BIGINT =null,
	@paramBranchIp varchar(max) =null
	AS
	  BEGIN 
 
			--**Tablas**
			DECLARE @Branches TABLE
			(Id       INT IDENTITY(1, 1), 
			 BranchId BIGINT, 
			 BranchIp NVARCHAR(20)
			);

			DECLARE @Objects TABLE
			(Id                  INT IDENTITY(1, 1), 
			 CentralDatabaseName NVARCHAR(20), 
			 DatabaseName        NVARCHAR(20), 
			 SchemaName          NVARCHAR(20), 
			 TableName           NVARCHAR(50), 
			 IsIdentityId        BIT, 
			 ByBranch            BIT, 
			 ExcludeIsDeleted    BIT,
			 DiferentColumns	 BIT,
			 RelationshipAnotherTable BIT,
			 AnotherProcessToGet BIT
			);

			--**Variables**
			DECLARE @sqlQuery NVARCHAR(MAX);
			DECLARE @countBranch INT;
			DECLARE @countObjects INT;
			DECLARE @columnsList NVARCHAR(MAX);
			DECLARE @columnsListValues NVARCHAR(MAX);
			DECLARE @columnsListUpdate NVARCHAR(MAX);
			DECLARE @databaseName VARCHAR(20);
			DECLARE @centralDatabaseName VARCHAR(20);
			DECLARE @schemaName VARCHAR(20);
			DECLARE @tableName VARCHAR(40);
			DECLARE @isIdentityId BIT;
			DECLARE @byBranch BIT;
			DECLARE @excludeIsDeleted BIT;
			DECLARE @diferentColumns BIT;
			DECLARE @RelationshipAnotherTable BIT;
			DECLARE @AnotherProcessToGet BIT;
			DECLARE @branchIp VARCHAR(20);
			DECLARE @branchId BIGINT;
			DECLARE @descriptionError NVARCHAR(MAX);
			DECLARE @errorMessage NVARCHAR(MAX);
			DECLARE @maximo INT ;
			--insert into @Branches select Id, Ip from ORGANIZATIONS.Branches.Branches where id in (13,155,497,172,498,160)
	 INSERT INTO @Branches values(@paramBranchId,@paramBranchIp);
	 -- INSERT INTO @Branches values(365,'10.0.2.25')
			SET @countBranch =
			(
				SELECT COUNT(Id)
				FROM @Branches
			);
			-- se hace join con la tabla de pendientes para solo hacer cambios donde sean requeridos 
			INSERT INTO @Objects
				   SELECT 
						  Sc.CentalDatabaseName, 
						  Sc.DatabaseName, 
						  Sc.SchemaName, 
						  Sc.TableName, 
						  Sc.IsIdentityId, 
						  Sc.ByBranch, 
						  Sc.ExclideisDeleted,
						  Sc.DiferentColumns,
						  Sc.RelationshipAnotherTable,
						  Sc.AnotherProcessToGet
				   FROM [Sync].[Configuration].[SyncConfig] as Sc
				
				   WHERE Sc.isActive = 1 and Sc.IsBranchToAdmin = 0  and Sc.CentalDatabaseName = 'Empleados'  --and Sc.TableName = 'EmpleadoPuestos'
				   Group by Sc.CentalDatabaseName, 
		                  Sc.DatabaseName, 
		                  Sc.SchemaName, 
		                  Sc.TableName, 
		                  Sc.IsIdentityId, 
		                  Sc.ByBranch, 
		                  Sc.ExclideisDeleted,
						  Sc.DiferentColumns,
						  Sc.RelationshipAnotherTable,
						  Sc.AnotherProcessToGet
				 
			
			WHILE @countBranch > 0
				BEGIN
					SET @countObjects =
					(
						SELECT COUNT(Id)
						FROM @Objects
					);

					WHILE @countObjects > 0
						BEGIN
							SET @descriptionError = '';
							SET @errorMessage = '';

							SELECT @branchIp = BranchIp, 
								   @branchId = BranchId
							FROM @Branches
							WHERE Id = @countBranch;
					
							SELECT @centralDatabaseName = CentralDatabaseName, 
								   @databaseName = DatabaseName, 
								   @schemaName = SchemaName, 
								   @tableName = TableName, 
								   @isIdentityId = IsIdentityId, 
								   @byBranch = ByBranch, 
								   @excludeIsDeleted = ExcludeIsDeleted,
								   @diferentColumns = DiferentColumns,
								   @RelationshipAnotherTable = RelationshipAnotherTable,
								   @AnotherProcessToGet = AnotherProcessToGet
							FROM @Objects
							WHERE Id = @countObjects;
							
						select @tableName
							  BEGIN TRY
								DECLARE @columnsListDataType NVARCHAR(MAX)= STUFF(
								(
									SELECT CASE
											   WHEN DATA_TYPE = 'nvarchar'
													AND CHARACTER_MAXIMUM_LENGTH = -1
											   THEN ', [' + COLUMN_NAME + '] ' + '[' + DATA_TYPE + '] ' + '(max) NULL'
											   WHEN DATA_TYPE = 'nvarchar'
											   THEN ', [' + COLUMN_NAME + '] ' + '[' + DATA_TYPE + '] ' + '(' + CONVERT(VARCHAR(7), CHARACTER_MAXIMUM_LENGTH) + ') NULL'
											   WHEN DATA_TYPE = 'varchar'
											   THEN ', [' + COLUMN_NAME + '] ' + '[' + DATA_TYPE + '] ' + '(max) NULL'
											   WHEN DATA_TYPE = 'decimal'
											   THEN ', [' + COLUMN_NAME + '] ' + '[' + DATA_TYPE + '] ' + '(' + CONVERT(VARCHAR(7), NUMERIC_PRECISION) + ',' + CONVERT(VARCHAR(7), NUMERIC_SCALE) + ') NULL'
											   ELSE ', [' + COLUMN_NAME + '] ' + '[' + DATA_TYPE + '] NULL'
										   END
									FROM INFORMATION_SCHEMA.COLUMNS
									WHERE TABLE_SCHEMA = @schemaName
										  AND TABLE_NAME = @tableName FOR XML PATH('')
								), 1, 1, '');

						

							DECLARE @createTable NVARCHAR(MAX)= 'EXEC (''CREATE TABLE ' + @databaseName + '.dbo.SourceObjectSyncEmpl(' + @columnsListDataType + ')'') AT [' + @branchIp + ']'; 
						select @createTable
							  EXECUTE (@createTable);
							  	select @createTable
								BEGIN TRY

								-- solo  funciona en updates cuando aplica para otra columna  se debe agregar a en  la tabla [SyncConfigColumns]
								IF @diferentColumns = 0
					
									Begin
									SET @columnsList = STUFF(
									(
										SELECT ',[' + COLUMN_NAME + ']'
										FROM INFORMATION_SCHEMA.COLUMNS
										WHERE TABLE_SCHEMA = @schemaName
											  AND TABLE_NAME = @tableName FOR XML PATH('')
									), 1, 1, '');
							
									SET @columnsListValues = STUFF(
									(
										SELECT ', SOURCE.[' + COLUMN_NAME + ']'
										FROM INFORMATION_SCHEMA.COLUMNS
										WHERE TABLE_SCHEMA = @schemaName
											  AND TABLE_NAME = @tableName FOR XML PATH('')
									), 1, 1, '');
							
									SET @columnsListUpdate = STUFF(
									(
										SELECT ', [' + COLUMN_NAME + ']=SOURCE.[' + COLUMN_NAME + ']'
										FROM INFORMATION_SCHEMA.COLUMNS
										WHERE TABLE_SCHEMA = @schemaName
											  AND TABLE_NAME = @tableName FOR XML PATH('')
									), 1, 1, '');
							
									END
									ELSE 
										Begin
								  SET @columnsList = STUFF(
									(
										SELECT ',[' + COLUMN_NAME + ']'
										FROM INFORMATION_SCHEMA.COLUMNS
										WHERE TABLE_SCHEMA = @schemaName
											  AND TABLE_NAME = @tableName FOR XML PATH('')
									), 1, 1, '');
								
									SET @columnsListValues = STUFF(
									(
										SELECT ', SOURCE.[' + ColumnNmae + ']'
									 FROM [Sync].[Configuration].[SyncConfigColumns]
										  WHERE SyncConfigId = @tableName
											 -- AND TABLE_NAME = @tableName FOR XML PATH('')
									), 1, 1, '');
							
									SET @columnsListUpdate = STUFF(
									(
										SELECT ', [' + ColumnNmae + ']=SOURCE.[' + ColumnNmae + ']'
										FROM [Sync].[Configuration].[SyncConfigColumns]
										WHERE SyncConfigId = @tableName
											 -- AND TABLE_NAME = @tableName FOR XML PATH('')
									), 1, 1, '');
							
									ENd
								
									IF @excludeIsDeleted = 1
								
										BEGIN
									
											SET @columnsListUpdate = STUFF(
											(
												SELECT ', [' + COLUMN_NAME + ']=SOURCE.[' + COLUMN_NAME + ']'
												FROM INFORMATION_SCHEMA.COLUMNS
												WHERE TABLE_SCHEMA = @schemaName
													  AND TABLE_NAME = @tableName
													  AND COLUMN_NAME != 'IsDeleted' FOR XML PATH('')
											), 1, 1, '');
										END;

									DECLARE @selectSource NVARCHAR(MAX)= '''SELECT ' + @columnsList + ' FROM ' + @databaseName + '.dbo.SourceObjectSyncEmpl''';
									DECLARE @queryInsertSourceOpenquery NVARCHAR(MAX)= 'INSERT INTO Openquery([' + @branchIp + '], ' + @selectSource + ') SELECT ' + @columnsList + ' FROM ' + @centralDatabaseName + '.' + @schemaName + '.' + @tableName;
                               
						
								   IF(@byBranch = 1)

							   
										BEGIN
									
										-- esta funcion solo funciona cuando son Joins  a  otras tablas y si se quiere agregar otro join ir al sp [getObjects]
										-- en caso que la relacion sea directa se debe modificar.
										IF (@RelationshipAnotherTable = 1)
										BEGIN

										if(@AnotherProcessToGet = 1)
										begin 
										EXEC [Sync].[dbo].[getObjectsByAnotherProcess] @Central = @centralDatabaseName,@branch = @databaseName ,@Action = @tableName,@pbranchIp = @branchIp, @pbranchId = @branchId,@selectSource =@selectSource
										-- Select * from GoMartBranch.dbo.SourceObjectSyncEmpl
										end;
										else 
										begin
											  SET @columnsList = STUFF(
									(
										SELECT ',p.' + COLUMN_NAME + ''
										FROM INFORMATION_SCHEMA.COLUMNS
										WHERE TABLE_SCHEMA = @schemaName
											  AND TABLE_NAME = @tableName FOR XML PATH('')
									), 1, 1, '');

										DECLARE @get VARCHAR(max);
										EXEC [Sync].[dbo].[getObjects] @Central = @centralDatabaseName ,@Action = @tableName, @output = @get OUTPUT

										 set @queryInsertSourceOpenquery = 'INSERT INTO Openquery([' + @branchIp + '], ' + @selectSource + ') SELECT ' + @columnsList + ' FROM ' + @centralDatabaseName + '.' + @schemaName + '.' + @tableName + ' as p '+ @get;
										 select @queryInsertSourceOpenquery
											DECLARE @params NVARCHAR(200)= '@paramBranchId bigint';
											SET @queryInsertSourceOpenquery+=' where  bp.SucursalId = @paramBranchId';
										--	select @queryInsertSourceOpenquery 
											EXECUTE sp_executesql 
													@queryInsertSourceOpenquery, 
													@params, 
													@paramBranchId = @branchId;

									

									 SET @columnsList = STUFF(
									(
										SELECT ',[' + COLUMN_NAME + ']'
										FROM INFORMATION_SCHEMA.COLUMNS
										WHERE TABLE_SCHEMA = @schemaName
											  AND TABLE_NAME = @tableName FOR XML PATH('')
									), 1, 1, '');
										end;
								
										END;

										ELSE 
										BEGIN
										  DECLARE @paramss NVARCHAR(200)= '@paramBranchId bigint';

											SET @queryInsertSourceOpenquery+=' WHERE SucursalId = @paramBranchId';

											
										select @queryInsertSourceOpenquery
											EXECUTE sp_executesql 
													@queryInsertSourceOpenquery, 
													@paramss, 
													@paramBranchId = @branchId;
										END;
										End
										ELSE

									  EXECUTE (@queryInsertSourceOpenquery);

									DECLARE @querySelectTarget NVARCHAR(MAX)= 'SELECT ' + @ColumnsList + ' FROM ' + @databaseName + '.' + @schemaName + '.' + @tableName;
									DECLARE @querySelectSource NVARCHAR(MAX)= 'SELECT ' + @ColumnsList + ' FROM ' + @databaseName + '.dbo.SourceObjectSyncEmpl';

								  IF(@isIdentityId = 1)

							  
										BEGIN
									
											SET @columnsListValues = STUFF(
											(
												SELECT ', SOURCE.[' + COLUMN_NAME + ']'
												FROM INFORMATION_SCHEMA.COLUMNS
												WHERE TABLE_SCHEMA = @schemaName
													  AND TABLE_NAME = @tableName
													  AND COLUMN_NAME != 'Id' FOR XML PATH('')
											), 1, 1, '');
										IF @diferentColumns = 0
											Begin
											SET @columnsListUpdate = STUFF(
											(
												SELECT ', [' + COLUMN_NAME + ']=SOURCE.[' + COLUMN_NAME + ']'
												FROM INFORMATION_SCHEMA.COLUMNS
												WHERE TABLE_SCHEMA = @schemaName
													  AND TABLE_NAME = @tableName
													  AND COLUMN_NAME != 'Id' FOR XML PATH('')
											), 1, 1, '');
								
											end
											SET @columnsList = STUFF(
											(
												SELECT ',[' + COLUMN_NAME + ']'
												FROM INFORMATION_SCHEMA.COLUMNS
												WHERE TABLE_SCHEMA = @schemaName
													  AND TABLE_NAME = @tableName
													  AND COLUMN_NAME != 'Id' FOR XML PATH('')
											), 1, 1, '');

											IF @excludeIsDeleted = 1 and @diferentColumns = 0
												BEGIN
													SET @columnsListUpdate = STUFF(
													(
														SELECT ', [' + COLUMN_NAME + ']=SOURCE.[' + COLUMN_NAME + ']'
														FROM INFORMATION_SCHEMA.COLUMNS
														WHERE TABLE_SCHEMA = @schemaName
															  AND TABLE_NAME = @tableName
															  AND COLUMN_NAME != 'IsDeleted'
															  AND COLUMN_NAME != 'Id' FOR XML PATH('')
													

													), 1, 1, '');
												END;
									
										END;
									DECLARE @queryInsertMerge NVARCHAR(MAX)= ' INSERT (' + @columnsList + ') VALUES ( ' + @columnsListValues + ' )';
									DECLARE @queryUpdatetMerge NVARCHAR(MAX)= 'UPDATE SET ' + @columnsListUpdate;

						-- Select * from GoMartBranch.dbo.SourceObjectSyncEmpl
									BEGIN TRY
										SET @sqlQuery = '
															EXEC(''
																WITH TARGET AS (' + @querySelectTarget + ')
																MERGE INTO TARGET 
																USING (' + @querySelectSource + ') AS SOURCE 
																ON (TARGET.Id = SOURCE.Id )
																WHEN NOT MATCHED BY target THEN ' + @queryInsertMerge + '
																WHEN MATCHED THEN ' + @queryUpdatetMerge + ';
															
																DROP TABLE ' + @databaseName + '.dbo.SourceObjectSyncEmpl
															
															'') AT [' + @branchIp + ']';


															--WHEN NOT MATCHED BY SOURCE THEN  DELETE;

									select @sqlQuery
												
								  EXECUTE (@sqlQuery);

							
							 			--EXEC [Sync].[dbo].[SyncObjects_SyncToBranch] @paramBranchId = @branchId, @paramBranchIp = @branchIp,@databaseName = @databaseName
										set @maximo = (SELECT MAX(id) FROM [Sync].[Logs].[SyncPending] where TableName =  @tableName and SchemaName = @schemaName );

									END TRY

									--- solo se registran los logs. 
									BEGIN CATCH
										SET @descriptionError = 'Ocurrio un error al intentar realizar el MERGE (admin to branch) del objeto: "' + @tableName + '" en sucursal.';
										SET @errorMessage = ERROR_MESSAGE() + ' Línea: ' + CONVERT(VARCHAR(5), ERROR_LINE());
										set @maximo = (SELECT SyncPendingId FROM [Sync].[dbo].[LastSync] where BranchId = @paramBranchId);
										INSERT INTO [Sync].[Logs].[Errors]
										VALUES
										(@branchId, 
										 @descriptionError, 
										 @errorMessage, 
										 GETDATE()
										);

										SET @sqlQuery = 'EXEC(''DROP TABLE ' + @databaseName + '.dbo.SourceObjectSyncEmpl'') AT [' + @branchIp + ']';
										EXECUTE (@sqlQuery);
									END CATCH;
								END TRY

								BEGIN CATCH
									SET @descriptionError = 'Ocurrio un error al intentar insertar los datos en la tabla: "' + @tableName + '" en sucursal.';
									SET @errorMessage = ERROR_MESSAGE() + ' Línea: ' + CONVERT(VARCHAR(5), ERROR_LINE());
										set @maximo = (SELECT SyncPendingId FROM [Sync].[dbo].[LastSync] where BranchId = @paramBranchId);
									INSERT INTO [Sync].[Logs].[Errors]
									VALUES
									(@branchId, 
									 @descriptionError, 
									 @errorMessage, 
									 GETDATE()
									);
									SET @sqlQuery = 'EXEC(''DROP TABLE ' + @databaseName + '.dbo.SourceObjectSyncEmpl'') AT [' + @branchIp + ']';
									EXECUTE (@sqlQuery);
								END CATCH;
							END TRY

							BEGIN CATCH
								SET @descriptionError = 'Ocurrio un error al intentar generar la tabla: "' + @tableName + '" en sucursal.';
								SET @errorMessage = ERROR_MESSAGE() + ' Línea: ' + CONVERT(VARCHAR(5), ERROR_LINE());
									set @maximo = (SELECT SyncPendingId FROM [Sync].[dbo].[LastSync] where BranchId = @paramBranchId);

								INSERT INTO [Sync].[Logs].[Errors]
								VALUES
								(@branchId, 
								 @descriptionError, 
								 @errorMessage, 
								 GETDATE()
								);
							END CATCH;
							SET @countObjects-=1;
						END;
					SET @countBranch-=1;
					select @maximo
			

				END;
		END;