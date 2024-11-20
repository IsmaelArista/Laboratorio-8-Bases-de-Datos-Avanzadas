CREATE DATABASE IF NOT EXISTS Libreria;
USE Libreria;

-- PASO 1
CREATE TABLE dim_tiempo (
    id_tiempo INT PRIMARY KEY,
    año INT,
    mes INT,
    dia INT,
    trimestre INT
);

-- Tabla de dimensión de libros
CREATE TABLE dim_libro (
    id_libro INT PRIMARY KEY,
    titulo VARCHAR(100),
    autor VARCHAR(100),
    genero VARCHAR(50),
    precio_unitario DECIMAL(10, 2)
);

-- Tabla de dimensión de clientes
CREATE TABLE dim_cliente (
    id_cliente INT PRIMARY KEY,
    nombre_cliente VARCHAR(100),
    edad INT,
    genero VARCHAR(10),
    ciudad VARCHAR(100)
);

-- Tabla de dimensión de tiendas
CREATE TABLE dim_tienda (
    id_tienda INT PRIMARY KEY,
    nombre_tienda VARCHAR(100),
    ciudad VARCHAR(100),
    pais VARCHAR(100)
);

-- Tabla de hechos para las ventas de libros
CREATE TABLE hechos_ventas_libros (
    id_venta INT PRIMARY KEY,
    id_tiempo INT,
    id_libro INT,
    id_cliente INT,
    id_tienda INT,
    cantidad INT,
    precio_total DECIMAL(10, 2),
    FOREIGN KEY (id_tiempo) REFERENCES dim_tiempo(id_tiempo),
    FOREIGN KEY (id_libro) REFERENCES dim_libro(id_libro),
    FOREIGN KEY (id_cliente) REFERENCES dim_cliente(id_cliente),
    FOREIGN KEY (id_tienda) REFERENCES dim_tienda(id_tienda)
);

-- PASO 2
-- Insertar datos en dim_tiempo
INSERT INTO dim_tiempo VALUES
(1, 2024, 11, 19, 4),
(2, 2024, 9, 12, 3),
(3, 2024, 6, 8, 2);

-- Insertar datos en dim_libro
INSERT INTO dim_libro VALUES
(1, 'La Casa de los Espíritus', 'Isabel Allende', 'Ficción', 180.50),
(2, 'El Hombre en Busca de Sentido', 'Viktor Frankl', 'Psicología', 220.00),
(3, 'El Alquimista', 'Paulo Coelho', 'Aventura', 150.00),
(4, 'La Sombra del Viento', 'Carlos Ruiz Zafón', 'Misterio', 200.00),
(5, 'Crónica de una Muerte Anunciada', 'Gabriel García Márquez', 'Realismo', 190.00);

-- Insertar datos en dim_cliente
INSERT INTO dim_cliente VALUES
(1, 'Roberto Martínez', 33, 'Masculino', 'Querétaro'),
(2, 'Lucía Torres', 29, 'Femenino', 'León'),
(3, 'Fernando Castillo', 40, 'Masculino', 'Toluca'),
(4, 'Claudia Herrera', 26, 'Femenino', 'Mérida'),
(5, 'Juan Pablo Rojas', 35, 'Masculino', 'Cancún');

-- Insertar datos en dim_tienda
INSERT INTO dim_tienda VALUES
(1, 'Librería Insurgentes', 'Ciudad de México', 'México'),
(2, 'Librería Reforma', 'Guadalajara', 'México'),
(3, 'Librería Independencia', 'Monterrey', 'México');

-- Insertar datos en hechos_ventas_libros
INSERT INTO hechos_ventas_libros VALUES
(1, 1, 1, 1, 1, 2, 361.00),
(2, 1, 2, 2, 2, 1, 220.00),
(3, 2, 3, 3, 3, 4, 600.00),
(4, 2, 4, 4, 1, 1, 200.00),
(5, 3, 5, 5, 2, 3, 570.00),
(6, 3, 1, 1, 3, 2, 361.00),
(7, 1, 3, 2, 1, 1, 150.00),
(8, 2, 4, 3, 2, 2, 400.00),
(9, 3, 2, 4, 3, 1, 220.00),
(10, 1, 5, 5, 1, 5, 950.00);

-- PASO 3
-- Consulta 1: Total de ventas (precio_total) por género de libro y mes
SELECT 
    dl.genero,
    dt.mes,
    SUM(hvl.precio_total) AS total_ventas
FROM hechos_ventas_libros hvl
JOIN dim_libro dl ON hvl.id_libro = dl.id_libro
JOIN dim_tiempo dt ON hvl.id_tiempo = dt.id_tiempo
GROUP BY dl.genero, dt.mes
ORDER BY dl.genero, dt.mes;

-- Consulta 2: Cantidad total de libros vendidos por tienda y autor
SELECT 
    dt.nombre_tienda,
    dl.autor,
    SUM(hvl.cantidad) AS total_libros_vendidos
FROM hechos_ventas_libros hvl
JOIN dim_tienda dt ON hvl.id_tienda = dt.id_tienda
JOIN dim_libro dl ON hvl.id_libro = dl.id_libro
GROUP BY dt.nombre_tienda, dl.autor
ORDER BY dt.nombre_tienda, dl.autor;

-- Consulta 3: Ingresos totales por ciudad de cliente y trimestre
SELECT 
    dc.ciudad AS ciudad_cliente,
    dt.trimestre,
    SUM(hvl.precio_total) AS ingresos_totales
FROM hechos_ventas_libros hvl
JOIN dim_cliente dc ON hvl.id_cliente = dc.id_cliente
JOIN dim_tiempo dt ON hvl.id_tiempo = dt.id_tiempo
GROUP BY dc.ciudad, dt.trimestre
ORDER BY dc.ciudad, dt.trimestre;

-- Consulta 4: Total de ventas de cada cliente y número de libros comprados
SELECT 
    dc.nombre_cliente,
    SUM(hvl.precio_total) AS total_ventas,
    SUM(hvl.cantidad) AS total_libros_comprados
FROM hechos_ventas_libros hvl
JOIN dim_cliente dc ON hvl.id_cliente = dc.id_cliente
GROUP BY dc.nombre_cliente
ORDER BY total_ventas DESC;
