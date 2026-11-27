/* ============================================================================
   1. DATABASE & SCHEMA CREATION
   ============================================================================ */
USE [master];
GO

IF DB_ID(N'SQL2022_ComprehensiveDemo') IS NOT NULL
BEGIN
    ALTER DATABASE [SQL2022_ComprehensiveDemo] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [SQL2022_ComprehensiveDemo];
END
GO

CREATE DATABASE [SQL2022_ComprehensiveDemo];
GO

USE [SQL2022_ComprehensiveDemo];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE SCHEMA [Demo] AUTHORIZATION [dbo];
GO


/* ============================================================================
   2. USER-DEFINED TYPES (ALIAS TYPES & TABLE-VALUED PARAMETER TYPE)
   ============================================================================ */
-- Scalar Alias Types
CREATE TYPE [Demo].[EmailAddress] FROM NVARCHAR(255) NOT NULL;
CREATE TYPE [Demo].[CurrencyAmount] FROM DECIMAL(19, 4) NOT NULL;
GO

-- User-Defined Table Type (for Stored Procedure Table-Valued Parameters)
CREATE TYPE [Demo].[OrderItemTableType] AS TABLE
(
    ProductCode VARCHAR(20) NOT NULL,
    Quantity    INT NOT NULL CHECK (Quantity > 0),
    UnitPrice   [Demo].[CurrencyAmount] NOT NULL
);
GO


/* ============================================================================
   3. SEQUENCE OBJECT
   ============================================================================ */
CREATE SEQUENCE [Demo].[Seq_InvoiceNumber]
    AS BIGINT
    START WITH 100000
    INCREMENT BY 1
    MINVALUE 100000
    NO MAXVALUE
    CACHE 50;
GO


/* ============================================================================
   4. TABLES (ALL SQL SERVER 2022 DATA TYPES + RELATIONAL TABLES)
   ============================================================================ */

-- 4A. Showcase Table Covering Every Column-Supported Data Type in SQL Server 2022
CREATE TABLE [Demo].[AllDataTypesShowcase]
(
    RecordID            INT IDENTITY(1,1) NOT NULL PRIMARY KEY,

    -- Exact Numerics
    Col_BigInt          BIGINT NOT NULL,
    Col_Int             INT NOT NULL,
    Col_SmallInt        SMALLINT NOT NULL,
    Col_TinyInt         TINYINT NOT NULL,
    Col_Bit             BIT NOT NULL,
    Col_Decimal         DECIMAL(18, 4) NOT NULL,
    Col_Numeric         NUMERIC(10, 2) NOT NULL,
    Col_Money           MONEY NOT NULL,
    Col_SmallMoney      SMALLMONEY NOT NULL,

    -- Approximate Numerics
    Col_Float           FLOAT(53) NOT NULL,
    Col_Real            REAL NOT NULL,

    -- Date and Time
    Col_Date            DATE NOT NULL,
    Col_Time            TIME(7) NOT NULL,
    Col_DateTime2       DATETIME2(7) NOT NULL,
    Col_DateTimeOffset  DATETIMEOFFSET(7) NOT NULL,
    Col_DateTime        DATETIME NOT NULL,
    Col_SmallDateTime   SMALLDATETIME NOT NULL,

    -- Character Strings (Non-Unicode)
    Col_Char            CHAR(10) NOT NULL,
    Col_VarChar         VARCHAR(100) NOT NULL,
    Col_VarCharMax      VARCHAR(MAX) NULL,

    -- Unicode Character Strings & SQL 2022 JSON Pattern
    Col_NChar           NCHAR(10) NOT NULL,
    Col_NVarChar        NVARCHAR(100) NOT NULL,
    Col_NVarCharMax     NVARCHAR(MAX) NULL,
    Col_JsonPayload     NVARCHAR(MAX) NULL
        CONSTRAINT [CK_AllDataTypes_Json] CHECK (Col_JsonPayload IS NULL OR ISJSON(Col_JsonPayload) = 1),

    -- Binary Strings
    Col_Binary          BINARY(8) NOT NULL,
    Col_VarBinary       VARBINARY(256) NOT NULL,
    Col_VarBinaryMax    VARBINARY(MAX) NULL,

    -- Special, Hierarchical & Spatial Types
    Col_UniqueId        UNIQUEIDENTIFIER NOT NULL DEFAULT NEWSEQUENTIALID(),
    Col_RowVersion      ROWVERSION NOT NULL, -- Auto-generated binary(8) concurrency stamp
    Col_Xml             XML NULL,
    Col_SqlVariant      SQL_VARIANT NULL,
    Col_HierarchyId     HIERARCHYID NULL,
    Col_Geometry        GEOMETRY NULL,
    Col_Geography       GEOGRAPHY NULL,

    -- Legacy / Deprecated Types (Supported in 2022, avoid in new schemas)
    Col_Text            TEXT NULL,
    Col_NText           NTEXT NULL,
    Col_Image           IMAGE NULL
);
GO

