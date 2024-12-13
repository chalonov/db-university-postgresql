-- DROP DATABASE IF EXISTS biblioteca;

CREATE DATABASE biblioteca
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    --LC_COLLATE = 'English_United States.1252'
    --LC_CTYPE = 'English_United States.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

CREATE SCHEMA biblioteca;

CREATE extension dblink;

SET search_path = biblioteca;

CREATE DOMAIN CODE_DOMAIN varchar(20) NOT NULL;

CREATE DOMAIN CODE_DOMAIN_NULL varchar(20) NULL;

CREATE DOMAIN ID_DOMAIN integer NOT NULL;
	
CREATE DOMAIN NAME_DOMAIN varchar(100) NOT NULL;

CREATE DOMAIN NAME_DOMAIN_NULL varchar(100) NULL;

---------------------------------------------------------------------
CREATE TABLE tipo_identificacion
(
	tipo	CODE_DOMAIN,
	nombre	NAME_DOMAIN
);

ALTER TABLE tipo_identificacion ADD CONSTRAINT tipo_identificacion_PK PRIMARY KEY (tipo);
ALTER TABLE tipo_identificacion ADD CONSTRAINT tipo_identificacion_UQ UNIQUE (nombre);
---------------------------------------------------------------------
CREATE TABLE persona
(
	tipo_identificacion	CODE_DOMAIN,
	identificacion		CODE_DOMAIN,
	primer_nombre		NAME_DOMAIN,
	segundo_nombre		NAME_DOMAIN_NULL,
	primer_apellido		NAME_DOMAIN,
	segundo_apellido	NAME_DOMAIN_NULL,
	direccion			varchar(100)	NULL,
	telefono			varchar(100)	NULL,
	fecha_nacimiento	date			NULL	
);

ALTER TABLE persona ADD CONSTRAINT persona_PK PRIMARY KEY (identificacion);
ALTER TABLE persona ADD CONSTRAINT persona_2_tipo_identificacion_FK FOREIGN KEY(tipo_identificacion) REFERENCES tipo_identificacion(tipo);
---------------------------------------------------------------------
CREATE TABLE estudiante
(
	codigo				CODE_DOMAIN,
	identificacion		CODE_DOMAIN
);

ALTER TABLE estudiante ADD CONSTRAINT estudiante_PK PRIMARY KEY (codigo);
ALTER TABLE estudiante ADD CONSTRAINT estudiante_2_persona_FK FOREIGN KEY(identificacion) REFERENCES persona(identificacion);
---------------------------------------------------------------------
CREATE TABLE bibliotecario
(
	codigo				CODE_DOMAIN,
	identificacion		CODE_DOMAIN
);

ALTER TABLE bibliotecario ADD CONSTRAINT bibliotecario_PK PRIMARY KEY (codigo);
ALTER TABLE bibliotecario ADD CONSTRAINT bibliotecario_2_persona_FK FOREIGN KEY(identificacion) REFERENCES persona(identificacion);
---------------------------------------------------------------------
CREATE TABLE autor
(
	codigo		ID_DOMAIN,
	nombre		NAME_DOMAIN
);

ALTER TABLE autor ADD CONSTRAINT autor_PK PRIMARY KEY (codigo);
ALTER TABLE autor ADD CONSTRAINT autor_UQ UNIQUE (nombre);
---------------------------------------------------------------------
CREATE TABLE libro
(
	isbn		CODE_DOMAIN,
	titulo		NAME_DOMAIN,
	editorial	NAME_DOMAIN
);

ALTER TABLE libro ADD CONSTRAINT libro_PK PRIMARY KEY (isbn);
---------------------------------------------------------------------
CREATE TABLE libro_autor
(
	isbn			CODE_DOMAIN,
	codigo_autor	ID_DOMAIN
);

ALTER TABLE libro_autor ADD CONSTRAINT libro_autor_PK PRIMARY KEY (isbn, codigo_autor);
ALTER TABLE libro_autor ADD CONSTRAINT libro_autor_2_libro_FK FOREIGN KEY(isbn) REFERENCES libro(isbn);
ALTER TABLE libro_autor ADD CONSTRAINT libro_autor_2_autor_FK FOREIGN KEY(codigo_autor) REFERENCES autor(codigo);
---------------------------------------------------------------------
CREATE TABLE ejemplar
(
	isbn	CODE_DOMAIN,
	id		ID_DOMAIN
);

ALTER TABLE ejemplar ADD CONSTRAINT ejemplar_PK PRIMARY KEY (isbn, id);
ALTER TABLE ejemplar ADD CONSTRAINT ejemplar_2_libro_FK FOREIGN KEY(isbn) REFERENCES libro(isbn);
---------------------------------------------------------------------
CREATE TABLE prestamo
(
	isbn				CODE_DOMAIN,
	id_ejemplar			ID_DOMAIN,
	codigo_estudiante	CODE_DOMAIN,
	fecha_prestamo		timestamp			NOT NULL DEFAULT now(),
	dias_prestamo		integer 			NOT NULL DEFAULT 3,
	fecha_devolucion	timestamp			NULL
);

ALTER TABLE prestamo ADD CONSTRAINT prestamo_PK PRIMARY KEY (isbn, id_ejemplar, codigo_estudiante, fecha_prestamo);
ALTER TABLE prestamo ADD CONSTRAINT prestamo_2_ejemplar_FK FOREIGN KEY(isbn, id_ejemplar) REFERENCES ejemplar(isbn, id);
ALTER TABLE prestamo ADD CONSTRAINT prestamo_2_estudiante_FK FOREIGN KEY(codigo_estudiante) REFERENCES estudiante(codigo);
---------------------------------------------------------------------
CREATE OR REPLACE VIEW biblioteca.ReporteLibros AS
SELECT l.isbn, l.titulo, l.editorial, a.nombre as autor 
FROM  biblioteca.libro l
INNER JOIN biblioteca.libro_autor la ON l.isbn = la.isbn 
INNER JOIN biblioteca.autor a ON la.codigo_autor = a.codigo;
---------------------------------------------------------------------
CREATE OR REPLACE VIEW biblioteca.DisponibilidadLibros AS
SELECT l.isbn, l.titulo, l.editorial, a.nombre as autor, ej.id as ejemplar
FROM  biblioteca.libro l
INNER JOIN biblioteca.libro_autor la ON l.isbn = la.isbn 
INNER JOIN biblioteca.autor a ON la.codigo_autor = a.codigo
INNER JOIN biblioteca.ejemplar ej on l.isbn = ej.isbn
WHERE (ej.isbn, ej.id) NOT IN 
(
	SELECT pre.isbn, pre.id_ejemplar
	FROM biblioteca.prestamo pre
	WHERE pre.isbn = ej.isbn AND pre.id_ejemplar = ej.id AND fecha_devolucion IS NULL
);
---------------------------------------------------------------------
CREATE OR REPLACE VIEW biblioteca.PrestamosPorEstudiante AS
SELECT l.isbn, l.titulo, l.editorial, a.nombre as autor, ej.id as ejemplar, pre.fecha_prestamo, pre.fecha_devolucion
FROM  biblioteca.libro l
INNER JOIN biblioteca.libro_autor la ON l.isbn = la.isbn 
INNER JOIN biblioteca.autor a ON la.codigo_autor = a.codigo
INNER JOIN biblioteca.ejemplar ej ON l.isbn = ej.isbn
INNER JOIN biblioteca.prestamo pre ON ej.isbn = pre.isbn AND pre.id_ejemplar = ej.id
WHERE pre.codigo_estudiante :: text = CURRENT_USER;
---------------------------------------------------------------------
