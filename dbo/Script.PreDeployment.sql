declare @deletePreCheck int = 0, @deletePreSet int = 0, @preCheck varchar(max), @preSet varchar(max)

IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreCheckVersion]'))
BEGIN
	select @deletePreCheck = 1
	DROP FUNCTION dbo.PreCheckVersion
END
select @preCheck = 
'CREATE FUNCTION dbo.PreCheckVersion (@moduleName nvarchar(50),	@version int, @andBelow int) RETURNS int
BEGIN
	declare @result int = 0
	IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[CheckVersion]''))
		SELECT @result = dbo.CheckVersion(@moduleName, @version, @andBelow)
	RETURN @result
END'
exec (@preCheck)
IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PreSetVersion]'))
BEGIN
	select @deletePreSet = 1
	DROP PROC dbo.PreSetVersion
END
select @preSet = 
'CREATE PROCEDURE [dbo].[PreSetVersion] @moduleName nvarchar(50), @version int AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[SetVersion]''))
		EXEC dbo.SetVersion @moduleName = @moduleName, @version = @version
	ELSE
		print ''Executed v'' + convert(nvarchar(200), @version)
END'
exec (@preSet)

DECLARE @moduleName nvarchar(50), @version int, @currVersion int = 0;
SET @moduleName = 'Sample_PreDeploy'
DECLARE @shouldCheckAllPrevVersionExist bit = 0



IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DbVersion]'))
	select top 1 @currVersion = VersionId from dbo.DbVersion where Module = @moduleName order by VersionId desc;
print '********************************************************************************'
print '** BEGIN UPDATE: ' + @moduleName
print '** CURRENT VERSION: ' + convert(nvarchar(200), @currVersion)
print '** DATE/TIME: ' + convert(nvarchar(200), getdate(), 121)
print '********************************************************************************'




SET @version = 1
IF (dbo.PreCheckVersion(@moduleName, @version, @shouldCheckAllPrevVersionExist) = 0)
BEGIN
	BEGIN TRY
	
	--print'START VERSION UPDATE' +@version
	
	EXEC dbo.PreSetVersion @moduleName = @moduleName, @version = @version
	END TRY
	BEGIN CATCH
		print ERROR_MESSAGE();
		print 'Error on v.' + convert(nvarchar(200), @version)
	END CATCH;
END




IF (@deletePreCheck = 0)
	DROP FUNCTION dbo.PreCheckVersion
IF (@deletePreSet = 0)
	DROP PROC dbo.PreSetVersion
IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DbVersion]'))
	select top 1 @currVersion = VersionId from dbo.DbVersion where Module = @moduleName order by VersionId desc;
print '********************************************************************************'
print '** UPDATE FINISHED: ' + @moduleName
print '** CURRENT VERSION: ' + convert(nvarchar(200), @currVersion)
print '** DATE/TIME: ' + convert(nvarchar(200), getdate(), 121)
print '********************************************************************************'
