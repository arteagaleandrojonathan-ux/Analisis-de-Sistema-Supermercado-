
CREATE DATABASE SUPERMERCADO_GRUPO;

USE SUPERMERCADO_GRUPO;

-- TABLAS PRINCIPALES
CREATE TABLE Rol_grupo (
    idRol CHAR(10) PRIMARY KEY NOT NULL, 
    Nombres VARCHAR(50) NOT NULL, 
    Rol VARCHAR(50) NOT NULL
);
CREATE TABLE ZONAS_grupo (
    idZona CHAR(10) PRIMARY KEY NOT NULL,
    Nombre VARCHAR(100) NOT NULL UNIQUE, 
    Estado VARCHAR(20) NOT NULL CHECK (Estado IN ('Activa', 'Inactiva')) -- Regla: Solo delivery en zonas activas
);
CREATE TABLE Categoria_grupo (
    idCategoria CHAR(10) PRIMARY KEY NOT NULL, 
    Nombre VARCHAR(50) NOT NULL
);
CREATE TABLE Marca_grupo (
    idMarca CHAR(10) PRIMARY KEY NOT NULL, 
    Nombre VARCHAR(50) NOT NULL
);
CREATE TABLE Proveedores_grupo (
    idProveedor CHAR(10) PRIMARY KEY NOT NULL, 
    Nombre VARCHAR(100) NOT NULL, 
    Razon VARCHAR(100) NOT NULL, 
    Telefono1 VARCHAR(15)NOT NULL,
    Telefono2 VARCHAR(15), 
    Telefono3 VARCHAR(15), 
    RUC VARCHAR(15) NOT NULL UNIQUE -- Regla: Proveedores identificados y únicos
);
CREATE TABLE Tipo_Comprobante_grupo (
    idTipoComprobante CHAR(10) PRIMARY KEY NOT NULL,
    Nombre VARCHAR(50) NOT NULL
);
CREATE TABLE MetodoPago_grupo (
    idMetodoPago CHAR(10) PRIMARY KEY NOT NULL,
    Nombre VARCHAR(50) NOT NULL
);
CREATE TABLE TipoVenta_grupo (
    idTipoVenta CHAR(10) PRIMARY KEY NOT NULL, 
    Nombre VARCHAR(50) NOT NULL
);
CREATE TABLE Tarjeta_grupo (
    idTarjeta CHAR(10) PRIMARY KEY NOT NULL,
    Nombre VARCHAR(50) NOT NULL,
    Estado VARCHAR(20) CHECK (Estado IN ('Activa', 'Inactiva')),
    Descripcion VARCHAR(200)
);
CREATE TABLE Cliente_grupo (
    idCliente CHAR(10) PRIMARY KEY NOT NULL, 
    Nombre VARCHAR(100) NOT NULL, 
    TipoDOI VARCHAR(10) NOT NULL, 
    NumDOI VARCHAR(20) NOT NULL UNIQUE -- Regla: DNI/RUC debe ser único
);
CREATE TABLE CUPONES_grupo (
    idCupon CHAR(10) PRIMARY KEY NOT NULL,
    MontoFijo DECIMAL(10,2) DEFAULT 0,
    Porcentaje DECIMAL(5,2) DEFAULT 0,
    MinVenta DECIMAL(10,2) NOT NULL, -- Regla: Respetar mínimo de compra
    FechaExpiracion DATE NOT NULL, 
    UsoMaxi INT NOT NULL CHECK (UsoMaxi > 0),
    UsoActuales INT DEFAULT 0,
    Estado VARCHAR(20) CHECK (Estado IN ('Disponible', 'Agotado', 'Expirado')),
    
    CONSTRAINT CHK_LimitesCupon CHECK (UsoActuales <= UsoMaxi) -- Regla: Válido hasta límite requerido
);


-- TABLAS SECUNDARIAS 
CREATE TABLE Empleados_grupo (
    idEmpleado CHAR(10) PRIMARY KEY NOT NULL, 
    idRol CHAR(10) NOT NULL REFERENCES Rol_grupo(idRol),
    Nombre VARCHAR(100) NOT NULL, 
    Telefono VARCHAR(15) NOT NULL, 
    TipoDOI VARCHAR(10) NOT NULL, 
    NumDOI VARCHAR(20) NOT NULL UNIQUE, -- Regla: Empleado identificado con documento único
    Direccion VARCHAR(200), 
    Estado VARCHAR(20) NOT NULL CHECK (Estado IN ('Activo', 'Inactivo')) -- Regla: Define si puede operar


);
CREATE TABLE COORDENADAS_grupo (
    idCoordenada CHAR(10) PRIMARY KEY NOT NULL,
    idZona CHAR(10) NOT NULL REFERENCES ZONAS_grupo(idZona), -- Regla: Pertenece a una zona obligatoriamente
    Latitud VARCHAR(50) NOT NULL, -- Regla: Valores válidos de latitud y longitud
    Longitud VARCHAR(50) NOT NULL
);
CREATE TABLE Productos_grupo (
    idProducto CHAR(10) PRIMARY KEY NOT NULL,
    idMarca CHAR(10) REFERENCES Marca_grupo(idMarca),
    idCategoria CHAR(10) REFERENCES Categoria_grupo(idCategoria),
    Nombre VARCHAR(100) NOT NULL, 
    Precio DECIMAL(10,2) NOT NULL CHECK (Precio > 0), -- Regla: Precio mayor a 0
    Stockmax INT CHECK (Stockmax > 0), 
    StockMin INT DEFAULT 0, 
    StockActual INT DEFAULT 0 CHECK (StockActual >= 0) -- Regla: No vender sin stock
);
CREATE TABLE Cliente_Tarjeta_grupo (
    idClienteTarjeta CHAR(10) PRIMARY KEY NOT NULL,
    idCliente CHAR(10) NOT NULL REFERENCES Cliente_grupo(idCliente),
    idTarjeta CHAR(10) NOT NULL REFERENCES Tarjeta_grupo(idTarjeta)
);
CREATE TABLE Descuentos_grupo (
    idDescuento CHAR(10) PRIMARY KEY NOT NULL,
    idCategoria CHAR(10),
    idTarjeta CHAR(10),
    idCupon CHAR(10) ,
    Nombre VARCHAR(100),
    Valor DECIMAL(10,2) NOT NULL,
    FechaInicio DATE,
    FechaFin DATE,
    Estado VARCHAR(20),
    Tipo VARCHAR(50),
    
    FOREIGN KEY (idCategoria) REFERENCES Categoria_grupo(idCategoria),
    FOREIGN KEY (idTarjeta) REFERENCES Tarjeta_grupo(idTarjeta),
    FOREIGN KEY (idCupon) REFERENCES CUPONES_grupo(idCupon)
);


