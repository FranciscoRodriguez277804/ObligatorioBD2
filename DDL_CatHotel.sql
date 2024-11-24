CREATE DATABASE CatHotel
GO
USE CatHotel
GO
CREATE TABLE Propietario (
    propietarioDocumento CHAR(30) PRIMARY KEY,
    propietarioNombre VARCHAR(100) NOT NULL,
    propietarioTelefono VARCHAR(20) NULL,
    propietarioEmail VARCHAR(100) NULL,
    CONSTRAINT CHK_Propietario_TelefonoEmail CHECK (propietarioTelefono IS NOT NULL OR propietarioEmail IS NOT NULL) );
GO
CREATE TABLE Gato (
    gatoID INT IDENTITY(1,1) PRIMARY KEY,
    gatoNombre VARCHAR(50) NOT NULL,
    gatoRaza VARCHAR(50),
    gatoEdad INT,
    gatoPeso DECIMAL(5,2),
    propietarioDocumento CHAR(30) NOT NULL,
    CONSTRAINT CHK_Gato_Edad CHECK (gatoEdad >= 0),
    CONSTRAINT CHK_Gato_Peso CHECK (gatoPeso > 0),
    CONSTRAINT FK_Gato_Propietario FOREIGN KEY (propietarioDocumento) REFERENCES Propietario(propietarioDocumento) );
GO
CREATE TABLE Habitacion (
    habitacionNombre CHAR(30) PRIMARY KEY,
    habitacionCapacidad INT,
	habitacionPrecio DECIMAL(6,2),
    habitacionEstado VARCHAR(20),
    CONSTRAINT CHK_Habitacion_Capacidad CHECK (habitacionCapacidad > 0),
    CONSTRAINT CHK_Habitacion_Precio CHECK (habitacionPrecio > 0),
    CONSTRAINT CHK_Habitacion_Estado CHECK (habitacionEstado IN ('DISPONIBLE', 'LLENA', 'LIMPIANDO')) );
GO
CREATE TABLE Reserva (
    reservaID INT IDENTITY(1,1) PRIMARY KEY,
    gatoID INT NOT NULL,
    habitacionNombre CHAR(30) NOT NULL,
    reservaFechaInicio DATE NOT NULL,
    reservaFechaFin DATE NOT NULL,
    reservaMonto DECIMAL(7,2) NOT NULL,
    CONSTRAINT FK_Reserva_Gato FOREIGN KEY (gatoID) REFERENCES Gato(gatoID),
    CONSTRAINT FK_Reserva_Habitacion FOREIGN KEY (habitacionNombre) REFERENCES Habitacion(habitacionNombre),
    CONSTRAINT CHK_Reserva_Fecha CHECK (reservaFechaFin > reservaFechaInicio) );
GO
CREATE TABLE Servicio (
    servicioNombre CHAR(30) NOT NULL PRIMARY KEY,
    servicioPrecio DECIMAL(7,2),
    CONSTRAINT CHK_Servicio_Precio CHECK (servicioPrecio >= 0) );
GO
CREATE TABLE Reserva_Servicio (
    reservaID INT NOT NULL,
    servicioNombre CHAR(30) NOT NULL,
    cantidad INT DEFAULT 1,
    PRIMARY KEY (reservaID, servicioNombre),
    CONSTRAINT CHK_ReservaServicio_Cantidad CHECK (cantidad > 0),
    CONSTRAINT FK_ReservaServicio_Reserva FOREIGN KEY (reservaID) REFERENCES Reserva(reservaID),
    CONSTRAINT FK_ReservaServicio_Servicio FOREIGN KEY (servicioNombre) REFERENCES Servicio(servicioNombre) );
GO

-- Creación de índices que considere puedan ser útiles para optimizar las consultas (según criterio
-- establecido en el curso).






--a Mostrar el nombre del gato, el nombre del propietario, la habitación y el monto de la reserva
--más reciente en la(s) habitación con la capacidad más alta.

SELECT g.gatoNombre , p.propietarioNombre , r.habitacionNombre , r.reservaMonto 
FROM Gato g 
INNER JOIN Propietario p on g.propietarioDocumento = p.propietarioDocumento
INNER JOIN Reserva r on g.gatoID = r.gatoID 
WHERE r.reservaFechaInicio = (SELECT MAX(r2.reservaFechaInicio)
							  FROM Reserva r2
							  INNER JOIN Habitacion h on h.habitacionNombre = r2.habitacionNombre
							  WHERE h.habitacionCapacidad = (SELECT MAX(ha.habitacionCapacidad)
														     FROM Habitacion ha))

