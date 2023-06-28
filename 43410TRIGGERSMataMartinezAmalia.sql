-- drop schema if exists VeterinariaEntrega;
-- create schema if not exists VeterinariaEntrega;
use VeterinariaEntrega;

CREATE TABLE PERSONAL(
ID_PERSONAL int,
NOMBRE_EMPLEADO varchar(50) NOT NULL,
APELLIDOS_EMPLEADO varchar(50) NOT NULL,
DIRECCION varchar(250) NOT NULL,
CIUDAD varchar(15) NOT NULL,
ESTADO varchar(15) NOT NULL,
CP int,
E_MAIL varchar(50) NOT NULL,
TELEFONO varchar(15) NOT NULL,
CARGO varchar(50) NOT NULL,
primary key (ID_PERSONAL)
);

CREATE TABLE SERVICIO(
ID_SERVICIO int,
SERVICIO varchar(100) NOT NULL,
DESCRIPCIÓN varchar(450) NOT NULL,
PRECIO decimal (6,2),
primary key (ID_SERVICIO)
);

CREATE TABLE CLIENTES(
ID_CLIENTE int,
NOMBRE varchar(50) NOT NULL,
APELLIDOS varchar(50) NOT NULL,
E_MAIL varchar(50) NOT NULL,
DIRECCIÓN varchar(50) NOT NULL,
CIUDAD varchar(15) NOT NULL,
ESTADO varchar(15) NOT NULL,
CP int,
TELÉFONO varchar(15) NOT NULL,
FECHA_DE_NACIMIENTO date,
primary key (ID_CLIENTE)
);

CREATE TABLE MASCOTAS(
ID_MASCOTA int,
NOMBRE_MASCOTA varchar(50) NOT NULL,
RAZA varchar(50) NOT NULL,
SEXO_MASCOTA ENUM('F', 'M') NOT NULL,
COLOR varchar(25) NOT NULL,
EDAD int,
TAMANO int,
PESO decimal (6,2),
PEDIGREE varchar(25),
CHIP int,
DESCRIPCIÓN varchar(150) NOT NULL,
FECHA_DE_NACIMIENTO date NOT NULL,
ID_CLIENTE int,
PROPIETARIO varchar(50) NOT NULL,
primary key (ID_MASCOTA),
foreign key (ID_CLIENTE) references CLIENTES(ID_CLIENTE));

CREATE TABLE KARDEX(
NO_KARDEX int,
ID_MASCOTA int,
NOMBRE_MASCOTA varchar(50) NOT NULL,
FECHA date NOT NULL,
ID_SERVICIO int,
SERVICIO varchar(100) NOT NULL,
DESCRIPCIÓN varchar(350) NOT NULL,
PRÓXIMA_FECHA date NOT NULL,
ID_PERSONAL int,
NOMBRE_EMPLEADO varchar(150) NOT NULL,
HISTORIA_CLÍNICA varchar(250) NOT NULL,
primary key (NO_KARDEX),
foreign key (ID_MASCOTA) references MASCOTAS(ID_MASCOTA),
foreign key (ID_SERVICIO) references SERVICIO(ID_SERVICIO),
foreign key (ID_PERSONAL) references PERSONAL(ID_PERSONAL));

CREATE TABLE FACTURA(
NO_FOLIO int,
FECHA date NOT NULL,
ID_CLIENTE int,
ID_MASCOTA int,
ID_SERVICIO int,
DETALLE varchar(250),
PRECIO_UNITARIO_DLLS decimal(8,2) NOT NULL,
SUBTOTAL_DLLS decimal(8,2) NOT NULL,
IVA decimal(3,2) NOT NULL,
TOTAL_DLLS decimal(8,2) NOT NULL,
primary key (NO_FOLIO),
foreign key (ID_CLIENTE) references CLIENTES(ID_CLIENTE),
foreign key (ID_MASCOTA) references MASCOTAS(ID_MASCOTA),
foreign key (ID_SERVICIO) references SERVICIO(ID_SERVICIO)
);