-- TABLAS TERCIARIAS 
CREATE TABLE SolicitudCompra_grupo (
    idSolicitud CHAR(10) PRIMARY KEY NOT NULL, 
    idEmpleado CHAR(10) NOT NULL REFERENCES Empleados_grupo(idEmpleado), -- Regla: Generada por un empleado
    Fecha DATE NOT NULL, 
    Motivo VARCHAR(200) NOT NULL, -- Regla: Motivo válido obligatorio
    Estado VARCHAR(20) NOT NULL CHECK (Estado IN ('Pendiente', 'Aprobada', 'Rechazada')) -- Regla: Refleja situación
    
);
CREATE TABLE Venta_grupo (
    idVenta CHAR(10) PRIMARY KEY NOT NULL, 
    idEmpleado CHAR(10) NOT NULL REFERENCES Empleados_grupo(idEmpleado), -- Regla: Iniciada por cajero
    idCliente CHAR(10) NOT NULL REFERENCES Cliente_grupo(idCliente),
    FechaVenta DATETIME , -- COLCADO MANUALMENTE SIMULA UNA FECHA 
    TotalFinal DECIMAL(10,2) NOT NULL CHECK (TotalFinal >= 0), 
    idTipoVenta CHAR(10) NOT NULL REFERENCES TipoVenta_grupo(idTipoVenta), 
    Estado VARCHAR(20) DEFAULT 'Completada', 
    TotalDsc DECIMAL(10,2) DEFAULT 0, 
    IGVTotal DECIMAL(10,2) NOT NULL
);
CREATE TABLE Promociones_grupo (
    idPromocion CHAR(10) PRIMARY KEY NOT NULL,
    idMarca CHAR(10) REFERENCES Marca_grupo(idMarca),
    idProducto CHAR(10) REFERENCES Productos_grupo(idProducto),
    idCategoria CHAR(10) REFERENCES Categoria_grupo(idCategoria),
    Nombre VARCHAR(100) NOT NULL,
    FechaInicio DATE ,
    FechaFin DATE ,
    LlevaCantidad INT CHECK (LlevaCantidad > 0),
    PagaCantidad INT CHECK (PagaCantidad > 0),
    Estado VARCHAR(20) ,
    
    CONSTRAINT ch_estado CHECK (Estado IN ('ACTIVO','INACTIVO','ANULADO'))
);
CREATE TABLE MERMA_grupo (
    idMerma CHAR(10) PRIMARY KEY NOT NULL,
    idProducto CHAR(10) NOT NULL REFERENCES Productos_grupo(idProducto), -- Regla: Producto específico
    idEmpleado CHAR(10) NOT NULL REFERENCES Empleados_grupo(idEmpleado), -- Regla: Empleado que detecta
    CantidadPerdida INT NOT NULL CHECK (CantidadPerdida > 0),
    MotivoMerma VARCHAR(200) NOT NULL,
    FechaHora DATETIME  -- COLCADO MANUALMENTE SIMULA UNA FECHA 
    
);
CREATE TABLE DescuentoAplicado_grupo (
    idDescuentoAplicado CHAR(10) PRIMARY KEY NOT NULL,
    idDescuento CHAR(10) NOT NULL,
    MontoDescuento DECIMAL(10,2) NOT NULL,
    
     FOREIGN KEY (idDescuento) REFERENCES Descuentos_grupo(idDescuento)
);


-- TABLAS CUATERNARIAS 
CREATE TABLE Compra_grupo (
    idCompra CHAR(10) PRIMARY KEY NOT NULL, 
    idProveedor CHAR(10) NOT NULL REFERENCES Proveedores_grupo(idProveedor), -- Regla: Proveedor registrado validado
    idSolicitud CHAR(10) NOT NULL REFERENCES SolicitudCompra_grupo(idSolicitud), -- Regla: Orden necesita solicitud validada previa
    Fecha DATE NOT NULL, 
    TotalCompra DECIMAL(10,2) NOT NULL CHECK (TotalCompra >= 0), 
    Estado VARCHAR(20) DEFAULT 'Aprobada', 
    NumeroFactura VARCHAR(20) UNIQUE NOT NULL
);
CREATE TABLE Pago_grupo (
    idPago CHAR(10) PRIMARY KEY NOT NULL,
    idVenta CHAR(10) NOT NULL REFERENCES Venta_grupo(idVenta), -- Regla: Todo pago asociado a una venta
    Monto DECIMAL(10,2) NOT NULL CHECK (Monto > 0),
    FechaPago DATETIME , -- COLCADO MANUALMENTE SIMULA UNA FECHA
    EstadoPago VARCHAR(20) NOT NULL CHECK (EstadoPago IN ('Exitoso', 'Fallido', 'Cancelado'))
    
);
CREATE TABLE Comprobante_grupo (
    IdComprobante CHAR(10) PRIMARY KEY NOT NULL,
	idVenta CHAR(10) NOT NULL UNIQUE REFERENCES Venta_grupo(idVenta), -- Regla: Asociado a venta y solo 1 por venta
    idTipoComprobante CHAR(10) NOT NULL REFERENCES Tipo_Comprobante_grupo(idTipoComprobante),
    Numero VARCHAR(50) NOT NULL UNIQUE, -- Regla: Número de comprobante único
    Fecha DATE NOT NULL,
    Total DECIMAL(10,2) NOT NULL CHECK (Total >= 0)

);
CREATE TABLE Detalle_Venta_grupo (
    idDetalleVenta CHAR(10) PRIMARY KEY NOT NULL, 
    idVenta CHAR(10) NOT NULL REFERENCES Venta_grupo(idVenta), 
    idProducto CHAR(10) NOT NULL REFERENCES Productos_grupo(idProducto), -- Regla: Producto debe existir
	idDescuentoAplicado CHAR(10) REFERENCES DescuentoAplicado_grupo(idDescuentoAplicado), 
    Cantidad INT NOT NULL CHECK (Cantidad > 0), -- Regla: Cantidad > 0
    PrecioVentaTotal DECIMAL(10,2) NOT NULL, 
    MontoIGV DECIMAL(10,2) NOT NULL
);
CREATE TABLE Devolucion_grupo (
    idDevolucion CHAR(10) PRIMARY KEY NOT NULL, 
	idVenta CHAR(10) NOT NULL REFERENCES Venta_grupo(idVenta), -- Regla: Vinculado a Venta registrada
    FechaHora DATETIME , -- COLCOADO MANUALMENTE SIMULA UNA FECHA
    TipoOperacion VARCHAR(50) NOT NULL CHECK (TipoOperacion IN ('Reembolso', 'Cambio')), -- Regla: Diferenciar claramente
    Estado VARCHAR(20) DEFAULT 'Aprobada', 
    TotalReempbloso DECIMAL(10,2) NOT NULL CHECK (TotalReempbloso >= 0)
);
CREATE TABLE DELIVERY_grupo (
    idDelivery CHAR(10) PRIMARY KEY NOT NULL,
    idVenta CHAR(10) NOT NULL REFERENCES Venta_grupo(idVenta), 
    idEmpleado CHAR(10) REFERENCES Empleados_grupo(idEmpleado), 
    idCoordenada CHAR(10) NOT NULL REFERENCES COORDENADAS_grupo(idCoordenada), -- Regla: Validar por GPS obligatorio
    DireccionEnvio VARCHAR(200) NOT NULL,
    FechaHoraSalida DATETIME,
    FechaHoraEntrega DATETIME,
    Estado VARCHAR(20) DEFAULT 'Pendiente'
);
CREATE TABLE PromocionAplicada_grupo (
    idPromocionAplicada CHAR(10) PRIMARY KEY NOT NULL,
    idPromocion CHAR(10) NOT NULL, 
    idDetalleVenta CHAR(10) NOT NULL,

    FOREIGN KEY (idPromocion) REFERENCES Promociones_grupo(idPromocion),
    FOREIGN KEY (idDetalleVenta) REFERENCES Detalle_Venta_grupo(idDetalleVenta)
);


