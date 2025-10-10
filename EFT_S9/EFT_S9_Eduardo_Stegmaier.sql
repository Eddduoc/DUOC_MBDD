-- MBDD EFT - S9 - Cristaleria ANDINA SA

--DROP TABLES / CONSTRAINTS  /SEQUENCE
DROP TABLE ASIGNACION_TURNO CASCADE CONSTRAINTS;
DROP TABLE ORDEN_MANTENCION CASCADE CONSTRAINTS;
DROP TABLE TECNICO_MANTENCION CASCADE CONSTRAINTS;
DROP TABLE OPERARIO CASCADE CONSTRAINTS;
DROP TABLE JEFE_TURNO CASCADE CONSTRAINTS;
DROP TABLE MAQUINA CASCADE CONSTRAINTS;
DROP TABLE EMPLEADO CASCADE CONSTRAINTS;
DROP TABLE PLANTA CASCADE CONSTRAINTS;
DROP TABLE COMUNA CASCADE CONSTRAINTS;
DROP TABLE TURNO CASCADE CONSTRAINTS;
DROP TABLE TIPO_MAQUINA CASCADE CONSTRAINTS;
DROP TABLE AFP CASCADE CONSTRAINTS;
DROP TABLE SALUD CASCADE CONSTRAINTS;
DROP TABLE REGION CASCADE CONSTRAINTS;

DROP SEQUENCE seq_region;

--CREATE TABLES fuerte a debil

CREATE TABLE REGION (
    id_region      NUMBER(2)      CONSTRAINT pk_region PRIMARY KEY,
    nombre         VARCHAR2(25)   NOT NULL
);

CREATE TABLE SALUD (
    id_salud       NUMBER(2)      CONSTRAINT pk_salud PRIMARY KEY,
    nombre_salud      VARCHAR2(25)   NOT NULL
);

CREATE TABLE AFP (
    id_afp         NUMBER(4)      CONSTRAINT pk_afp PRIMARY KEY,
    nombre_afp     VARCHAR2(25)   NOT NULL
);

CREATE TABLE TIPO_MAQUINA (
    id_tipo_maquina NUMBER(5)     CONSTRAINT pk_tipo_maquina PRIMARY KEY,
    nombre          VARCHAR2(40)  NOT NULL
);

CREATE TABLE TURNO (
    id_turno      VARCHAR2(5)     CONSTRAINT pk_turno PRIMARY KEY,
    tipo_turno    VARCHAR2(25)    NOT NULL,
    hora_inicio   CHAR(5)         NOT NULL,
    hora_termino  CHAR(5)         NOT NULL
);

CREATE TABLE COMUNA (
    id_comuna   NUMBER(4)       GENERATED ALWAYS AS IDENTITY (START WITH 1050 INCREMENT BY 5)
    CONSTRAINT pk_comuna PRIMARY KEY,
    nombre      VARCHAR2(25)    NOT NULL,
    id_region   NUMBER(2)       NOT NULL,
    CONSTRAINT fk_comuna_region FOREIGN KEY (id_region) REFERENCES REGION(id_region)
);

CREATE TABLE PLANTA (
    id_planta    NUMBER(2)       CONSTRAINT pk_planta PRIMARY KEY,
    nombre       VARCHAR2(25)    NOT NULL,
    direccion        VARCHAR2(100) NOT NULL,
    id_comuna    NUMBER(4)       NOT NULL,
    CONSTRAINT fk_planta_comuna FOREIGN KEY (id_comuna) REFERENCES COMUNA(id_comuna)
);

