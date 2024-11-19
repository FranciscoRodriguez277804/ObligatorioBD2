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

--Creación de índices que considere puedan ser útiles para optimizar las consultas (según criterio
--establecido en el curso).




--Ingreso de un juego completo de datos de prueba (será más valorada la calidad de los datos que la
--cantidad).

INSERT INTO Propietario VALUES (44666254,'Sofia Moran',094485887,'soomoran20@gmail.com'),
							   (45896425,'Lorena Nuñez',09922222,'lore@gmail.com'),
							   (46621433,'Alexis Falcon',09654896,'alexei@gmail.com'),
							   (48687123,'Freddy Mercury',09478965,'lavozdelsiglo20@gmail.com'),
							   (42488794,'Lucas Viera',09958632,'lv@gmail.com'),
							   (65895478,'Flor Jazmin Peña',222660019,'florjazmin@gmail.com')

INSERT INTO Gato VALUES ('Diegote','Bombay',5,8,46621433),
						('Meme','Bengali',3,5,44666254),
						('Budin','Mestizo',4,8,65895478),
						('Lulita','Siames',4,5,42488794),
						('Macri','Siames',6,4,42488794)


INSERT INTO Habitacion VALUES ('Palacio de pelusa',4,150,'DISPONIBLE'),
							  ('Mirador de Ratones',1,1000,'LLENA'),
							  ('Noche de Fantasia',2,250,'DISPONIBLE'),
							  ('Refugio de plumas',10,90,'DISPONIBLE'),
							  ('Dormitorio gaturro',4,50,'LIMPIANDO'),
							  ('Retiro Secreto',2,120,'LLENA')

INSERT INTO Reserva VALUES (3,'Palacio de pelusa','2024-09-14','2024-09-22',150),
						   (1,'Refugio de plumas','2024-05-03','2024-05-05',180),
						   (4,'Noche de Fantasia','2024-05-03','2024-05-05',100),
						   (4,'Noche de Fantasia','2024-10-03','2024-10-06',750),
						   (5,'Mirador de Ratones','2024-09-01','2024-09-09',9000)


INSERT INTO Servicio VALUES ('Atencion Veterinaria',50),
							('Servicio de Spa y Belleza',120),
							('Gym',130),
							('Transporte',150)

INSERT INTO Reserva_Servicio VALUES (5,'Atencion Veterinaria',1),
									(5,'Servicio de Spa y Belleza',1),
									(5,'Gym',1),
									(5,'Transporte',1),
									(2,'Servicio de Spa y Belleza',1),
									(3,'Gym',1),
									(3,'Servicio de Spa y Belleza',1),
									(1,'Servicio de Spa y Belleza',1),
									(1,'Atencion Veterinaria',1)


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


--a. Escribir un procedimiento almacenado para reservar una habitación.
--Se debe actualizar el estado de DISPONIBLE a LLENA si se alcanzó la capacidad de la
--habitación con la reserva en cuestión
--No permitir realizar la reserva si el estado de la habitación es LLENA o LIMPIANDO. 

CREATE OR ALTER PROCEDURE SP_EJ1 
@gatoID int , @nombreHab char(30) , @inicio date , @fin date , @monto decimal(7,2)
AS
BEGIN 

DECLARE @capacidadHabitacion int , @estado varchar(20) , @huespedes int 

SELECT @capacidadHabitacion = h.habitacionCapacidad , @estado = h.habitacionEstado , @huespedes  = COUNT(r.gatoID)
FROM Habitacion h ,Reserva r
WHERE h.habitacionNombre = @nombreHab and r.habitacionNombre = h.habitacionNombre

IF @estado = 'LLENA' OR  @estado = 'LIMPIANDO'
    BEGIN
        PRINT ('No se puede realizar la reserva, la habitación está llena o en limpieza.');
    END


 IF @capacidadHabitacion  >= @huespedes 
 BEGIN 
	UPDATE Habitacion 
	SET habitacionEstado = 'LLENA'
	WHERE habitacionNombre = @nombreHab
 END 

INSERT INTO Reserva (gatoID, habitacionNombre, reservaFechaInicio, reservaFechaFin, reservaMonto)
    VALUES (@gatoID, @nombreHab, @inicio, @fin, @monto);


END