-- TABLAS QUINTENARIAS 
CREATE TABLE Detalle_compra_grupo (
    idDetalleCompra CHAR(10) PRIMARY KEY NOT NULL, 
    idCompra CHAR(10) NOT NULL REFERENCES Compra_grupo(idCompra), 
    idProducto CHAR(10) NOT NULL REFERENCES Productos_grupo(idProducto), 
    Cantidad INT NOT NULL CHECK (Cantidad > 0), 
    PrecioCompra DECIMAL(10,2) NOT NULL
);
CREATE TABLE DetallePago_grupo (
    idDetallePago CHAR(10) PRIMARY KEY NOT NULL,
    idMetodoPago CHAR(10) NOT NULL REFERENCES MetodoPago_grupo(idMetodoPago), 
    idPago CHAR(10) NOT NULL REFERENCES Pago_grupo(idPago), 
    idTarjeta CHAR(10) REFERENCES Tarjeta_grupo(idTarjeta),
    Montototal DECIMAL(10,2) NOT NULL
);
CREATE TABLE Detalle_Devolucion_grupo (
    idDetalleDevolucion CHAR(10) PRIMARY KEY NOT NULL, 
    idDetalleVenta CHAR(10) NOT NULL, 
    idDevolucion CHAR(10) NOT NULL, 
    idProductoNuevo CHAR(10) , -- Regla: Qué producto nuevo se lleva
    CantidadDevuelta INT NOT NULL CHECK (CantidadDevuelta > 0), -- Regla: Cantidad > 0
    Motivo VARCHAR(100) NOT NULL,
    
    FOREIGN KEY (idDetalleVenta) REFERENCES Detalle_Venta_grupo(idDetalleVenta),
    FOREIGN KEY (idDevolucion) REFERENCES Devolucion_grupo(idDevolucion),
    FOREIGN KEY (idProductoNuevo) REFERENCES Productos_grupo(idProducto)
);


-- TABLAS SEXTENARIAS 
CREATE TABLE MovimientoStock_grupo (
    idMovimientoStock CHAR(10) PRIMARY KEY NOT NULL,
    idProducto CHAR(10) NOT NULL REFERENCES Productos_grupo(idProducto), -- Regla: Asociado a un producto
    idVenta CHAR(10) REFERENCES Venta_grupo(idVenta), 
    idCompra CHAR(10) REFERENCES Compra_grupo(idCompra), 
    idMerma CHAR(10) REFERENCES MERMA_grupo(idMerma), 
    idDevolucion CHAR(10) REFERENCES Devolucion_grupo(idDevolucion),
    Tipo VARCHAR(20) NOT NULL CHECK (Tipo IN ('Entrada', 'Salida')), -- Regla: Entrada o salida
    Cantidad INT NOT NULL CHECK (Cantidad > 0), -- Regla: Mayor a cero
    Fecha DATETIME  -- COLCOADO MANUALMENTE SIMULA UNA FECHA
    
    -- Lógica implícita: Al menos un campo de referencia debe tener valor dependiendo del Tipo, se maneja usualmente por Trigger.
);



-- NIVEL 1: TABLAS PRINCIPALES 

-- ROLES
INSERT INTO Rol_grupo VALUES ('ROL0000001', 'Administrador General', 'Admin');
INSERT INTO Rol_grupo VALUES ('ROL0000002', 'Cajero de Tienda', 'Cajero');
INSERT INTO Rol_grupo VALUES ('ROL0000003', 'Repartidor Web', 'Delivery');
INSERT INTO Rol_grupo VALUES ('ROL0000004', 'Jefe de Almacén', 'Almacen');

-- ZONAS
INSERT INTO ZONAS_grupo VALUES ('ZON0000001', 'San Juan de Lurigancho', 'Activa');
INSERT INTO ZONAS_grupo VALUES ('ZON0000002', 'Santiago de Surco', 'Activa');
INSERT INTO ZONAS_grupo VALUES ('ZON0000003', 'Callao', 'Inactiva'); -- No permite delivery
INSERT INTO ZONAS_grupo VALUES ('ZON0000004', 'Miraflores', 'Activa');
INSERT INTO ZONAS_grupo VALUES ('ZON0000005', 'Comas', 'Activa');

