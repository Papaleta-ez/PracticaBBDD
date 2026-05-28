
USE master;

IF DB_ID(N'bd_universidad') IS NOT NULL
BEGIN
    ALTER DATABASE bd_universidad SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE bd_universidad;
END;

---------------------

EXEC(N'CREATE DATABASE bd_universidad');

USE bd_universidad;

SELECT name FROM sys.databases WHERE name = N'bd_universidad';

SELECT name, physical_name, type_desc
FROM sys.database_files;

SELECT SERVERPROPERTY(N'Collation') AS collation_instancia;


------------------------
-- Ejercicio 2
------------------------

CREATE TABLE CARRERA (
    id_carrera INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    duracion_anios TINYINT NOT NULL,
    modalidad NVARCHAR(20) NOT NULL,
    CONSTRAINT ck_modalidad_carrera CHECK (modalidad IN (N'Presencial', N'Virtual', N'Semipresencial'))
);

CREATE TABLE MATERIA (
    id_materia INT IDENTITY(1,1) NOT NULL,
    codigo NVARCHAR(20) NOT NULL UNIQUE,
    nombre NVARCHAR(100) NOT NULL,
    creditos TINYINT NOT NULL,
    semestre TINYINT NOT NULL,
    CONSTRAINT pk_materia PRIMARY KEY (id_materia),
    CONSTRAINT ck_creditos_positivos CHECK (creditos > 0),
    CONSTRAINT ck_semestre CHECK (semestre BETWEEN 1 AND 10)
);


------------------------
-- Ejercicio 3
------------------------

CREATE TABLE ESTUDIANTE (
    id_estudiante INT IDENTITY(1,1) PRIMARY KEY,
    carnet NVARCHAR(10) NOT NULL UNIQUE,
    nombre_completo NVARCHAR(150) NOT NULL,
    fecha_nacimiento DATE NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    id_carrera INT NOT NULL,
    CONSTRAINT fk_estudiante_carrera FOREIGN KEY (id_carrera)
        REFERENCES CARRERA (id_carrera)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);


SELECT * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS;

BEGIN TRY
    INSERT INTO ESTUDIANTE 
    (carnet, nombre_completo, fecha_nacimiento, email, id_carrera)
    VALUES 
    (N'20260001', N'Estudiante Prueba', '2005-01-01', N'prueba@correo.com', 9999);
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS numero_error, ERROR_MESSAGE() AS mensaje_error;
END CATCH;

------------------------
-- Ejercicio 4
------------------------

CREATE TABLE INSCRIPCION (
    id_inscripcion INT IDENTITY(1,1) PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_materia INT NOT NULL,
    anio SMALLINT NOT NULL,
    periodo NVARCHAR(3) NOT NULL,
    nota_final DECIMAL(4,2) NULL,
    CONSTRAINT fk_inscripcion_estudiante FOREIGN KEY (id_estudiante)
        REFERENCES ESTUDIANTE (id_estudiante)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT fk_inscripcion_materia FOREIGN KEY (id_materia)
        REFERENCES MATERIA (id_materia)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT ck_periodo_valido CHECK (periodo IN (N'I', N'II', N'III')),
    CONSTRAINT ck_anio_valido CHECK (anio BETWEEN 2000 AND 2099),
    CONSTRAINT uq_inscripcion UNIQUE (id_estudiante, id_materia, anio, periodo)
);


------------------------
-- Ejercicio 5
------------------------

ALTER TABLE ESTUDIANTE
    ADD telefono NVARCHAR(20) NULL;

ALTER TABLE ESTUDIANTE
    ADD estado NVARCHAR(10) NOT NULL DEFAULT N'Activo',
        CONSTRAINT ck_estado_valido CHECK (estado IN (N'Activo', N'Inactivo'));

ALTER TABLE MATERIA
    ADD descripcion NVARCHAR(MAX) NULL;


------------------------
-- Ejercicio 6
------------------------

ALTER TABLE ESTUDIANTE
    ALTER COLUMN telefono NVARCHAR(25) NULL;

EXEC sp_rename
    N'CARRERA.duracion_anios',
    N'duracion',
    N'COLUMN';

ALTER TABLE INSCRIPCION
    ALTER COLUMN nota_final DECIMAL(5,2) NULL;


SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'INSCRIPCION';
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'CARRERA';
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'ESTUDIANTE';
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'MATERIA';

------------------------
-- Ejercicio 7
------------------------

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
ORDER BY TABLE_NAME;

SELECT name, definition
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID(N'MATERIA');

ALTER TABLE CARRERA
    ADD CONSTRAINT ck_duracion_carrera CHECK (duracion BETWEEN 3 AND 6);

CREATE NONCLUSTERED INDEX IX_estudiante_email 
ON ESTUDIANTE (email);

ALTER TABLE MATERIA
    DROP CONSTRAINT ck_semestre;

ALTER TABLE MATERIA
    ADD CONSTRAINT ck_semestre_valido CHECK (semestre BETWEEN 1 AND 10);

SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
ORDER BY TABLE_NAME;


------------------------
-- Ejercicio 8
------------------------

SELECT d.name AS default_name
FROM sys.default_constraints d
JOIN sys.columns c 
    ON d.parent_column_id = c.column_id
    AND d.parent_object_id = c.object_id
WHERE c.object_id = OBJECT_ID(N'MATERIA')
    AND c.name = N'descripcion';

DECLARE @default_descripcion SYSNAME;
DECLARE @sql NVARCHAR(MAX);

SELECT @default_descripcion = d.name
FROM sys.default_constraints d
JOIN sys.columns c 
    ON d.parent_column_id = c.column_id
    AND d.parent_object_id = c.object_id
