CREATE TABLE [dbo].[Categories](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[Type] [int] NOT NULL,
 CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
))
GO

CREATE TABLE [dbo].[Cities](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Location] [json] NOT NULL,
 CONSTRAINT [PK_Cities] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
))
GO

CREATE TABLE [dbo].[Products](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](150) NOT NULL,
	[Description] [nvarchar](1000) NULL,
	[UnitPrice] [decimal](10, 2) NOT NULL,
	[Tags] [json] NOT NULL,
	[CategoryId] [uniqueidentifier] NOT NULL,
	[IsDiscontinued] [bit] NOT NULL,
 CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
))
GO

CREATE TABLE [dbo].[ProductSuppliers](
	[Id] [uniqueidentifier] NOT NULL,
	[ProductId] [uniqueidentifier] NOT NULL,
	[SupplierId] [uniqueidentifier] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NOT NULL,
 CONSTRAINT [PK_ProductSuppliers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
))
GO

CREATE TABLE [dbo].[Suppliers](
	[Id] [uniqueidentifier] NOT NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[CityId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Suppliers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
))
GO

CREATE UNIQUE NONCLUSTERED INDEX [UQ_Categories_Name] ON [dbo].[Categories]
(
	[Name] ASC
)
GO

CREATE NONCLUSTERED INDEX [IX_Products_CategoryId] ON [dbo].[Products]
(
	[CategoryId] ASC
)
GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_ProductSuppliers] ON [dbo].[ProductSuppliers]
(
	[ProductId] ASC,
	[SupplierId] ASC
)
GO

CREATE NONCLUSTERED INDEX [IX_ProductSuppliers_SupplierId] ON [dbo].[ProductSuppliers]
(
	[SupplierId] ASC
)
GO

CREATE NONCLUSTERED INDEX [IX_Suppliers_CityId] ON [dbo].[Suppliers]
(
	[CityId] ASC
)
GO

