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

-- VISTA para la Tabla Mascotas
CREATE OR REPLACE VIEW VW_MASCOTAS AS
(SELECT * FROM MASCOTAS);

-- VISTA De la tabla Kardex en donde el servicio que se muestra es Vacunas
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
 
 -- VISTA muestra la cantidad de veces que un servicio fue realizado
CREATE OR REPLACE VIEW VW_SERVICIO_MAS_SOLICITADO AS
 (SELECT SERVICIO, COUNT(*) AS CANTIDAD_SOLICITADO
 FROM KARDEX GROUP BY 1);
 
select * from VW_SERVICIO_MAS_SOLICITADO;
