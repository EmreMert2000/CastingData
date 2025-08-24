-- Departments kolonlarý
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='Departments'
ORDER BY ORDINAL_POSITION;

-- Employees kolonlarý
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='Employees'
ORDER BY ORDINAL_POSITION;



alter PROCEDURE dbo.usp_Department_Upsert
    @DepartmentId   int             = NULL OUTPUT, -- NULL ise INSERT, dolu ise UPDATE
    @DepartmentName nvarchar(100),
    @IsActive       bit             = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;
        IF @DepartmentId IS NULL
        BEGIN
            INSERT dbo.Departments(DepartmentName, IsActive)
            VALUES(@DepartmentName, @IsActive);

            SET @DepartmentId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE dbo.Departments
               SET DepartmentName = @DepartmentName,
                   IsActive       = @IsActive
             WHERE DepartmentId   = @DepartmentId;

            IF @@ROWCOUNT = 0
                THROW 51000, 'Güncellenecek Department bulunamadý.', 1;
        END
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END
GO