-- Mostar los datos de las mascotas a quiénes se les hizo servicio de Peluquería 
CREATE OR REPLACE VIEW VW_SERVICIO_PELUQUERIA AS 
(SELECT * FROM kardex
WHERE servicio LIKE '%Peluqueria%');

-- VISTA Mostrar Nombre, Apellido y Ciudad de los Clientes que viven en la Ciudad de Ramos Arizpe
CREATE OR REPLACE VIEW VW_CLIENTES_RAMOS AS
(SELECT nombre, apellidos,ciudad FROM clientes 
WHERE ciudad LIKE '%Ramos Arizpe%');

-- VISTA Tabla Mascotas
CREATE OR REPLACE VIEW VW_MASCOTAS AS
(SELECT * FROM MASCOTAS);

-- VISTA De la tabla Kardex en donde el servicio es Vacunas
CREATE OR REPLACE VIEW VW_SERVICIO_VACUNAS AS
(SELECT  K.*
 FROM kardex AS K JOIN servicio AS S
 ON K.id_servicio = S.id_servicio
 WHERE S.SERVICIO like '%Vacunas%');
 
 -- VISTA Muestra el servicio que se realizó, a quién y por quién.
 CREATE OR REPLACE VIEW VW_PERSONAL_Y_SERVICIO_BRINDADO AS
 (SELECT PERSONAL.NOMBRE_EMPLEADO, PERSONAL.APELLIDOS_EMPLEADO, PERSONAL.CARGO, KARDEX.NOMBRE_MASCOTA, KARDEX.SERVICIO
 FROM KARDEX
 INNER JOIN PERSONAL
 ON PERSONAL.ID_PERSONAL = KARDEX.ID_PERSONAL
 ORDER BY 4);
 
CREATE OR REPLACE VIEW VW_SERVICIO_MAS_SOLICITADO AS
 (SELECT SERVICIO, COUNT(*) AS CANTIDAD_SOLICITADO
 FROM KARDEX GROUP BY 1);
 
select * from factura;

drop function if exists fn_calcular_subtotal;
-- Función para calcular Subtotal sin IVA
delimiter $$
create function fn_calcular_subtotal (p_cantidad int, 		
										p_id_cliente int)
returns decimal(6,2)
deterministic
begin

declare v_subtotal int;
set v_subtotal =
(select distinct precio_unitario_dlls * p_cantidad
as SUBTOTAL_DLLS from factura
where id_cliente = p_id_cliente);

return v_subtotal;
end$$
delimiter ; 

select fn_calcular_subtotal(2,4)
as v_subtotal;

drop function if exists fn_calcular_iva;
-- Función para calcular IVA
delimiter $$
create function fn_calcular_iva (p_iva decimal (4,2),
								p_id_cliente int)
returns decimal(6,2)
deterministic
begin

declare v_iva decimal(6,2);
set v_iva =
(select distinct fn_calcular_subtotal(2,4) * p_iva
as IVA from factura
where id_cliente = p_id_cliente);

return v_iva;
end$$
delimiter ; 

select fn_calcular_iva(.21,4)
as v_iva;

drop function if exists fn_calcular_total;
-- Función para calcular TOTAL CON IVA
delimiter $$
create function fn_calcular_total (p_id_cliente int)
returns decimal(6,2)
deterministic
begin

declare v_total decimal(6,2);
set v_total =
(select distinct fn_calcular_subtotal(2,4) + fn_calcular_iva(.21,4)
as TOTAL from factura
where id_cliente = p_id_cliente);

return v_total;
end$$
delimiter ; 

select fn_calcular_total(4)
as v_total;

-- Mostrar algunos campos de la tabla factura y los resultados de las funciones para el cliente con ID.4
select no_folio, fecha,detalle, precio_unitario_dlls,
fn_calcular_subtotal(2,4) as SUBTOTAL,
fn_calcular_iva(.21,4) as IVA,
fn_calcular_total(4) as TOTAL
from factura
where id_cliente = 4;

-- Sumar la columna de total_dll
SELECT SUM(TOTAL_DLLS) AS TOTAL_DLLS FROM FACTURA;