ALTER TABLE [dbo].[Categories] ADD  CONSTRAINT [DF_Categories_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[Products] ADD  CONSTRAINT [DF_Products_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT (CONVERT([bit],(0))) FOR [IsDiscontinued]
GO
ALTER TABLE [dbo].[ProductSuppliers] ADD  CONSTRAINT [DF_ProductSuppliers_Id]  DEFAULT (newsequentialid()) FOR [Id]
GO
ALTER TABLE [dbo].[Products]  ADD  CONSTRAINT [FK_Products_Categories] FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Categories] ([Id])
GO
ALTER TABLE [dbo].[ProductSuppliers]  ADD  CONSTRAINT [FK_ProductSuppliers_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[ProductSuppliers]  ADD  CONSTRAINT [FK_ProductSuppliers_Suppliers] FOREIGN KEY([SupplierId])
REFERENCES [dbo].[Suppliers] ([Id])
GO
ALTER TABLE [dbo].[Suppliers]  ADD  CONSTRAINT [FK_Suppliers_Cities_CityId] FOREIGN KEY([CityId])
REFERENCES [dbo].[Cities] ([Id])
ON DELETE CASCADE
GO

INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'e8bc3d4e-5f6a-4b7c-8d8e-0123456789cd', N'Travel', NULL, 6)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'ad1e2f3a-4b5c-4d7e-8f8a-0123456789de', N'Automotive', N'Car parts and accessories', 6)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'1f1a1b2c-3d4e-4f5a-8b6c-1234567890ab', N'Electronics', N'Gadgets and electronic devices', 0)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'be2f3a4b-5c6d-4e8f-9a9b-1234567890ef', N'Pet Supplies', N'Products for pets', 4)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'2a2b3c4d-5e6f-4a7b-8c9d-2345678901bc', N'Books', N'Printed and digital books', 5)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'cf3a4b5c-6d7e-4f9a-8b0c-2345678901fa', N'Groceries', N'Food and beverage items', 3)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'd14b5c6d-7e8f-4a0b-9c1d-3456789012ab', N'Furniture', N'Indoor furniture items', 2)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'3c3d4e5f-6a7b-4c8d-9e1f-3456789012cd', N'Clothing', N'Apparel for men, women, and kids', 1)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'e25c6d7e-8f9a-4b1c-8d2e-4567890123bc', N'Jewelry', N'Rings, necklaces, and bracelets', 1)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'4d4e5f6a-7b8c-4d9e-8f2a-4567890123de', N'Toys', N'Toys for all ages', 0)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'f36d7e8f-9a1b-4c2d-9e3f-5678901234cd', N'Shoes', N'Footwear for men and women', 1)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'5e5f6a7b-8c9d-4e1f-9a3b-5678901234ef', N'Sports', N'Sports equipment and accessories', 5)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'a47e8f9a-1b2c-4d3e-8f4a-6789012345de', N'Art', N'Paintings, sculptures, and art supplies', 5)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'6f6a7b8c-9d1e-4f2a-8b4c-6789012345fa', N'Home', N'Home appliances and furniture', 2)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'7a7b8c9d-1e2f-4a3b-9c5d-7890123456ab', N'Garden', N'Garden tools and outdoor equipment', 2)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'b58f9a1b-2c3d-4e4f-9a5b-7890123456ef', N'Music', N'Instruments and accessories', 5)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'8b8c9d1e-2f3a-4b5c-8d6e-8901234567bc', N'Beauty', N'Cosmetics and personal care', 4)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'c69a1b2c-3d4e-4f5a-8b6c-8901234567fa', N'Office', N'Office supplies and stationery', 0)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'd7ab2c3d-4e5f-4a6b-9c7d-9012345678ab', N'Photography', N'Cameras and accessories', 5)
GO
INSERT [dbo].[Categories] ([Id], [Name], [Description], [Type]) VALUES (N'9c9d1e2f-3a4b-4c6d-9e7f-9012345678cd', N'Health', N'Health and wellness products', 4)
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'204f25a8-cafa-f011-9032-0050b6a2672f', N'Travel Backpack', N'Lightweight backpack ideal for weekend trips.', CAST(79.99 AS Decimal(10, 2)), CAST(N'["travel","outdoor","lightweight"]' AS Json), N'e8bc3d4e-5f6a-4b7c-8d8e-0123456789cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'214f25a8-cafa-f011-9032-0050b6a2672f', N'Car Cover', N'Waterproof cover to protect your car from dust and rain.', CAST(49.50 AS Decimal(10, 2)), CAST(N'["automotive","protection"]' AS Json), N'ad1e2f3a-4b5c-4d7e-8f8a-0123456789de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'224f25a8-cafa-f011-9032-0050b6a2672f', N'Wireless Earbuds', N'High-quality sound with noise cancellation.', CAST(129.99 AS Decimal(10, 2)), CAST(N'["electronics","audio","wireless"]' AS Json), N'1f1a1b2c-3d4e-4f5a-8b6c-1234567890ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'234f25a8-cafa-f011-9032-0050b6a2672f', N'Dog Chew Toy', NULL, CAST(12.49 AS Decimal(10, 2)), CAST(N'["pet","toy","durable"]' AS Json), N'be2f3a4b-5c6d-4e8f-9a9b-1234567890ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'244f25a8-cafa-f011-9032-0050b6a2672f', N'Fantasy Novel: The Lost Kingdom', N'A thrilling adventure through mystical lands.', CAST(15.99 AS Decimal(10, 2)), CAST(N'["books","fantasy","bestseller"]' AS Json), N'2a2b3c4d-5e6f-4a7b-8c9d-2345678901bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'254f25a8-cafa-f011-9032-0050b6a2672f', N'Organic Olive Oil', N'Cold-pressed extra virgin olive oil.', CAST(9.99 AS Decimal(10, 2)), CAST(N'["groceries","organic","food"]' AS Json), N'cf3a4b5c-6d7e-4f9a-8b0c-2345678901fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'264f25a8-cafa-f011-9032-0050b6a2672f', N'Office Chair', NULL, CAST(149.95 AS Decimal(10, 2)), CAST(N'["furniture","office"]' AS Json), N'd14b5c6d-7e8f-4a0b-9c1d-3456789012ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'274f25a8-cafa-f011-9032-0050b6a2672f', N'Men''s Casual Shirt', N'Cotton shirt available in multiple colors.', CAST(29.99 AS Decimal(10, 2)), CAST(N'["clothing","men","cotton"]' AS Json), N'3c3d4e5f-6a7b-4c8d-9e1f-3456789012cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'284f25a8-cafa-f011-9032-0050b6a2672f', N'Gold Necklace', NULL, CAST(199.99 AS Decimal(10, 2)), CAST(N'["jewelry","gold","necklace"]' AS Json), N'e25c6d7e-8f9a-4b1c-8d2e-4567890123bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'294f25a8-cafa-f011-9032-0050b6a2672f', N'Building Blocks Set', N'Creative toy set for kids aged 3-8.', CAST(34.50 AS Decimal(10, 2)), CAST(N'["toys","kids","educational"]' AS Json), N'4d4e5f6a-7b8c-4d9e-8f2a-4567890123de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'2a4f25a8-cafa-f011-9032-0050b6a2672f', N'Running Sneakers', N'Comfortable running shoes with excellent grip.', CAST(89.99 AS Decimal(10, 2)), CAST(N'["shoes","sports","running"]' AS Json), N'f36d7e8f-9a1b-4c2d-9e3f-5678901234cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'2b4f25a8-cafa-f011-9032-0050b6a2672f', N'Yoga Mat', NULL, CAST(29.99 AS Decimal(10, 2)), CAST(N'["sports","fitness","yoga"]' AS Json), N'5e5f6a7b-8c9d-4e1f-9a3b-5678901234ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'2c4f25a8-cafa-f011-9032-0050b6a2672f', N'Watercolor Paint Set', N'Professional-grade paints with vibrant colors.', CAST(24.99 AS Decimal(10, 2)), CAST(N'["art","painting","watercolor"]' AS Json), N'a47e8f9a-1b2c-4d3e-8f4a-6789012345de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'2d4f25a8-cafa-f011-9032-0050b6a2672f', N'Blender', NULL, CAST(59.90 AS Decimal(10, 2)), CAST(N'["home","appliances","kitchen"]' AS Json), N'6f6a7b8c-9d1e-4f2a-8b4c-6789012345fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'2e4f25a8-cafa-f011-9032-0050b6a2672f', N'Garden Hose 20m', N'Durable hose suitable for all garden tasks.', CAST(39.95 AS Decimal(10, 2)), CAST(N'["garden","tools","watering"]' AS Json), N'7a7b8c9d-1e2f-4a3b-9c5d-7890123456ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'2f4f25a8-cafa-f011-9032-0050b6a2672f', N'Acoustic Guitar', NULL, CAST(249.99 AS Decimal(10, 2)), CAST(N'["music","instrument","guitar"]' AS Json), N'b58f9a1b-2c3d-4e4f-9a5b-7890123456ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'304f25a8-cafa-f011-9032-0050b6a2672f', N'Lipstick Set', N'Long-lasting colors suitable for all skin tones.', CAST(19.99 AS Decimal(10, 2)), CAST(N'["beauty","cosmetics","makeup"]' AS Json), N'8b8c9d1e-2f3a-4b5c-8d6e-8901234567bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'314f25a8-cafa-f011-9032-0050b6a2672f', N'Printer Paper A4 Pack', NULL, CAST(6.50 AS Decimal(10, 2)), CAST(N'["office","stationery"]' AS Json), N'c69a1b2c-3d4e-4f5a-8b6c-8901234567fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'324f25a8-cafa-f011-9032-0050b6a2672f', N'Digital Camera', N'Compact camera with 20MP and 5x optical zoom.', CAST(349.95 AS Decimal(10, 2)), CAST(N'["photography","camera","digital"]' AS Json), N'd7ab2c3d-4e5f-4a6b-9c7d-9012345678ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'334f25a8-cafa-f011-9032-0050b6a2672f', N'Vitamin Supplements', NULL, CAST(29.99 AS Decimal(10, 2)), CAST(N'["health","supplements"]' AS Json), N'9c9d1e2f-3a4b-4c6d-9e7f-9012345678cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'8c1f4a7e-2d5b-4e9a-c6f3-1a9e5c2f8b4d', N'Pearl Earrings', NULL, CAST(149.99 AS Decimal(10, 2)), CAST(N'["jewelry","pearl","earrings"]' AS Json), N'e25c6d7e-8f9a-4b1c-8d2e-4567890123bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'c7e1a4f9-4b8d-4c2e-e5f6-1b4a8c2e9f5d', N'Ergonomic Mouse Pad', N'Gel wrist rest for comfort during long sessions.', CAST(14.99 AS Decimal(10, 2)), CAST(N'["office","accessories","ergonomic"]' AS Json), N'c69a1b2c-3d4e-4f5a-8b6c-8901234567fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'9f2b5a8e-3c6d-4c1a-e4f7-1b4e8a2c5f9d', N'Cookware Set 10 Pieces', N'Non-stick pots and pans with lids.', CAST(129.99 AS Decimal(10, 2)), CAST(N'["home","kitchen","cookware"]' AS Json), N'6f6a7b8c-9d1e-4f2a-8b4c-6789012345fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'6a4f1c8e-7d3b-4a5f-9e2c-1b8d4a7f3e6c', N'Car Vacuum Cleaner', N'Portable 12V vacuum with strong suction.', CAST(39.95 AS Decimal(10, 2)), CAST(N'["automotive","cleaning"]' AS Json), N'ad1e2f3a-4b5c-4d7e-8f8a-0123456789de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'5a8c1f4e-7d2b-4e9a-a6c3-1b8e4a7c2f5d', N'Electric Guitar Starter Pack', N'Includes guitar, amp, and accessories.', CAST(299.99 AS Decimal(10, 2)), CAST(N'["music","instrument","guitar","electric"]' AS Json), N'b58f9a1b-2c3d-4e4f-9a5b-7890123456ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'4d7a1c9f-5e2b-4c8e-a4f6-1b8e5a2d9c4f', N'Board Game: Strategy Quest', NULL, CAST(39.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'4d4e5f6a-7b8c-4d9e-8f2a-4567890123de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'3f7a2c8e-5d1b-4a9f-c6e4-1b8f5a2d9c3e', N'Self-Help: Mindfulness Guide', NULL, CAST(18.99 AS Decimal(10, 2)), CAST(N'["books","self-help","wellness"]' AS Json), N'2a2b3c4d-5e6f-4a7b-8c9d-2345678901bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'3f8e1a5c-9d2b-4c7f-a4e6-1b9d5c2a8f3e', N'Portable Power Bank 20000mAh', NULL, CAST(45.99 AS Decimal(10, 2)), CAST(N'["electronics","charging","portable"]' AS Json), N'1f1a1b2c-3d4e-4f5a-8b6c-1234567890ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'8e1b4a7c-6f2d-4a9e-c5f8-1d4b7e9a2c5f', N'Casual Loafers', NULL, CAST(74.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'f36d7e8f-9a1b-4c2d-9e3f-5678901234cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'a4e7c1f9-6b3d-4a5e-c8f2-1d5a8c2e9f4b', N'Golf Club Set', N'Complete 12-piece set for beginners.', CAST(349.99 AS Decimal(10, 2)), CAST(N'["sports","golf","equipment"]' AS Json), N'5e5f6a7b-8c9d-4e1f-9a3b-5678901234ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'c4e7a1f9-3b8d-4a5c-e2f6-1d5a8c4f2b9e', N'Fitness Tracker Band', N'Tracks steps, sleep, and heart rate.', CAST(59.99 AS Decimal(10, 2)), CAST(N'["health","fitness","wearable"]' AS Json), N'9c9d1e2f-3a4b-4c6d-9e7f-9012345678cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'7e2b5a8f-9c1d-4f4e-a6c3-1d8b5e2a9f4c', N'Kids Raincoat', NULL, CAST(34.99 AS Decimal(10, 2)), CAST(N'["clothing","kids","rain"]' AS Json), N'3c3d4e5f-6a7b-4c8d-9e1f-3456789012cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'4a7c1f9e-8d2b-4a8e-b6c3-1e5a9c2f8b4d', N'Lens Filter Set', N'UV, CPL, and ND filters in carrying case.', CAST(49.99 AS Decimal(10, 2)), CAST(N'["photography","lens","filters"]' AS Json), N'd7ab2c3d-4e5f-4a6b-9c7d-9012345678ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'9b6c3f1a-8d5e-4c2a-f7b4-1e9a5d2c8f6b', N'4K Streaming Stick', N'Stream your favorite content in Ultra HD.', CAST(49.99 AS Decimal(10, 2)), CAST(N'["electronics","streaming","tv"]' AS Json), N'1f1a1b2c-3d4e-4f5a-8b6c-1234567890ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'3a6c9f2e-5d8b-4c1a-b7e4-1f4d8a5c2b9e', N'Coffee Table Glass', NULL, CAST(189.00 AS Decimal(10, 2)), CAST(N'["furniture","living room","glass"]' AS Json), N'd14b5c6d-7e8f-4a0b-9c1d-3456789012ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'4e1b7a9f-3c5d-4d8e-a6c2-1f9b4e7a2c5d', N'Organic Honey 500g', N'Pure raw honey from local beekeepers.', CAST(14.99 AS Decimal(10, 2)), CAST(N'["groceries","organic","honey"]' AS Json), N'cf3a4b5c-6d7e-4f9a-8b0c-2345678901fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'3c6f9a2e-7d1b-4e4c-b8f5-2a5e8c1f4b9d', N'Tennis Racket Pro', N'Carbon fiber frame for advanced players.', CAST(189.99 AS Decimal(10, 2)), CAST(N'["sports","tennis","equipment"]' AS Json), N'5e5f6a7b-8c9d-4e1f-9a3b-5678901234ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'c4e7a1f9-8d5b-4a4c-e3f6-2a6c9e1f5b8d', N'Drum Sticks Professional', N'Hickory wood with nylon tips.', CAST(15.99 AS Decimal(10, 2)), CAST(N'["music","drums","accessories"]' AS Json), N'b58f9a1b-2c3d-4e4f-9a5b-7890123456ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'b4e7c1a9-6f3d-4c9e-e2f5-2a6c9e4f1b8d', N'Sticky Notes Variety Pack', NULL, CAST(9.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'c69a1b2c-3d4e-4f5a-8b6c-8901234567fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'7e1a4c9f-5b2d-4a7c-e3f8-2b5e8a1c4f9d', N'Robot Vacuum Cleaner', NULL, CAST(299.99 AS Decimal(10, 2)), CAST(N'["home","appliances","cleaning"]' AS Json), N'6f6a7b8c-9d1e-4f2a-8b4c-6789012345fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'9c5e2a8f-1d4b-4c7a-f6e3-2b5f8c1e9a4d', N'Recliner Chair Leather', N'Premium leather with adjustable positions.', CAST(449.00 AS Decimal(10, 2)), CAST(N'["furniture","chair","leather"]' AS Json), N'd14b5c6d-7e8f-4a0b-9c1d-3456789012ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'b5e8a1c4-9f2d-4e9c-a3f6-2b8d5a1c9f4e', N'Photo Printer Portable', N'Print 4x6 photos directly from smartphone.', CAST(129.99 AS Decimal(10, 2)), CAST(N'["photography","printer","portable"]' AS Json), N'd7ab2c3d-4e5f-4a6b-9c7d-9012345678ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'7e1a4d9c-3f8b-4e2a-c5f7-2b9e6d1a4c8f', N'Bird Cage Large', NULL, CAST(89.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'be2f3a4b-5c6d-4e8f-9a9b-1234567890ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'7f2a5c8e-1b4d-4a1c-b7e4-2c6a9e3f5b8d', N'Posture Corrector', NULL, CAST(24.99 AS Decimal(10, 2)), CAST(N'["health","posture","back support"]' AS Json), N'9c9d1e2f-3a4b-4c6d-9e7f-9012345678cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'a1e4c7f9-5b8d-4c2a-e3f6-2c6e9a1f5b8d', N'Kids Sandals', N'Comfortable summer sandals with velcro straps.', CAST(29.99 AS Decimal(10, 2)), CAST(N'["shoes","kids","summer"]' AS Json), N'f36d7e8f-9a1b-4c2d-9e3f-5678901234cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'5e8b1c4a-2f9d-4c7e-a3f6-2c8e5a1f9b4d', N'Easel Wooden Studio', N'Adjustable height with tilting canvas holder.', CAST(89.99 AS Decimal(10, 2)), CAST(N'["art","easel","studio"]' AS Json), N'a47e8f9a-1b2c-4d3e-8f4a-6789012345de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'7f2a5c8e-9d1b-4a4f-b3e6-2c8f1a5e9b4d', N'Gemstone Pendant', N'Natural amethyst on sterling silver chain.', CAST(179.99 AS Decimal(10, 2)), CAST(N'["jewelry","gemstone","necklace"]' AS Json), N'e25c6d7e-8f9a-4b1c-8d2e-4567890123bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'8e1c4a7f-6b9d-4c2a-e5f3-2c9e5a1f8b4d', N'Pruning Shears', NULL, CAST(24.99 AS Decimal(10, 2)), CAST(N'["garden","tools","cutting"]' AS Json), N'7a7b8c9d-1e2f-4a3b-9c5d-7890123456ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'8e1c4a7f-5b9d-4a2c-b3e6-2c9f5a1e8b4d', N'Hair Dryer Professional', NULL, CAST(79.99 AS Decimal(10, 2)), CAST(N'["beauty","hair","appliances"]' AS Json), N'8b8c9d1e-2f3a-4b5c-8d6e-8901234567bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'f2a8c5e1-6b3d-4f9a-8c4e-2d7b5a1f9c6e', N'Jump Starter Kit', N'Portable battery pack with 800A peak current.', CAST(89.99 AS Decimal(10, 2)), CAST(N'["automotive","emergency","battery"]' AS Json), N'ad1e2f3a-4b5c-4d7e-8f8a-0123456789de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'a1d4c7f2-8b5e-4a3d-9c6f-2e1a7b4d8c5f', N'Passport Holder', N'Premium leather passport case with RFID blocking.', CAST(24.50 AS Decimal(10, 2)), CAST(N'["travel","accessories","leather"]' AS Json), N'e8bc3d4e-5f6a-4b7c-8d8e-0123456789cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'5f8b1c4a-7e2d-4c9f-a5b3-2e6d9a1f5c8b', N'Dark Chocolate Assortment', NULL, CAST(22.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'cf3a4b5c-6d7e-4f9a-8b0c-2345678901fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'c5b2e9a1-4f7d-4e3c-8a6b-2f5d9c1e7a4b', N'Bluetooth Speaker', N'Waterproof speaker with 12-hour battery life.', CAST(69.99 AS Decimal(10, 2)), CAST(N'["electronics","audio","bluetooth"]' AS Json), N'1f1a1b2c-3d4e-4f5a-8b6c-1234567890ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'6f3b8e1c-4a7d-4d2f-9c5e-3a1b8f4c7d2e', N'Cat Scratching Post', N'Sisal-wrapped post with plush base.', CAST(42.99 AS Decimal(10, 2)), CAST(N'["pet","cat","furniture"]' AS Json), N'be2f3a4b-5c6d-4e8f-9a9b-1234567890ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'9f2b5a8e-1c4d-4c1a-b7e3-3a7c1e4f9b2d', N'Camera Tripod Professional', N'Carbon fiber with ball head, holds up to 15kg.', CAST(189.99 AS Decimal(10, 2)), CAST(N'["photography","tripod","equipment"]' AS Json), N'd7ab2c3d-4e5f-4a6b-9c7d-9012345678ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'c7e1a4f9-4b8d-4c2a-e6f5-3a7c1e4f9b2d', N'Canvas Pack 5 Pieces', N'Pre-stretched cotton canvas various sizes.', CAST(34.99 AS Decimal(10, 2)), CAST(N'["art","canvas","painting"]' AS Json), N'a47e8f9a-1b2c-4d3e-8f4a-6789012345de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'6f9c2a5e-1d8b-4c4f-b3e6-3a7c1f9e5b2d', N'Seed Starter Kit', N'Everything needed to start a vegetable garden.', CAST(29.99 AS Decimal(10, 2)), CAST(N'["garden","seeds","growing"]' AS Json), N'7a7b8c9d-1e2f-4a3b-9c5d-7890123456ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'a1e4b7c9-8f2d-4a5c-d6e3-3b9f1c4e7a8d', N'Athletic Shorts', N'Breathable fabric for sports activities.', CAST(24.99 AS Decimal(10, 2)), CAST(N'["clothing","sports","unisex"]' AS Json), N'3c3d4e5f-6a7b-4c8d-9e1f-3456789012cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'5e8b1c4a-9f2d-4a7c-a4e7-3c6f9a2e5b1d', N'Anti-Aging Serum', N'With vitamin C and hyaluronic acid.', CAST(49.99 AS Decimal(10, 2)), CAST(N'["beauty","skincare","anti-aging"]' AS Json), N'8b8c9d1e-2f3a-4b5c-8d6e-8901234567bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'5a8c1f4e-2d9b-4e7a-a3c6-3c8e5a2f9b1d', N'First Aid Kit Complete', N'Over 300 pieces for home and travel.', CAST(34.99 AS Decimal(10, 2)), CAST(N'["health","first aid","emergency"]' AS Json), N'9c9d1e2f-3a4b-4c6d-9e7f-9012345678cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'5e8b1c4a-9f2d-4a7c-a4e6-3c9f5a2e8b1d', N'Cycling Helmet', N'Lightweight with ventilation system.', CAST(64.99 AS Decimal(10, 2)), CAST(N'["sports","cycling","safety"]' AS Json), N'5e5f6a7b-8c9d-4e1f-9a3b-5678901234ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'6b9d2c5a-8f1e-4a7c-a4e8-3d6b9f2c5a1e', N'Nightstand with Drawer', NULL, CAST(79.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'd14b5c6d-7e8f-4a0b-9c1d-3456789012ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'9e2b5a8f-1c4d-4f7e-a3c6-3f9e2b5a8c1d', N'Puzzle 1000 Pieces', NULL, CAST(19.99 AS Decimal(10, 2)), CAST(N'["toys","puzzle","family"]' AS Json), N'4d4e5f6a-7b8c-4d9e-8f2a-4567890123de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'6f9c2a5e-4d1b-4c4f-b8e6-4a1c7f9e5b2d', N'Blood Pressure Monitor', N'Digital monitor with memory function.', CAST(49.99 AS Decimal(10, 2)), CAST(N'["health","monitoring","blood pressure"]' AS Json), N'9c9d1e2f-3a4b-4c6d-9e7f-9012345678cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'5e2a8d4f-3c7b-4a1e-b9f6-4c8e2d5a1b7f', N'Wireless Mouse', N'Ergonomic design with silent clicks.', CAST(34.99 AS Decimal(10, 2)), CAST(N'["electronics","mouse","wireless"]' AS Json), N'1f1a1b2c-3d4e-4f5a-8b6c-1234567890ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'3b7e9a4f-1c6d-4b2e-8f5a-4c9d2e7b1a6f', N'Car Phone Mount', NULL, CAST(18.99 AS Decimal(10, 2)), CAST(N'["automotive","phone","mount"]' AS Json), N'ad1e2f3a-4b5c-4d7e-8f8a-0123456789de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'7f2a5c8e-4b9d-4a1c-b7e4-4d1a7c5f2e9b', N'Microphone USB Condenser', NULL, CAST(89.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'b58f9a1b-2c3d-4e4f-9a5b-7890123456ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'6f9c2a5e-1b8d-4c4f-a7e2-4d1a8c5f2b9e', N'Silk Scarf', NULL, CAST(44.99 AS Decimal(10, 2)), CAST(N'["clothing","accessories","silk"]' AS Json), N'3c3d4e5f-6a7b-4c8d-9e1f-3456789012cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'b1e4a7c9-3f6d-4e2b-8c5a-4d1f7b9e2a6c', N'Quinoa Organic 1kg', N'High-protein superfood grain.', CAST(16.99 AS Decimal(10, 2)), CAST(N'["groceries","organic","healthy"]' AS Json), N'cf3a4b5c-6d7e-4f9a-8b0c-2345678901fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'1c4a7f9e-2b5d-4e8c-b6f3-4d8b1a5c9f2e', N'Smart Thermostat', N'WiFi-enabled with energy saving features.', CAST(149.99 AS Decimal(10, 2)), CAST(N'["home","smart home","heating"]' AS Json), N'6f6a7b8c-9d1e-4f2a-8b4c-6789012345fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'2a5c8f1e-7d4b-4e9a-c6f3-4e1b8a5c2d9f', N'Women''s High Heels', N'Elegant stilettos for formal occasions.', CAST(109.99 AS Decimal(10, 2)), CAST(N'["shoes","women","formal"]' AS Json), N'f36d7e8f-9a1b-4c2d-9e3f-5678901234cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'6b3e7f1a-9c4d-4e8b-a2c5-4f7e1b9d3a6c', N'Science Fiction: Star Voyagers', NULL, CAST(14.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'2a2b3c4d-5e6f-4a7b-8c9d-2345678901bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'c6e9a2f5-1b4d-4c7a-f8e3-5a2c8f1b9e4d', N'Stuffed Animal Bear', N'Soft plush teddy bear 40cm tall.', CAST(24.99 AS Decimal(10, 2)), CAST(N'["toys","plush","kids"]' AS Json), N'4d4e5f6a-7b8c-4d9e-8f2a-4567890123de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'b8c1f4a7-2e5d-4a9b-c7e3-5a9f2c8b1e6d', N'Men''s Wool Sweater', N'Warm merino wool in classic design.', CAST(79.99 AS Decimal(10, 2)), CAST(N'["clothing","men","winter"]' AS Json), N'3c3d4e5f-6a7b-4c8d-9e1f-3456789012cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'3c6a9f2e-1b4d-4e7c-a5f8-5b2e8a1c9f3d', N'Facial Cleanser Gentle', N'For sensitive skin, dermatologist tested.', CAST(18.99 AS Decimal(10, 2)), CAST(N'["beauty","skincare","cleanser"]' AS Json), N'8b8c9d1e-2f3a-4b5c-8d6e-8901234567bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'8d2f5a9c-1e7b-4a4e-c6f3-5b8e2a1d9c4f', N'Bookshelf 5-Tier', N'Modern design with sturdy construction.', CAST(129.99 AS Decimal(10, 2)), CAST(N'["furniture","storage","wood"]' AS Json), N'd14b5c6d-7e8f-4a0b-9c1d-3456789012ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'3a6c9f2e-7d1b-4e8c-a4f7-5c9e2a5f1b8d', N'Desk Organizer', NULL, CAST(24.99 AS Decimal(10, 2)), CAST(N'["office","organization"]' AS Json), N'c69a1b2c-3d4e-4f5a-8b6c-8901234567fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'8e1c4a7f-3b6d-4c2a-e5f7-5c9e2a6f1b4d', N'Memory Card 128GB', NULL, CAST(29.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'd7ab2c3d-4e5f-4a6b-9c7d-9012345678ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'9e2c5a8f-3b6d-4c1a-b4e7-5c9f2a8e1b4d', N'Keyboard 61 Keys', NULL, CAST(179.99 AS Decimal(10, 2)), CAST(N'["music","instrument","keyboard"]' AS Json), N'b58f9a1b-2c3d-4e4f-9a5b-7890123456ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'c3e6a9f1-7b4d-4e8c-a5f2-5d1a8c4f2b9e', N'Wall Clock Modern', N'Minimalist design with silent movement.', CAST(44.99 AS Decimal(10, 2)), CAST(N'["home","decor","clock"]' AS Json), N'6f6a7b8c-9d1e-4f2a-8b4c-6789012345fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'9a5f2c8e-1b7d-4a4c-f3e6-5d2b9a1c7f4e', N'Programming: Python Mastery', N'From beginner to advanced Python concepts.', CAST(49.99 AS Decimal(10, 2)), CAST(N'["books","programming","python"]' AS Json), N'2a2b3c4d-5e6f-4a7b-8c9d-2345678901bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'c4a7e1f9-6b3d-4c8a-e2f5-5d8b2a9c1f6e', N'Diamond Ring 0.5ct', N'Elegant solitaire diamond in white gold setting.', CAST(1299.00 AS Decimal(10, 2)), CAST(N'["jewelry","diamond","ring","wedding"]' AS Json), N'e25c6d7e-8f9a-4b1c-8d2e-4567890123bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'6c9f2a5e-8d1b-4e4a-b3c7-5e2a9c6f1b8d', N'Oil Paint Set 24 Colors', N'Professional-grade oil paints in tubes.', CAST(49.99 AS Decimal(10, 2)), CAST(N'["art","painting","oil"]' AS Json), N'a47e8f9a-1b2c-4d3e-8f4a-6789012345de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'1e8b5d2a-9c4f-4d6e-b7a3-5e2c8f1d4a9b', N'Dash Camera 1080p', NULL, CAST(79.99 AS Decimal(10, 2)), CAST(N'["automotive","camera","safety"]' AS Json), N'ad1e2f3a-4b5c-4d7e-8f8a-0123456789de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'1b4a7c9f-9e2d-4c8e-a6f3-5e8b1a4c9f2d', N'Essential Oils Set', N'12 pure aromatherapy oils for diffusers.', CAST(29.99 AS Decimal(10, 2)), CAST(N'["health","aromatherapy","wellness"]' AS Json), N'9c9d1e2f-3a4b-4c6d-9e7f-9012345678cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'2c8f5a1d-9e3b-4d7a-b6c4-5f1e8a2d9c7b', N'Travel Neck Pillow', NULL, CAST(19.95 AS Decimal(10, 2)), CAST(N'["travel","comfort"]' AS Json), N'e8bc3d4e-5f6a-4b7c-8d8e-0123456789cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'4c8f2a5e-1d7b-4c9a-b6e3-5f2d8a4c1b9e', N'Aquarium Filter System', N'Silent operation for tanks up to 100L.', CAST(67.50 AS Decimal(10, 2)), CAST(N'["pet","fish","aquarium"]' AS Json), N'be2f3a4b-5c6d-4e8f-9a9b-1234567890ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'b5e8c1f4-9a2d-4c6b-a3e7-5f8b2c1e9a4d', N'Ballet Flats', N'Classic design in genuine leather.', CAST(59.99 AS Decimal(10, 2)), CAST(N'["shoes","women","casual"]' AS Json), N'f36d7e8f-9a1b-4c2d-9e3f-5678901234cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'7c4f2a8e-9d1b-4a5c-b3e7-6a2d8c5f1b9e', N'Italian Pasta Variety Pack', NULL, CAST(11.99 AS Decimal(10, 2)), CAST(N'["groceries","pasta","italian"]' AS Json), N'cf3a4b5c-6d7e-4f9a-8b0c-2345678901fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'8a4d1f7c-2e5b-4d9a-c3f8-6b2e5a9d1c4f', N'USB-C Hub 7-in-1', NULL, CAST(54.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'1f1a1b2c-3d4e-4f5a-8b6c-1234567890ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'5a8c1f4e-2b7d-4c9a-e6f3-6d2a9c5f1b8e', N'Remote Control Car', N'High-speed RC car with 30-minute battery life.', CAST(59.99 AS Decimal(10, 2)), CAST(N'["toys","remote control","vehicle"]' AS Json), N'4d4e5f6a-7b8c-4d9e-8f2a-4567890123de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'b5e8a1c4-3f6d-4e9c-a7f2-6d3a9c5f2b8e', N'Outdoor Planter Large', N'Weather-resistant resin planter.', CAST(49.99 AS Decimal(10, 2)), CAST(N'["garden","planter","outdoor"]' AS Json), N'7a7b8c9d-1e2f-4a3b-9c5d-7890123456ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'1c4a7f9e-9b2d-4e8c-a5f6-6d3b8a1c5f2e', N'Whiteboard 90x60cm', N'Magnetic surface with aluminum frame.', CAST(54.99 AS Decimal(10, 2)), CAST(N'["office","presentation","whiteboard"]' AS Json), N'c69a1b2c-3d4e-4f5a-8b6c-8901234567fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'7a9e2c5f-4b8d-4a1e-c6f3-6d3b9a5c2f8e', N'Basketball Official Size', NULL, CAST(34.99 AS Decimal(10, 2)), CAST(N'["sports","basketball"]' AS Json), N'5e5f6a7b-8c9d-4e1f-9a3b-5678901234ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'b4e7c1a9-3f6d-4c8e-e2f5-6d8a2c5f1b9e', N'Perfume Eau de Toilette', N'Fresh floral scent, 100ml bottle.', CAST(64.99 AS Decimal(10, 2)), CAST(N'["beauty","fragrance","women"]' AS Json), N'8b8c9d1e-2f3a-4b5c-8d6e-8901234567bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'5c8f2a1e-4d9b-4e7a-b3c6-6e1d4a7f9c2b', N'Men''s Winter Jacket', N'Insulated jacket with water-resistant shell.', CAST(149.99 AS Decimal(10, 2)), CAST(N'["clothing","men","winter","outdoor"]' AS Json), N'3c3d4e5f-6a7b-4c8d-9e1f-3456789012cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'9c2f5a8e-6b1d-4a4c-b7e3-6e9a2c5f1b8d', N'Charcoal Pencils Set', NULL, CAST(14.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'a47e8f9a-1b2c-4d3e-8f4a-6789012345de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'8a1c5e9f-2d7b-4f3a-b4c8-6f1e9a2d5c7b', N'Cookbook: Mediterranean Flavors', N'Over 200 authentic recipes from the Mediterranean.', CAST(32.99 AS Decimal(10, 2)), CAST(N'["books","cooking","recipes"]' AS Json), N'2a2b3c4d-5e6f-4a7b-8c9d-2345678901bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'9d2c5f8a-4b1e-4e7d-a3c9-6f2b8e1a5d4c', N'Tire Pressure Gauge', N'Digital gauge with backlit display.', CAST(14.50 AS Decimal(10, 2)), CAST(N'["automotive","tools","safety"]' AS Json), N'ad1e2f3a-4b5c-4d7e-8f8a-0123456789de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'b3f6c9a1-8e2d-4a5c-d7e4-7a1c4f9b2e5d', N'Doll House Set', N'Three-story dollhouse with furniture included.', CAST(89.99 AS Decimal(10, 2)), CAST(N'["toys","dolls","playset"]' AS Json), N'4d4e5f6a-7b8c-4d9e-8f2a-4567890123de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'a1e4c7f9-4b8d-4a2c-e5f7-7d4a1c8f2b5e', N'Compost Bin 300L', N'Durable plastic with aeration system.', CAST(69.99 AS Decimal(10, 2)), CAST(N'["garden","compost","eco"]' AS Json), N'7a7b8c9d-1e2f-4a3b-9c5d-7890123456ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'c3e6a9f1-5b8d-4e4c-a2f5-7d4a8c1f5b2e', N'Camera Bag Backpack', NULL, CAST(79.99 AS Decimal(10, 2)), CAST(N'["photography","bag","accessories"]' AS Json), N'd7ab2c3d-4e5f-4a6b-9c7d-9012345678ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'8c1f4a7d-2e5b-4f9c-b3a6-7d4e1c8f5a2b', N'Travel Adapter Universal', N'Works in over 150 countries with USB ports.', CAST(27.99 AS Decimal(10, 2)), CAST(N'["travel","electronics","adapter"]' AS Json), N'e8bc3d4e-5f6a-4b7c-8d8e-0123456789cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'9c2f5a8e-6b1d-4c4a-b7e3-7e1a4c9f2b5d', N'Makeup Brush Set 15 Pieces', N'Professional quality synthetic bristles.', CAST(39.99 AS Decimal(10, 2)), CAST(N'["beauty","makeup","brushes"]' AS Json), N'8b8c9d1e-2f3a-4b5c-8d6e-8901234567bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'9c2f5a8e-1b4d-4e9c-b7f3-7e1a4c9f2b5d', N'Resistance Bands Set', NULL, CAST(19.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'5e5f6a7b-8c9d-4e1f-9a3b-5678901234ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'1f4a7c9e-3b6d-4e2f-b8c5-7e1a4d9b2c6f', N'TV Stand Entertainment Center', N'Fits TVs up to 65 inches with cable management.', CAST(249.99 AS Decimal(10, 2)), CAST(N'["furniture","living room","entertainment"]' AS Json), N'd14b5c6d-7e8f-4a0b-9c1d-3456789012ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'5e8c1a4f-9b2d-4a7e-c3f6-7e2a5c9f1b4d', N'Decorative Lamp', NULL, CAST(54.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'6f6a7b8c-9d1e-4f2a-8b4c-6789012345fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'9e2c5a8f-6b1d-4c4a-b4e7-7f2a4c9e1b5d', N'Digital Thermometer', NULL, CAST(14.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'9c9d1e2f-3a4b-4c6d-9e7f-9012345678cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'2d7a9c5f-1e4b-4f6d-8a3c-7f2b4e9a1d5c', N'Tablet Stand Adjustable', NULL, CAST(29.99 AS Decimal(10, 2)), CAST(N'["electronics","accessories"]' AS Json), N'1f1a1b2c-3d4e-4f5a-8b6c-1234567890ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'2b5e8a1c-4f7d-4c9a-e6f3-8c4e1b5a9f2d', N'Swimming Goggles', N'Anti-fog lenses with UV protection.', CAST(22.99 AS Decimal(10, 2)), CAST(N'["sports","swimming","accessories"]' AS Json), N'5e5f6a7b-8c9d-4e1f-9a3b-5678901234ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'7d1a4c9f-5e2b-4a8d-b6f3-8c5e2a1d7f4b', N'Smart Watch Pro', N'Fitness tracking with heart rate monitor.', CAST(249.99 AS Decimal(10, 2)), CAST(N'["electronics","wearable","fitness"]' AS Json), N'1f1a1b2c-3d4e-4f5a-8b6c-1234567890ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'1d8c4a7f-2e5b-4f1d-b9a3-8c6e2f5a1d4b', N'Children''s Book: Animal Adventures', N'Colorful illustrated stories for ages 4-8.', CAST(12.99 AS Decimal(10, 2)), CAST(N'["books","children","illustrated"]' AS Json), N'2a2b3c4d-5e6f-4a7b-8c9d-2345678901bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'3a6c9f2e-1d5b-4e8a-c4f7-8d1b4a7c9f2e', N'Air Purifier HEPA', N'Removes 99.97% of airborne particles.', CAST(179.99 AS Decimal(10, 2)), CAST(N'["home","appliances","air quality"]' AS Json), N'6f6a7b8c-9d1e-4f2a-8b4c-6789012345fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'7e1a4c9f-2b5d-4a7a-b3e8-8d2b5a1c4f9e', N'Highlighter Set 6 Colors', N'Chisel tip for precise highlighting.', CAST(7.99 AS Decimal(10, 2)), CAST(N'["office","stationery","writing"]' AS Json), N'c69a1b2c-3d4e-4f5a-8b6c-8901234567fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'7f3a9c2e-1b4d-4e8f-a5c7-8d2e4f6a1b3c', N'Carry-On Luggage', N'Compact wheeled suitcase approved for cabin use.', CAST(119.99 AS Decimal(10, 2)), CAST(N'["travel","luggage","cabin"]' AS Json), N'e8bc3d4e-5f6a-4b7c-8d8e-0123456789cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'6f9b2e5a-3c8d-4a1f-b7e4-8d5a2c9f1b6e', N'Men''s Leather Boots', NULL, CAST(159.99 AS Decimal(10, 2)), CAST(N'["shoes","men","leather","winter"]' AS Json), N'f36d7e8f-9a1b-4c2d-9e3f-5678901234cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'3b6e9a1f-5c8d-4a2c-b4f7-8e2d5a1c9f3b', N'Silver Bracelet', N'Handcrafted sterling silver with adjustable clasp.', CAST(89.99 AS Decimal(10, 2)), CAST(N'["jewelry","silver","bracelet"]' AS Json), N'e25c6d7e-8f9a-4b1c-8d2e-4567890123bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'4a7c1f9e-2d5b-4a8e-b3c6-8e2f5a1c9b4d', N'Lawn Mower Electric', N'Cordless mower with 40V battery.', CAST(279.99 AS Decimal(10, 2)), CAST(N'["garden","tools","lawn"]' AS Json), N'7a7b8c9d-1e2f-4a3b-9c5d-7890123456ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'2c5a8f1e-6b4d-4a7c-c7e3-8e3a6c9f2b5d', N'Ring Light 18 inch', N'Dimmable LED with phone holder and tripod.', CAST(69.99 AS Decimal(10, 2)), CAST(N'["photography","lighting","video"]' AS Json), N'd7ab2c3d-4e5f-4a6b-9c7d-9012345678ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'1b4a7c9f-2e5d-4c8e-a6f3-8e3b5a2c9f1d', N'Violin Full Size', N'Handcrafted with case and bow included.', CAST(349.99 AS Decimal(10, 2)), CAST(N'["music","instrument","violin","classical"]' AS Json), N'b58f9a1b-2c3d-4e4f-9a5b-7890123456ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'b5d2f8a1-9c6e-4d4b-a7c3-8e4f1b5d2a9c', N'Pet Grooming Kit', N'Complete set with brushes and nail clippers.', CAST(28.99 AS Decimal(10, 2)), CAST(N'["pet","grooming","accessories"]' AS Json), N'be2f3a4b-5c6d-4e8f-9a9b-1234567890ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'4a7f1c9e-6d3b-4a8c-b2e5-8f4a1d7c3b9e', N'Women''s Summer Dress', N'Floral pattern perfect for warm weather.', CAST(49.99 AS Decimal(10, 2)), CAST(N'["clothing","women","summer"]' AS Json), N'3c3d4e5f-6a7b-4c8d-9e1f-3456789012cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'5e9a2f7c-3d1b-4c8e-a4f6-9b2d5c8a1e7f', N'Packing Cubes Set', NULL, CAST(32.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'e8bc3d4e-5f6a-4b7c-8d8e-0123456789cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'4c7a9f3e-2d8b-4c1f-a5e7-9b3d6a4c8f2e', N'Car Air Freshener Set', N'Pack of 6 with various scents.', CAST(8.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'ad1e2f3a-4b5c-4d7e-8f8a-0123456789de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'4c7a9f2e-1d5b-4e8c-a6f3-9b3e6c1a4f8d', N'Hiking Boots Waterproof', N'All-terrain boots with ankle support.', CAST(134.99 AS Decimal(10, 2)), CAST(N'["shoes","hiking","outdoor","waterproof"]' AS Json), N'f36d7e8f-9a1b-4c2d-9e3f-5678901234cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'c1f4a7e9-2d5b-4c8a-e3f6-9b6e2a1c5f4d', N'Dumbbell Set 20kg', N'Adjustable weights for home workout.', CAST(79.99 AS Decimal(10, 2)), CAST(N'["sports","fitness","weights"]' AS Json), N'5e5f6a7b-8c9d-4e1f-9a3b-5678901234ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'c7e1a4f8-2b5d-4f9c-e3a6-9c2f5b8e1d4a', N'Dining Table Set 4 Chairs', N'Solid oak table with matching chairs.', CAST(599.99 AS Decimal(10, 2)), CAST(N'["furniture","dining","wood"]' AS Json), N'd14b5c6d-7e8f-4a0b-9c1d-3456789012ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'2d5a8c1f-7b4e-4c6d-e9a3-9c2f5e8b1a4d', N'Women''s Jeans Slim Fit', NULL, CAST(59.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'3c3d4e5f-6a7b-4c8d-9e1f-3456789012cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'a5e8c1f4-6d3b-4c9a-e2f7-9c6e2a5f1b4d', N'Ukulele Soprano', N'Perfect for beginners with carrying bag.', CAST(49.99 AS Decimal(10, 2)), CAST(N'["music","instrument","ukulele"]' AS Json), N'b58f9a1b-2c3d-4e4f-9a5b-7890123456ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'b4e7c1a9-8f3d-4c6e-a2f5-9c6e3a7f1b4d', N'Throw Blanket Fleece', N'Super soft blanket 150x200cm.', CAST(39.99 AS Decimal(10, 2)), CAST(N'["home","decor","comfort"]' AS Json), N'6f6a7b8c-9d1e-4f2a-8b4c-6789012345fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'a2e5c9f1-8b4d-4a7c-e3f6-9d1c5a2b8e4f', N'Dog Food Premium 10kg', NULL, CAST(54.99 AS Decimal(10, 2)), CAST(N'["pet","dog","food"]' AS Json), N'be2f3a4b-5c6d-4e8f-9a9b-1234567890ef')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'8f1c4a7e-2d5b-4a9c-b3e7-9d2f5c8a1e4b', N'Science Experiment Kit', N'50 experiments for curious young scientists.', CAST(34.99 AS Decimal(10, 2)), CAST(N'["toys","educational","science"]' AS Json), N'4d4e5f6a-7b8c-4d9e-8f2a-4567890123de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'1a4c7f9e-3b6d-4a8c-e5f2-9d3b6a1c4f8e', N'Sketch Pad A3', NULL, CAST(12.99 AS Decimal(10, 2)), CAST(N'["art","drawing","paper"]' AS Json), N'a47e8f9a-1b2c-4d3e-8f4a-6789012345de')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'1c9f5a2e-7b4d-4f8c-a1e5-9d3b7c4a2f8e', N'Mechanical Keyboard RGB', N'Cherry MX switches with customizable lighting.', CAST(129.99 AS Decimal(10, 2)), CAST(N'["electronics","gaming","keyboard"]' AS Json), N'1f1a1b2c-3d4e-4f5a-8b6c-1234567890ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'c4e9a1f5-8b2d-4c7a-e3f6-9d5c2a8b1f4e', N'History: Ancient Civilizations', N'Comprehensive study of ancient world cultures.', CAST(45.00 AS Decimal(10, 2)), CAST(N'["books","history","education"]' AS Json), N'2a2b3c4d-5e6f-4a7b-8c9d-2345678901bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'a1e4c7f9-7b3d-4a2c-e5f8-9d6e2a5c1f4b', N'Massage Gun', NULL, CAST(129.99 AS Decimal(10, 2)), CAST(N'["health","massage","recovery"]' AS Json), N'9c9d1e2f-3a4b-4c6d-9e7f-9012345678cd')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'2c5a8f1e-9b4d-4a7c-c6e3-9e2b5a8c1f4d', N'Solar Garden Lights Set', NULL, CAST(34.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'7a7b8c9d-1e2f-4a3b-9c5d-7890123456ab')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'5e8c1a4f-3b6d-4a7e-c4f7-9e2c5a8f1b4d', N'Paper Shredder', N'Cross-cut for secure document destruction.', CAST(79.99 AS Decimal(10, 2)), CAST(N'["office","security","shredder"]' AS Json), N'c69a1b2c-3d4e-4f5a-8b6c-8901234567fa')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'1a4c7f9e-2b5d-4e8a-c6f3-9e3b6a1c4f8d', N'Nail Polish Set 12 Colors', NULL, CAST(24.99 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'8b8c9d1e-2f3a-4b5c-8d6e-8901234567bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'1e4b7a9c-3f6d-4e2b-a8c5-9f2e5b1d4a7c', N'Men''s Cufflinks Set', NULL, CAST(65.00 AS Decimal(10, 2)), CAST(N'[]' AS Json), N'e25c6d7e-8f9a-4b1c-8d2e-4567890123bc')
GO
INSERT [dbo].[Products] ([Id], [Name], [Description], [UnitPrice], [Tags], [CategoryId]) VALUES (N'2a9c5e1f-4b8d-4f7a-c2e6-9f3b1d7a4c8e', N'Premium Green Tea 50 bags', N'Antioxidant-rich Japanese green tea.', CAST(8.49 AS Decimal(10, 2)), CAST(N'["groceries","tea","organic"]' AS Json), N'cf3a4b5c-6d7e-4f9a-8b0c-2345678901fa')
GO
INSERT [dbo].[Cities] ([Id], [Name], [Location]) VALUES (N'7a3f1c4e-8b6a-4c8e-9e2e-0d5a9e8b1a01', N'Taggia', CAST(N'{"latitude":"43.8469","longitude":"7.8533"}' AS Json))
GO
INSERT [dbo].[Cities] ([Id], [Name], [Location]) VALUES (N'c4e8a1f3-9d6b-4f02-b7a1-1a8d9c3e4c03', N'New York', CAST(N'{"latitude":"40.7128","longitude":"-74.0060"}' AS Json))
GO
INSERT [dbo].[Cities] ([Id], [Name], [Location]) VALUES (N'9f2c7d1e-6a5b-4e83-91a4-2b8e6c0d5a04', N'Tokyo', CAST(N'{"latitude":"35.6762","longitude":"139.6503"}' AS Json))
GO
INSERT [dbo].[Cities] ([Id], [Name], [Location]) VALUES (N'e6d1a8c9-2f4b-4c17-8b5a-3c9e0d1f6b05', N'Sydney', CAST(N'{"latitude":"-33.8688","longitude":"151.2093"}' AS Json))
GO
INSERT [dbo].[Cities] ([Id], [Name], [Location]) VALUES (N'4b0c9e2a-1d8f-4a65-9c73-5a1e6b2d7c06', N'Berlin', CAST(N'{"latitude":"52.5200","longitude":"13.4050"}' AS Json))
GO
INSERT [dbo].[Cities] ([Id], [Name], [Location]) VALUES (N'1b9d5c72-3a4f-4a91-8c1a-6f2e0c9d2b02', N'London', CAST(N'{"latitude":"51.5074","longitude":"-0.1278"}' AS Json))
GO
INSERT [dbo].[Cities] ([Id], [Name], [Location]) VALUES (N'8a7d6b5c-9e1f-4d42-b0c1-7e2a3f9c4a07', N'Paris', CAST(N'{"latitude":"48.8566","longitude":"2.3522"}' AS Json))
GO
INSERT [dbo].[Cities] ([Id], [Name], [Location]) VALUES (N'd3a9f6c2-1e4b-4c5d-9a7f-8b0e2c1d6a09', N'Cape Town', CAST(N'{"latitude":"-33.9249","longitude":"18.4241"}' AS Json))
GO
INSERT [dbo].[Cities] ([Id], [Name], [Location]) VALUES (N'2c5e9a1d-7b6f-4e38-8c4a-9d0b1a6f3e08', N'Buenos Aires', CAST(N'{"latitude":"-34.6037","longitude":"-58.3816"}' AS Json))
GO
INSERT [dbo].[Cities] ([Id], [Name], [Location]) VALUES (N'5e1b7c0a-9d6f-4a28-8e3c-af2d4b1c9a10', N'São Paulo', CAST(N'{"latitude":"-23.5505","longitude":"-46.6333"}' AS Json))
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'6b29fc40-ca47-1067-b31d-00dd010662da', N'James', N'Smith', N'1b9d5c72-3a4f-4a91-8c1a-6f2e0c9d2b02')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'2a7e5c9d-6b4f-44f1-8e2a-0123456789ab', N'Emma', N'Johnson', N'e6d1a8c9-2f4b-4c17-8b5a-3c9e0d1f6b05')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'bc4d5e6f-7a8b-4c1d-8e2f-0123456789ab', N'Hiroshi', N'Tanaka', N'7a3f1c4e-8b6a-4c8e-9e2e-0d5a9e8b1a01')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'6f7a8b9c-1d2e-4f4a-9b5c-0123456789ab', N'Yuki', N'Yamamoto', N'7a3f1c4e-8b6a-4c8e-9e2e-0d5a9e8b1a01')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'3f2504e0-4f89-11d3-9a0c-0305e82c3301', N'Marco', N'Minerva', N'7a3f1c4e-8b6a-4c8e-9e2e-0d5a9e8b1a01')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'1e2f3a4b-5c6d-4e7f-8a9b-0abcdef12345', N'Hans', N'Müller', N'7a3f1c4e-8b6a-4c8e-9e2e-0d5a9e8b1a01')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'1a2b3c4d-5e6f-4a7b-8c9d-1234567890ab', N'Sophie', N'Williams', N'e6d1a8c9-2f4b-4c17-8b5a-3c9e0d1f6b05')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'6c7d8e9f-1a2b-4c3d-8f4e-1234567890ab', N'Oliver', N'Brown', N'1b9d5c72-3a4f-4a91-8c1a-6f2e0c9d2b02')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'1d3b5a7c-87f2-4f0a-ab9d-1234567890ab', N'Michael', N'Davis', N'c4e8a1f3-9d6b-4f02-b7a1-1a8d9c3e4c03')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'7a8b9c1d-2e3f-4a5b-8c6d-1234567890bc', N'Charlotte', N'Wilson', N'1b9d5c72-3a4f-4a91-8c1a-6f2e0c9d2b02')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'cd5e6f7a-8b9c-4d2e-9f3a-1234567890bc', N'Amélie', N'Dubois', N'1b9d5c72-3a4f-4a91-8c1a-6f2e0c9d2b02')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'2f3a4b5c-6d7e-4f8a-9b1c-123456abcdef', N'Pierre', N'Martin', N'1b9d5c72-3a4f-4a91-8c1a-6f2e0c9d2b02')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'8f1a2b3c-4d5e-4f6a-8b7c-1234abcd5678', N'Carlos', N'González', N'2c5e9a1d-7b6f-4e38-8c4a-9d0b1a6f3e08')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'3a1b2c4d-5e6f-4a7b-8c9d-1234abcd5678', N'María', N'Rodríguez', N'2c5e9a1d-7b6f-4e38-8c4a-9d0b1a6f3e08')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'4b5c6d7e-8f1a-4b2c-9d3e-1a2b3c4d5e6f', N'João', N'Silva', N'5e1b7c0a-9d6f-4a28-8e3c-af2d4b1c9a10')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'de6f7a8b-9c1d-4e3f-8a4b-234567890cde', N'William', N'Taylor', N'c4e8a1f3-9d6b-4f02-b7a1-1a8d9c3e4c03')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'3a4b5c6d-7e8f-4a9b-1c2d-23456789abcd', N'Alexander', N'Anderson', N'c4e8a1f3-9d6b-4f02-b7a1-1a8d9c3e4c03')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'ef7a8b9c-1d2e-4f4a-9b5c-345678901def', N'Kenji', N'Suzuki', N'9f2c7d1e-6a5b-4e83-91a4-2b8e6c0d5a04')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'4b5c6d7e-8f1a-4b2c-9d3e-34567890abcd', N'Sakura', N'Watanabe', N'9f2c7d1e-6a5b-4e83-91a4-2b8e6c0d5a04')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'f18b9c1d-2e3f-4a5b-8c6d-45678901abcd', N'Jack', N'Thompson', N'e6d1a8c9-2f4b-4c17-8b5a-3c9e0d1f6b05')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'5c6d7e8f-1a2b-4c3d-8e4f-4567890abcde', N'Olivia', N'White', N'e6d1a8c9-2f4b-4c17-8b5a-3c9e0d1f6b05')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'1a2b3c4d-5e6f-4a7b-8c9d-5678901234ab', N'Klaus', N'Schmidt', N'4b0c9e2a-1d8f-4a65-9c73-5a1e6b2d7c06')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'6d7e8f1a-2b3c-4d5e-9f6a-567890abcdef', N'Anna', N'Fischer', N'4b0c9e2a-1d8f-4a65-9c73-5a1e6b2d7c06')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'2b3c4d5e-6f7a-4b8c-9d1e-6789012345bc', N'Roberto', N'Damico', N'8a7d6b5c-9e1f-4d42-b0c1-7e2a3f9c4a07')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'7e8f1a2b-3c4d-4e5f-8a7b-67890abcdefa', N'Jean-Pierre', N'Leroy', N'8a7d6b5c-9e1f-4d42-b0c1-7e2a3f9c4a07')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'3c4d5e6f-7a8b-4c1d-8e2f-7890123456cd', N'Thabo', N'Mokoena', N'2c5e9a1d-7b6f-4e38-8c4a-9d0b1a6f3e08')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'8f1a2b3c-4d5e-4f6a-8b7c-7890abcdef12', N'Nomvula', N'Nkosi', N'2c5e9a1d-7b6f-4e38-8c4a-9d0b1a6f3e08')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'7c2d3e4f-1a5b-4c6d-8e7f-87654321abcd', N'Pieter', N'Van Der Berg', N'd3a9f6c2-1e4b-4c5d-9a7f-8b0e2c1d6a09')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'2b3c4d5e-6f7a-4b8c-9d1e-87654321abcd', N'Zanele', N'Dlamini', N'd3a9f6c2-1e4b-4c5d-9a7f-8b0e2c1d6a09')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'4d5e6f7a-8b9c-4d2e-9f3a-8901234567de', N'Sipho', N'Ndlovu', N'd3a9f6c2-1e4b-4c5d-9a7f-8b0e2c1d6a09')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'9a2b3c4d-5e6f-4a7b-8c9d-890abcdef123', N'Mandla', N'Zulu', N'd3a9f6c2-1e4b-4c5d-9a7f-8b0e2c1d6a09')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'ab3c4d5e-6f7a-4b8c-9d1e-9012345678ab', N'Ana', N'Pereira', N'5e1b7c0a-9d6f-4a28-8e3c-af2d4b1c9a10')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'5e6f7a8b-9c1d-4e3f-8a4b-9012345678ef', N'Lucas', N'Oliveira', N'5e1b7c0a-9d6f-4a28-8e3c-af2d4b1c9a10')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'5f3d1b7c-9a2f-4c6e-8b1a-9876543210fe', N'Friedrich', N'Weber', N'4b0c9e2a-1d8f-4a65-9c73-5a1e6b2d7c06')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'9a1b2c3d-4e5f-4a6b-8c7d-9876543210fe', N'Emily', N'Clark', N'c4e8a1f3-9d6b-4f02-b7a1-1a8d9c3e4c03')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'7f8e9d0c-1a2b-4c3d-9b4a-9876543210fe', N'Thomas', N'Wagner', N'4b0c9e2a-1d8f-4a65-9c73-5a1e6b2d7c06')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'9d0c1b2a-3e4f-4a5b-8c6d-abcde1234567', N'Gabriel', N'Santos', N'5e1b7c0a-9d6f-4a28-8e3c-af2d4b1c9a10')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'2d3e4f5a-6b7c-4d8e-9f1a-abcde1234567', N'Chiara', N'Romano', N'7a3f1c4e-8b6a-4c8e-9e2e-0d5a9e8b1a01')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'5f6a7b8c-9d1e-4f2a-8c3b-abcdef123456', N'Takeshi', N'Nakamura', N'9f2c7d1e-6a5b-4e83-91a4-2b8e6c0d5a04')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'9c8f1d2b-4e3f-41a0-ba8d-abcdef123456', N'Yui', N'Kobayashi', N'9f2c7d1e-6a5b-4e83-91a4-2b8e6c0d5a04')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'3e4f5a6b-7c8d-4e1f-8b2a-abcdef987654', N'Camille', N'Bernard', N'8a7d6b5c-9e1f-4d42-b0c1-7e2a3f9c4a07')
GO
INSERT [dbo].[Suppliers] ([Id], [FirstName], [LastName], [CityId]) VALUES (N'8e2c3d1f-7b6a-4d8e-9c1b-abcdef987654', N'Isabelle', N'Moreau', N'8a7d6b5c-9e1f-4d42-b0c1-7e2a3f9c4a07')
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'a959e250-ccfa-f011-9032-0050b6a2672f', N'204f25a8-cafa-f011-9032-0050b6a2672f', N'bc4d5e6f-7a8b-4c1d-8e2f-0123456789ab', CAST(N'2022-03-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'aa59e250-ccfa-f011-9032-0050b6a2672f', N'a1d4c7f2-8b5e-4a3d-9c6f-2e1a7b4d8c5f', N'bc4d5e6f-7a8b-4c1d-8e2f-0123456789ab', CAST(N'2021-06-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'ab59e250-ccfa-f011-9032-0050b6a2672f', N'2c8f5a1d-9e3b-4d7a-b6c4-5f1e8a2d9c7b', N'bc4d5e6f-7a8b-4c1d-8e2f-0123456789ab', CAST(N'2020-01-10' AS Date), CAST(N'2023-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'ac59e250-ccfa-f011-9032-0050b6a2672f', N'8c1f4a7d-2e5b-4f9c-b3a6-7d4e1c8f5a2b', N'6f7a8b9c-1d2e-4f4a-9b5c-0123456789ab', CAST(N'2023-01-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'ad59e250-ccfa-f011-9032-0050b6a2672f', N'7f3a9c2e-1b4d-4e8f-a5c7-8d2e4f6a1b3c', N'6f7a8b9c-1d2e-4f4a-9b5c-0123456789ab', CAST(N'2019-05-20' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'ae59e250-ccfa-f011-9032-0050b6a2672f', N'5e9a2f7c-3d1b-4c8e-a4f6-9b2d5c8a1e7f', N'6f7a8b9c-1d2e-4f4a-9b5c-0123456789ab', CAST(N'2022-08-15' AS Date), CAST(N'2024-08-15' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'af59e250-ccfa-f011-9032-0050b6a2672f', N'214f25a8-cafa-f011-9032-0050b6a2672f', N'6f7a8b9c-1d2e-4f4a-9b5c-0123456789ab', CAST(N'2021-11-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'b059e250-ccfa-f011-9032-0050b6a2672f', N'6a4f1c8e-7d3b-4a5f-9e2c-1b8d4a7f3e6c', N'3f2504e0-4f89-11d3-9a0c-0305e82c3301', CAST(N'2020-07-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'b159e250-ccfa-f011-9032-0050b6a2672f', N'f2a8c5e1-6b3d-4f9a-8c4e-2d7b5a1f9c6e', N'3f2504e0-4f89-11d3-9a0c-0305e82c3301', CAST(N'2018-03-10' AS Date), CAST(N'2022-03-10' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'b259e250-ccfa-f011-9032-0050b6a2672f', N'3b7e9a4f-1c6d-4b2e-8f5a-4c9d2e7b1a6f', N'1e2f3a4b-5c6d-4e7f-8a9b-0abcdef12345', CAST(N'2023-05-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'b359e250-ccfa-f011-9032-0050b6a2672f', N'1e8b5d2a-9c4f-4d6e-b7a3-5e2c8f1d4a9b', N'1e2f3a4b-5c6d-4e7f-8a9b-0abcdef12345', CAST(N'2022-02-14' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'b459e250-ccfa-f011-9032-0050b6a2672f', N'9d2c5f8a-4b1e-4e7d-a3c9-6f2b8e1a5d4c', N'1e2f3a4b-5c6d-4e7f-8a9b-0abcdef12345', CAST(N'2021-09-01' AS Date), CAST(N'2025-09-01' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'b559e250-ccfa-f011-9032-0050b6a2672f', N'4c7a9f3e-2d8b-4c1f-a5e7-9b3d6a4c8f2e', N'1e2f3a4b-5c6d-4e7f-8a9b-0abcdef12345', CAST(N'2020-12-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'b659e250-ccfa-f011-9032-0050b6a2672f', N'224f25a8-cafa-f011-9032-0050b6a2672f', N'1e2f3a4b-5c6d-4e7f-8a9b-0abcdef12345', CAST(N'2019-04-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'b759e250-ccfa-f011-9032-0050b6a2672f', N'3f8e1a5c-9d2b-4c7f-a4e6-1b9d5c2a8f3e', N'2d3e4f5a-6b7c-4d8e-9f1a-abcde1234567', CAST(N'2023-07-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'b859e250-ccfa-f011-9032-0050b6a2672f', N'9b6c3f1a-8d5e-4c2a-f7b4-1e9a5d2c8f6b', N'2d3e4f5a-6b7c-4d8e-9f1a-abcde1234567', CAST(N'2022-01-20' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'b959e250-ccfa-f011-9032-0050b6a2672f', N'c5b2e9a1-4f7d-4e3c-8a6b-2f5d9c1e7a4b', N'2d3e4f5a-6b7c-4d8e-9f1a-abcde1234567', CAST(N'2021-06-10' AS Date), CAST(N'2024-06-10' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'ba59e250-ccfa-f011-9032-0050b6a2672f', N'5e2a8d4f-3c7b-4a1e-b9f6-4c8e2d5a1b7f', N'1d3b5a7c-87f2-4f0a-ab9d-1234567890ab', CAST(N'2020-10-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'bb59e250-ccfa-f011-9032-0050b6a2672f', N'8a4d1f7c-2e5b-4d9a-c3f8-6b2e5a9d1c4f', N'1d3b5a7c-87f2-4f0a-ab9d-1234567890ab', CAST(N'2019-08-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'bc59e250-ccfa-f011-9032-0050b6a2672f', N'2d7a9c5f-1e4b-4f6d-8a3c-7f2b4e9a1d5c', N'de6f7a8b-9c1d-4e3f-8a4b-234567890cde', CAST(N'2023-02-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'bd59e250-ccfa-f011-9032-0050b6a2672f', N'7d1a4c9f-5e2b-4a8d-b6f3-8c5e2a1d7f4b', N'de6f7a8b-9c1d-4e3f-8a4b-234567890cde', CAST(N'2022-04-20' AS Date), CAST(N'2026-04-20' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'be59e250-ccfa-f011-9032-0050b6a2672f', N'1c9f5a2e-7b4d-4f8c-a1e5-9d3b7c4a2f8e', N'de6f7a8b-9c1d-4e3f-8a4b-234567890cde', CAST(N'2021-11-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'bf59e250-ccfa-f011-9032-0050b6a2672f', N'234f25a8-cafa-f011-9032-0050b6a2672f', N'de6f7a8b-9c1d-4e3f-8a4b-234567890cde', CAST(N'2020-05-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'c059e250-ccfa-f011-9032-0050b6a2672f', N'7e1a4d9c-3f8b-4e2a-c5f7-2b9e6d1a4c8f', N'3a4b5c6d-7e8f-4a9b-1c2d-23456789abcd', CAST(N'2023-09-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'c159e250-ccfa-f011-9032-0050b6a2672f', N'6f3b8e1c-4a7d-4d2f-9c5e-3a1b8f4c7d2e', N'3a4b5c6d-7e8f-4a9b-1c2d-23456789abcd', CAST(N'2022-12-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'c259e250-ccfa-f011-9032-0050b6a2672f', N'4c8f2a5e-1d7b-4c9a-b6e3-5f2d8a4c1b9e', N'3a4b5c6d-7e8f-4a9b-1c2d-23456789abcd', CAST(N'2018-07-10' AS Date), CAST(N'2021-07-10' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'c359e250-ccfa-f011-9032-0050b6a2672f', N'b5d2f8a1-9c6e-4d4b-a7c3-8e4f1b5d2a9c', N'9a1b2c3d-4e5f-4a6b-8c7d-9876543210fe', CAST(N'2024-01-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'c459e250-ccfa-f011-9032-0050b6a2672f', N'a2e5c9f1-8b4d-4a7c-e3f6-9d1c5a2b8e4f', N'9a1b2c3d-4e5f-4a6b-8c7d-9876543210fe', CAST(N'2023-03-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'c559e250-ccfa-f011-9032-0050b6a2672f', N'244f25a8-cafa-f011-9032-0050b6a2672f', N'9a1b2c3d-4e5f-4a6b-8c7d-9876543210fe', CAST(N'2022-06-01' AS Date), CAST(N'2025-06-01' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'c659e250-ccfa-f011-9032-0050b6a2672f', N'3f7a2c8e-5d1b-4a9f-c6e4-1b8f5a2d9c3e', N'ef7a8b9c-1d2e-4f4a-9b5c-345678901def', CAST(N'2021-02-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'c759e250-ccfa-f011-9032-0050b6a2672f', N'6b3e7f1a-9c4d-4e8b-a2c5-4f7e1b9d3a6c', N'ef7a8b9c-1d2e-4f4a-9b5c-345678901def', CAST(N'2020-09-10' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'c859e250-ccfa-f011-9032-0050b6a2672f', N'9a5f2c8e-1b7d-4a4c-f3e6-5d2b9a1c7f4e', N'ef7a8b9c-1d2e-4f4a-9b5c-345678901def', CAST(N'2019-12-01' AS Date), CAST(N'2023-12-01' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'c959e250-ccfa-f011-9032-0050b6a2672f', N'8a1c5e9f-2d7b-4f3a-b4c8-6f1e9a2d5c7b', N'ef7a8b9c-1d2e-4f4a-9b5c-345678901def', CAST(N'2023-08-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'ca59e250-ccfa-f011-9032-0050b6a2672f', N'1d8c4a7f-2e5b-4f1d-b9a3-8c6e2f5a1d4b', N'4b5c6d7e-8f1a-4b2c-9d3e-34567890abcd', CAST(N'2022-05-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'cb59e250-ccfa-f011-9032-0050b6a2672f', N'c4e9a1f5-8b2d-4c7a-e3f6-9d5c2a8b1f4e', N'4b5c6d7e-8f1a-4b2c-9d3e-34567890abcd', CAST(N'2021-08-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'cc59e250-ccfa-f011-9032-0050b6a2672f', N'254f25a8-cafa-f011-9032-0050b6a2672f', N'5f6a7b8c-9d1e-4f2a-8c3b-abcdef123456', CAST(N'2023-04-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'cd59e250-ccfa-f011-9032-0050b6a2672f', N'4e1b7a9f-3c5d-4d8e-a6c2-1f9b4e7a2c5d', N'5f6a7b8c-9d1e-4f2a-8c3b-abcdef123456', CAST(N'2022-07-20' AS Date), CAST(N'2024-07-20' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'ce59e250-ccfa-f011-9032-0050b6a2672f', N'5f8b1c4a-7e2d-4c9f-a5b3-2e6d9a1f5c8b', N'5f6a7b8c-9d1e-4f2a-8c3b-abcdef123456', CAST(N'2021-01-10' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'cf59e250-ccfa-f011-9032-0050b6a2672f', N'b1e4a7c9-3f6d-4e2b-8c5a-4d1f7b9e2a6c', N'5f6a7b8c-9d1e-4f2a-8c3b-abcdef123456', CAST(N'2020-04-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'd059e250-ccfa-f011-9032-0050b6a2672f', N'7c4f2a8e-9d1b-4a5c-b3e7-6a2d8c5f1b9e', N'9c8f1d2b-4e3f-41a0-ba8d-abcdef123456', CAST(N'2023-10-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'd159e250-ccfa-f011-9032-0050b6a2672f', N'2a9c5e1f-4b8d-4f7a-c2e6-9f3b1d7a4c8e', N'9c8f1d2b-4e3f-41a0-ba8d-abcdef123456', CAST(N'2022-11-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'd259e250-ccfa-f011-9032-0050b6a2672f', N'264f25a8-cafa-f011-9032-0050b6a2672f', N'9c8f1d2b-4e3f-41a0-ba8d-abcdef123456', CAST(N'2019-06-01' AS Date), CAST(N'2022-06-01' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'd359e250-ccfa-f011-9032-0050b6a2672f', N'3a6c9f2e-5d8b-4c1a-b7e4-1f4d8a5c2b9e', N'2a7e5c9d-6b4f-44f1-8e2a-0123456789ab', CAST(N'2024-02-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'd459e250-ccfa-f011-9032-0050b6a2672f', N'9c5e2a8f-1d4b-4c7a-f6e3-2b5f8c1e9a4d', N'2a7e5c9d-6b4f-44f1-8e2a-0123456789ab', CAST(N'2023-06-10' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'd559e250-ccfa-f011-9032-0050b6a2672f', N'6b9d2c5a-8f1e-4a7c-a4e8-3d6b9f2c5a1e', N'2a7e5c9d-6b4f-44f1-8e2a-0123456789ab', CAST(N'2022-09-01' AS Date), CAST(N'2025-09-01' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'd659e250-ccfa-f011-9032-0050b6a2672f', N'8d2f5a9c-1e7b-4a4e-c6f3-5b8e2a1d9c4f', N'2a7e5c9d-6b4f-44f1-8e2a-0123456789ab', CAST(N'2021-12-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'd759e250-ccfa-f011-9032-0050b6a2672f', N'1f4a7c9e-3b6d-4e2f-b8c5-7e1a4d9b2c6f', N'2a7e5c9d-6b4f-44f1-8e2a-0123456789ab', CAST(N'2020-03-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'd859e250-ccfa-f011-9032-0050b6a2672f', N'c7e1a4f8-2b5d-4f9c-e3a6-9c2f5b8e1d4a', N'1a2b3c4d-5e6f-4a7b-8c9d-1234567890ab', CAST(N'2023-11-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'd959e250-ccfa-f011-9032-0050b6a2672f', N'274f25a8-cafa-f011-9032-0050b6a2672f', N'1a2b3c4d-5e6f-4a7b-8c9d-1234567890ab', CAST(N'2022-02-20' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'da59e250-ccfa-f011-9032-0050b6a2672f', N'7e2b5a8f-9c1d-4f4e-a6c3-1d8b5e2a9f4c', N'f18b9c1d-2e3f-4a5b-8c6d-45678901abcd', CAST(N'2021-07-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'db59e250-ccfa-f011-9032-0050b6a2672f', N'a1e4b7c9-8f2d-4a5c-d6e3-3b9f1c4e7a8d', N'f18b9c1d-2e3f-4a5b-8c6d-45678901abcd', CAST(N'2020-10-15' AS Date), CAST(N'2024-10-15' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'dc59e250-ccfa-f011-9032-0050b6a2672f', N'6f9c2a5e-1b8d-4c4f-a7e2-4d1a8c5f2b9e', N'f18b9c1d-2e3f-4a5b-8c6d-45678901abcd', CAST(N'2019-01-20' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'dd59e250-ccfa-f011-9032-0050b6a2672f', N'b8c1f4a7-2e5d-4a9b-c7e3-5a9f2c8b1e6d', N'5c6d7e8f-1a2b-4c3d-8e4f-4567890abcde', CAST(N'2024-03-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'de59e250-ccfa-f011-9032-0050b6a2672f', N'5c8f2a1e-4d9b-4e7a-b3c6-6e1d4a7f9c2b', N'5c6d7e8f-1a2b-4c3d-8e4f-4567890abcde', CAST(N'2023-05-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'df59e250-ccfa-f011-9032-0050b6a2672f', N'4a7f1c9e-6d3b-4a8c-b2e5-8f4a1d7c3b9e', N'5c6d7e8f-1a2b-4c3d-8e4f-4567890abcde', CAST(N'2022-08-01' AS Date), CAST(N'2026-08-01' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'e059e250-ccfa-f011-9032-0050b6a2672f', N'2d5a8c1f-7b4e-4c6d-e9a3-9c2f5e8b1a4d', N'5c6d7e8f-1a2b-4c3d-8e4f-4567890abcde', CAST(N'2021-10-10' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'e159e250-ccfa-f011-9032-0050b6a2672f', N'284f25a8-cafa-f011-9032-0050b6a2672f', N'1a2b3c4d-5e6f-4a7b-8c9d-5678901234ab', CAST(N'2020-06-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'e259e250-ccfa-f011-9032-0050b6a2672f', N'8c1f4a7e-2d5b-4e9a-c6f3-1a9e5c2f8b4d', N'1a2b3c4d-5e6f-4a7b-8c9d-5678901234ab', CAST(N'2019-09-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'e359e250-ccfa-f011-9032-0050b6a2672f', N'7f2a5c8e-9d1b-4a4f-b3e6-2c8f1a5e9b4d', N'6d7e8f1a-2b3c-4d5e-9f6a-567890abcdef', CAST(N'2023-12-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'e459e250-ccfa-f011-9032-0050b6a2672f', N'c4a7e1f9-6b3d-4c8a-e2f5-5d8b2a9c1f6e', N'6d7e8f1a-2b3c-4d5e-9f6a-567890abcdef', CAST(N'2022-03-10' AS Date), CAST(N'2025-03-10' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'e559e250-ccfa-f011-9032-0050b6a2672f', N'3b6e9a1f-5c8d-4a2c-b4f7-8e2d5a1c9f3b', N'6d7e8f1a-2b3c-4d5e-9f6a-567890abcdef', CAST(N'2021-05-20' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'e659e250-ccfa-f011-9032-0050b6a2672f', N'1e4b7a9c-3f6d-4e2b-a8c5-9f2e5b1d4a7c', N'5f3d1b7c-9a2f-4c6e-8b1a-9876543210fe', CAST(N'2024-04-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'e759e250-ccfa-f011-9032-0050b6a2672f', N'294f25a8-cafa-f011-9032-0050b6a2672f', N'5f3d1b7c-9a2f-4c6e-8b1a-9876543210fe', CAST(N'2023-07-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'e859e250-ccfa-f011-9032-0050b6a2672f', N'4d7a1c9f-5e2b-4c8e-a4f6-1b8e5a2d9c4f', N'5f3d1b7c-9a2f-4c6e-8b1a-9876543210fe', CAST(N'2022-10-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'e959e250-ccfa-f011-9032-0050b6a2672f', N'9e2b5a8f-1c4d-4f7e-a3c6-3f9e2b5a8c1d', N'5f3d1b7c-9a2f-4c6e-8b1a-9876543210fe', CAST(N'2021-01-15' AS Date), CAST(N'2024-01-15' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'ea59e250-ccfa-f011-9032-0050b6a2672f', N'c6e9a2f5-1b4d-4c7a-f8e3-5a2c8f1b9e4d', N'7f8e9d0c-1a2b-4c3d-9b4a-9876543210fe', CAST(N'2020-08-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'eb59e250-ccfa-f011-9032-0050b6a2672f', N'5a8c1f4e-2b7d-4c9a-e6f3-6d2a9c5f1b8e', N'7f8e9d0c-1a2b-4c3d-9b4a-9876543210fe', CAST(N'2019-11-10' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'ec59e250-ccfa-f011-9032-0050b6a2672f', N'b3f6c9a1-8e2d-4a5c-d7e4-7a1c4f9b2e5d', N'7f8e9d0c-1a2b-4c3d-9b4a-9876543210fe', CAST(N'2018-04-20' AS Date), CAST(N'2021-04-20' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'ed59e250-ccfa-f011-9032-0050b6a2672f', N'8f1c4a7e-2d5b-4a9c-b3e7-9d2f5c8a1e4b', N'6b29fc40-ca47-1067-b31d-00dd010662da', CAST(N'2023-08-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'ee59e250-ccfa-f011-9032-0050b6a2672f', N'2a4f25a8-cafa-f011-9032-0050b6a2672f', N'6b29fc40-ca47-1067-b31d-00dd010662da', CAST(N'2022-11-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'ef59e250-ccfa-f011-9032-0050b6a2672f', N'8e1b4a7c-6f2d-4a9e-c5f8-1d4b7e9a2c5f', N'6b29fc40-ca47-1067-b31d-00dd010662da', CAST(N'2021-02-15' AS Date), CAST(N'2024-02-15' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'f059e250-ccfa-f011-9032-0050b6a2672f', N'a1e4c7f9-5b8d-4c2a-e3f6-2c6e9a1f5b8d', N'6b29fc40-ca47-1067-b31d-00dd010662da', CAST(N'2020-05-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'f159e250-ccfa-f011-9032-0050b6a2672f', N'2a5c8f1e-7d4b-4e9a-c6f3-4e1b8a5c2d9f', N'6b29fc40-ca47-1067-b31d-00dd010662da', CAST(N'2019-07-20' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'f259e250-ccfa-f011-9032-0050b6a2672f', N'b5e8c1f4-9a2d-4c6b-a3e7-5f8b2c1e9a4d', N'6c7d8e9f-1a2b-4c3d-8f4e-1234567890ab', CAST(N'2024-05-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'f359e250-ccfa-f011-9032-0050b6a2672f', N'6f9b2e5a-3c8d-4a1f-b7e4-8d5a2c9f1b6e', N'6c7d8e9f-1a2b-4c3d-8f4e-1234567890ab', CAST(N'2023-09-10' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'f459e250-ccfa-f011-9032-0050b6a2672f', N'4c7a9f2e-1d5b-4e8c-a6f3-9b3e6c1a4f8d', N'7a8b9c1d-2e3f-4a5b-8c6d-1234567890bc', CAST(N'2022-12-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'f559e250-ccfa-f011-9032-0050b6a2672f', N'2b4f25a8-cafa-f011-9032-0050b6a2672f', N'7a8b9c1d-2e3f-4a5b-8c6d-1234567890bc', CAST(N'2021-03-01' AS Date), CAST(N'2024-03-01' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'f659e250-ccfa-f011-9032-0050b6a2672f', N'a4e7c1f9-6b3d-4a5e-c8f2-1d5a8c2e9f4b', N'7a8b9c1d-2e3f-4a5b-8c6d-1234567890bc', CAST(N'2020-06-20' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'f759e250-ccfa-f011-9032-0050b6a2672f', N'3c6f9a2e-7d1b-4e4c-b8f5-2a5e8c1f4b9d', N'cd5e6f7a-8b9c-4d2e-9f3a-1234567890bc', CAST(N'2023-01-20' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'f859e250-ccfa-f011-9032-0050b6a2672f', N'5e8b1c4a-9f2d-4a7c-a4e6-3c9f5a2e8b1d', N'cd5e6f7a-8b9c-4d2e-9f3a-1234567890bc', CAST(N'2022-04-10' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'f959e250-ccfa-f011-9032-0050b6a2672f', N'7a9e2c5f-4b8d-4a1e-c6f3-6d3b9a5c2f8e', N'cd5e6f7a-8b9c-4d2e-9f3a-1234567890bc', CAST(N'2021-07-01' AS Date), CAST(N'2025-07-01' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'fa59e250-ccfa-f011-9032-0050b6a2672f', N'9c2f5a8e-1b4d-4e9c-b7f3-7e1a4c9f2b5d', N'cd5e6f7a-8b9c-4d2e-9f3a-1234567890bc', CAST(N'2020-10-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'fb59e250-ccfa-f011-9032-0050b6a2672f', N'2b5e8a1c-4f7d-4c9a-e6f3-8c4e1b5a9f2d', N'2f3a4b5c-6d7e-4f8a-9b1c-123456abcdef', CAST(N'2024-06-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'fc59e250-ccfa-f011-9032-0050b6a2672f', N'c1f4a7e9-2d5b-4c8a-e3f6-9b6e2a1c5f4d', N'2f3a4b5c-6d7e-4f8a-9b1c-123456abcdef', CAST(N'2023-10-20' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'fd59e250-ccfa-f011-9032-0050b6a2672f', N'2c4f25a8-cafa-f011-9032-0050b6a2672f', N'2f3a4b5c-6d7e-4f8a-9b1c-123456abcdef', CAST(N'2022-01-15' AS Date), CAST(N'2025-01-15' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'fe59e250-ccfa-f011-9032-0050b6a2672f', N'5e8b1c4a-2f9d-4c7e-a3f6-2c8e5a1f9b4d', N'2b3c4d5e-6f7a-4b8c-9d1e-6789012345bc', CAST(N'2021-04-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'ff59e250-ccfa-f011-9032-0050b6a2672f', N'c7e1a4f9-4b8d-4c2a-e6f5-3a7c1e4f9b2d', N'2b3c4d5e-6f7a-4b8c-9d1e-6789012345bc', CAST(N'2020-07-10' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'005ae250-ccfa-f011-9032-0050b6a2672f', N'6c9f2a5e-8d1b-4e4a-b3c7-5e2a9c6f1b8d', N'7e8f1a2b-3c4d-4e5f-8a7b-67890abcdefa', CAST(N'2023-02-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'015ae250-ccfa-f011-9032-0050b6a2672f', N'9c2f5a8e-6b1d-4a4c-b7e3-6e9a2c5f1b8d', N'7e8f1a2b-3c4d-4e5f-8a7b-67890abcdefa', CAST(N'2022-05-20' AS Date), CAST(N'2026-05-20' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'025ae250-ccfa-f011-9032-0050b6a2672f', N'1a4c7f9e-3b6d-4a8c-e5f2-9d3b6a1c4f8e', N'7e8f1a2b-3c4d-4e5f-8a7b-67890abcdefa', CAST(N'2021-08-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'035ae250-ccfa-f011-9032-0050b6a2672f', N'2d4f25a8-cafa-f011-9032-0050b6a2672f', N'7e8f1a2b-3c4d-4e5f-8a7b-67890abcdefa', CAST(N'2020-11-10' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'045ae250-ccfa-f011-9032-0050b6a2672f', N'9f2b5a8e-3c6d-4c1a-e4f7-1b4e8a2c5f9d', N'3e4f5a6b-7c8d-4e1f-8b2a-abcdef987654', CAST(N'2024-07-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'055ae250-ccfa-f011-9032-0050b6a2672f', N'7e1a4c9f-5b2d-4a7c-e3f8-2b5e8a1c4f9d', N'3e4f5a6b-7c8d-4e1f-8b2a-abcdef987654', CAST(N'2023-11-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'065ae250-ccfa-f011-9032-0050b6a2672f', N'1c4a7f9e-2b5d-4e8c-b6f3-4d8b1a5c9f2e', N'8e2c3d1f-7b6a-4d8e-9c1b-abcdef987654', CAST(N'2022-06-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'075ae250-ccfa-f011-9032-0050b6a2672f', N'c3e6a9f1-7b4d-4e8c-a5f2-5d1a8c4f2b9e', N'8e2c3d1f-7b6a-4d8e-9c1b-abcdef987654', CAST(N'2021-09-20' AS Date), CAST(N'2024-09-20' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'085ae250-ccfa-f011-9032-0050b6a2672f', N'5e8c1a4f-9b2d-4a7e-c3f6-7e2a5c9f1b4d', N'8e2c3d1f-7b6a-4d8e-9c1b-abcdef987654', CAST(N'2020-12-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'095ae250-ccfa-f011-9032-0050b6a2672f', N'3a6c9f2e-1d5b-4e8a-c4f7-8d1b4a7c9f2e', N'7c2d3e4f-1a5b-4c6d-8e7f-87654321abcd', CAST(N'2024-08-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'0a5ae250-ccfa-f011-9032-0050b6a2672f', N'b4e7c1a9-8f3d-4c6e-a2f5-9c6e3a7f1b4d', N'7c2d3e4f-1a5b-4c6d-8e7f-87654321abcd', CAST(N'2023-12-10' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'0b5ae250-ccfa-f011-9032-0050b6a2672f', N'2e4f25a8-cafa-f011-9032-0050b6a2672f', N'7c2d3e4f-1a5b-4c6d-8e7f-87654321abcd', CAST(N'2022-02-28' AS Date), CAST(N'2025-02-28' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'0c5ae250-ccfa-f011-9032-0050b6a2672f', N'8e1c4a7f-6b9d-4c2a-e5f3-2c9e5a1f8b4d', N'7c2d3e4f-1a5b-4c6d-8e7f-87654321abcd', CAST(N'2021-05-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'0d5ae250-ccfa-f011-9032-0050b6a2672f', N'6f9c2a5e-1d8b-4c4f-b3e6-3a7c1f9e5b2d', N'2b3c4d5e-6f7a-4b8c-9d1e-87654321abcd', CAST(N'2020-08-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'0e5ae250-ccfa-f011-9032-0050b6a2672f', N'b5e8a1c4-3f6d-4e9c-a7f2-6d3a9c5f2b8e', N'2b3c4d5e-6f7a-4b8c-9d1e-87654321abcd', CAST(N'2019-10-20' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'0f5ae250-ccfa-f011-9032-0050b6a2672f', N'a1e4c7f9-4b8d-4a2c-e5f7-7d4a1c8f2b5e', N'4d5e6f7a-8b9c-4d2e-9f3a-8901234567de', CAST(N'2023-03-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'105ae250-ccfa-f011-9032-0050b6a2672f', N'4a7c1f9e-2d5b-4a8e-b3c6-8e2f5a1c9b4d', N'4d5e6f7a-8b9c-4d2e-9f3a-8901234567de', CAST(N'2022-07-15' AS Date), CAST(N'2026-07-15' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'115ae250-ccfa-f011-9032-0050b6a2672f', N'2c5a8f1e-9b4d-4a7c-c6e3-9e2b5a8c1f4d', N'4d5e6f7a-8b9c-4d2e-9f3a-8901234567de', CAST(N'2021-11-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'125ae250-ccfa-f011-9032-0050b6a2672f', N'2f4f25a8-cafa-f011-9032-0050b6a2672f', N'9a2b3c4d-5e6f-4a7b-8c9d-890abcdef123', CAST(N'2024-09-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'135ae250-ccfa-f011-9032-0050b6a2672f', N'5a8c1f4e-7d2b-4e9a-a6c3-1b8e4a7c2f5d', N'9a2b3c4d-5e6f-4a7b-8c9d-890abcdef123', CAST(N'2023-01-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'145ae250-ccfa-f011-9032-0050b6a2672f', N'c4e7a1f9-8d5b-4a4c-e3f6-2a6c9e1f5b8d', N'9a2b3c4d-5e6f-4a7b-8c9d-890abcdef123', CAST(N'2022-04-01' AS Date), CAST(N'2025-04-01' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'155ae250-ccfa-f011-9032-0050b6a2672f', N'7f2a5c8e-4b9d-4a1c-b7e4-4d1a7c5f2e9b', N'9a2b3c4d-5e6f-4a7b-8c9d-890abcdef123', CAST(N'2021-06-20' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'165ae250-ccfa-f011-9032-0050b6a2672f', N'9e2c5a8f-3b6d-4c1a-b4e7-5c9f2a8e1b4d', N'9a2b3c4d-5e6f-4a7b-8c9d-890abcdef123', CAST(N'2020-09-10' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'175ae250-ccfa-f011-9032-0050b6a2672f', N'1b4a7c9f-9e2d-4c8e-a6f3-5e8b1a4c9f2d', N'8f1a2b3c-4d5e-4f6a-8b7c-1234abcd5678', CAST(N'2024-10-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'185ae250-ccfa-f011-9032-0050b6a2672f', N'9e2c5a8f-6b1d-4c4a-b4e7-7f2a4c9e1b5d', N'8f1a2b3c-4d5e-4f6a-8b7c-1234abcd5678', CAST(N'2023-02-28' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'195ae250-ccfa-f011-9032-0050b6a2672f', N'a1e4c7f9-7b3d-4a2c-e5f8-9d6e2a5c1f4b', N'3a1b2c4d-5e6f-4a7b-8c9d-1234abcd5678', CAST(N'2022-08-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'1a5ae250-ccfa-f011-9032-0050b6a2672f', N'304f25a8-cafa-f011-9032-0050b6a2672f', N'3a1b2c4d-5e6f-4a7b-8c9d-1234abcd5678', CAST(N'2021-12-01' AS Date), CAST(N'2024-12-01' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'1b5ae250-ccfa-f011-9032-0050b6a2672f', N'8e1c4a7f-5b9d-4a2c-b3e6-2c9f5a1e8b4d', N'3a1b2c4d-5e6f-4a7b-8c9d-1234abcd5678', CAST(N'2020-02-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'1c5ae250-ccfa-f011-9032-0050b6a2672f', N'5e8b1c4a-9f2d-4a7c-a4e7-3c6f9a2e5b1d', N'3c4d5e6f-7a8b-4c1d-8e2f-7890123456cd', CAST(N'2023-04-20' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'1d5ae250-ccfa-f011-9032-0050b6a2672f', N'3c6a9f2e-1b4d-4e7c-a5f8-5b2e8a1c9f3d', N'3c4d5e6f-7a8b-4c1d-8e2f-7890123456cd', CAST(N'2022-09-10' AS Date), CAST(N'2026-09-10' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'1e5ae250-ccfa-f011-9032-0050b6a2672f', N'b4e7c1a9-3f6d-4c8e-e2f5-6d8a2c5f1b9e', N'3c4d5e6f-7a8b-4c1d-8e2f-7890123456cd', CAST(N'2021-01-25' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'1f5ae250-ccfa-f011-9032-0050b6a2672f', N'9c2f5a8e-6b1d-4c4a-b7e3-7e1a4c9f2b5d', N'3c4d5e6f-7a8b-4c1d-8e2f-7890123456cd', CAST(N'2020-04-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'205ae250-ccfa-f011-9032-0050b6a2672f', N'1a4c7f9e-2b5d-4e8a-c6f3-9e3b6a1c4f8d', N'8f1a2b3c-4d5e-4f6a-8b7c-7890abcdef12', CAST(N'2024-11-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'215ae250-ccfa-f011-9032-0050b6a2672f', N'314f25a8-cafa-f011-9032-0050b6a2672f', N'8f1a2b3c-4d5e-4f6a-8b7c-7890abcdef12', CAST(N'2023-05-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'225ae250-ccfa-f011-9032-0050b6a2672f', N'c7e1a4f9-4b8d-4c2e-e5f6-1b4a8c2e9f5d', N'4b5c6d7e-8f1a-4b2c-9d3e-1a2b3c4d5e6f', CAST(N'2022-10-20' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'235ae250-ccfa-f011-9032-0050b6a2672f', N'b4e7c1a9-6f3d-4c9e-e2f5-2a6c9e4f1b8d', N'4b5c6d7e-8f1a-4b2c-9d3e-1a2b3c4d5e6f', CAST(N'2021-03-10' AS Date), CAST(N'2024-03-10' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'245ae250-ccfa-f011-9032-0050b6a2672f', N'3a6c9f2e-7d1b-4e8c-a4f7-5c9e2a5f1b8d', N'4b5c6d7e-8f1a-4b2c-9d3e-1a2b3c4d5e6f', CAST(N'2020-06-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'255ae250-ccfa-f011-9032-0050b6a2672f', N'1c4a7f9e-9b2d-4e8c-a5f6-6d3b8a1c5f2e', N'ab3c4d5e-6f7a-4b8c-9d1e-9012345678ab', CAST(N'2023-06-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'265ae250-ccfa-f011-9032-0050b6a2672f', N'7e1a4c9f-2b5d-4a7a-b3e8-8d2b5a1c4f9e', N'ab3c4d5e-6f7a-4b8c-9d1e-9012345678ab', CAST(N'2022-11-20' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'275ae250-ccfa-f011-9032-0050b6a2672f', N'5e8c1a4f-3b6d-4a7e-c4f7-9e2c5a8f1b4d', N'ab3c4d5e-6f7a-4b8c-9d1e-9012345678ab', CAST(N'2021-02-01' AS Date), CAST(N'2024-02-01' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'285ae250-ccfa-f011-9032-0050b6a2672f', N'324f25a8-cafa-f011-9032-0050b6a2672f', N'ab3c4d5e-6f7a-4b8c-9d1e-9012345678ab', CAST(N'2020-05-10' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'295ae250-ccfa-f011-9032-0050b6a2672f', N'4a7c1f9e-8d2b-4a8e-b6c3-1e5a9c2f8b4d', N'ab3c4d5e-6f7a-4b8c-9d1e-9012345678ab', CAST(N'2019-08-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'2a5ae250-ccfa-f011-9032-0050b6a2672f', N'b5e8a1c4-9f2d-4e9c-a3f6-2b8d5a1c9f4e', N'5e6f7a8b-9c1d-4e3f-8a4b-9012345678ef', CAST(N'2024-12-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'2b5ae250-ccfa-f011-9032-0050b6a2672f', N'9f2b5a8e-1c4d-4c1a-b7e3-3a7c1e4f9b2d', N'5e6f7a8b-9c1d-4e3f-8a4b-9012345678ef', CAST(N'2023-03-25' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'2c5ae250-ccfa-f011-9032-0050b6a2672f', N'8e1c4a7f-3b6d-4c2a-e5f7-5c9e2a6f1b4d', N'5e6f7a8b-9c1d-4e3f-8a4b-9012345678ef', CAST(N'2022-06-10' AS Date), CAST(N'2025-06-10' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'2d5ae250-ccfa-f011-9032-0050b6a2672f', N'c3e6a9f1-5b8d-4e4c-a2f5-7d4a8c1f5b2e', N'9c8f1d2b-4e3f-41a0-ba8d-abcdef123456', CAST(N'2021-09-01' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'2e5ae250-ccfa-f011-9032-0050b6a2672f', N'2c5a8f1e-6b4d-4a7c-c7e3-8e3a6c9f2b5d', N'9c8f1d2b-4e3f-41a0-ba8d-abcdef123456', CAST(N'2020-12-15' AS Date), CAST(N'9999-12-31' AS Date))
GO
INSERT [dbo].[ProductSuppliers] ([Id], [ProductId], [SupplierId], [StartDate], [EndDate]) VALUES (N'2f5ae250-ccfa-f011-9032-0050b6a2672f', N'334f25a8-cafa-f011-9032-0050b6a2672f', N'9c8f1d2b-4e3f-41a0-ba8d-abcdef123456', CAST(N'2019-02-28' AS Date), CAST(N'2022-02-28' AS Date))
GO