-- CATEGORÍAS
INSERT INTO Categoria_grupo VALUES ('CAT0000001', 'Abarrotes');
INSERT INTO Categoria_grupo VALUES ('CAT0000002', 'Lácteos');
INSERT INTO Categoria_grupo VALUES ('CAT0000003', 'Limpieza');
INSERT INTO Categoria_grupo VALUES ('CAT0000004', 'Bebidas');
INSERT INTO Categoria_grupo VALUES ('CAT0000005', 'Carnes y Aves');
INSERT INTO Categoria_grupo VALUES ('CAT0000006', 'Snacks');
INSERT INTO Categoria_grupo VALUES ('CAT0000007', 'Panadería');

-- MARCAS
INSERT INTO Marca_grupo VALUES ('MAR0000001', 'Costeño');
INSERT INTO Marca_grupo VALUES ('MAR0000002', 'Gloria');
INSERT INTO Marca_grupo VALUES ('MAR0000003', 'Clorox');
INSERT INTO Marca_grupo VALUES ('MAR0000004', 'Coca Cola');
INSERT INTO Marca_grupo VALUES ('MAR0000005', 'San Fernando');
INSERT INTO Marca_grupo VALUES ('MAR0000006', 'Inca Kola');
INSERT INTO Marca_grupo VALUES ('MAR0000007', 'Lays');
INSERT INTO Marca_grupo VALUES ('MAR0000008', 'Bimbo');

-- PROVEEDORES
INSERT INTO Proveedores_grupo VALUES ('PRV0000001', 'Alicorp SAA', 'Alicorp Peru S.A.', '01-444555', '01-444556', NULL, '20100055566');
INSERT INTO Proveedores_grupo VALUES ('PRV0000002', 'Gloria SA', 'Leche Gloria S.A.', '01-999888', NULL, NULL, '20100123456');
INSERT INTO Proveedores_grupo VALUES ('PRV0000003', 'San Fernando', 'San Fernando S.A.', '01-777666', NULL, NULL, '20100778899');
INSERT INTO Proveedores_grupo VALUES ('PRV0000004', 'Corporacion Lindley', 'Lindley S.A.', '01-555222', NULL, NULL, '20100333444');

-- TIPO COMPROBANTE
INSERT INTO Tipo_Comprobante_grupo VALUES ('TCP0000001', 'Boleta Electrónica');
INSERT INTO Tipo_Comprobante_grupo VALUES ('TCP0000002', 'Factura Electrónica');

-- MÉTODO DE PAGO
INSERT INTO MetodoPago_grupo VALUES ('MPG0000001', 'Tarjeta de Crédito / Débito');
INSERT INTO MetodoPago_grupo VALUES ('MPG0000002', 'Efectivo');
INSERT INTO MetodoPago_grupo VALUES ('MPG0000003', 'Billetera Digital (Yape/Plin)');

-- TIPO VENTA
INSERT INTO TipoVenta_grupo VALUES ('TPV0000001', 'Venta Presencial');
INSERT INTO TipoVenta_grupo VALUES ('TPV0000002', 'Venta Web (Delivery)');

-- TARJETAS
INSERT INTO Tarjeta_grupo VALUES ('TAR0000001', 'Tarjeta Oh!', 'Activa', 'Tarjeta afiliada');
INSERT INTO Tarjeta_grupo VALUES ('TAR0000002', 'Cencosud', 'Inactiva', 'Bloqueada');
INSERT INTO Tarjeta_grupo VALUES ('TAR0000003', 'CMR Falabella', 'Activa', 'Tarjeta de credito externa');

-- CLIENTES (Diversos)
INSERT INTO Cliente_grupo VALUES ('CLI0000001', 'Emerson Arteaga', 'DNI', '77788899');
INSERT INTO Cliente_grupo VALUES ('CLI0000002', 'Mario Bautista', 'DNI', '11122233');
INSERT INTO Cliente_grupo VALUES ('CLI0000003', 'Tatiana Cuzcano', 'DNI', '44455566');
INSERT INTO Cliente_grupo VALUES ('CLI0000004', 'Andrea Guerra', 'DNI', '99988877');
INSERT INTO Cliente_grupo VALUES ('CLI0000005', 'Empresa Tech SAC', 'RUC', '20555444333');
INSERT INTO Cliente_grupo VALUES ('CLI0000006', 'Constructora A&B', 'RUC', '20888999111');
INSERT INTO Cliente_grupo VALUES ('CLI0000007', 'Juan Perez', 'DNI', '12345678');

-- CUPONES (Disponibles, Agotados, Expirados)
INSERT INTO CUPONES_grupo VALUES ('CUP0000001', 15.00, 0.00, 50.00, '2026-12-31', 100, 5, 'Disponible');
INSERT INTO CUPONES_grupo VALUES ('CUP0000002', 0.00, 10.00, 20.00, '2025-01-01', 50, 50, 'Agotado');
INSERT INTO CUPONES_grupo VALUES ('CUP0000003', 5.00, 0.00, 10.00, '2026-10-15', 200, 199, 'Disponible');
INSERT INTO CUPONES_grupo VALUES ('CUP0000004', 0.00, 20.00, 100.00, '2026-02-28', 500, 100, 'Expirado');



-- NIVEL 2: TABLAS SECUNDARIAS

