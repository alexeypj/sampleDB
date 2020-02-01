/*
Скрипт развертывания для SampleDB

Этот код был создан программным средством.
Изменения, внесенные в этот файл, могут привести к неверному выполнению кода и будут потеряны
в случае его повторного формирования.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "SampleDB"
:setvar DefaultFilePrefix "SampleDB"
:setvar DefaultDataPath "D:\SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\"
:setvar DefaultLogPath "D:\SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\"

GO
:on error exit
GO
/*
Проверьте режим SQLCMD и отключите выполнение скрипта, если режим SQLCMD не поддерживается.
Чтобы повторно включить скрипт после включения режима SQLCMD выполните следующую инструкцию:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'Для успешного выполнения этого скрипта должен быть включен режим SQLCMD.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULLS ON,
                ANSI_PADDING ON,
                ANSI_WARNINGS ON,
                ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                QUOTED_IDENTIFIER ON,
                ANSI_NULL_DEFAULT ON,
                CURSOR_DEFAULT LOCAL,
                RECOVERY FULL 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET PAGE_VERIFY NONE 
            WITH ROLLBACK IMMEDIATE;
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET TARGET_RECOVERY_TIME = 0 SECONDS 
    WITH ROLLBACK IMMEDIATE;


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE (CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 367)) 
            WITH ROLLBACK IMMEDIATE;
    END


GO
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
GO

GO
PRINT N'Операция рефакторинга Rename с помощью ключа 1a148fd8-7154-4990-a6d4-97582329b5a4 пропущена, элемент [dbo].[Tags].[Id] (SqlSimpleColumn) не будет переименован в TagId';


GO
PRINT N'Выполняется создание [dbo].[Articles]...';


GO
CREATE TABLE [dbo].[Articles] (
    [ArticleId] INT            IDENTITY (1, 1) NOT NULL,
    [Title]     NVARCHAR (450) NOT NULL,
    CONSTRAINT [PK_Articles] PRIMARY KEY CLUSTERED ([ArticleId] ASC)
);


GO
PRINT N'Выполняется создание [dbo].[ArticleTag]...';


GO
CREATE TABLE [dbo].[ArticleTag] (
    [Id]        INT IDENTITY (1, 1) NOT NULL,
    [ArticleId] INT NOT NULL,
    [TagId]     INT NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
PRINT N'Выполняется создание [dbo].[DbVersion]...';


GO
CREATE TABLE [dbo].[DbVersion] (
    [VersionId]   INT           NOT NULL,
    [Module]      VARCHAR (50)  NOT NULL,
    [Description] VARCHAR (200) NULL,
    [CreatedAt]   DATETIME      NULL,
    CONSTRAINT [PK_VersionId] PRIMARY KEY CLUSTERED ([VersionId] ASC, [Module] ASC)
);


GO
PRINT N'Выполняется создание [dbo].[Tags]...';


GO
CREATE TABLE [dbo].[Tags] (
    [TagId] INT           IDENTITY (1, 1) NOT NULL,
    [Tag]   NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([TagId] ASC)
);


GO
PRINT N'Выполняется создание [dbo].[FK_ArticleTag_Articles]...';


GO
ALTER TABLE [dbo].[ArticleTag] WITH NOCHECK
    ADD CONSTRAINT [FK_ArticleTag_Articles] FOREIGN KEY ([ArticleId]) REFERENCES [dbo].[Articles] ([ArticleId]);


GO
PRINT N'Выполняется создание [dbo].[FK_ArticleTag_Tags]...';


GO
ALTER TABLE [dbo].[ArticleTag] WITH NOCHECK
    ADD CONSTRAINT [FK_ArticleTag_Tags] FOREIGN KEY ([TagId]) REFERENCES [dbo].[Tags] ([TagId]);


GO
PRINT N'Выполняется создание [dbo].[CheckVersion]...';


GO

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
GO
PRINT N'Выполняется создание [dbo].[SetVersion]...';


GO
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
GO
-- Выполняется этап рефакторинга для обновления развернутых журналов транзакций на целевом сервере

IF OBJECT_ID(N'dbo.__RefactorLog') IS NULL
BEGIN
    CREATE TABLE [dbo].[__RefactorLog] (OperationKey UNIQUEIDENTIFIER NOT NULL PRIMARY KEY)
    EXEC sp_addextendedproperty N'microsoft_database_tools_support', N'refactoring log', N'schema', N'dbo', N'table', N'__RefactorLog'
END
GO
IF NOT EXISTS (SELECT OperationKey FROM [dbo].[__RefactorLog] WHERE OperationKey = '1a148fd8-7154-4990-a6d4-97582329b5a4')
INSERT INTO [dbo].[__RefactorLog] (OperationKey) values ('1a148fd8-7154-4990-a6d4-97582329b5a4')

GO

GO
SET NOCOUNT ON;	

DECLARE @moduleName nvarchar(50), @version int, @currVersion int;
SET @moduleName = 'Sample_PostDeploy'
DECLARE @shouldCheckAllPrevVersionExist bit = 0

select top 1 @currVersion = VersionId from dbo.DbVersion where Module = @moduleName order by VersionId desc;
print '********************************************************************************'
print '** BEGIN UPDATE: ' + @moduleName
print '** CURRENT VERSION: ' + convert(nvarchar(200), @currVersion)
print '** DATE/TIME: ' + convert(nvarchar(200), getdate(), 121)
print '********************************************************************************'



SET @version = 1
IF (dbo.CheckVersion(@moduleName, @version, @shouldCheckAllPrevVersionExist) = 0)
BEGIN
	BEGIN TRY	
	--Статьи
	INSERT INTO [dbo].[Articles]
           ([Title])
     VALUES
	 --Химия
           ('МЕТОДОЛОГИЧЕСКИЕ ОСОБЕННОСТИ ОПРЕДЕЛЕНИЯ СОЛЕЙ ДИПИРИДИЛИЯ В ПРОДУКЦИИ СЕЛЬСКОГО ХОЗЯЙСТВА И РАСТЕНИЕВОДСТВА'),
		   ('ФАЗООБРАЗОВАНИЕ ПРИ МЕХАНОХИМИЧЕСКОМ СИНТЕЗЕ ГАФНАТОВ ЕВРОПИЯ И ЛАНТАНА'),
		   ('ФОРМИРОВАНИЕ РЕЛЬЕФА НА ПОВЕРХНОСТИ ПОЛИЭТИЛЕНА ВЫСОКОЙ ПЛОТНОСТИ С ЖЕСТКИМИ ПОКРЫТИЯМИ'),
		   ('ХИМИЧЕСКАЯ МОДИФИКАЦИЯ АМИНОПОЛИСАХАРИДА ИЗ ПАНЦИРЯ КРЕВЕТОК ПРЯМЫМ СОЕДИНЕНИЕМ С ПОЛИАНИЛИНОМ'),
		   ('СИНТЕЗ И КРИСТАЛЛИЧЕСКАЯ СТРУКТУРА НИТРАТНЫХ КОМПЛЕКСОВ ПАЛЛАДИЯ(II)'),
		   ('ПЕРСПЕКТИВНЫЕ НАПОЛНИТЕЛИ ДЛЯ ПОЛИМЕРНЫХ КОМПОЗИТОВ'),
		   ('СИНТЕЗ ДИОКСИМА ДЕКАГИДРОАКРИДИНДИОНА'),
	  --Физика
		   ('Астрофизика с точки зрения физика'),
		   ('Магнитное поле Земли и других небесных тел'),
		   ('Электромагнитная модель нейтрино'),
		   ('О природе нейтрино и мезонов'),
		   ('О природе ядерных сил'),
		   ('Об экспериментальной проверке постулата изотропности скорости света'),
	  --Экономика
		   ('Антикризисные мероприятия в сфере налогового законодательства'),
		   ('Пространственные ограничения политики ценовой стабильности в российской Федерации'),
		   ('Государственные закупки в условиях модернизации системы управления качеством проектной продукции'),
		   ('Гринмейл в призме теории и практики недобросовестной конкуренции'),
	  --Математика
		   ('О вычислении арифметических корней'),
		   ('Числа Лишрел'),
		   ('Центральная предельная теорема'),
		   ('Уравнения Навье — Стокса'),
		   ('Теоремы Тебо'),
		   ('Лемма Шепли — Фолкмана'),
		   ('Парадокс Рассела'),
		--Медицина
		   ('Антигистаминные препараты в лечении аллергического ринита: в фокусе внимания пациенты с коморбидной аллеpгопатологией'),
		   ('Оптимизация концентрации аллергенов для использования в тесте активации базофилов'),
		   ('Исследование гистаминолиберирующих свойств мелиттина, полученного из отечественного пчелиного яда'),
		   ('Влияние азоксимера бромида на формирование внеклеточных нейтрофильных ловушек'),
		   ('Микробиота, мукозальный иммунитет и антибиотики: тонкости взаимодействия'),
		   ('Иммунокоррекция и принципы ее применения'),
		  --Астрономия
		   ('Что такое световой год?'),
		   ('Полярный вихрь на Титане делает его климат экстремально холодным'),
		   ('Солнце: основные сведения'),
		   ('Космическая радиация в нашей галактике'),
		   ('Темная материя или отрицательное тяготение'),
		   ('Самая яркая звезда, когда-либо замеченная за всю историю')


		   --Тэги
		   INSERT INTO [dbo].[Tags]
           ([Tag])
       VALUES
           ('Химия'),
		   ('Физика'),
		   ('Экономика'),
		   ('Математика'),
		   ('Медицина'),
		   ('Астрономия')



		 
EXEC dbo.SetVersion @moduleName = 'Articles and Tags insert', @version = @version
	END TRY
	BEGIN CATCH
		print ERROR_MESSAGE();
		print 'Error on v.' + convert(nvarchar(200), @version)
	END CATCH;
END












select top 1 @currVersion = VersionId from dbo.DbVersion where Module = @moduleName order by VersionId desc;
print '********************************************************************************'
print '** UPDATE FINISHED: ' + @moduleName
print '** CURRENT VERSION: ' + convert(nvarchar(200), @currVersion)
print '** DATE/TIME: ' + convert(nvarchar(200), getdate(), 121)
print '********************************************************************************'
GO

GO
PRINT N'Существующие данные проверяются относительно вновь созданных ограничений';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dbo].[ArticleTag] WITH CHECK CHECK CONSTRAINT [FK_ArticleTag_Articles];

ALTER TABLE [dbo].[ArticleTag] WITH CHECK CHECK CONSTRAINT [FK_ArticleTag_Tags];


GO
PRINT N'Обновление завершено.';


GO