CREATE TABLE EMPLEADO (
    id_empleado        NUMBER(5)      CONSTRAINT pk_empleado PRIMARY KEY,
    rut                VARCHAR2(10)   NOT NULL,
    primer_nombre      VARCHAR2(25)   NOT NULL,
    segundo_nombre     VARCHAR2(25)   NOT NULL,
    primer_apellido    VARCHAR2(25)   NOT NULL,
    segundo_apellido   VARCHAR2(25)   NOT NULL,
    fecha_contratacion DATE           NOT NULL,
    sueldo_base        NUMBER(7)      NOT NULL,
    activo             CHAR(1)        DEFAULT 'S' NOT NULL,
    id_afp             NUMBER(4)      NOT NULL,
    id_salud           NUMBER(2)      NOT NULL,
    id_planta          NUMBER(2)      NOT NULL,
    id_jefe           NUMBER(5),
    CONSTRAINT fk_empleado_afp FOREIGN KEY (id_afp) REFERENCES AFP(id_afp),
    CONSTRAINT fk_empleado_salud FOREIGN KEY (id_salud) REFERENCES SALUD(id_salud),
    CONSTRAINT fk_empleado_planta FOREIGN KEY (id_planta) REFERENCES PLANTA(id_planta),

    CONSTRAINT fk_empleado_jefe FOREIGN KEY (id_jefe) REFERENCES EMPLEADO(id_empleado)
);

CREATE TABLE MAQUINA (
    numero_maquina  NUMBER(5)      NOT NULL,
    id_planta       NUMBER(2)      NOT NULL,
    nombre          VARCHAR2(25)   NOT NULL,
    activo          CHAR(1)        NOT NULL,
    id_tipo_maquina NUMBER(5)      NOT NULL,
    CONSTRAINT pk_maquina PRIMARY KEY (numero_maquina, id_planta),
    CONSTRAINT fk_maquina_planta FOREIGN KEY (id_planta) REFERENCES PLANTA(id_planta),
    CONSTRAINT fk_maquina_tipo FOREIGN KEY (id_tipo_maquina) REFERENCES TIPO_MAQUINA(id_tipo_maquina)
);

CREATE TABLE JEFE_TURNO (
    id_empleado     NUMBER(5)      CONSTRAINT pk_jefe_turno PRIMARY KEY,
    area            VARCHAR2(40)   NOT NULL,
    max_operarios  NUMBER(4)      NOT NULL,
    CONSTRAINT fk_jefe_turno_empleado FOREIGN KEY (id_empleado) REFERENCES EMPLEADO(id_empleado)
);

CREATE TABLE OPERARIO (
    id_empleado    NUMBER(5)      CONSTRAINT pk_operario PRIMARY KEY,
    categoria      VARCHAR2(50)   NOT NULL,
    certificacion  VARCHAR2(50),
    horas_turno    NUMBER(2)      NOT NULL,
    CONSTRAINT fk_operario_empleado FOREIGN KEY (id_empleado) REFERENCES EMPLEADO(id_empleado)
);

CREATE TABLE TECNICO_MANTENCION (
    id_empleado       NUMBER(5)      CONSTRAINT pk_tecnico_mantencion PRIMARY KEY,
    especialidad      VARCHAR2(50)   NOT NULL,
    certificacion     VARCHAR2(50),
    tiempo_respuesta  NUMBER(4)      NOT NULL,
    CONSTRAINT fk_tecnico_mantencion_empleado FOREIGN KEY (id_empleado) REFERENCES EMPLEADO(id_empleado)
);

CREATE TABLE ORDEN_MANTENCION (
    id_orden          NUMBER(5)       CONSTRAINT pk_orden_mantencion PRIMARY KEY,
    fecha_programada  DATE            NOT NULL,
    fecha_ejecucion   DATE,
    descripcion       VARCHAR2(200),
    id_empleado       NUMBER(5)       NOT NULL,
    numero_maquina    NUMBER(5)       NOT NULL,
    id_planta         NUMBER(2)       NOT NULL,
    CONSTRAINT fk_orden_mantencion_tecnico FOREIGN KEY (id_empleado) REFERENCES EMPLEADO(id_empleado),
    CONSTRAINT fk_orden_mantencion_maquina FOREIGN KEY (numero_maquina, id_planta) REFERENCES MAQUINA(numero_maquina, id_planta)
);