--b Mostrar los 3 servicios más solicitados, con su nombre, precio y cantidad total solicitada en
--el año anterior. Solo listar el servicio si cumple que tiene una cantidad total solicitada mayor
--o igual que 5

SELECT TOP 3 s.servicioNombre , s.servicioPrecio , SUM(rs.cantidad) as CantidadTotalSolicitada
FROM Reserva_Servicio rs , Servicio s , Reserva r 
WHERE rs.servicioNombre = s.servicioNombre and r.reservaID = rs.reservaID and YEAR(r.reservaFechaFin) = YEAR(GETDATE()) - 1
GROUP BY s.servicioNombre , s.servicioPrecio 
HAVING SUM(rs.cantidad) >= 5
ORDER BY CantidadTotalSolicitada DESC 

--c Listar nombre de gato y nombre de habitación para las reservas que tienen asociados todos
--los servicios adicionales disponibles

SELECT g.gatoNombre , r.habitacionNombre
FROM Gato g , Reserva r , Reserva_Servicio rs 
WHERE g.gatoID = r.gatoID and rs.reservaID = r.reservaID
GROUP BY g.gatoNombre , r.habitacionNombre 
HAVING COUNT(DISTINCT rs.servicioNombre) = (SELECT COUNT(s.servicioNombre)
											FROM Servicio s)

--d Listar monto total de reserva por año y por gato (nombre) para los gatos que tienen más de
--1 años de edad, son de raza "Persa" y que en el año tuvieron montos total de reserva
--superior a 500 dólares

SELECT YEAR(r.reservaFechaInicio) as año , g.gatoNombre , SUM(r.reservaMonto) as montoTotal
FROM Reserva r , gato g 
WHERE r.gatoID = r.gatoID and g.gatoEdad > 10 and g.gatoRaza = 'Persa'
GROUP BY YEAR(r.reservaFechaInicio) , g.gatoNombre , r.reservaMonto 
HAVING SUM(r.reservaMonto) >= 500

  
--e. Mostrar el ranking de reservas más caras, tomando como monto total de una reserva el monto
--propio de la reserva más los servicios adicionales contratados en la reserva

SELECT r.reservaID , r.gatoID , r.habitacionNombre , r.reservaFechaFin , r.reservaFechaFin ,
r.reservaMonto + (
SELECT SUM(rs.cantidad * s.servicioPrecio)
FROM Reserva_Servicio rs , Servicio s
WHERE s.servicioNombre = rs.servicioNombre and rs.reservaID = r.reservaID
) as montoTotal
FROM Reserva r 
ORDER BY montoTotal DESC;

--f. Calcular el promedio de duración en días de las reservas realizadas durante el año en curso.
--Deben ser consideradas solo aquellas reservas en las que se contrató el servicio
--"CONTROL_PARASITOS" pero no se contrató el servicio "REVISION_VETERINARIA"

SELECT AVG(DATEDIFF(DAY, r.reservaFechaFin , r.reservaFechaFin)) as diferenciaDias
FROM Reserva r , Reserva_Servicio rs 
WHERE YEAR(r.reservaFechaInicio)  = YEAR(GETDATE()) and rs.servicioNombre = 'CONTROL_PARASITOS' 
and rs.servicioNombre not in (SELECT rs2.servicioNombre
							  FROM Reserva_Servicio rs2
							  WHERE rs2.servicioNombre = 'REVISION_VETERINARIA')

--g. Para cada habitación, listar su nombre, la cantidad de días que ha estado ocupada y la
--cantidad de días transcurridos desde la fecha de inicio de la primera reserva en el hotel.
--Además, incluir una columna adicional que indique la categoría de rentabilidad, asignando
--el valor "REDITUABLE" si la habitación estuvo ocupada más del 60% de los días, "MAGRO"
--si estuvo ocupada entre el 40% y el 60%, y "NOESNEGOCIO" si estuvo ocupada menos del
--40%.

