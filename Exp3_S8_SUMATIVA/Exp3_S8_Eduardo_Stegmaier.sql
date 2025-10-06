-- MBDD SUMATIVA S8 - MiniMarket “Dona Marta”
 
--Drop tables /constraints /sequence
DROP TABLE DETALLE_VENTA CASCADE CONSTRAINTS;
DROP TABLE VENTA CASCADE CONSTRAINTS;
DROP TABLE VENDEDOR CASCADE CONSTRAINTS;
DROP TABLE ADMINISTRATIVO CASCADE CONSTRAINTS;
DROP TABLE EMPLEADO CASCADE CONSTRAINTS;
DROP TABLE PRODUCTO CASCADE CONSTRAINTS;
DROP TABLE PROVEEDOR CASCADE CONSTRAINTS;
DROP TABLE COMUNA CASCADE CONSTRAINTS;
DROP TABLE CATEGORIA CASCADE CONSTRAINTS;
DROP TABLE MARCA CASCADE CONSTRAINTS;
DROP TABLE MEDIO_PAGO CASCADE CONSTRAINTS;
DROP TABLE AFP CASCADE CONSTRAINTS;
DROP TABLE SALUD CASCADE CONSTRAINTS;
DROP TABLE REGION CASCADE CONSTRAINTS;

DROP SEQUENCE seq_salud;
DROP SEQUENCE seq_empleado;


--Crear Tablas
--tablas sin FK
CREATE TABLE REGION (
    id_region NUMBER(4) CONSTRAINT pk_region PRIMARY KEY,
    nom_region VARCHAR2(255) NOT NULL
);

CREATE TABLE SALUD (
    id_salud NUMBER(4) CONSTRAINT pk_salud PRIMARY KEY,
    nom_salud VARCHAR2(40) NOT NULL
);

CREATE TABLE AFP (
    id_afp NUMBER(5) GENERATED ALWAYS AS IDENTITY (START WITH 210 INCREMENT BY 6)
    CONSTRAINT pk_afp PRIMARY KEY,
    nom_afp VARCHAR2(255) NOT NULL
);

CREATE TABLE MEDIO_PAGO (
    id_mpago NUMBER(3) CONSTRAINT pk_mpago PRIMARY KEY,
    nombre_mpago VARCHAR2(50) NOT NULL
);

CREATE TABLE MARCA (
    id_marca NUMBER(3) CONSTRAINT pk_marca PRIMARY KEY,
    nombre_marca VARCHAR2(25) NOT NULL
);

CREATE TABLE CATEGORIA (
    id_categoria NUMBER(3) CONSTRAINT pk_categoria PRIMARY KEY,
    nombre_categoria VARCHAR2(255) NOT NULL
);

--con FK
CREATE TABLE COMUNA (
    id_comuna NUMBER(4) CONSTRAINT pk_comuna PRIMARY KEY,
    nom_comuna VARCHAR2(100) NOT NULL,
    cod_region NUMBER(4) NOT NULL,
    CONSTRAINT fk_comuna_region FOREIGN KEY (cod_region) REFERENCES REGION(id_region)
);

CREATE TABLE PROVEEDOR (
    id_proveedor NUMBER(5) CONSTRAINT pk_proveedor PRIMARY KEY,
    nombre_proveedor VARCHAR2(150) NOT NULL,
    rut_proveedor VARCHAR2(10) NOT NULL,
    telefono VARCHAR2(10) NOT NULL,
    email VARCHAR2(200) NOT NULL,
    direccion VARCHAR2(200) NOT NULL,
    cod_comuna NUMBER(4) NOT NULL,
    CONSTRAINT fk_proveedor_comuna FOREIGN KEY (cod_comuna) REFERENCES COMUNA(id_comuna)
);

