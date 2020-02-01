CREATE TABLE [dbo].[Articles] (
    [ArticleId] INT            IDENTITY (1, 1) NOT NULL,
    [Title]      NVARCHAR (450) NOT NULL,
    CONSTRAINT [PK_Articles] PRIMARY KEY CLUSTERED ([ArticleId] ASC)
);