-- EMPLEADOS (Más repartidores, cajeros)
INSERT INTO Empleados_grupo VALUES ('EMP0000001', 'ROL0000002', 'Ana Lopez', '999111222', 'DNI', '10203040', 'SJL', 'Activo'); -- Cajero
INSERT INTO Empleados_grupo VALUES ('EMP0000002', 'ROL0000002', 'Carlos Ruiz', '999333444', 'DNI', '88776655', 'Surco', 'Activo'); -- Cajero
INSERT INTO Empleados_grupo VALUES ('EMP0000003', 'ROL0000003', 'Luis Moto', '987654321', 'DNI', '88889999', 'SJL', 'Activo'); -- Repartidor 1
INSERT INTO Empleados_grupo VALUES ('EMP0000004', 'ROL0000003', 'Pedro Bici', '911111111', 'DNI', '77776666', 'Miraflores', 'Activo'); -- Repartidor 2
INSERT INTO Empleados_grupo VALUES ('EMP0000005', 'ROL0000003', 'Jorge Auto', '922222222', 'DNI', '55554444', 'Surco', 'Activo'); -- Repartidor 3
INSERT INTO Empleados_grupo VALUES ('EMP0000006', 'ROL0000003', 'Miguel Falla', '933333333', 'DNI', '33332222', 'Callao', 'Inactivo'); -- Repartidor 4 (Inactivo)
INSERT INTO Empleados_grupo VALUES ('EMP0000007', 'ROL0000001', 'Sofia Jefa', '944444444', 'DNI', '11110000', 'San Isidro', 'Activo'); -- Admin
INSERT INTO Empleados_grupo VALUES ('EMP0000008', 'ROL0000004', 'Raul Almacen', '955555555', 'DNI', '99998888', 'Comas', 'Activo'); -- Almacen

-- COORDENADAS (Varias por zona para simular distintos domicilios)
INSERT INTO COORDENADAS_grupo VALUES ('COR0000001', 'ZON0000001', '-11.987654', '-77.012345'); -- SJL Cliente 1
INSERT INTO COORDENADAS_grupo VALUES ('COR0000002', 'ZON0000001', '-11.990000', '-77.015000'); -- SJL Cliente 2
INSERT INTO COORDENADAS_grupo VALUES ('COR0000003', 'ZON0000002', '-12.143180', '-77.028240'); -- Surco 1
INSERT INTO COORDENADAS_grupo VALUES ('COR0000004', 'ZON0000002', '-12.150000', '-77.030000'); -- Surco 2
INSERT INTO COORDENADAS_grupo VALUES ('COR0000005', 'ZON0000004', '-12.120000', '-77.035000'); -- Miraflores
INSERT INTO COORDENADAS_grupo VALUES ('COR0000006', 'ZON0000005', '-11.930000', '-77.045000'); -- Comas

-- PRODUCTOS (15 Productos cruzando Categorías y Marcas)
INSERT INTO Productos_grupo VALUES ('PRO0000001', 'MAR0000001', 'CAT0000001', 'Arroz Extra 1kg', 4.50, 1000, 50, 450);
INSERT INTO Productos_grupo VALUES ('PRO0000002', 'MAR0000001', 'CAT0000001', 'Azúcar Rubia 1kg', 3.20, 800, 50, 300);
INSERT INTO Productos_grupo VALUES ('PRO0000003', 'MAR0000002', 'CAT0000002', 'Leche Evaporada', 3.80, 500, 20, 200);
INSERT INTO Productos_grupo VALUES ('PRO0000004', 'MAR0000002', 'CAT0000002', 'Yogurt Fresa 1L', 6.50, 300, 15, 120);
INSERT INTO Productos_grupo VALUES ('PRO0000005', 'MAR0000003', 'CAT0000003', 'Lejía Clásica 1L', 2.50, 300, 10, 150);
INSERT INTO Productos_grupo VALUES ('PRO0000006', 'MAR0000004', 'CAT0000004', 'Coca Cola 3L', 11.00, 400, 30, 250);
INSERT INTO Productos_grupo VALUES ('PRO0000007', 'MAR0000006', 'CAT0000004', 'Inca Kola 3L', 10.50, 400, 30, 280);
INSERT INTO Productos_grupo VALUES ('PRO0000008', 'MAR0000005', 'CAT0000005', 'Pollo Entero x Kg', 8.50, 200, 20, 80);
INSERT INTO Productos_grupo VALUES ('PRO0000009', 'MAR0000005', 'CAT0000005', 'Hot Dog de Pollo', 12.00, 150, 10, 60);
INSERT INTO Productos_grupo VALUES ('PRO0000010', 'MAR0000007', 'CAT0000006', 'Papas Lays Clásica', 4.00, 500, 40, 300);
INSERT INTO Productos_grupo VALUES ('PRO0000011', 'MAR0000007', 'CAT0000006', 'Doritos Queso', 4.50, 500, 40, 250);
INSERT INTO Productos_grupo VALUES ('PRO0000012', 'MAR0000008', 'CAT0000007', 'Pan Blanco Integral', 7.50, 100, 10, 45);
INSERT INTO Productos_grupo VALUES ('PRO0000013', 'MAR0000008', 'CAT0000007', 'Pan de Molde Blanco', 6.50, 150, 15, 80);
INSERT INTO Productos_grupo VALUES ('PRO0000014', 'MAR0000001', 'CAT0000001', 'Fideos Spaghetti 500g', 2.50, 600, 50, 400);
INSERT INTO Productos_grupo VALUES ('PRO0000015', 'MAR0000003', 'CAT0000003', 'Detergente Polvo 1kg', 14.00, 200, 20, 90);

-- CLIENTE_TARJETA
INSERT INTO Cliente_Tarjeta_grupo VALUES ('CLT0000001', 'CLI0000001', 'TAR0000001');
INSERT INTO Cliente_Tarjeta_grupo VALUES ('CLT0000002', 'CLI0000002', 'TAR0000003');
INSERT INTO Cliente_Tarjeta_grupo VALUES ('CLT0000003', 'CLI0000004', 'TAR0000001');

-- DESCUENTOS
INSERT INTO Descuentos_grupo VALUES ('DSC0000001', 'CAT0000001', NULL, NULL, 'Abarrotes Fest', 2.00, '2026-04-01', '2026-04-30', 'Activo', 'Monto');
INSERT INTO Descuentos_grupo VALUES ('DSC0000002', NULL, 'TAR0000001', NULL, 'Promo Tarjeta Oh!', 10.00, '2026-01-01', '2026-12-31', 'Activo', 'Porcentaje');



-- NIVEL 3: TABLAS TERCIARIAS

