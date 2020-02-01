CREATE VIEW dbo.TitleAndTagStr_Agg
AS
SELECT        Article.ArticleId, Article.Title, STRING_AGG(Tag.Tag, ', ') AS Tags
FROM            dbo.Articles AS Article LEFT OUTER JOIN
                         dbo.ArticleTag AS ArT ON ArT.ArticleId = Article.ArticleId LEFT OUTER JOIN
                         dbo.Tags AS Tag ON Tag.TagId = ArT.TagId
GROUP BY Article.ArticleId, Article.Title
GO
