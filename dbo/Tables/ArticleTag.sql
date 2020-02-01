CREATE TABLE [dbo].[ArticleTag] (
    [Id]        INT IDENTITY (1, 1) NOT NULL,
    [ArticleId] INT NOT NULL,
    [TagId]     INT NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ArticleTag_Articles] FOREIGN KEY ([ArticleId]) REFERENCES [dbo].[Articles] ([ArticleId]),
    CONSTRAINT [FK_ArticleTag_Tags] FOREIGN KEY ([TagId]) REFERENCES [dbo].[Tags] ([TagId])
);


