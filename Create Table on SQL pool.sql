IF NOT EXISTS (SELECT * FROM sys.objects WHERE NAME = 'nyc_taxi' AND TYPE = 'U')
CREATE TABLE dbo.nyc_taxi
(
    tipped int,
    fareAmount float,
    paymentType int,
    passengerCount int,
    tripDistance float,
    tripTimeSecs bigint,
    pickupTimeBin nvarchar(30)
)
WITH
(
    DISTRIBUTION = ROUND_ROBIN,
    CLUSTERED COLUMNSTORE INDEX
)
GO

COPY INTO dbo.nyc_taxi
(tipped 1, fareAmount 2, paymentType 3, passengerCount 4, tripDistance 5, tripTimeSecs 6, pickupTimeBin 7)
FROM '<URL to the test data in the linked storage account, will end in NYCTaxi/testdata/ the name of the generated file.csv>'
WITH
(
    FILE_TYPE = 'CSV',
    ROWTERMINATOR='0x0A',
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    FIRSTROW = 2
)
GO

SELECT TOP 100 * FROM nyc_taxi
GO