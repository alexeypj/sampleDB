CREATE PROCEDURE [dbo].[SetVersion]
	@moduleName nvarchar(50), 
	@version int 
AS
BEGIN
	SET NOCOUNT ON;
	
	IF (NOT EXISTS (SELECT 1 
		FROM INFORMATION_SCHEMA.TABLES 
		WHERE TABLE_SCHEMA = 'dbo' 
		AND  TABLE_NAME = 'DbVersion'))
	 BEGIN
		CREATE TABLE [dbo].[DbVersion](
			[VersionId] int,
			[Module] varchar(50),
			[Description] varchar(200) NULL,
			[CreatedAt] DateTime NULL,
			CONSTRAINT [PK_VersionId] PRIMARY KEY CLUSTERED ([VersionId] ASC, [Module] ASC)
		);
	END

	IF NOT EXISTS(SELECT * FROM [dbo].[DbVersion] WHERE Module = @moduleName AND VersionId = @version)
	BEGIN
		INSERT INTO [dbo].[DbVersion] (VersionId, Module, CreatedAt) VALUES (@version, @moduleName, GETUTCDATE())
	END

	print 'Installed v.' + convert(nvarchar(200), @version)
END