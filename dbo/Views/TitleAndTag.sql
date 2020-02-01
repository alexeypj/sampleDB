CREATE VIEW dbo.TitleAndTag
AS
SELECT        Article.ArticleId, Article.Title, Tag.Tag
FROM           dbo.Articles AS Article LEFT OUTER JOIN
                         dbo.ArticleTag AS ArT ON ArT.ArticleId = Article.ArticleId LEFT OUTER JOIN
                         dbo.Tags AS Tag ON Tag.TagId = ArT.TagId
GO