-- LISTAR CLIENTES POR CIUDAD
DELIMITER $$
DROP procedure if exists SP_CLIENTES_POR_CIUDAD;
CREATE PROCEDURE SP_CLIENTES_POR_CIUDAD(IN NOMBRE_CIUDAD VARCHAR (50))
BEGIN
SELECT * 
FROM CLIENTES
WHERE CIUDAD = NOMBRE_CIUDAD;
END$$
DELIMITER ; 

CALL SP_CLIENTES_POR_CIUDAD('SALTILLO');

-- CUANTOS CLIENTES POR CIUDAD SON
DELIMITER $$
DROP procedure if exists SP_CUANTOS_CLIENTES_POR_CIUDAD;
CREATE PROCEDURE SP_CUANTOS_CLIENTES_POR_CIUDAD(IN NOM_CIUDAD VARCHAR (50), OUT NUMERO INT)
BEGIN
SELECT COUNT(CIUDAD)
INTO NUMERO
FROM CLIENTES
WHERE CIUDAD = NOM_CIUDAD 
END$$
DELIMITER ; 

CALL SP_CUANTOS_CLIENTES_POR_CIUDAD('SALTILLO', @NUMERO);
select @NUMERO AS TOTAL_CLIENTES;

-- CREAR REGISTROS EN TABLA PERSONAL
DELIMITER $$
CREATE PROCEDURE SP_CREAR_PERSONAL (IN ID_PERSONAL int,
									IN NOMBRE_EMPLEADO varchar(50),
									IN APELLIDOS_EMPLEADO varchar(50),
									IN DIRECCION varchar(250),
									IN CIUDAD varchar(15),
									IN ESTADO varchar(15),
									IN CP int,
									IN E_MAIL varchar(50),
									IN TELEFONO varchar(15),
									IN CARGO varchar(50))
BEGIN
INSERT INTO
PERSONAL(ID_PERSONAL, NOMBRE_EMPLEADO, APELLIDOS_EMPLEADO, DIRECCION, CIUDAD, ESTADO, CP, E_MAIL, TELEFONO, CARGO)
VALUES
(ID_PERSONAL, NOMBRE_EMPLEADO, APELLIDOS_EMPLEADO, DIRECCION, CIUDAD, ESTADO, CP, E_MAIL, TELEFONO, CARGO);
END$$
DELIMITER ;

CALL SP_CREAR_PERSONAL(10, 'ULISES', 'MALDONADO SIFUENTES', 'CALLE SUR 780' , 'SALTILLO', 'COAHUILA', 45780, 'ULISIFUENTES@HOTMAIL.COM', 8447502369, 'VETERINARIO');

SELECT * FROM PERSONAL;

-- ORDENAR LOS REGISTROS DE UNA TABLA EN BASE A UNA COLUMNA Y SE PASE POR PARAMETRO SI ES ASCENDENTE O DESCENDENTE
DELIMITER $$
DROP PROCEDURE IF EXISTS SP_ORDENAR;
CREATE PROCEDURE SP_ORDENAR (INOUT PARAM_TABLA VARCHAR(50), INOUT PARAM_COLUMNA VARCHAR(50), INOUT PARAM_ORDEN VARCHAR(32))
BEGIN
SET @T1 = CONCAT('SELECT * FROM', PARAM_TABLA, 'U ORDER BY',' ',PARAM_COLUMNA,' ', PARAM_ORDEN);
PREPARE PARAM_STMT FROM @T1
EXECUTE PARAM_STMT;
DEALLOCATE PREPARE PARAM_STMT;
END $$
DELIMITER ;
SET @PARAM_TABLA = 'PERSONAL';
SET @PARAM_COLUMNA = 'NOMBRE_EMPLEADO';
SET @PARAM_ORDEN = 'DES';

CALL SP_ORDENAR (@PARAM_TABLA, @PARAM_ORDER, @PARAM_ASC_DES);

select * from clientes;

-- TRIGGERS
-- TABLA PARA MOSTRAR CAMBIOS EN LA TABLA CLIENTES
DROP TABLE IF exists LOG_AUDITORIA;
CREATE TABLE IF NOT exists LOG_AUDITORIA
(ID_LOG INT auto_increment,
NOMBRE_DE_ACCION varchar(10),
NOMBRE_TABLA varchar(50),
USUARIO varchar(100),
FECHA_UPD_INS_DEL DATE,
primary key(ID_LOG)
);

