/* 1) DEPARTMAN CRUD
---------------------------------------------*/
CREATE OR ALTER PROCEDURE dbo.usp_Department_Create
    @DepartmentName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Departments(DepartmentName)
    VALUES(@DepartmentName);

    SELECT SCOPE_IDENTITY() AS DepartmentID;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Department_Update
    @DepartmentID INT,
    @DepartmentName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Departments
    SET DepartmentName = @DepartmentName
    WHERE DepartmentID = @DepartmentID;

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Department_Delete
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Ýliþkiden dolayý Employees varsa hata verecektir (FK). Ýstersen önce transfer et.
    DELETE FROM Departments WHERE DepartmentID = @DepartmentID;
    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Department_List
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DepartmentID, DepartmentName
    FROM Departments
    ORDER BY DepartmentName;
END
GO

/* 2) ÇALIÞAN CRUD + ARAMA/PAGÝNASYON
---------------------------------------------*/
CREATE OR ALTER PROCEDURE dbo.usp_Employee_Create
    @FirstName NVARCHAR(50),
    @LastName  NVARCHAR(50),
    @DepartmentID INT,
    @HireDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS(SELECT 1 FROM Departments WHERE DepartmentID = @DepartmentID)
    BEGIN
        RAISERROR('DepartmentID geçersiz.', 16, 1);
        RETURN;
    END

    INSERT INTO Employees(FirstName, LastName, DepartmentID, HireDate)
    VALUES(@FirstName, @LastName, @DepartmentID, @HireDate);

    SELECT SCOPE_IDENTITY() AS EmployeeID;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Employee_Update
    @EmployeeID INT,
    @FirstName NVARCHAR(50),
    @LastName  NVARCHAR(50),
    @DepartmentID INT,
    @HireDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS(SELECT 1 FROM Departments WHERE DepartmentID = @DepartmentID)
    BEGIN
        RAISERROR('DepartmentID geçersiz.', 16, 1);
        RETURN;
    END

    UPDATE Employees
    SET FirstName = @FirstName,
        LastName  = @LastName,
        DepartmentID = @DepartmentID,
        HireDate  = @HireDate
    WHERE EmployeeID = @EmployeeID;

    SELECT @@ROWCOUNT AS RowsAffected;
END
GO

/* Arama + Paginasyon: boþ/NULL parametreler filtrelemez */
CREATE OR ALTER PROCEDURE dbo.usp_Employee_Search
    @NameLike NVARCHAR(50) = NULL,     -- ad/soyad aramasý
    @DepartmentID INT = NULL,
    @HiredFrom DATE = NULL,
    @HiredTo   DATE = NULL,
    @Page INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    IF @Page < 1 SET @Page = 1;
    IF @PageSize < 1 SET @PageSize = 20;

    WITH CTE AS (
        SELECT e.EmployeeID, e.FirstName, e.LastName, e.DepartmentID, d.DepartmentName,
               e.HireDate,
               ROW_NUMBER() OVER (ORDER BY e.EmployeeID DESC) AS rn
        FROM Employees e
        INNER JOIN Departments d ON d.DepartmentID = e.DepartmentID
        WHERE (@DepartmentID IS NULL OR e.DepartmentID = @DepartmentID)
          AND (@NameLike IS NULL OR (e.FirstName LIKE '%' + @NameLike + '%' OR e.LastName LIKE '%' + @NameLike + '%'))
          AND (@HiredFrom IS NULL OR e.HireDate >= @HiredFrom)
          AND (@HiredTo   IS NULL OR e.HireDate <= @HiredTo)
    )
    SELECT EmployeeID, FirstName, LastName, DepartmentID, DepartmentName, HireDate
    FROM CTE
    WHERE rn BETWEEN ((@Page-1)*@PageSize + 1) AND (@Page*@PageSize);

    -- Toplam kayýt adedi:
    SELECT COUNT(1) AS TotalCount
    FROM Employees e
    WHERE (@DepartmentID IS NULL OR e.DepartmentID = @DepartmentID)
      AND (@NameLike IS NULL OR (e.FirstName LIKE '%' + @NameLike + '%' OR e.LastName LIKE '%' + @NameLike + '%'))
      AND (@HiredFrom IS NULL OR e.HireDate >= @HiredFrom)
      AND (@HiredTo   IS NULL OR e.HireDate <= @HiredTo);
END
GO

