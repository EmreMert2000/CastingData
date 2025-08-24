CREATE OR ALTER PROCEDURE dbo.usp_Employee_Create
    @FirstName    nvarchar(50),
    @LastName     nvarchar(50),
    @Email        nvarchar(100) = NULL, -- varsa benzersiz kontrol� yap�l�r
    @Phone        nvarchar(30)  = NULL,
    @HireDate     date,
    @Salary       decimal(18,2) = NULL,
    @DepartmentId int,
    @IsActive     bit           = 1,
    @NewEmployeeId int          OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- Departman var m�?
        IF NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE DepartmentId=@DepartmentId)
            THROW 51001, 'Ge�ersiz DepartmentId.', 1;

        -- Email varsa benzersiz mi?
        IF @Email IS NOT NULL AND EXISTS(SELECT 1 FROM dbo.Employees WHERE Email=@Email)
            THROW 51002, 'Email zaten kay�tl�.', 1;

        INSERT dbo.Employees(FirstName, LastName, Email, Phone, HireDate, Salary, DepartmentId, IsActive)
        VALUES(@FirstName, @LastName, @Email, @Phone, @HireDate, @Salary, @DepartmentId, @IsActive);

        SET @NewEmployeeId = SCOPE_IDENTITY();

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END
GO