-- SOLICITUD COMPRA
INSERT INTO SolicitudCompra_grupo VALUES ('SOL0000001', 'EMP0000008', '2026-04-10', 'Reabastecimiento semanal abarrotes', 'Aprobada');
INSERT INTO SolicitudCompra_grupo VALUES ('SOL0000002', 'EMP0000008', '2026-04-12', 'Exceso de stock preventivo lácteos', 'Rechazada');
INSERT INTO SolicitudCompra_grupo VALUES ('SOL0000003', 'EMP0000008', '2026-04-15', 'Campaña bebidas', 'Aprobada');

-- VENTAS (10 Ventas: 4 Presenciales, 6 Delivery)
INSERT INTO Venta_grupo VALUES ('VEN0000001', 'EMP0000001', 'CLI0000001', '2026-04-20 10:00:00', 45.00, 'TPV0000001', 'Completada', 2.00, 8.10); -- Presencial Exitoso
INSERT INTO Venta_grupo VALUES ('VEN0000002', 'EMP0000002', 'CLI0000002', '2026-04-20 11:30:00', 78.50, 'TPV0000002', 'Completada', 0.00, 14.13); -- Web Exitoso
INSERT INTO Venta_grupo VALUES ('VEN0000003', 'EMP0000001', 'CLI0000005', '2026-04-20 12:15:00', 150.00, 'TPV0000002', 'Cancelada', 0.00, 27.00); -- Web Fallida (Pago o Delivery)
INSERT INTO Venta_grupo VALUES ('VEN0000004', 'EMP0000002', 'CLI0000003', '2026-04-21 09:00:00', 25.00, 'TPV0000001', 'Completada', 0.00, 4.50); -- Presencial Exitoso
INSERT INTO Venta_grupo VALUES ('VEN0000005', 'EMP0000001', 'CLI0000004', '2026-04-21 15:45:00', 120.00, 'TPV0000002', 'Completada', 12.00, 21.60); -- Web Exitoso con Dscto Tarjeta
INSERT INTO Venta_grupo VALUES ('VEN0000006', 'EMP0000002', 'CLI0000006', '2026-04-22 10:00:00', 350.00, 'TPV0000002', 'Completada', 0.00, 63.00); -- Web Factura
INSERT INTO Venta_grupo VALUES ('VEN0000007', 'EMP0000001', 'CLI0000007', '2026-04-22 13:20:00', 15.50, 'TPV0000001', 'Completada', 0.00, 2.79); -- Presencial Rápido
INSERT INTO Venta_grupo VALUES ('VEN0000008', 'EMP0000002', 'CLI0000001', '2026-04-23 18:00:00', 88.00, 'TPV0000002', 'En Proceso', 0.00, 15.84); -- Web Pendiente
INSERT INTO Venta_grupo VALUES ('VEN0000009', 'EMP0000001', 'CLI0000002', '2026-04-24 19:30:00', 65.00, 'TPV0000002', 'Completada', 0.00, 11.70); -- Web Exitoso
INSERT INTO Venta_grupo VALUES ('VEN0000010', 'EMP0000002', 'CLI0000003', '2026-04-25 08:10:00', 42.00, 'TPV0000001', 'Completada', 0.00, 7.56); -- Presencial

-- PROMOCIONES
INSERT INTO Promociones_grupo VALUES ('PRM0000001', 'MAR0000001', 'PRO0000014', 'CAT0000001', 'Lleva 3 Paga 2 Fideos', '2026-04-01', '2026-04-30', 3, 2, 'ACTIVO');
INSERT INTO Promociones_grupo VALUES ('PRM0000002', 'MAR0000007', 'PRO0000010', 'CAT0000006', 'Lleva 2 Paga 1 Papas', '2026-04-15', '2026-04-25', 2, 1, 'ACTIVO');

-- MERMA (Varios tipos)
INSERT INTO MERMA_grupo VALUES ('MRM0000001', 'PRO0000003', 'EMP0000008', 5, 'Latas golpeadas en almacén', '2026-04-14 08:00:00');
INSERT INTO MERMA_grupo VALUES ('MRM0000002', 'PRO0000012', 'EMP0000001', 3, 'Pan expirado en vitrina', '2026-04-18 20:00:00');
INSERT INTO MERMA_grupo VALUES ('MRM0000003', 'PRO0000008', 'EMP0000008', 2, 'Pérdida cadena de frío', '2026-04-20 07:00:00');

-- DESCUENTO APLICADO
INSERT INTO DescuentoAplicado_grupo VALUES ('DSA0000001', 'DSC0000001', 2.00); -- Fijo en abarrotes
INSERT INTO DescuentoAplicado_grupo VALUES ('DSA0000002', 'DSC0000002', 12.00); -- 10% Tarjeta Oh!



-- NIVEL 4: TABLAS CUATERNARIAS

-- COMPRA
INSERT INTO Compra_grupo VALUES ('COM0000001', 'PRV0000001', 'SOL0000001', '2026-04-11', 2250.00, 'Aprobada', 'F001-9988');
INSERT INTO Compra_grupo VALUES ('COM0000002', 'PRV0000004', 'SOL0000003', '2026-04-16', 3000.00, 'Aprobada', 'F002-1122');

-- PAGOS (Varios escenarios: éxitos, fallos, reintentos)
INSERT INTO Pago_grupo VALUES ('PAG0000001', 'VEN0000001', 45.00, '2026-04-20 10:02:00', 'Exitoso');
INSERT INTO Pago_grupo VALUES ('PAG0000002', 'VEN0000002', 78.50, '2026-04-20 11:32:00', 'Fallido'); -- Rebotó tarjeta
INSERT INTO Pago_grupo VALUES ('PAG0000003', 'VEN0000002', 78.50, '2026-04-20 11:35:00', 'Exitoso'); -- Reintento exitoso
INSERT INTO Pago_grupo VALUES ('PAG0000004', 'VEN0000003', 150.00, '2026-04-20 12:16:00', 'Exitoso'); -- Pago bien, delivery fallará
INSERT INTO Pago_grupo VALUES ('PAG0000005', 'VEN0000004', 25.00, '2026-04-21 09:02:00', 'Exitoso');
INSERT INTO Pago_grupo VALUES ('PAG0000006', 'VEN0000005', 120.00, '2026-04-21 15:47:00', 'Exitoso');
INSERT INTO Pago_grupo VALUES ('PAG0000007', 'VEN0000006', 350.00, '2026-04-22 10:05:00', 'Exitoso');
INSERT INTO Pago_grupo VALUES ('PAG0000008', 'VEN0000007', 15.50, '2026-04-22 13:21:00', 'Exitoso');
INSERT INTO Pago_grupo VALUES ('PAG0000009', 'VEN0000008', 88.00, '2026-04-23 18:02:00', 'Cancelado'); -- Canceló antes de pagar
INSERT INTO Pago_grupo VALUES ('PAG0000010', 'VEN0000009', 65.00, '2026-04-24 19:32:00', 'Exitoso');
INSERT INTO Pago_grupo VALUES ('PAG0000011', 'VEN0000010', 42.00, '2026-04-25 08:12:00', 'Exitoso');