/* 3) MAAÞ EKLEME ve SON MAAÞI GETÝRME
---------------------------------------------*/
CREATE OR ALTER PROCEDURE dbo.usp_Salary_Add
    @EmployeeID INT,
    @Amount DECIMAL(10,2),
    @EffectiveDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS(SELECT 1 FROM Employees WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('EmployeeID geçersiz.',16,1); RETURN;
    END

    INSERT INTO Salaries(EmployeeID, Amount, EffectiveDate)
    VALUES(@EmployeeID, @Amount, @EffectiveDate);

    SELECT SCOPE_IDENTITY() AS SalaryID;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_Salary_GetLatest
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP(1) s.SalaryID, s.EmployeeID, s.Amount, s.EffectiveDate
    FROM Salaries s
    WHERE s.EmployeeID = @EmployeeID
    ORDER BY s.EffectiveDate DESC, s.SalaryID DESC;
END
GO

/* 4) ADRES EKLE/GÜNCELLE (Upsert)
---------------------------------------------*/
CREATE OR ALTER PROCEDURE dbo.usp_Address_Upsert
    @EmployeeID INT,
    @City NVARCHAR(50),
    @District NVARCHAR(50),
    @Street NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS(SELECT 1 FROM Employees WHERE EmployeeID = @EmployeeID)
    BEGIN
        RAISERROR('EmployeeID geçersiz.',16,1); RETURN;
    END

    IF EXISTS(SELECT 1 FROM Addresses WHERE EmployeeID = @EmployeeID)
    BEGIN
        UPDATE Addresses
        SET City=@City, District=@District, Street=@Street
        WHERE EmployeeID=@EmployeeID;

        SELECT 'updated' AS Result;
    END
    ELSE
    BEGIN
        INSERT INTO Addresses(EmployeeID, City, District, Street)
        VALUES(@EmployeeID, @City, @District, @Street);

        SELECT 'inserted' AS Result, SCOPE_IDENTITY() AS AddressID;
    END
END
GO

/* 5) PROJEYE ÇALIÞAN ATAMA (Idempotent): Ayný kayýt varsa günceller/tekrar eklemez
---------------------------------------------*/
CREATE OR ALTER PROCEDURE dbo.usp_Project_AssignEmployee
    @EmployeeID INT,
    @ProjectID INT,
    @AssignedDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @AssignedDate IS NULL SET @AssignedDate = CAST(GETDATE() AS DATE);

    IF NOT EXISTS(SELECT 1 FROM Employees WHERE EmployeeID = @EmployeeID)
    BEGIN RAISERROR('EmployeeID geçersiz.',16,1); RETURN; END
    IF NOT EXISTS(SELECT 1 FROM Projects WHERE ProjectID = @ProjectID)
    BEGIN RAISERROR('ProjectID geçersiz.',16,1); RETURN; END

    IF EXISTS(SELECT 1 FROM EmployeeProjects WHERE EmployeeID=@EmployeeID AND ProjectID=@ProjectID)
    BEGIN
        UPDATE EmployeeProjects
        SET AssignedDate = @AssignedDate
        WHERE EmployeeID=@EmployeeID AND ProjectID=@ProjectID;

        SELECT 'updated' AS Result;
    END
    ELSE
    BEGIN
        INSERT INTO EmployeeProjects(EmployeeID, ProjectID, AssignedDate)
        VALUES(@EmployeeID, @ProjectID, @AssignedDate);

        SELECT 'inserted' AS Result;
    END
END
GO

/* 6) ÇALIÞANI SÝL (Child tablolarla birlikte, TRANSACTION)
---------------------------------------------*/
CREATE OR ALTER PROCEDURE dbo.usp_Employee_DeleteCascade
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;

        DELETE FROM EmployeeProjects WHERE EmployeeID=@EmployeeID;
        DELETE FROM Salaries         WHERE EmployeeID=@EmployeeID;
        DELETE FROM Addresses        WHERE EmployeeID=@EmployeeID;
        DELETE FROM Employees        WHERE EmployeeID=@EmployeeID;

        COMMIT TRAN;
        SELECT 1 AS Success;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;

        DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@msg,16,1);
    END CATCH
END
GO

/* 7) RAPOR: Çalýþan Tam Profil (Departman, Son Maaþ, Adres, Projeler)
---------------------------------------------*/
CREATE OR ALTER PROCEDURE dbo.usp_Employee_FullProfile
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH LastSalary AS (
        SELECT TOP(1) s.EmployeeID, s.Amount, s.EffectiveDate
        FROM Salaries s
        WHERE s.EmployeeID = @EmployeeID
        ORDER BY s.EffectiveDate DESC, s.SalaryID DESC
    )
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        d.DepartmentName,
        e.HireDate,
        ls.Amount AS LatestSalary,
        ls.EffectiveDate AS LatestSalaryDate,
        a.City, a.District, a.Street
    FROM Employees e
    INNER JOIN Departments d ON d.DepartmentID = e.DepartmentID
    LEFT JOIN LastSalary ls ON ls.EmployeeID = e.EmployeeID
    LEFT JOIN Addresses a   ON a.EmployeeID = e.EmployeeID
    WHERE e.EmployeeID = @EmployeeID;

    -- Proje listesi ayrýca:
    SELECT p.ProjectID, p.ProjectName, ep.AssignedDate
    FROM EmployeeProjects ep
    INNER JOIN Projects p ON p.ProjectID = ep.ProjectID
    WHERE ep.EmployeeID = @EmployeeID
    ORDER BY ep.AssignedDate DESC, p.ProjectID DESC;
END
GO
