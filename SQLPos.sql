
USE master;
GO
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'POS')
BEGIN
    ALTER DATABASE [POS] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [POS];
END
GO

CREATE DATABASE [POS];
GO
USE [POS];
GO

IF OBJECT_ID('dbo.Usuarios','U') IS NOT NULL
    DROP TABLE dbo.Usuarios;
GO

CREATE TABLE dbo.Usuarios
(
    idk        INT IDENTITY(1,1) PRIMARY KEY,
    nombre     NVARCHAR(100)    NULL,
    apellidoP  NVARCHAR(100)    NULL,
    apellidoM  NVARCHAR(100)    NULL,
    correo     NVARCHAR(100)    NULL,
    usuario    NVARCHAR(20)     NULL,
    password   NVARCHAR(20)     NULL,
    idPerfil   INT              NULL
);
GO

INSERT INTO dbo.Usuarios
    (nombre, apellidoP, apellidoM, correo, usuario, password, idPerfil)
VALUES
    ('Admin',  'User',    '',      'admin@domain.com', 'admin', 'admin123', 1),
    ('Ana',    'Rascon',  'Ochoa', 'ana.rascon@ues.mx','Ana',   '123456',    1);
GO


USE POS
GO
IF OBJECT_ID('dbo.proc_InsertarUsuarios','P') IS NOT NULL
    DROP PROC dbo.proc_InsertarUsuarios;
GO

CREATE PROCEDURE dbo.proc_InsertarUsuarios
    @nombre     NVARCHAR(100),
    @apellidoP  NVARCHAR(100),
    @apellidoM  NVARCHAR(100),
    @correo     NVARCHAR(100),
    @usuario    NVARCHAR(20),
    @password   NVARCHAR(20),
    @idPerfil   INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Usuarios
        (nombre, apellidoP, apellidoM, correo, usuario, [password], idPerfil)
    VALUES
        (@nombre, @apellidoP, @apellidoM, @correo, @usuario, @password, @idPerfil);
END;
GO
USE POS;
GO
IF OBJECT_ID('dbo.proc_ValidaLogin','P') IS NOT NULL
   DROP PROC dbo.proc_ValidaLogin;
GO
CREATE PROCEDURE dbo.proc_ValidaLogin
  @usuario  NVARCHAR(20),
  @password NVARCHAR(20)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT
    idk            AS Clave,   
    usuario,                  
    nombre + ' ' + apellidoP + ' ' + apellidoM AS nombre,
    idPerfil                  
  FROM dbo.Usuarios
  WHERE usuario  = @usuario
    AND [password] = @password;
END;
GO

IF OBJECT_ID('dbo.proc_BuscarUsuarioPorID','P') IS NOT NULL
    DROP PROC dbo.proc_BuscarUsuarioPorID;
GO

CREATE PROCEDURE dbo.proc_BuscarUsuarioPorID
    @idk INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
      FROM dbo.Usuarios
     WHERE idk = @idk;
END;
GO

ALTER DATABASE [POS] SET READ_WRITE;
GO
EXEC dbo.proc_ValidaLogin 'Ana','123456';

use POS
GO
EXEC proc_InsertarUsuarios 
  @nombre     = 'cristina',
  @apellidoP  = 'ochoa',
  @apellidoM  = 'mazon',
  @correo     = 'cristina.ochoa@ues.mx',
  @usuario    = 'cristina',
  @password   = '123456',
  @idPerfil   = 2;



  USE POS 
  GO
  EXEC proc_InsertarUsuarios
  @nombre     = 'eee',
  @apellidoP  = 'eee',
  @apellidoM  = 'eee',
  @correo     = 'dadsas.dasd@ues.mx',
  @usuario    = 'eee',
  @password   = '123456',
  @idPerfil   = 3;


  use POS
  GO 
  IF EXISTS(SELECT 1 FROM Usuarios WHERE usuario = @usuario)
    RETURN 0;


	USE POS
	GO
	CREATE OR ALTER PROCEDURE proc_InsertarProductos
    @clave NVARCHAR(20),
    @nombre NVARCHAR(100),
    @descripcion NVARCHAR(200),
    @unidadMedida NVARCHAR(50),
    @ubicacion NVARCHAR(50),
    @precioCompra DECIMAL(10,2),
    @precioVenta DECIMAL(10,2),
    @existencia INT,
    @minimo INT,
    @maximo INT
AS
BEGIN
    SET NOCOUNT OFF; -- ← importante

    IF EXISTS (SELECT 1 FROM Productos WHERE clave = @clave)
    BEGIN
        RAISERROR('La clave ya existe. Por favor, usa otra.', 16, 1);
        RETURN;
    END

    INSERT INTO Productos (
        clave, nombre, descripcion, unidadMedida,
        ubicacion, precioCompra, precioVenta,
        existencia, minimo, maximo
    )
    VALUES (
        @clave, @nombre, @descripcion, @unidadMedida,
        @ubicacion, @precioCompra, @precioVenta,
        @existencia, @minimo, @maximo
    );
END


use pos
go


EXEC proc_InsertarProductos
    @clave = '777',
    @nombre = 'Coca Cola',
    @descripcion = 'Bebida',
    @unidadMedida = 'pieza',
    @ubicacion = 'Almacen',
    @precioCompra = 44,
    @precioVenta = 66,
    @existencia = 78,
    @minimo = 45,
    @maximo = 100;

	USE POS