-- COMPROBANTES (Omitimos Venta 3 y 8 porque fallaron/cancelaron, regla de negocio)
INSERT INTO Comprobante_grupo VALUES ('CPB0000001', 'VEN0000001', 'TCP0000001', 'B001-000111', '2026-04-20', 45.00);
INSERT INTO Comprobante_grupo VALUES ('CPB0000002', 'VEN0000002', 'TCP0000001', 'B001-000112', '2026-04-20', 78.50);
INSERT INTO Comprobante_grupo VALUES ('CPB0000003', 'VEN0000004', 'TCP0000001', 'B001-000113', '2026-04-21', 25.00);
INSERT INTO Comprobante_grupo VALUES ('CPB0000004', 'VEN0000005', 'TCP0000001', 'B001-000114', '2026-04-21', 120.00);
INSERT INTO Comprobante_grupo VALUES ('CPB0000005', 'VEN0000006', 'TCP0000002', 'F001-000055', '2026-04-22', 350.00); -- Factura corporativa
INSERT INTO Comprobante_grupo VALUES ('CPB0000006', 'VEN0000007', 'TCP0000001', 'B001-000115', '2026-04-22', 15.50);
INSERT INTO Comprobante_grupo VALUES ('CPB0000007', 'VEN0000009', 'TCP0000001', 'B001-000116', '2026-04-24', 65.00);
INSERT INTO Comprobante_grupo VALUES ('CPB0000008', 'VEN0000010', 'TCP0000001', 'B001-000117', '2026-04-25', 42.00);

-- DETALLE VENTA
INSERT INTO Detalle_Venta_grupo VALUES ('DTV0000001', 'VEN0000001', 'PRO0000001', 'DSA0000001', 10, 43.00, 7.74); 
INSERT INTO Detalle_Venta_grupo VALUES ('DTV0000002', 'VEN0000002', 'PRO0000006', NULL, 5, 55.00, 9.90);
INSERT INTO Detalle_Venta_grupo VALUES ('DTV0000003', 'VEN0000002', 'PRO0000010', NULL, 6, 23.50, 4.23); 
INSERT INTO Detalle_Venta_grupo VALUES ('DTV0000004', 'VEN0000003', 'PRO0000015', NULL, 10, 150.00, 27.00);
INSERT INTO Detalle_Venta_grupo VALUES ('DTV0000005', 'VEN0000004', 'PRO0000003', NULL, 6, 25.00, 4.50);
INSERT INTO Detalle_Venta_grupo VALUES ('DTV0000006', 'VEN0000005', 'PRO0000008', 'DSA0000002', 14, 120.00, 21.60); -- Con Dscnt Tarjeta
INSERT INTO Detalle_Venta_grupo VALUES ('DTV0000007', 'VEN0000006', 'PRO0000005', NULL, 140, 350.00, 63.00);
INSERT INTO Detalle_Venta_grupo VALUES ('DTV0000008', 'VEN0000007', 'PRO0000012', NULL, 2, 15.50, 2.79);
INSERT INTO Detalle_Venta_grupo VALUES ('DTV0000009', 'VEN0000008', 'PRO0000006', NULL, 8, 88.00, 15.84);
INSERT INTO Detalle_Venta_grupo VALUES ('DTV0000010', 'VEN0000009', 'PRO0000014', NULL, 26, 65.00, 11.70);
INSERT INTO Detalle_Venta_grupo VALUES ('DTV0000011', 'VEN0000010', 'PRO0000004', NULL, 6, 42.00, 7.56);

-- DEVOLUCION (1 Cambio y 1 Reembolso por entrega fallida)
INSERT INTO Devolucion_grupo VALUES ('DEV0000001', 'VEN0000001', '2026-04-20 11:00:00', 'Cambio', 'Aprobada', 4.50);
INSERT INTO Devolucion_grupo VALUES ('DEV0000002', 'VEN0000003', '2026-04-20 14:00:00', 'Reembolso', 'Aprobada', 150.00); -- Delivery Fallido se devuelve dinero

-- DELIVERY (Ventas Web: V2, V3, V5, V6, V8, V9)
INSERT INTO DELIVERY_grupo VALUES ('DEL0000001', 'VEN0000002', 'EMP0000003', 'COR0000001', 'Av. Flores 123', '2026-04-20 12:00:00', '2026-04-20 12:45:00', 'Entregado');
INSERT INTO DELIVERY_grupo VALUES ('DEL0000002', 'VEN0000003', 'EMP0000004', 'COR0000003', 'Jr. La Union 444', '2026-04-20 13:00:00', NULL, 'Fallido'); -- Cliente no salió, se cancela y reembolsa
INSERT INTO DELIVERY_grupo VALUES ('DEL0000003', 'VEN0000005', 'EMP0000005', 'COR0000004', 'Calle 5 Surco', '2026-04-21 16:30:00', '2026-04-21 17:10:00', 'Entregado');
INSERT INTO DELIVERY_grupo VALUES ('DEL0000004', 'VEN0000006', 'EMP0000003', 'COR0000002', 'Obra SJL MZ A', '2026-04-22 11:00:00', '2026-04-22 11:50:00', 'Entregado');
INSERT INTO DELIVERY_grupo VALUES ('DEL0000005', 'VEN0000008', NULL, 'COR0000005', 'Av. Larco 99', NULL, NULL, 'Pendiente'); -- Pago cancelado, no salió el delivery
INSERT INTO DELIVERY_grupo VALUES ('DEL0000006', 'VEN0000009', 'EMP0000004', 'COR0000001', 'Av. Flores 456', '2026-04-24 20:00:00', '2026-04-24 20:30:00', 'Entregado');