WHERE c.object_id = OBJECT_ID(N'MATERIA')
    AND c.name = N'descripcion';

IF @default_descripcion IS NOT NULL
BEGIN
    SET @sql = N'ALTER TABLE MATERIA DROP CONSTRAINT ' + QUOTENAME(@default_descripcion);
    EXEC sp_executesql @sql;
END;

ALTER TABLE MATERIA
    DROP COLUMN descripcion;

SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = N'MATERIA';


SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'CARRERA';
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'ESTUDIANTE';
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'MATERIA';
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'INSCRIPCION';

------------------------
-- Ejercicio 9
------------------------

BEGIN TRY
    DROP TABLE CARRERA;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS numero_error, ERROR_MESSAGE() AS mensaje_error;
END CATCH;

DROP TABLE IF EXISTS INSCRIPCION;
DROP TABLE IF EXISTS ESTUDIANTE;
DROP TABLE IF EXISTS MATERIA;
DROP TABLE IF EXISTS CARRERA;


------------------------
-- Ejercicio 10
------------------------

CREATE TABLE CARRERA (
    id_carrera INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    duracion TINYINT NOT NULL,
    modalidad NVARCHAR(20) NOT NULL,
    CONSTRAINT ck_modalidad_carrera CHECK (modalidad IN (N'Presencial', N'Virtual', N'Semipresencial')),
    CONSTRAINT ck_duracion_carrera CHECK (duracion BETWEEN 3 AND 6)
);

CREATE TABLE MATERIA (
    id_materia INT IDENTITY(1,1) NOT NULL,
    codigo NVARCHAR(20) NOT NULL UNIQUE,
    nombre NVARCHAR(100) NOT NULL,
    creditos TINYINT NOT NULL,
    semestre TINYINT NOT NULL,
    CONSTRAINT pk_materia PRIMARY KEY (id_materia),
    CONSTRAINT ck_creditos_positivos CHECK (creditos > 0),
    CONSTRAINT ck_semestre_valido CHECK (semestre BETWEEN 1 AND 10)
);

CREATE TABLE ESTUDIANTE (
    id_estudiante INT IDENTITY(1,1) PRIMARY KEY,
    carnet NVARCHAR(10) NOT NULL UNIQUE,
    nombre_completo NVARCHAR(150) NOT NULL,
    fecha_nacimiento DATE NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    id_carrera INT NOT NULL,
    telefono NVARCHAR(25) NULL,
    estado NVARCHAR(10) NOT NULL DEFAULT N'Activo',
    CONSTRAINT ck_estado_valido CHECK (estado IN (N'Activo', N'Inactivo')),
    CONSTRAINT fk_estudiante_carrera FOREIGN KEY (id_carrera)
        REFERENCES CARRERA (id_carrera)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);

CREATE TABLE INSCRIPCION (
    id_inscripcion INT IDENTITY(1,1) PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_materia INT NOT NULL,
    anio SMALLINT NOT NULL,
    periodo NVARCHAR(3) NOT NULL,
    nota_final DECIMAL(5,2) NULL,
    CONSTRAINT fk_inscripcion_estudiante FOREIGN KEY (id_estudiante)
        REFERENCES ESTUDIANTE (id_estudiante)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT fk_inscripcion_materia FOREIGN KEY (id_materia)
        REFERENCES MATERIA (id_materia)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT ck_periodo_valido CHECK (periodo IN (N'I', N'II', N'III')),
    CONSTRAINT ck_anio_valido CHECK (anio BETWEEN 2000 AND 2099),
    CONSTRAINT uq_inscripcion UNIQUE (id_estudiante, id_materia, anio, periodo)
);

INSERT INTO CARRERA (nombre, duracion, modalidad)
VALUES 
(N'Ingeniería en Sistemas', 5, N'Presencial'),
(N'Medicina', 6, N'Presencial'),
(N'Administración', 4, N'Virtual');

INSERT INTO MATERIA (codigo, nombre, creditos, semestre)
VALUES
(N'BD-101', N'Bases de Datos I', 4, 3),
(N'PR-101', N'Programación I', 4, 1),
(N'MT-101', N'Matemática I', 3, 1);

INSERT INTO ESTUDIANTE
(carnet, nombre_completo, fecha_nacimiento, email, id_carrera, telefono, estado)
VALUES
(N'20260001', N'Carlos López', '2005-04-12', N'carlos@gmail.com', 1, N'8888-1111', N'Activo');

INSERT INTO INSCRIPCION
(id_estudiante, id_materia, anio, periodo, nota_final)
VALUES
(1, 1, 2026, N'I', NULL),
(1, 2, 2026, N'I', 89.50),
(1, 3, 2026, N'II', NULL);

SELECT * FROM INSCRIPCION;

DELETE FROM INSCRIPCION;

INSERT INTO INSCRIPCION
(id_estudiante, id_materia, anio, periodo, nota_final)
VALUES
(1, 1, 2026, N'I', NULL);

SELECT * FROM INSCRIPCION;

TRUNCATE TABLE INSCRIPCION;

INSERT INTO INSCRIPCION
(id_estudiante, id_materia, anio, periodo, nota_final)
VALUES
(1, 1, 2026, N'I', NULL);

SELECT * FROM INSCRIPCION;

BEGIN TRANSACTION;
    TRUNCATE TABLE INSCRIPCION;
    SELECT COUNT(*) AS filas_durante_truncate FROM INSCRIPCION;
ROLLBACK;

SELECT * FROM INSCRIPCION;

BEGIN TRY
    TRUNCATE TABLE CARRERA;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS numero_error, ERROR_MESSAGE() AS mensaje_error;
END CATCH;




SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'CARRERA';

SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'ESTUDIANTE';

SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'MATERIA';

SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'INSCRIPCION';