-- 4B. Relational Business Tables (Using UDTs & Sequence)
CREATE TABLE [Demo].[Customers]
(
    CustomerID  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FullName    NVARCHAR(100) NOT NULL,
    Email       [Demo].[EmailAddress] NOT NULL UNIQUE,
    CreatedAt   DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

CREATE TABLE [Demo].[Orders]
(
    OrderID         INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    InvoiceNumber   BIGINT NOT NULL DEFAULT (NEXT VALUE FOR [Demo].[Seq_InvoiceNumber]),
    CustomerID      INT NOT NULL CONSTRAINT [FK_Orders_Customers] REFERENCES [Demo].[Customers](CustomerID),
    OrderDate       DATETIME2(3) NOT NULL DEFAULT SYSUTCDATETIME(),
    Status          VARCHAR(20) NOT NULL DEFAULT 'COMPLETED'
);
GO

CREATE TABLE [Demo].[OrderItems]
(
    OrderItemID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    OrderID     INT NOT NULL CONSTRAINT [FK_OrderItems_Orders] REFERENCES [Demo].[Orders](OrderID),
    ProductCode VARCHAR(20) NOT NULL,
    Quantity    INT NOT NULL CHECK (Quantity > 0),
    UnitPrice   [Demo].[CurrencyAmount] NOT NULL
);
GO


/* ============================================================================
   5. SAMPLE DATA POPULATION
   ============================================================================ */
INSERT INTO [Demo].[AllDataTypesShowcase]
(
    Col_BigInt, Col_Int, Col_SmallInt, Col_TinyInt, Col_Bit,
    Col_Decimal, Col_Numeric, Col_Money, Col_SmallMoney,
    Col_Float, Col_Real,
    Col_Date, Col_Time, Col_DateTime2, Col_DateTimeOffset, Col_DateTime, Col_SmallDateTime,
    Col_Char, Col_VarChar, Col_VarCharMax,
    Col_NChar, Col_NVarChar, Col_NVarCharMax, Col_JsonPayload,
    Col_Binary, Col_VarBinary, Col_VarBinaryMax,
    Col_Xml, Col_SqlVariant, Col_HierarchyId, Col_Geometry, Col_Geography,
    Col_Text, Col_NText, Col_Image
)
VALUES
(
    9223372036854775800, 2147483647, 32767, 255, 1,
    12345678901234.5678, 98765432.10, 150000.50, 214748.36,
    3.14159265358979, 2.71828,
    '2026-11-26', '14:30:15.1234567', '2026-11-26 14:30:15.1234567',
    '2026-11-26 14:30:15.1234567 +08:00', '2026-11-26 14:30:15.123', '2026-11-26 14:30:00',
    'FIXED_CHAR', 'Variable ASCII string', REPLICATE(CAST('Large ASCII block. ' AS VARCHAR(MAX)), 20),
    N'UNICODE_10', N'Unicode symbols: 你好 • € • 🚀', REPLICATE(CAST(N'Large Unicode block. ' AS NVARCHAR(MAX)), 20),
    JSON_OBJECT('engine': 'MSSQL 2022', 'features': JSON_ARRAY('JSON_OBJECT', 'DATE_BUCKET', 'GREATEST')),
    0x0102030405060708, CAST('BinaryPayload' AS VARBINARY(256)), CAST('LargeBinaryStream' AS VARBINARY(MAX)),
    CAST('<Order id="101"><Item code="SKU-01" qty="2"/></Order>' AS XML),
    CAST(99.95 AS DECIMAL(5,2)),
    hierarchyid::Parse('/1/2/1/'),
    geometry::STGeomFromText('POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))', 0),
    geography::Point(22.2783, 114.1747, 4326),
    'Legacy text value', N'Legacy ntext value', 0x89504E470D0A1A0A
);
GO

INSERT INTO [Demo].[Customers] (FullName, Email)
VALUES
    (N'Ada Lovelace', N'ada@analyticalengine.org'),
    (N'Grace Hopper', N'grace@compiler-lab.io');
GO

INSERT INTO [Demo].[Orders] (CustomerID, OrderDate, Status)
VALUES
    (1, '2026-11-20 09:15:00', 'COMPLETED'),
    (1, '2026-11-25 16:45:00', 'COMPLETED'),
    (2, '2026-11-26 11:00:00', 'COMPLETED');
GO

INSERT INTO [Demo].[OrderItems] (OrderID, ProductCode, Quantity, UnitPrice)
VALUES
    (1, 'SQL-ENT-2022', 2, 3500.0000),
    (1, 'SSD-NVME-4TB', 4, 420.5000),
    (2, 'SQL-ENT-2022', 1, 3500.0000),
    (3, 'RAM-DDR5-128G', 8, 299.9900);
GO


/* ============================================================================
   6. STANDARD VIEW & MATERIALIZED VIEW (INDEXED VIEW)
   ============================================================================ */

-- 6A. Standard View (Uses SQL Server 2022 DATE_BUCKET)
CREATE VIEW [Demo].[vw_CustomerOrderSummary]
AS
SELECT
    c.CustomerID,
    c.FullName,
    c.Email,
    DATE_BUCKET(WEEK, 1, o.OrderDate) AS OrderWeekBucket,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalSpend
FROM [Demo].[Customers] AS c
INNER JOIN [Demo].[Orders] AS o
    ON c.CustomerID = o.CustomerID
INNER JOIN [Demo].[OrderItems] AS oi
    ON o.OrderID = oi.OrderID
GROUP BY
    c.CustomerID,
    c.FullName,
    c.Email,
    DATE_BUCKET(WEEK, 1, o.OrderDate);
GO

-- 6B. Materialized View (Implemented as a Schema-Bound Indexed View in MSSQL)
CREATE VIEW [Demo].[vw_ProductSalesMaterialized]
WITH SCHEMABINDING
AS
SELECT
    oi.ProductCode,
    SUM(oi.Quantity) AS TotalUnitsSold,
    SUM(CAST(oi.Quantity AS DECIMAL(19,4)) * oi.UnitPrice) AS TotalRevenue,
    COUNT_BIG(*) AS LineItemCount
FROM [Demo].[OrderItems] AS oi
GROUP BY oi.ProductCode;
GO

-- Materializing the view onto disk via a Unique Clustered Index
CREATE UNIQUE CLUSTERED INDEX [IX_vw_ProductSalesMaterialized_ProductCode]
    ON [Demo].[vw_ProductSalesMaterialized] (ProductCode);
GO


/* ============================================================================
   7. USER-DEFINED FUNCTIONS (SCALAR, INLINE TVF, MULTI-STATEMENT TVF)
   ============================================================================ */

-- 7A. Scalar Function (Uses SQL Server 2022 GREATEST)
CREATE FUNCTION [Demo].[fn_CalculateDiscountedPrice]
(
    @UnitPrice       [Demo].[CurrencyAmount],
    @DiscountPercent DECIMAL(5,2)
)
RETURNS [Demo].[CurrencyAmount]
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @FinalPrice [Demo].[CurrencyAmount];
    SET @FinalPrice = GREATEST(0.0000, @UnitPrice * (1.0 - (@DiscountPercent / 100.0)));
    RETURN @FinalPrice;
END;
GO

-- 7B. Inline Table-Valued Function (Set-based, optimizes like a parameterized view)
CREATE FUNCTION [Demo].[fn_GetCustomerOrders]
(
    @CustomerID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        o.OrderID,
        o.InvoiceNumber,
        o.OrderDate,
        o.Status,
        SUM(oi.Quantity * oi.UnitPrice) AS OrderTotal
    FROM [Demo].[Orders] AS o
    INNER JOIN [Demo].[OrderItems] AS oi
        ON o.OrderID = oi.OrderID
    WHERE o.CustomerID = @CustomerID
    GROUP BY o.OrderID, o.InvoiceNumber, o.OrderDate, o.Status
);
GO

-- 7C. Multi-Statement Table-Valued Function
CREATE FUNCTION [Demo].[fn_GetOrderTierBreakdown]
(
    @HighValueThreshold [Demo].[CurrencyAmount]
)
RETURNS @TierSummary TABLE
(
    OrderID       INT PRIMARY KEY,
    InvoiceNumber BIGINT,
    OrderTotal    [Demo].[CurrencyAmount],
    TierLabel     VARCHAR(20)
)
AS
BEGIN
    INSERT INTO @TierSummary (OrderID, InvoiceNumber, OrderTotal, TierLabel)
    SELECT
        o.OrderID,
        o.InvoiceNumber,
        SUM(oi.Quantity * oi.UnitPrice) AS OrderTotal,
        CASE
            WHEN SUM(oi.Quantity * oi.UnitPrice) >= @HighValueThreshold THEN 'ENTERPRISE'
            ELSE 'STANDARD'
        END AS TierLabel
    FROM [Demo].[Orders] AS o
    INNER JOIN [Demo].[OrderItems] AS oi
        ON o.OrderID = oi.OrderID
    GROUP BY o.OrderID, o.InvoiceNumber;

    RETURN;
END;
GO


/* ============================================================================
   8. STORED PROCEDURES (TRANSACTIONS, TVPs, OUTPUT PARAMS, CURSOR)
   ============================================================================ */

-- 8A. Transactional Stored Procedure with Table-Valued Parameter & OUTPUT Params
CREATE PROCEDURE [Demo].[usp_CreateOrderWithItems]
    @CustomerID       INT,
    @DiscountPercent  DECIMAL(5,2) = 0.00,
    @Items            [Demo].[OrderItemTableType] READONLY,
    @NewOrderID       INT OUTPUT,
    @GeneratedInvoice BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM [Demo].[Customers] WHERE CustomerID = @CustomerID)
    BEGIN
        THROW 50001, 'CustomerID does not exist.', 1;
    END

    IF NOT EXISTS (SELECT 1 FROM @Items)
    BEGIN
        THROW 50002, 'At least one order item is required.', 1;
    END

    DECLARE @InsertedOrder TABLE
    (
        OrderID       INT,
        InvoiceNumber BIGINT
    );

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [Demo].[Orders] (CustomerID, Status)
        OUTPUT inserted.OrderID, inserted.InvoiceNumber
        INTO @InsertedOrder (OrderID, InvoiceNumber)
        VALUES (@CustomerID, 'COMPLETED');

        SELECT
            @NewOrderID = OrderID,
            @GeneratedInvoice = InvoiceNumber
        FROM @InsertedOrder;

        INSERT INTO [Demo].[OrderItems] (OrderID, ProductCode, Quantity, UnitPrice)
        SELECT
            @NewOrderID,
            ProductCode,
            Quantity,
            [Demo].[fn_CalculateDiscountedPrice](UnitPrice, @DiscountPercent)
        FROM @Items;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 8B. Stored Procedure Demonstrating the CURSOR Data Type
