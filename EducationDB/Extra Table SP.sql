-- VARSA SÝL (Tekrar çalýþtýrmak için)
DROP TABLE IF EXISTS EmployeeProjects, Salaries, Addresses, Projects, Employees, Departments;

------------------------------
-- 1. Departments Tablosu
------------------------------
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(50)
);

INSERT INTO Departments (DepartmentName)
VALUES ('IT'), ('HR'), ('Finance'), ('Marketing'), ('Logistics');

------------------------------
-- 2. Employees Tablosu
------------------------------
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    DepartmentID INT,
    HireDate DATE,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

DECLARE @i INT = 1;
WHILE @i <= 100
BEGIN
    INSERT INTO Employees (FirstName, LastName, DepartmentID, HireDate)
    VALUES (
        CONCAT('Name', @i),
        CONCAT('Surname', @i),
        ((@i % 5) + 1), -- 1-5 arasý department
        DATEADD(DAY, -@i * 15, GETDATE())
    );
    SET @i += 1;
END;

------------------------------
-- 3. Projects Tablosu
------------------------------
CREATE TABLE Projects (
    ProjectID INT PRIMARY KEY IDENTITY(1,1),
    ProjectName NVARCHAR(100),
    StartDate DATE,
    EndDate DATE
);

INSERT INTO Projects (ProjectName, StartDate, EndDate)
VALUES 
('CRM System Upgrade', '2025-01-01', '2025-06-30'),
('HR Portal', '2025-02-15', '2025-08-15'),
('Financial Dashboard', '2025-03-01', '2025-09-30'),
('Marketing Campaign', '2025-04-10', '2025-10-20'),
('Warehouse Automation', '2025-05-05', '2025-12-31');

------------------------------
-- 4. EmployeeProjects Tablosu (Many-to-Many iliþki)
------------------------------
CREATE TABLE EmployeeProjects (
    EmployeeID INT,
    ProjectID INT,
    AssignedDate DATE,
    PRIMARY KEY (EmployeeID, ProjectID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID)
);

SET @i = 1;
WHILE @i <= 100
BEGIN
    INSERT INTO EmployeeProjects (EmployeeID, ProjectID, AssignedDate)
    VALUES (
        @i,
        ((@i % 5) + 1), -- Her çalýþana bir proje
        DATEADD(DAY, -@i * 5, GETDATE())
    );
    SET @i += 1;
END;

------------------------------
-- 5. Salaries Tablosu
------------------------------
CREATE TABLE Salaries (
    SalaryID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT,
    Amount DECIMAL(10,2),
    EffectiveDate DATE,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

SET @i = 1;
WHILE @i <= 100
BEGIN
    INSERT INTO Salaries (EmployeeID, Amount, EffectiveDate)
    VALUES (
        @i,
        ROUND(RAND() * (9000 - 3000) + 3000, 2),
        DATEADD(MONTH, -(@i % 12), GETDATE())
    );
    SET @i += 1;
END;

------------------------------
-- 6. Addresses Tablosu
------------------------------
CREATE TABLE Addresses (
    AddressID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT,
    City NVARCHAR(50),
    District NVARCHAR(50),
    Street NVARCHAR(100),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

SET @i = 1;
WHILE @i <= 100
BEGIN
    INSERT INTO Addresses (EmployeeID, City, District, Street)
    VALUES (
        @i,
        CONCAT('City', (@i % 10) + 1),
        CONCAT('District', (@i % 5) + 1),
        CONCAT('Street ', (@i % 20) + 1)
    );
    SET @i += 1;
END;

------------------------------
-- KONTROL
------------------------------
SELECT * FROM Departments;
SELECT * FROM Employees;
SELECT * FROM Projects;
SELECT * FROM EmployeeProjects;
SELECT * FROM Salaries;
SELECT * FROM Addresses;