CREATE TABLE ASIGNACION_TURNO (
    id_empleado     NUMBER(5)       NOT NULL,
    fecha           DATE            NOT NULL,
    rol             VARCHAR2(200),
    numero_maquina  NUMBER(5),
    id_planta       NUMBER(2)       NOT NULL,
    id_turno        VARCHAR2(5)     NOT NULL,
    CONSTRAINT pk_asignacion_turno PRIMARY KEY (id_empleado, fecha),

    CONSTRAINT fk_asignacion_turno_empleado FOREIGN KEY (id_empleado) REFERENCES EMPLEADO(id_empleado),
    CONSTRAINT fk_asignacion_turno_maquina FOREIGN KEY (numero_maquina, id_planta) REFERENCES MAQUINA(numero_maquina, id_planta),
    CONSTRAINT fk_asignacion_turno_turno FOREIGN KEY (id_turno) REFERENCES TURNO(id_turno)
);

------------------
-- Aplicar ALTERs
ALTER TABLE ORDEN_MANTENCION
    ADD CONSTRAINT check_fecha_ejecucion
    CHECK (fecha_ejecucion >= fecha_programada);

--nombres unicos
ALTER TABLE REGION
    ADD CONSTRAINT unique_region_nombre UNIQUE (nombre);
ALTER TABLE SALUD
    ADD CONSTRAINT unique_salud_nombre UNIQUE (nombre_salud);
ALTER TABLE AFP
    ADD CONSTRAINT unique_afp_nombre UNIQUE (nombre_afp);
ALTER TABLE TIPO_MAQUINA
    ADD CONSTRAINT unique_tipo_maquina_nombre UNIQUE (nombre);
ALTER TABLE TURNO
    ADD CONSTRAINT unique_turno_horario UNIQUE (tipo_turno);

----------------
--SEQUENCE
CREATE SEQUENCE seq_region START WITH 21 INCREMENT BY 1;

----------------

--INSERTS

-- REGION
INSERT INTO REGION (id_region, nombre) VALUES (seq_region.NEXTVAL , 'Región de Valparaíso');
INSERT INTO REGION (id_region, nombre) VALUES (seq_region.NEXTVAL, 'Región Metropolitana');

-- COMUNA 
INSERT INTO COMUNA (nombre, id_region) VALUES ('Quilpué', 21);
INSERT INTO COMUNA (nombre, id_region) VALUES ('Maipú', 22);

-- PLANTA        
INSERT INTO PLANTA (id_planta, nombre, direccion, id_comuna) VALUES (45, 'Planta Oriente', 'Camino Industrial 1234', 1050);
INSERT INTO PLANTA (id_planta, nombre, direccion, id_comuna) VALUES (46, 'Planta Costa', 'Av. Vidrieras 890', 1055);

-- TURNO
INSERT INTO TURNO (id_turno, tipo_turno, hora_inicio, hora_termino) VALUES ('M0715', 'Mañana', '07:00', '15:00');
INSERT INTO TURNO (id_turno, tipo_turno, hora_inicio, hora_termino) VALUES ('N2307', 'Noche', '23:00', '07:00');
INSERT INTO TURNO (id_turno, tipo_turno, hora_inicio, hora_termino) VALUES ('T1523', 'Tarde', '15:00', '23:00');

---------------
--Fase 4: Recuperacion de Datos

--INFORME 1
SELECT 
    id_turno || ' ' || tipo_turno   AS "TURNO",
    hora_inicio                     AS "ENTRADA",
    hora_termino                    AS "SALIDA"
 FROM TURNO
 WHERE hora_inicio >= '20:00' 
 ORDER BY hora_inicio DESC;


--INFORME 2
SELECT 
    tipo_turno || ' ' || id_turno   AS "TURNO",
    hora_inicio                     AS "ENTRADA",
    hora_termino                    AS "SALIDA"
 FROM TURNO
 WHERE hora_inicio >= '06:00' AND hora_inicio <= '14:59'
 ORDER BY hora_inicio ASC;
