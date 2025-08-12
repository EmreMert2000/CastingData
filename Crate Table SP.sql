-- 1. Örnek tabloyu oluþtur
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Department NVARCHAR(50),
    Salary DECIMAL(10,2),
    HireDate DATE
);

-- 2. 100 sahte veri ekle
DECLARE @i INT = 1;

WHILE @i <= 100
BEGIN
    INSERT INTO Employees (FirstName, LastName, Department, Salary, HireDate)
    VALUES (
        CONCAT('Name', @i),
        CONCAT('Surname', @i),
        CASE 
            WHEN @i % 4 = 0 THEN 'IT'
            WHEN @i % 4 = 1 THEN 'HR'
            WHEN @i % 4 = 2 THEN 'Finance'
            ELSE 'Marketing'
        END,
        ROUND(RAND() * (9000 - 3000) + 3000, 2), -- Maaþ 3000-9000 arasý
        DATEADD(DAY, -@i * 30, GETDATE()) -- Ýþe giriþ tarihi geriye doðru
    );
    SET @i += 1;
END;

-- 3. Eklenen verileri kontrol et
SELECT * FROM Employees;
