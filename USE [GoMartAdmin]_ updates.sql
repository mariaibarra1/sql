USE [GoMartAdmin]
GO
/****** Object:  StoredProcedure [dbo].[SyncObjects_AdmintoBranch]    Script Date: 3/29/2022 7:21:01 AM ******/
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
			 AnotherProcessToGet BIT,
			 OrderSync int 
			);

              DECLARE @resultMaxStockDestiny TABLE (
                                TABLE_CATALOG nvarchar(max),
                                TABLE_SCHEMA nvarchar(max),
                                TABLE_NAME nvarchar(max),
                                TABLE_TYPE nvarchar(max)
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
			DECLARE @schemaName NVARCHAR(MAX);
			DECLARE @tableName NVARCHAR(MAX);
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
						  Sc.AnotherProcessToGet,
						  Sc.OrderSync
				  FROM SyncLab.[Configuration].[SyncConfig] as Sc
					inner JOIN SyncLab.[Logs].[SyncPending] as Sp
						  On Sc.TableName= Sp.TableName and Sc.SchemaName = Sp.SchemaName
				   WHERE Sc.isActive = 1 and Sc.IsBranchToAdmin = 0 and Sc.CentalDatabaseName = 'GoMartAdmin'  --and Sc.SchemaName = 'Products'
				   Group by Sc.CentalDatabaseName, 
		                  Sc.DatabaseName, 
		                  Sc.SchemaName, 
		                  Sc.TableName, 
		                  Sc.IsIdentityId, 
		                  Sc.ByBranch, 
		                  Sc.ExclideisDeleted,
						  Sc.DiferentColumns,
						  Sc.RelationshipAnotherTable,
						  Sc.AnotherProcessToGet,
						  Sc.OrderSync
				    order by OrderSync  desc
				
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

						 

							DECLARE @createTable NVARCHAR(MAX)= 'EXEC (''CREATE TABLE ' + @databaseName + '.dbo.SourceObjectSync(' + @columnsListDataType + ')'') AT [' + @branchIp + ']'; 
						select @createTable
							  EXECUTE (@createTable);

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
									 FROM SyncLab.[Configuration].[SyncConfigColumns]
										  WHERE SyncConfigId = @tableName
											 -- AND TABLE_NAME = @tableName FOR XML PATH('')
									), 1, 1, '');
							
									SET @columnsListUpdate = STUFF(
									(
										SELECT ', [' + ColumnNmae + ']=SOURCE.[' + ColumnNmae + ']'
										FROM SyncLab.[Configuration].[SyncConfigColumns]
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

									DECLARE @selectSource NVARCHAR(MAX)= '''SELECT ' + @columnsList + ' FROM ' + @databaseName + '.dbo.SourceObjectSync''';
									DECLARE @queryInsertSourceOpenquery NVARCHAR(MAX)= 'INSERT INTO Openquery([' + @branchIp + '], ' + @selectSource + ') SELECT ' + @columnsList + ' FROM ' + @centralDatabaseName + '.' + @schemaName + '.' + @tableName;
                               
						
								   IF(@byBranch = 1)

							   
										BEGIN
									
										-- esta funcion solo funciona cuando son Joins  a  otras tablas y si se quiere agregar otro join ir al sp [getObjects]
										-- en caso que la relacion sea directa se debe modificar.
										IF (@RelationshipAnotherTable = 1)
										BEGIN

										if(@AnotherProcessToGet = 1)
										begin 
										EXEC SyncLab.[dbo].[getObjectsByAnotherProcess] @Central = @centralDatabaseName,@branch = @databaseName ,@Action = @tableName,@pbranchIp = @branchIp, @pbranchId = @branchId,@selectSource =@selectSource
										-- Select * from GoMartBranch.dbo.SourceObjectSync
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
										EXEC SyncLab.[dbo].[getObjects] @Central = @centralDatabaseName ,@Action = @tableName, @output = @get OUTPUT

										 set @queryInsertSourceOpenquery = 'INSERT INTO Openquery([' + @branchIp + '], ' + @selectSource + ') SELECT ' + @columnsList + ' FROM ' + @centralDatabaseName + '.' + @schemaName + '.' + @tableName + ' as p '+ @get;
										 select @queryInsertSourceOpenquery
											DECLARE @params NVARCHAR(200)= '@paramBranchId bigint';
											SET @queryInsertSourceOpenquery+=' where  bp.BranchId = @paramBranchId';
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
											SET @queryInsertSourceOpenquery+=' WHERE BranchId = @paramBranchId  and Visible = 1';
											EXECUTE sp_executesql 
													@queryInsertSourceOpenquery, 
													@paramss, 
													@paramBranchId = @branchId;
										END;
										End
										ELSE
									  EXECUTE (@queryInsertSourceOpenquery);


									    DECLARE @QueryEve NVARCHAR(MAX)= 'EXEC (''delete  from  [Sync].[Logs].[SyncPending] where TableName = '''''+@tableName+''''' and Field not in (select Id from  ' + @databaseName + '.[dbo].[SourceObjectSync])'') AT [' + @branchIp + ']'; 
									
										  EXECUTE (@QueryEve);

									DECLARE @querySelectTarget NVARCHAR(MAX)= 'SELECT ' + @ColumnsList + ' FROM ' + @databaseName + '.' + @schemaName + '.' + @tableName;
									DECLARE @querySelectSource NVARCHAR(MAX)= 'SELECT ' + @ColumnsList + ' FROM ' + @databaseName + '.dbo.SourceObjectSync';

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

						-- Select * from GoMartBranch.dbo.SourceObjectSync
									BEGIN TRY
										SET @sqlQuery = '
															EXEC(''
																WITH TARGET AS (' + @querySelectTarget + ')
																MERGE INTO TARGET 
																USING (' + @querySelectSource + ') AS SOURCE 
																ON (TARGET.Id = SOURCE.Id )
																WHEN NOT MATCHED BY target THEN ' + @queryInsertMerge + '
																WHEN MATCHED THEN ' + @queryUpdatetMerge + ';
															
																DROP TABLE ' + @databaseName + '.dbo.SourceObjectSync
															
															'') AT [' + @branchIp + ']';


															--WHEN NOT MATCHED BY SOURCE THEN  DELETE;

									select @sqlQuery
												
								  EXECUTE (@sqlQuery);

							
							 		  EXEC SyncLab.[dbo].[SyncObjects_AdmintoBranch] @paramBranchId = @branchId, @paramBranchIp = @branchIp--@databaseName = @databaseName
										set @maximo = (SELECT  Max(id) FROM SyncLab.[Logs].[SyncPending] where TableName =  @tableName and SchemaName = @schemaName );

									END TRY

									--- solo se registran los logs. 
									BEGIN CATCH
										SET @descriptionError = 'Ocurrio un error al intentar realizar el MERGE (admin to branch) del objeto: "' + @tableName + '" en sucursal.';
										SET @errorMessage = ERROR_MESSAGE() + ' Línea: ' + CONVERT(VARCHAR(5), ERROR_LINE());
										set @maximo = (SELECT SyncPendingId FROM SyncLab.[dbo].[LastSync] where BranchId = @paramBranchId);
										INSERT INTO SyncLab.[Logs].[Errors]
										VALUES
										(@branchId, 
										 @descriptionError, 
										 @errorMessage, 
										 GETDATE()
										);

										SET @sqlQuery = 'EXEC(''DROP TABLE ' + @databaseName + '.dbo.SourceObjectSync'') AT [' + @branchIp + ']';
										EXECUTE (@sqlQuery);
									END CATCH;
								END TRY

								BEGIN CATCH
									SET @descriptionError = 'Ocurrio un error al intentar insertar los datos en la tabla: "' + @tableName + '" en sucursal.';
									SET @errorMessage = ERROR_MESSAGE() + ' Línea: ' + CONVERT(VARCHAR(5), ERROR_LINE());
										set @maximo = (SELECT SyncPendingId FROM SyncLab.[dbo].[LastSync] where BranchId = @paramBranchId);
									INSERT INTO SyncLab.[Logs].[Errors]
									VALUES
									(@branchId, 
									 @descriptionError, 
									 @errorMessage, 
									 GETDATE()
									);
									SET @sqlQuery = 'EXEC(''DROP TABLE ' + @databaseName + '.dbo.SourceObjectSync'') AT [' + @branchIp + ']';
									EXECUTE (@sqlQuery);
								END CATCH;
							END TRY

							BEGIN CATCH
								SET @descriptionError = 'Ocurrio un error al intentar generar la tabla: "' + @tableName + '" en sucursal.';
								SET @errorMessage = ERROR_MESSAGE() + ' Línea: ' + CONVERT(VARCHAR(5), ERROR_LINE());
									set @maximo = (SELECT SyncPendingId FROM SyncLab.[dbo].[LastSync] where BranchId = @paramBranchId);

								INSERT INTO SyncLab.[Logs].[Errors]
								VALUES
								(@branchId, 
								 @descriptionError, 
								 @errorMessage, 
								 GETDATE()
								);
								
								  
                                        declare @Script  NVARCHAR(MAX) = 'EXEC ('' Select  *
                                            from [' + @dataBaseName + '].INFORMATION_SCHEMA.TABLES  where   table_name = ''''SourceObjectSync''''
                                            and table_schema = ''''dbo''''     '') AT [' + @branchIp + ']';
                        
                              
                                INSERT INTO @resultMaxStockDestiny (TABLE_CATALOG,TABLE_SCHEMA,TABLE_NAME,TABLE_TYPE)  
                                EXECUTE (@Script);  
                        
                                IF (SELECT COUNT(*) FROM @resultMaxStockDestiny) > 0  
                                BEGIN  
                                declare @sqlQuerydropaux  NVARCHAR(MAX)= 'EXEC(''DROP TABLE ' + @databaseName + '.dbo.SourceObjectSync'') AT [' + @branchIp + ']';
                                EXECUTE (@sqlQuerydropaux);
                                END

							
							END CATCH;
							SET @countObjects-=1;
						END;
					SET @countBranch-=1;
					select @maximo
				   UPDATE  SyncLab.[dbo].[LastSync] SET [SyncPendingId] = @maximo	WHERE branchId = @paramBranchId; 
				  
				END;
		END;