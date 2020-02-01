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
/*
Удаляется столбец [dbo].[Articles].[ArticlesId], возможна потеря данных.
*/

IF EXISTS (select top 1 1 from [dbo].[Articles])
    RAISERROR (N'Обнаружены строки. Обновление схемы завершено из-за возможной потери данных.', 16, 127) WITH NOWAIT

GO
PRINT N'Операция рефакторинга Rename с помощью ключа 1a148fd8-7154-4990-a6d4-97582329b5a4 пропущена, элемент [dbo].[Tags].[Id] (SqlSimpleColumn) не будет переименован в TagId';


GO
PRINT N'Выполняется запуск перестройки таблицы [dbo].[Articles]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_Articles] (
    [ArticleId] INT            IDENTITY (1, 1) NOT NULL,
    [Title]     NVARCHAR (450) NOT NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_Articles1] PRIMARY KEY CLUSTERED ([ArticleId] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[Articles])
    BEGIN
        INSERT INTO [dbo].[tmp_ms_xx_Articles] ([Title])
        SELECT [Title]
        FROM   [dbo].[Articles];
    END

DROP TABLE [dbo].[Articles];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_Articles]', N'Articles';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_Articles1]', N'PK_Articles', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


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
PRINT N'Выполняется создание [dbo].[Tags]...';


GO
CREATE TABLE [dbo].[Tags] (
    [TagId] INT           IDENTITY (1, 1) NOT NULL,
    [Tag]   NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([TagId] ASC)
);


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
PRINT N'Обновление завершено.';


GO