GO

CREATE TABLE Productos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    clave NVARCHAR(20),
    nombre NVARCHAR(100),
    descripcion NVARCHAR(200),
    unidadMedida NVARCHAR(50),
    ubicacion NVARCHAR(100),
    precioCompra DECIMAL(10,2),
    precioVenta DECIMAL(10,2),
    existencia INT,
    minimo INT,
    maximo INT
);


USE POS
GO
CREATE OR ALTER PROCEDURE proc_BuscarProductoPorID
    @id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        id,
        clave,
        nombre,
        descripcion,
        unidadMedida,
        ubicacion,
        precioCompra,
        precioVenta,
        existencia,
        minimo,
        maximo
    FROM Productos
    WHERE id = @id;
END;

use pos
go
CREATE OR ALTER PROCEDURE buscarproductoporid
    @id INT
AS
BEGIN
    SELECT id, clave, nombre, precioVenta FROM Productos WHERE id = @id;
END;

use POS
GO
-- 🧾 Procedimiento para insertar una venta y obtener el ID generado
CREATE OR ALTER PROCEDURE proc_InsertarVenta
    @fecha DATETIME,
    @total DECIMAL(10,2),
    @idVenta INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO ventas (fecha, total)
        VALUES (@fecha, @total);

        SET @idVenta = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        RAISERROR('Error al insertar la venta.', 16, 1);
    END CATCH
END;
GO


-- 📦 Procedimiento para insertar un producto relacionado con una venta
USE POS
GO
CREATE PROCEDURE proc_InsertarDetalleVenta
    @idVenta INT,
    @idProducto INT,
    @cantidad INT,
    @precioUnitario DECIMAL(10,2),
    @importe DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO venta_detalle (idVenta, idProducto, cantidad, precioUnitario, importe)
        VALUES (@idVenta, @idProducto, @cantidad, @precioUnitario, @importe);
    END TRY
    BEGIN CATCH
        DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('❌ Detalle de venta falló: %s', 16, 1, @msg);
    END CATCH

IF OBJECT_ID('venta_detalle', 'U') IS NOT NULL DROP TABLE venta_detalle;
GO
IF OBJECT_ID('ventas', 'U') IS NOT NULL DROP TABLE ventas;
GO
IF OBJECT_ID('productos', 'U') IS NOT NULL DROP TABLE productos;
GO

-- 🧺 Tabla productos
CREATE TABLE productos (
    idProducto INT PRIMARY KEY IDENTITY(1,1),
    clave NVARCHAR(20),
    nombre NVARCHAR(100),
    precioVenta DECIMAL(10,2)
);
GO

USE POS
GO
INSERT INTO productos (clave, nombre, precioVenta)
VALUES 
('A1', 'Pan', 50.00),
('A2', 'Agua', 15.00),
('A3', 'Coca Cola', 45.00);

SELECT * FROM productos;

-- 🧾 Tabla ventas
CREATE TABLE ventas (
    idVenta INT PRIMARY KEY IDENTITY(1,1),
    fecha DATETIME NOT NULL,
    total DECIMAL(10,2) NOT NULL
);
GO

-- 📦 Tabla venta_detalle
CREATE TABLE venta_detalle (
    idDetalle INT PRIMARY KEY IDENTITY(1,1),
    idVenta INT NOT NULL,
    idProducto INT NOT NULL,
    cantidad INT NOT NULL,
    precioUnitario DECIMAL(10,2) NOT NULL,
    importe DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (idVenta) REFERENCES ventas(idVenta),
    FOREIGN KEY (idProducto) REFERENCES productos(idProducto)
);
GO


USE POS
GO
EXEC sp_helptext 'proc_BuscarIDPorClave';
EXEC sp_helptext 'proc_BuscarProductoPorID';
EXEC sp_helptext 'proc_BuscarUsuarioPorID';
EXEC sp_helptext 'proc_InsertarDetalleVenta';
EXEC sp_helptext 'proc_InsertarProductos';
EXEC sp_helptext 'proc_InsertarUsuarios';
EXEC sp_helptext 'proc_InsertarVenta';
EXEC sp_helptext 'proc_ObtenerVentasDelDia';
EXEC sp_helptext 'proc_ValidarLogin';


use pos 
go
SELECT name 
FROM sys.procedures 
ORDER BY name;




go
EXEC proc_InsertarDetalleVenta
    @idVenta = 5,
    @idProducto = 221,
    @cantidad = 1,
    @precioUnitario = 20,
    @importe = 20;

	Use POS
	GO SELECT idProducto, clave, nombre FROM productos;


	use POS
	GO
	CREATE PROCEDURE proc_ObtenerVentasDelDia
    @fecha DATE
AS
BEGIN
    SELECT 
        vd.cantidad,
        p.clave,
        p.nombre,
        (vd.cantidad * vd.precioUnitario) AS importe
    FROM venta_detalle vd
    INNER JOIN ventas v ON v.idVenta = vd.idVenta
    INNER JOIN productos p ON p.idProducto = vd.idProducto
    WHERE CAST(v.fecha AS DATE) = @fecha
END