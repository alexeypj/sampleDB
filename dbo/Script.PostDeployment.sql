﻿SET NOCOUNT ON;	

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
		   ('Самая яркая звезда, когда-либо замеченная за всю историю'),
		  --Статьи без тега
		   ('Статья без тега 1'),
		   ('Статья без тега 2')

		   --Тэги
		   INSERT INTO [dbo].[Tags]
           ([Tag])
       VALUES
           ('Химия'),
		   ('Физика'),
		   ('Экономика'),
		   ('Математика'),
		   ('Медицина'),
		   ('Астрономия'),
		   ('Политика')  -- Нет статей с таким тэгом



		 
EXEC dbo.SetVersion @moduleName = 'Articles and Tags insert', @version = @version
	END TRY
	BEGIN CATCH
		print ERROR_MESSAGE();
		print 'Error on v.' + convert(nvarchar(200), @version)
	END CATCH;
END


SET @version = 2
IF (dbo.CheckVersion(@moduleName, @version, @shouldCheckAllPrevVersionExist) = 0)
BEGIN
	BEGIN TRY	
	--Проставляем теги
	INSERT INTO [dbo].[ArticleTag]
           ([ArticleId]
           ,[TagId])
     VALUES
           (1,1),
		   (2,1),
		   (3,1),
		   (4,1),
		   (5,1),
		   (6,1),
		   (7,1),

		   (8,2),
		   (9,2),
		   (10,2),
		   (11,2),
		   (12,2),
		   (13,2),

		   (14,3),
		   (15,3),
		   (16,3),
		   (17,3),
		   
		   (18,4),
		   (19,4),
		   (20,4),
		   (21,4),
		   (22,4),
		   (23,4),
		   (24,4),

		   (25,5),
		   (26,5),
		   (27,5),
		   (28,5),
		   (29,5),
		   (30,5),

		   (31,6),
		   (32,6),
		   (33,6),
		   (34,6),
		   (35,6),
		   (36,6),
	     --multi tags
		   (8,4),
		   (8,6),
		   
		   (16,4),

		   (35,2),
		   
		   (31,4),
		   (31,2),

		   (4,2),
		   (4,4),
		  
		   (11,6),
		   (20,2),
		   (33,1),
		   (12,4)



		 
EXEC dbo.SetVersion @moduleName = 'Link Article to tag', @version = @version
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