/* TABLA PARA MOSTRAR CAMBIOS EN LA TABLA CLIENTES MOSTRANDO USUARIO, FECHA Y HORA DE CUANDO SE HIZO CAMBIO 
Y TRES CAMPOS IMPORTANTES DE LA TABLA CLIENTES */
drop table if exists LOG_AUDITORIA_2;
CREATE TABLE IF NOT exists LOG_AUDITORIA_2
(ID_LOG int auto_increment,
NOMBRE varchar(50),
APELLIDOS varchar(50),
TELÉFONO varchar(15),
NOMBRE_DE_ACCION VARCHAR (10),
NOMBRE_TABLA VARCHAR (50),
USUARIO VARCHAR(50),
FECHA_UPD_INS_DEL DATE,
HORA time,
PRIMARY KEY (ID_LOG)
);

/*TRIGGER PARA DETETAR CAMBIOS POSTERIOR A UN INSERT EN LA TABLA CLIENTES PARA LA TABLA AUDITORIA*/
DELIMITER $$
CREATE trigger TRG_LOG_CLIENTES AFTER INSERT ON CLIENTES
FOR EACH ROW
BEGIN
INSERT INTO LOG_AUDITORIA (NOMBRE_DE_ACCION, NOMBRE_TABLA, USUARIO, FECHA_UPD_INS_DEL)
VALUES ('INSERT', 'CLIENTES', current_user(), now());
END$$
DELIMITER ;

/*TRIGGER PARA DETECTAR CAMBIOS POSTERIOR A UN INSERT EN LA TABLA CLIENTES PARA LA TABLA AUDITORIA_2 
(ESTA TABLA ES MÁS COMPLETA)*/
DROP trigger IF exists TRG_LOS_CLIENTES_2;
DELIMITER //
CREATE trigger TRG_LOS_CLIENTES_2 AFTER INSERT ON CLIENTES
FOR EACH ROW
BEGIN
INSERT INTO LOG_AUDITORIA_2 (NOMBRE, APELLIDOS, TELÉFONO, NOMBRE_DE_ACCION, NOMBRE_TABLA, USUARIO, FECHA_UPD_INS_DEL,HORA)
VALUES (NEW.NOMBRE, NEW.APELLIDOS, NEW.TELÉFONO, 'INSERT', 'CLIENTES', current_user(), now(), current_time());
END//
DELIMITER ;

SELECT * FROM LOG_AUDITORIA;
SELECT * FROM LOG_AUDITORIA_2;
SELECT * FROM CLIENTES;

INSERT INTO CLIENTES(ID_CLIENTE, NOMBRE, APELLIDOS, E_MAIL, DIRECCIÓN, CIUDAD, ESTADO, CP, TELÉFONO, FECHA_DE_NACIMIENTO)
VALUES (17, 'ENRIQUE', 'LOPEZ LOPEZ', 'LOPEZLOPEZ@HOTMAIL.COM', 'AVENIDA SUR 877', 'RAMOS ARIZPE', 'COAHUILA', 63304, 8422781415, 19890102);

/*TRIGGER PARA DETECTAR CAMBIOS DE UN UPDATE EN LA TABLA CLIENTES PARA LA TABLA AUDITORIA_2*/
DROP TRIGGER IF exists TRG_LOG_CLIENTES_3
DELIMITER //
CREATE TRIGGER TRG_LOG_CLIENTES_3 BEFORE UPDATE ON CLIENTES
FOR EACH ROW
BEGIN
INSERT INTO LOG_AUDITORIA_2(NOMBRE, APELLIDOS, TELÉFONO, NOMBRE_DE_ACCION, NOMBRE_TABLA, USUARIO, FECHA_UPD_INS_DEL,HORA)
VALUES ( CONCAT(OLD.NOMBRE, '-', NEW.NOMBRE), CONCAT(OLD.APELLIDOS, '-', NEW.APELLIDOS), OLD.TELÉFONO, 'UPDATE','CLIENTES',current_user(), now(),current_time());
END//
DELIMITER ;