SELECT h.habitacionNombre , SUM(DATEDIFF(DAY,r.reservaFechaInicio , r.reservaFechaFin)) cantidadDiasOcupada ,
CASE 
	WHEN AVG(DATEDIFF(Day , r.reservaFechaInicio , r.reservaFechaFin)) > 60 THEN 'REDITUABLE'
	WHEN AVG(DATEDIFF(Day , r.reservaFechaInicio , r.reservaFechaFin)) BETWEEN 40 and 60 THEN 'MAGRO'
	WHEN AVG(DATEDIFF(Day , r.reservaFechaInicio , r.reservaFechaFin)) < 40 THEN 'NO ES NEGOCIO' 
	END rentabilidad
FROM Habitacion h , Reserva r 
WHERE h.habitacionNombre = r.habitacionNombre
GROUP BY h.habitacionNombre 


-- 4a Escribir un procedimiento almacenado para reservar una habitación.
-- Se debe actualizar el estado de DISPONIBLE a LLENA si se alcanzó la capacidad de la
-- habitación con la reserva en cuestión
-- No permitir realizar la reserva si el estado de la habitación es LLENA o LIMPIANDO.
-- Se debe retornar el número de reserva asignado (cero sino se logró reservar)

CREATE OR ALTER PROCEDURE SP_EJ1 
    @gatoID int,
    @habitacion char(30),
    @reservaInicio date,
    @reservaFin date, 
    @reservaMonto decimal(7,2),
    @numeroDeReserva int OUTPUT
AS
BEGIN
    SET @numeroDeReserva = 0;
    
    -- Verifico si la habitacion esta disponible
    IF EXISTS (SELECT 1
               FROM Habitacion 
               WHERE habitacionNombre = @habitacion 
               AND habitacionEstado = 'DISPONIBLE')
    BEGIN
        -- Inserto reserva
        INSERT INTO Reserva (gatoID, habitacionNombre, reservaFechaInicio, reservaFechaFin, reservaMonto)
        VALUES (@gatoID, @habitacion, @reservaInicio, @reservaFin, @reservaMonto);
        
        -- Obtengo el ultimo id asignado
        SET @numeroDeReserva = SCOPE_IDENTITY();
        
        -- Cuento las reservas actuales de la habitacion
        IF (SELECT COUNT(*)
            FROM Reserva
            WHERE habitacionNombre = @habitacion
            AND reservaFechaFin >= @reservaInicio
            AND reservaFechaInicio <= @reservaFin) >= (SELECT habitacionCapacidad 
                                                       FROM Habitacion 
													   WHERE habitacionNombre = @habitacion)
        BEGIN
            -- Actualizar estado a LLENA si se alcanzó la capacidad
            UPDATE Habitacion
            SET habitacionEstado = 'LLENA'
            WHERE habitacionNombre = @habitacion;
        END
    END
END

DECLARE @reservaID int
EXEC SP_EJ1 1, 'Suite Deluxe', '2024-03-20', '2024-03-23', 300.00, @reservaID OUTPUT
SELECT @reservaID as NumeroReservaAsignado

-- 4b. Mediante una función que reciba un nombre de servicio, devolver un booleano indicando si
-- ste año el servicio fue contratado más veces que el año pasado

CREATE OR ALTER FUNCTION FN_EJE4B(@nombreDeServicio CHAR(30))
RETURNS BIT
AS
BEGIN
    DECLARE @return BIT = 0

    -- Verificar si existe el servicio
    IF EXISTS (SELECT 1 FROM Servicio WHERE servicioNombre = @nombreDeServicio)
    BEGIN
        DECLARE @cantidadEsteAnio INT
        DECLARE @cantidadAnioAnterior INT

        -- Cuento cantidad de servicios de este año
        SELECT @cantidadEsteAnio = COUNT(*)
        FROM Reserva r 
        JOIN Reserva_Servicio rs ON r.reservaID = rs.reservaID
        WHERE rs.servicioNombre = @nombreDeServicio 
        AND YEAR(r.reservaFechaInicio) = YEAR(GETDATE())

        -- Cuento la cantidad de servicios de el año pasado 
        SELECT @cantidadAnioAnterior = COUNT(*)
        FROM Reserva r 
        JOIN Reserva_Servicio rs ON r.reservaID = rs.reservaID
        WHERE rs.servicioNombre = @nombreDeServicio 
        AND YEAR(r.reservaFechaInicio) = YEAR(GETDATE()) - 1

        
        SET @return = CASE WHEN @cantidadEsteAnio > @cantidadAnioAnterior THEN 1 ELSE 0 END

    END

		RETURN @return

END

