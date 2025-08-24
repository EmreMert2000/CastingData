CREATE OR ALTER PROCEDURE dbo.usp_Employee_Update
    @EmployeeId     int,
    @FirstName      nvarchar(50) = NULL,
    @LastName       nvarchar(50) = NULL,
    @Email          nvarchar(100) = NULL,
    @Phone          nvarchar(30) = NULL,
    @HireDate       date = NULL,
    @Salary         decimal(18,2) = NULL,
    @DepartmentId   int   = NULL,
    @IsActive       bit   = NULL,
    @ExpectedRowVer varbinary(8) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @hasRowVer bit =
        CASE WHEN EXISTS
            (SELECT 1 FROM sys.columns
             WHERE object_id = OBJECT_ID('dbo.Employees')
               AND name IN ('RowVer','RowVersion','rowversion'))
        THEN 1 ELSE 0 END;

    IF @DepartmentId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE DepartmentId=@DepartmentId)
        THROW 51003, 'Geçersiz DepartmentId.', 1;

    IF @hasRowVer = 1 AND @ExpectedRowVer IS NOT NULL
    BEGIN
        UPDATE e
           SET FirstName    = COALESCE(@FirstName,  e.FirstName),
               LastName     = COALESCE(@LastName,   e.LastName),
               Email        = COALESCE(@Email,      e.Email),
               Phone        = COALESCE(@Phone,      e.Phone),
               HireDate     = COALESCE(@HireDate,   e.HireDate),
               Salary       = COALESCE(@Salary,     e.Salary),
               DepartmentId = COALESCE(@DepartmentId, e.DepartmentId),
               IsActive     = COALESCE(@IsActive,   e.IsActive)
         FROM dbo.Employees e
        WHERE e.EmployeeId = @EmployeeId
          AND e.RowVer     = @ExpectedRowVer;

        IF @@ROWCOUNT = 0
            THROW 51004, 'Kayýt deðiþmiþ olabilir (rowversion uyuþmuyor) veya bulunamadý.', 1;
    END
    ELSE
    BEGIN
        UPDATE e
           SET FirstName    = COALESCE(@FirstName,  e.FirstName),
               LastName     = COALESCE(@LastName,   e.LastName),
               Email        = COALESCE(@Email,      e.Email),
               Phone        = COALESCE(@Phone,      e.Phone),
               HireDate     = COALESCE(@HireDate,   e.HireDate),
               Salary       = COALESCE(@Salary,     e.Salary),
               DepartmentId = COALESCE(@DepartmentId, e.DepartmentId),
               IsActive     = COALESCE(@IsActive,   e.IsActive)
         FROM dbo.Employees e
        WHERE e.EmployeeId = @EmployeeId;

        IF @@ROWCOUNT = 0
            THROW 51005, 'Güncellenecek Employee bulunamadý.', 1;
    END
END
GO
