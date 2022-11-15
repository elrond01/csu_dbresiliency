/****** Object:  Table [dbo].[Customers]    Script Date: 11/9/2022 9:15:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Customers](
	[Email] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[id] [int] NOT NULL,
 CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


INSERT INTO [dbo].[Customers] values ('andres.co@gmail.com','Andres',1);
INSERT INTO [dbo].[Customers] values ('oscar@gmail.com','Oscar',2);
INSERT INTO [dbo].[Customers] values ('maggy.co@gmail.com','Margarita',3);
