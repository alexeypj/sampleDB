
CREATE FUNCTION [dbo].[CheckVersion]
(
	@moduleName nvarchar(50), 
	@version int,			  
	@andBelow  int			 
)
RETURNS INT
AS
BEGIN
	IF (NOT EXISTS (SELECT 1 
		FROM INFORMATION_SCHEMA.TABLES 
		WHERE TABLE_SCHEMA = 'dbo' 
		AND  TABLE_NAME = 'DbVersion'))
	BEGIN
		RETURN 0; 
	END
	
	if (@andBelow = 1) 
	BEGIN
		declare @belowCount int
		SELECT @belowCount = COUNT(1) FROM [dbo].[DbVersion] WHERE Module=@moduleName AND VersionId >= 1 AND VersionId < @version
		IF (@belowCount <> @version - 1)
			RETURN 1; 
	END
	
	declare @result bit;
	set @result = 0;
	if EXISTS (SELECT 1 FROM [dbo].[DbVersion] WHERE Module = @moduleName AND VersionId = @version)
	BEGIN
		SET @result = 1;
	END
	
	RETURN @result;
END