CREATE TABLE PRODUCTO (
    id_producto NUMBER(4) CONSTRAINT pk_producto PRIMARY KEY,
    nombre_producto VARCHAR2(100) NOT NULL,
    precio_unitario NUMBER NOT NULL,
    origen_nacional CHAR(1) NOT NULL,
    stock_minimo NUMBER(3) NOT NULL,
    activo CHAR(1) NOT NULL,
    cod_marca NUMBER(3) NOT NULL,
    cod_categoria NUMBER(3) NOT NULL,
    cod_proveedor NUMBER(5) NOT NULL,
    CONSTRAINT fk_producto_marca FOREIGN KEY (cod_marca) REFERENCES MARCA(id_marca),
    CONSTRAINT fk_producto_categoria FOREIGN KEY (cod_categoria) REFERENCES CATEGORIA(id_categoria),
    CONSTRAINT fk_producto_proveedor FOREIGN KEY (cod_proveedor) REFERENCES PROVEEDOR(id_proveedor)
);

CREATE TABLE EMPLEADO (
    id_empleado NUMBER(4) CONSTRAINT pk_empleado PRIMARY KEY,
    rut_empleado VARCHAR2(10) NOT NULL,
    nombre_empleado VARCHAR2(25) NOT NULL,
    apellido_paterno VARCHAR2(25) NOT NULL,
    apellido_materno VARCHAR2(25) NOT NULL,
    fecha_contratacion DATE NOT NULL,
    sueldo_base NUMBER(10) NOT NULL,
    bono_jefatura NUMBER(10),
    activo CHAR(1) NOT NULL,
    tipo_empleado VARCHAR2(25) NOT NULL,
    cod_empleado NUMBER(4),
    cod_salud NUMBER(4) NOT NULL,
    cod_afp NUMBER(5) NOT NULL,
    CONSTRAINT fk_empleado_salud FOREIGN KEY (cod_salud) REFERENCES SALUD(id_salud),
    CONSTRAINT fk_empleado_afp FOREIGN KEY (cod_afp) REFERENCES AFP(id_afp),
    CONSTRAINT fk_empleado_empleado FOREIGN KEY (cod_empleado) REFERENCES EMPLEADO(id_empleado)
);

--Subtipos de empleado
CREATE TABLE ADMINISTRATIVO (
    id_empleado NUMBER(4) CONSTRAINT pk_administrativo PRIMARY KEY,
    CONSTRAINT fk_empleado_administrativo FOREIGN KEY (id_empleado) REFERENCES EMPLEADO(id_empleado)
);
CREATE TABLE VENDEDOR (
    id_empleado NUMBER(4) CONSTRAINT pk_vendedor PRIMARY KEY,
    comision_venta NUMBER(5,2) NOT NULL,
    CONSTRAINT fk_empleado_vendedor FOREIGN KEY (id_empleado) REFERENCES EMPLEADO(id_empleado)
);

CREATE TABLE VENTA (
    id_venta NUMBER(4) GENERATED ALWAYS AS IDENTITY (START WITH 5050 INCREMENT BY 3)
    CONSTRAINT pk_venta PRIMARY KEY,
    fecha_venta DATE NOT NULL,
    total_venta NUMBER(10) NOT NULL,
    cod_mpago NUMBER(3) NOT NULL,
    cod_empleado NUMBER(4) NOT NULL,
    CONSTRAINT fk_venta_mpago FOREIGN KEY (cod_mpago) REFERENCES MEDIO_PAGO(id_mpago),
    CONSTRAINT fk_venta_empleado FOREIGN KEY (cod_empleado) REFERENCES EMPLEADO(id_empleado)
);

CREATE TABLE DETALLE_VENTA (
    cod_venta NUMBER(4) NOT NULL,
    cod_producto NUMBER(4) NOT NULL,
    cantidad NUMBER(6) NOT NULL,
    CONSTRAINT pk_cod_venta_producto PRIMARY KEY (cod_venta, cod_producto),
    CONSTRAINT fk_cod_venta FOREIGN KEY (cod_venta) REFERENCES VENTA(id_venta),
    CONSTRAINT fk_cod_producto FOREIGN KEY (cod_producto) REFERENCES PRODUCTO(id_producto)
);


