-- 1. Создаем саму базу данных
CREATE DATABASE ChudoObuv;

USE ChudoObuv;


-- 2. Удаляем таблицы, если они уже есть (чтобы можно было перезапускать скрипт)
-- Порядок удаления обратный порядку создания (от дочерних к родительским)
IF OBJECT_ID('OrderItem', 'U') IS NOT NULL DROP TABLE OrderItem;
IF OBJECT_ID('Order', 'U') IS NOT NULL DROP TABLE [Order];
IF OBJECT_ID('StockItem', 'U') IS NOT NULL DROP TABLE StockItem;
IF OBJECT_ID('Product', 'U') IS NOT NULL DROP TABLE Product;
IF OBJECT_ID('User', 'U') IS NOT NULL DROP TABLE [User];
IF OBJECT_ID('Size', 'U') IS NOT NULL DROP TABLE Size;
IF OBJECT_ID('Manufacturer', 'U') IS NOT NULL DROP TABLE Manufacturer;
IF OBJECT_ID('Subcategory', 'U') IS NOT NULL DROP TABLE Subcategory;
IF OBJECT_ID('Category', 'U') IS NOT NULL DROP TABLE Category;
IF OBJECT_ID('Role', 'U') IS NOT NULL DROP TABLE Role;
GO

-- 3. Создаем таблицы справочников (без внешних ключей)
CREATE TABLE Role (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);

CREATE TABLE Category (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL
);

CREATE TABLE Subcategory (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL
);

CREATE TABLE Manufacturer (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL
);

CREATE TABLE Size (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Value NVARCHAR(10) NOT NULL UNIQUE -- Уникальный ключ, чтобы не было двух 36 размеров
);


-- 4. Создаем основные таблицы (с внешними ключами на справочники)
CREATE TABLE [User] (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Surname NVARCHAR(50) NOT NULL,
    Name NVARCHAR(50) NOT NULL,
    Patronymic NVARCHAR(50) NULL,
    Login NVARCHAR(50) NOT NULL UNIQUE, -- Логин должен быть уникальным
    RoleId INT NOT NULL,
    FOREIGN KEY (RoleId) REFERENCES Role(Id)
);

CREATE TABLE Product (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    CategoryId INT NOT NULL,
    SubcategoryId INT NOT NULL,
    ManufacturerId INT NOT NULL,
    Description NVARCHAR(500) NULL,
    Composition NVARCHAR(500) NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    Photo NVARCHAR(255) NULL,
    FOREIGN KEY (CategoryId) REFERENCES Category(Id),
    FOREIGN KEY (SubcategoryId) REFERENCES Subcategory(Id),
    FOREIGN KEY (ManufacturerId) REFERENCES Manufacturer(Id)
);


-- 5. Создаем промежуточные таблицы (Склад и Заказы)
CREATE TABLE StockItem (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT NOT NULL,
    SizeId INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity >= 0),
    FOREIGN KEY (ProductId) REFERENCES Product(Id),
    FOREIGN KEY (SizeId) REFERENCES Size(Id),
    CONSTRAINT UQ_Product_Size UNIQUE (ProductId, SizeId) -- Одна позиция (товар+размер) встречается 1 раз
);

CREATE TABLE [Order] (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    OrderDate DATE NOT NULL,
    UserId INT NOT NULL,
    FOREIGN KEY (UserId) REFERENCES [User](Id)
);


CREATE TABLE OrderItem (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT NOT NULL,
    StockItemId INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0), -- Цена на момент покупки
    FOREIGN KEY (OrderId) REFERENCES [Order](Id),
    FOREIGN KEY (StockItemId) REFERENCES StockItem(Id)
);