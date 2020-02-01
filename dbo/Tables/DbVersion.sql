CREATE TABLE [dbo].[DbVersion] (
    [VersionId]   INT           NOT NULL,
    [Module]      VARCHAR (50)  NOT NULL,
    [Description] VARCHAR (200) NULL,
    [CreatedAt]   DATETIME      NULL,
    CONSTRAINT [PK_VersionId] PRIMARY KEY CLUSTERED ([VersionId] ASC, [Module] ASC)
);