-- PROMOCION APLICADA
INSERT INTO PromocionAplicada_grupo VALUES ('PRA0000001', 'PRM0000002', 'DTV0000003'); -- Promo de papas Lays



-- NIVEL 5: TABLAS QUINTENARIAS

-- DETALLE COMPRA
INSERT INTO Detalle_compra_grupo VALUES ('DTC0000001', 'COM0000001', 'PRO0000001', 300, 1350.00);
INSERT INTO Detalle_compra_grupo VALUES ('DTC0000002', 'COM0000001', 'PRO0000014', 360, 900.00);
INSERT INTO Detalle_compra_grupo VALUES ('DTC0000003', 'COM0000002', 'PRO0000006', 150, 1650.00);
INSERT INTO Detalle_compra_grupo VALUES ('DTC0000004', 'COM0000002', 'PRO0000007', 128, 1350.00);

-- DETALLE PAGO
INSERT INTO DetallePago_grupo VALUES ('DTP0000001', 'MPG0000002', 'PAG0000001', NULL, 45.00);
INSERT INTO DetallePago_grupo VALUES ('DTP0000002', 'MPG0000001', 'PAG0000002', 'TAR0000001', 78.50); -- Fallido inicial
INSERT INTO DetallePago_grupo VALUES ('DTP0000003', 'MPG0000001', 'PAG0000003', 'TAR0000001', 78.50); -- Reintento Ok
INSERT INTO DetallePago_grupo VALUES ('DTP0000004', 'MPG0000003', 'PAG0000004', NULL, 150.00); -- Yape
INSERT INTO DetallePago_grupo VALUES ('DTP0000005', 'MPG0000002', 'PAG0000005', NULL, 25.00);
INSERT INTO DetallePago_grupo VALUES ('DTP0000006', 'MPG0000001', 'PAG0000006', 'TAR0000001', 120.00);
INSERT INTO DetallePago_grupo VALUES ('DTP0000007', 'MPG0000003', 'PAG0000007', NULL, 350.00); -- Plin
INSERT INTO DetallePago_grupo VALUES ('DTP0000008', 'MPG0000002', 'PAG0000008', NULL, 15.50);
INSERT INTO DetallePago_grupo VALUES ('DTP0000009', 'MPG0000001', 'PAG0000010', 'TAR0000003', 65.00);
INSERT INTO DetallePago_grupo VALUES ('DTP0000010', 'MPG0000002', 'PAG0000011', NULL, 42.00);

-- DETALLE DEVOLUCION
INSERT INTO Detalle_Devolucion_grupo VALUES ('DTD0000001', 'DTV0000001', 'DEV0000001', 'PRO0000001', 1, 'Empaque roto en caja'); -- Cambio
INSERT INTO Detalle_Devolucion_grupo VALUES ('DTD0000002', 'DTV0000004', 'DEV0000002', NULL, 10, 'Delivery fallido, cliente ausente'); -- Reembolso total



-- NIVEL 6: TABLAS SEXTENARIAS (Log de Movimientos de Stock)

-- ENTRADAS POR COMPRAS
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000001', 'PRO0000001', NULL, 'COM0000001', NULL, NULL, 'Entrada', 300, '2026-04-11 10:00:00');
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000002', 'PRO0000014', NULL, 'COM0000001', NULL, NULL, 'Entrada', 360, '2026-04-11 10:00:00');
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000003', 'PRO0000006', NULL, 'COM0000002', NULL, NULL, 'Entrada', 150, '2026-04-16 10:00:00');
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000004', 'PRO0000007', NULL, 'COM0000002', NULL, NULL, 'Entrada', 128, '2026-04-16 10:00:00');

-- SALIDAS POR MERMAS
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000005', 'PRO0000003', NULL, NULL, 'MRM0000001', NULL, 'Salida', 5, '2026-04-14 08:00:00');
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000006', 'PRO0000012', NULL, NULL, 'MRM0000002', NULL, 'Salida', 3, '2026-04-18 20:00:00');
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000007', 'PRO0000008', NULL, NULL, 'MRM0000003', NULL, 'Salida', 2, '2026-04-20 07:00:00');

-- SALIDAS POR VENTAS EXITOSAS
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000008', 'PRO0000001', 'VEN0000001', NULL, NULL, NULL, 'Salida', 10, '2026-04-20 10:00:00');
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000009', 'PRO0000006', 'VEN0000002', NULL, NULL, NULL, 'Salida', 5, '2026-04-20 11:30:00');
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000010', 'PRO0000010', 'VEN0000002', NULL, NULL, NULL, 'Salida', 6, '2026-04-20 11:30:00');
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000011', 'PRO0000003', 'VEN0000004', NULL, NULL, NULL, 'Salida', 6, '2026-04-21 09:00:00');
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000012', 'PRO0000008', 'VEN0000005', NULL, NULL, NULL, 'Salida', 14, '2026-04-21 15:45:00');
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000013', 'PRO0000005', 'VEN0000006', NULL, NULL, NULL, 'Salida', 140, '2026-04-22 10:00:00');
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000014', 'PRO0000012', 'VEN0000007', NULL, NULL, NULL, 'Salida', 2, '2026-04-22 13:20:00');
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000015', 'PRO0000014', 'VEN0000009', NULL, NULL, NULL, 'Salida', 26, '2026-04-24 19:30:00');
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000016', 'PRO0000004', 'VEN0000010', NULL, NULL, NULL, 'Salida', 6, '2026-04-25 08:10:00');

-- ENTRADAS/SALIDAS POR DEVOLUCIONES
-- Cambio (Entra el malo, sale el bueno nuevo)
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000017', 'PRO0000001', NULL, NULL, NULL, 'DEV0000001', 'Entrada', 1, '2026-04-20 11:00:00');
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000018', 'PRO0000001', NULL, NULL, NULL, 'DEV0000001', 'Salida', 1, '2026-04-20 11:05:00');
-- Reembolso por Delivery Fallido (La mercadería regresa al almacén)
INSERT INTO MovimientoStock_grupo VALUES ('MOV0000019', 'PRO0000015', NULL, NULL, NULL, 'DEV0000002', 'Entrada', 10, '2026-04-20 14:00:00');
