-- CASO 2: ALTER TABLE CKECK / UNIQUE
--Empleado
ALTER TABLE EMPLEADO ADD CONSTRAINT ck_empleado_sueldo CHECK (sueldo_base >= 400000);

--Vendedor --ARREGLAR
ALTER TABLE VENDEDOR ADD CONSTRAINT ck_vendedor_comision CHECK (comision_venta BETWEEN 0 AND 0.25);

--Producto
ALTER TABLE PRODUCTO ADD CONSTRAINT ck_producto_stock_minimo CHECK (stock_minimo >= 3);

--Proveedor
ALTER TABLE PROVEEDOR ADD CONSTRAINT un_proveedor_email UNIQUE (email);

--Marca
ALTER TABLE MARCA ADD CONSTRAINT un_marca_nombre UNIQUE (nombre_marca);

--Detalle Venta
ALTER TABLE DETALLE_VENTA ADD CONSTRAINT ck_detalle_venta_cantidad CHECK (cantidad >= 1);


-- CASO 3: POBLAR TABLAS

--SEQUENCE
CREATE SEQUENCE seq_salud START WITH 2050   INCREMENT BY 10;
CREATE SEQUENCE seq_empleado START WITH 750  INCREMENT BY 3;

--INSERTs

INSERT INTO REGION (id_region, nom_region) VALUES (1, 'Region Metropolitana');
INSERT INTO REGION (id_region, nom_region) VALUES (2, 'Valparaiso');
INSERT INTO REGION (id_region, nom_region) VALUES (3, 'Biobio');
INSERT INTO REGION (id_region, nom_region) VALUES (4, 'Los Lagos');

INSERT INTO SALUD (id_salud, nom_salud) VALUES (seq_salud.NEXTVAL, 'Fonasa');
INSERT INTO SALUD (id_salud, nom_salud) VALUES (seq_salud.NEXTVAL, 'Isapre Colmena');
INSERT INTO SALUD (id_salud, nom_salud) VALUES (seq_salud.NEXTVAL, 'Isapre Banmedica');
INSERT INTO SALUD (id_salud, nom_salud) VALUES (seq_salud.NEXTVAL, 'Isapre Cruz Blanca');

INSERT INTO AFP (nom_afp) VALUES ('Habitat');
INSERT INTO AFP (nom_afp) VALUES ('Provida');
INSERT INTO AFP (nom_afp) VALUES ('Cuprum');
INSERT INTO AFP (nom_afp) VALUES ('PlanVital');

INSERT INTO MEDIO_PAGO (id_mpago, nombre_mpago) VALUES (11, 'Efectivo');
INSERT INTO MEDIO_PAGO (id_mpago, nombre_mpago) VALUES (12, 'Tarjeta Debito');
INSERT INTO MEDIO_PAGO (id_mpago, nombre_mpago) VALUES (13, 'Tarjeta Credito');
INSERT INTO MEDIO_PAGO (id_mpago, nombre_mpago) VALUES (14, 'Cheque');

