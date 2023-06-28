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

-- FUNCIONES

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


 

 