CREATE PROCEDURE [Demo].[usp_AuditCustomerBalancesCursor]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CustName NVARCHAR(100);
    DECLARE @CustEmail [Demo].[EmailAddress];

    -- CURSOR data type declaration
    DECLARE cur_Customers CURSOR LOCAL FAST_FORWARD FOR
        SELECT FullName, Email
        FROM [Demo].[Customers]
        ORDER BY CustomerID;

    OPEN cur_Customers;
    FETCH NEXT FROM cur_Customers INTO @CustName, @CustEmail;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT CONCAT('Audited Customer: ', @CustName, ' <', @CustEmail, '>');
        FETCH NEXT FROM cur_Customers INTO @CustName, @CustEmail;
    END

    CLOSE cur_Customers;
    DEALLOCATE cur_Customers;
END;
GO


/* ============================================================================
   9. VERIFICATION & EXECUTION TEST
   ============================================================================ */

-- Test Stored Procedure with Table-Valued Parameter
DECLARE @NewItems [Demo].[OrderItemTableType];
INSERT INTO @NewItems (ProductCode, Quantity, UnitPrice)
VALUES
    ('SQL-ENT-2022', 1, 3500.0000),
    ('BACKUP-AGENT', 3, 150.0000);

DECLARE @OutOrderID INT, @OutInvoice BIGINT;