SELECT dbo.FN_EJE4B ('Masajes') 

-- 5a. Cada vez que se crea una nueva reserva se debe crear un registro de auditoria con todos
-- los datos ingresados en una tabla ReservaLog (definir su estructura libremente). 
-- Y adicionalmente cada vez que se modifica el campo monto de una reserva: debe registrar
-- monto previo y nuevo monto en la tabla ReservaLog.
-- En todos los casos se debe grabar fecha-hora de registro, usuario(login), nombre de equipo
-- desde el que se realizó la modificación.

CREATE TABLE ReservaLog (
    logID INT IDENTITY(1,1) PRIMARY KEY,
    reservaID INT,
    gatoID INT, 
    habitacionNombre CHAR(30),
    reservaFechaInicio DATE,
    reservaFechaFin DATE,
    reservaMonto DECIMAL(7,2),
    montoAnterior DECIMAL(7,2),
    fechaRegistro DATETIME DEFAULT GETDATE(),
    tipoOperacion VARCHAR(20),
    usuarioOperacion VARCHAR(50) DEFAULT SYSTEM_USER,
    nombreEquipo VARCHAR(50) DEFAULT HOST_NAME(),
    CONSTRAINT FK_ReservaLog_Reserva FOREIGN KEY (reservaID) 
    REFERENCES Reserva(reservaID)

);

CREATE OR ALTER TRIGGER TRG_EJE5A 
ON Reserva 
AFTER INSERT , UPDATE 
AS
BEGIN 
	
	-- Insertar nueva reserva
	IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
	BEGIN
		INSERT INTO ReservaLog SELECT i.reservaID, i.gatoID, i.habitacionNombre,
									  i.reservaFechaInicio, i.reservaFechaFin,
									  i.reservaMonto, NULL , GETDATE() ,'INSERT RESERVA',
									  SYSTEM_USER , HOST_NAME()
							   FROM inserted i
	END
	-- Actualizar monto
	IF UPDATE(reservaMonto)
	BEGIN 
		INSERT INTO ReservaLog SELECT  i.reservaID, i.gatoID, i.habitacionNombre,
									   i.reservaFechaInicio, i.reservaFechaFin,
                                       i.reservaMonto, d.reservaMonto, GETDATE(),
									   'UPDATE MONTO', SYSTEM_USER , HOST_NAME()
							   FROM inserted i , deleted d
							   WHERE i.reservaMonto <> d.reservaMonto
	END

END

-- 5b. Antes de insertar una nueva reserva, se debe controlar posibles solapamientos de reservas
-- (un gato no podría estar alojado simultáneamente 2 veces en el hotel).
-- Se debe dar de alta las reservas válidas y simplemente ignorar las reservas solapadas 


CREATE OR ALTER TRIGGER TRG_EJE5B 
ON Reserva
INSTEAD OF INSERT 
AS 
BEGIN 
INSERT INTO Reserva
    SELECT i.*
    FROM inserted i
    WHERE NOT EXISTS (
        SELECT r.reservaID
        FROM Reserva r
        WHERE r.gatoID = i.gatoID
		AND i.reservaFechaInicio <= r.reservaFechaFin 
        AND i.reservaFechaFin >= r.reservaFechaInicio
		)
END

-- 6. Crear una vista que liste el monto total a facturar por propietario por las reservas y servicios del
-- mes pasado. Se debe listar el nombre del propietario, el monto total de sus reservas, el monto total
-- de servicios adicionales que contrató y la suma de ambos montos (monto a facturar) 

CREATE OR ALTER VIEW V_EJ6
AS 

SELECT p.propietarioNombre ,
SUM(r.reservaMonto) as MontoTotalReservas ,
SUM(rs.cantidad * s.servicioPrecio) MontoTotalServicios ,
SUM(r.reservaMonto) + SUM(rs.cantidad * s.servicioPrecio) as MontoTotalaFacturar
FROM Propietario p , gato g , Reserva r , Reserva_Servicio rs , Servicio s
WHERE p.propietarioDocumento = g.propietarioDocumento and g.gatoID = r.gatoID and r.reservaID =
rs.reservaID and rs.servicioNombre = s.servicioNombre and
YEAR(r.reservaFechaInicio) = YEAR(GETDATE()) and MONTH(r.reservaFechaInicio) = (DATEADD(MONTH, -1, GETDATE()))
GROUP BY p.propietarioNombre 


 



