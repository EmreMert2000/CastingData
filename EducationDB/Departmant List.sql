CREATE OR ALTER PROCEDURE dbo.usp_Department_List
    @Search     nvarchar(100) = NULL,  -- isim içinde arar
    @OnlyActive bit = NULL              -- sadece aktif =1 istiyorsan 1, sadece pasif=0 istiyorsan 0, hepsi için NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DepartmentId, DepartmentName, IsActive
    FROM dbo.Departments
    WHERE (@Search IS NULL OR DepartmentName LIKE '%' + @Search + '%')
      AND (@OnlyActive IS NULL OR IsActive = @OnlyActive)
    ORDER BY DepartmentName;
END
GO