EXEC [Demo].[usp_CreateOrderWithItems]
    @CustomerID       = 2,
    @DiscountPercent  = 10.00,
    @Items            = @NewItems,
    @NewOrderID       = @OutOrderID OUTPUT,
    @GeneratedInvoice = @OutInvoice OUTPUT;

SELECT @OutOrderID AS CreatedOrderID, @OutInvoice AS SequenceInvoiceNumber;

-- Query Standard View
SELECT * FROM [Demo].[vw_CustomerOrderSummary];

-- Query Materialized (Indexed) View using NOEXPAND
SELECT * FROM [Demo].[vw_ProductSalesMaterialized] WITH (NOEXPAND);

-- Query Inline & Multi-Statement TVFs
SELECT * FROM [Demo].[fn_GetCustomerOrders](2);
SELECT * FROM [Demo].[fn_GetOrderTierBreakdown](5000.0000);

-- Run Cursor Procedure
EXEC [Demo].[usp_AuditCustomerBalancesCursor];

-- Inspect All Data Types Table (Including HierarchyID & Spatial Text Representations)
SELECT
    RecordID,
    Col_BigInt,
    Col_Decimal,
    Col_DateTimeOffset,
    Col_JsonPayload,
    Col_UniqueId,
    Col_RowVersion,
    Col_HierarchyId.ToString() AS HierarchyPath,
    Col_Geometry.STAsText()    AS GeometryWKT,
    Col_Geography.STAsText()   AS GeographyWKT
FROM [Demo].[AllDataTypesShowcase];
GO