INSERT INTO EMPLEADO VALUES (seq_empleado.NEXTVAL,'11111111-1', 'Marcela',  'Gonzaléz',  'Pérez',    TO_DATE('15-03-2022', 'DD-MM-YYYY'), 950000, 80000, 'S', 'Administrativo',  NULL, 2050, 210);
INSERT INTO EMPLEADO VALUES (seq_empleado.NEXTVAL,'22222222-2', 'José',     'Muñoz',     'Ramírez',  TO_DATE('10-07-2021', 'DD-MM-YYYY'), 900000, 75000, 'S', 'Administrativo',  NULL, 2060, 216);
INSERT INTO EMPLEADO VALUES (seq_empleado.NEXTVAL,'33333333-3', 'Verónica', 'Soto',      'Alarcón',  TO_DATE('05-01-2020', 'DD-MM-YYYY'), 880000, 70000, 'S', 'Vendedor',        750, 2060, 228);
INSERT INTO EMPLEADO VALUES (seq_empleado.NEXTVAL,'44444444-4', 'Luis',     'Reyes',     'Fuentes',  TO_DATE('01-04-2023', 'DD-MM-YYYY'), 560000, NULL, 'S', 'Vendedor',         750, 2070, 228);
INSERT INTO EMPLEADO VALUES (seq_empleado.NEXTVAL,'55555555-5', 'Claudia',  'Fernández', 'Lagos',    TO_DATE('15-04-2023', 'DD-MM-YYYY'), 600000, NULL, 'S', 'Vendedor',         753, 2070, 216);
INSERT INTO EMPLEADO VALUES (seq_empleado.NEXTVAL,'66666666-6', 'Carlos',   'Navarro',   'Vega',     TO_DATE('01-05-2023', 'DD-MM-YYYY'), 610000, NULL, 'S', 'Administrativo',   753, 2060, 210);
INSERT INTO EMPLEADO VALUES (seq_empleado.NEXTVAL,'77777777-7', 'Javiera',   'Pino',     'Rojas',    TO_DATE('10-05-2023', 'DD-MM-YYYY'), 650000, NULL, 'S', 'Administrativo',   750, 2050, 210);
INSERT INTO EMPLEADO VALUES (seq_empleado.NEXTVAL,'88888888-8', 'Diego',    'Mella',     'Contreras',TO_DATE('12-05-2023', 'DD-MM-YYYY'), 620000, NULL, 'S', 'Vendedor',         750, 2060, 216);
INSERT INTO EMPLEADO VALUES (seq_empleado.NEXTVAL,'99999999-9', 'Fernanda', 'Salas',     'Herrera',  TO_DATE('18-05-2023', 'DD-MM-YYYY'), 570000, NULL, 'S', 'Vendedor',         753, 2070, 228);
INSERT INTO EMPLEADO VALUES (seq_empleado.NEXTVAL,'10101010-0', 'Tomás',    'Vidal',     'Espinoza', TO_DATE('01-06-2023', 'DD-MM-YYYY'), 530000, NULL, 'S', 'Vendedor',         NULL, 2050, 222);

INSERT INTO VENTA (fecha_venta, total_venta, cod_mpago, cod_empleado) VALUES (TO_DATE('12-05-2023', 'DD-MM-YYYY'), 225990, 12, 771);
INSERT INTO VENTA (fecha_venta, total_venta, cod_mpago, cod_empleado) VALUES (TO_DATE('23-10-2023', 'DD-MM-YYYY'), 524990, 13, 777);
INSERT INTO VENTA (fecha_venta, total_venta, cod_mpago, cod_empleado) VALUES (TO_DATE('17-02-2023', 'DD-MM-YYYY'), 466990, 11, 759);

--CASO 4: RECUPERACIO DATOS

--SELECTs
--Empleado
SELECT 
    id_empleado                                     AS "IDENTIFICADOR",
    nombre_empleado  ||  ' ' || apellido_paterno    AS "NOMBRE COMPLETO",
    sueldo_base                                     AS "SALARIO",
    bono_jefatura                                   AS "BONIFICACION",
    (sueldo_base + bono_jefatura)                   AS "SALARIO SIMULADO" 
 FROM EMPLEADO
 WHERE activo = 'S'
 AND bono_jefatura IS NOT NULL
 ORDER BY (sueldo_base + bono_jefatura) DESC, apellido_paterno DESC;

SELECT 
    nombre_empleado  ||  ' ' || apellido_paterno    AS "EMPLEADO",
    sueldo_base                                     AS "SUELDO",
    0.08                                  AS "POSIBLE AUMENTO",
    (sueldo_base*1.08)                   AS "SALARIO SIMULADO" 
 FROM EMPLEADO
 WHERE sueldo_base BETWEEN 550000 AND 800000
 AND activo = 'S'
 ORDER BY sueldo_base DESC;
