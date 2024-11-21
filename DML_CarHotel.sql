USE CatHotel
GO

-- Insertar Propietarios
INSERT INTO Propietario (propietarioDocumento, propietarioNombre, propietarioTelefono, propietarioEmail) VALUES
('12345678', 'Ana García', '555-0101', 'ana@email.com'),
('23456789', 'Carlos Rodríguez', '555-0202', 'carlos@email.com'),
('34567890', 'María López', '555-0303', 'maria@email.com'),
('45678901', 'Juan Martínez', '555-0404', 'juan@email.com'),
('56789012', 'Laura Sánchez', '555-0505', 'laura@email.com');

-- Insertar Gatos
INSERT INTO Gato (gatoNombre, gatoRaza, gatoEdad, gatoPeso, propietarioDocumento) VALUES
('Luna', 'Siamés', 3, 4.5, '12345678'),
('Milo', 'Persa', 2, 5.0, '12345678'),
('Simba', 'Maine Coon', 4, 7.5, '23456789'),
('Nala', 'Bengalí', 1, 3.5, '34567890'),
('Oliver', 'Ragdoll', 5, 6.0, '45678901'),
('Lucy', 'Británico', 2, 4.0, '56789012'),
('Thor', 'Sphynx', 3, 3.8, '23456789');

-- Insertar Habitaciones
INSERT INTO Habitacion (habitacionNombre, habitacionCapacidad, habitacionPrecio, habitacionEstado) VALUES
('Suite Deluxe', 2, 100.00, 'DISPONIBLE'),
('Habitación Estándar 1', 1, 50.00, 'DISPONIBLE'),
('Habitación Estándar 2', 1, 50.00, 'LLENA'),
('Suite Familiar', 3, 150.00, 'DISPONIBLE'),
('Habitación VIP', 1, 80.00, 'LIMPIANDO');

-- Insertar Servicios
INSERT INTO Servicio (servicioNombre, servicioPrecio) VALUES
('Baño y Peluquería', 35.00),
('Masajes', 25.00),
('Juegos Especiales', 15.00),
('Alimentación Premium', 20.00),
('Cepillado', 10.00);

-- Insertar Reservas
INSERT INTO Reserva (gatoID, habitacionNombre, reservaFechaInicio, reservaFechaFin, reservaMonto) VALUES
-- Reservas del año 2023
(1, 'Suite Deluxe', '2023-03-15', '2023-03-18', 300.00),
(2, 'Habitación Estándar 1', '2023-06-10', '2023-06-12', 100.00),
(3, 'Suite Familiar', '2023-09-20', '2023-09-25', 750.00),

-- Reservas del año 2024
(4, 'Habitación VIP', '2024-02-15', '2024-02-19', 320.00),
(5, 'Suite Deluxe', '2024-03-01', '2024-03-04', 300.00),
(6, 'Habitación Estándar 2', '2024-03-10', '2024-03-13', 150.00),
(7, 'Suite Familiar', '2024-03-15', '2024-03-18', 450.00);

-- Insertar Reserva_Servicio
INSERT INTO Reserva_Servicio (reservaID, servicioNombre, cantidad) VALUES
-- Para reservas del 2023
(1, 'Baño y Peluquería', 1),
(1, 'Masajes', 2),
(2, 'Alimentación Premium', 1),
(3, 'Juegos Especiales', 3),

-- Para reservas del 2024
(4, 'Baño y Peluquería', 1),
(4, 'Masajes', 1),
(5, 'Alimentación Premium', 2),
(5, 'Cepillado', 3),
(6, 'Juegos Especiales', 2),
(7, 'Baño y Peluquería', 1),
(7, 'Masajes', 2);

GO

-- Consulta de verificación para ver los datos insertados
SELECT 'Propietarios' as Tabla, COUNT(*) as Cantidad FROM Propietario
UNION ALL
SELECT 'Gatos', COUNT(*) FROM Gato
UNION ALL
SELECT 'Habitaciones', COUNT(*) FROM Habitacion
UNION ALL
SELECT 'Servicios', COUNT(*) FROM Servicio
UNION ALL
SELECT 'Reservas', COUNT(*) FROM Reserva
UNION ALL
SELECT 'Reserva_Servicios', COUNT(*) FROM Reserva_Servicio;