SELECT * FROM CLIENTES;
update CLIENTES SET NOMBRE = 'CAROLINA' WHERE ID_CLIENTE = 5;
SELECT * FROM LOG_AUDITORIA_2;

/* TABLA PARA MOSTRAR CAMBIOS EN LA TABLA MASCOTAS MOSTRANDO USUARIO, FECHA Y HORA DE CUANDO SE HIZO CAMBIO 
Y DOS CAMPOS IMPORTANTES DE LA TABLA MASCOTAS */
SELECT * FROM MASCOTAS;
drop table if exists LOG_AUDITORIA_3;
CREATE TABLE IF NOT exists LOG_AUDITORIA_3
(ID_LOG int auto_increment,
NOMBRE_MASCOTA varchar(350),
PROPIETARIO varchar(350),
NOMBRE_DE_ACCION VARCHAR (10),
NOMBRE_TABLA VARCHAR (50),
USUARIO VARCHAR(50),
FECHA_UPD_INS_DEL DATE,
HORA time,
PRIMARY KEY (ID_LOG)
);

/*TRIGGER PARA DETECTAR CAMBIOS POSTERIOR A UN INSERT EN LA TABLA MASCOTAS PARA LA TABLA AUDITORIA_3*/
DROP trigger IF exists TRG_LOG_MASCOTAS;
DELIMITER //
CREATE trigger TRG_LOG_MASCOTAS AFTER INSERT ON MASCOTAS
FOR EACH ROW
BEGIN
INSERT INTO LOG_AUDITORIA_3 (NOMBRE_MASCOTA, PROPIETARIO,NOMBRE_DE_ACCION, NOMBRE_TABLA, USUARIO, FECHA_UPD_INS_DEL,HORA)
VALUES (NEW.NOMBRE_MASCOTA, NEW.PROPIETARIO,'INSERT', 'MASCOTAS', current_user(), now(), current_time());
END//
DELIMITER ;

SELECT * FROM LOG_AUDITORIA_3;

INSERT INTO MASCOTAS(ID_MASCOTA, NOMBRE_MASCOTA, RAZA, SEXO_MASCOTA, COLOR, EDAD, TAMANO, PESO, PEDIGREE, CHIP, DESCRIPCIÓN, FECHA_DE_NACIMIENTO,ID_CLIENTE,PROPIETARIO)
VALUES (16, 'PATO', 'Antiguo Pastor Ingles', 'M', 'Gris con blanco',5,63,13,'FCMV0619-D',1400317416, 'Goza de buena salud', 20230101, 2,'Ezequiel Ulloa Montes');

/*TRIGGER PARA DETECTAR CAMBIOS DE UN UPDATE EN LA TABLA MASCOTAS PARA LA TABLA AUDITORIA_3*/
DROP TRIGGER IF exists TRG_LOG_MASCOTAS_2
DELIMITER //
CREATE TRIGGER TRG_LOG_MASCOTAS_2 BEFORE UPDATE ON MASCOTAS
FOR EACH ROW
BEGIN
INSERT INTO LOG_AUDITORIA_3 (NOMBRE_MASCOTA, PROPIETARIO,NOMBRE_DE_ACCION, NOMBRE_TABLA, USUARIO, FECHA_UPD_INS_DEL,HORA)
VALUES ( CONCAT('ANTIGUO_NOMBRE: ', OLD.NOMBRE_MASCOTA, ' - NUEVO_NOMBRE: ', NEW.NOMBRE_MASCOTA), CONCAT('ANTIGUO_PROPIETARIO: ',OLD.PROPIETARIO, ' - NUEVO_PROPIETARIO: ', NEW.PROPIETARIO),'UPDATE','MASCOTAS',current_user(), now(),current_time());
END//
DELIMITER ;

SELECT * FROM MASCOTAS;
update MASCOTAS SET PROPIETARIO = 'Catalina Herrera Ulloa' WHERE ID_CLIENTE = 3;
update MASCOTAS SET NOMBRE_MASCOTA = 'SUSY' WHERE ID_MASCOTA=4;
SELECT * FROM LOG_AUDITORIA_3;






 



 


 

