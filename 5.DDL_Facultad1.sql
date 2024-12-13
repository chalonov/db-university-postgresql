CREATE DATABASE facultad1
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    --LC_COLLATE = 'English_United States.1252'
    --LC_CTYPE = 'English_United States.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

CREATE SCHEMA facultad;	

CREATE extension dblink;
	
SET search_path = facultad;

CREATE DOMAIN CODE_DOMAIN varchar(20) NOT NULL;

CREATE DOMAIN CODE_DOMAIN_NULL varchar(20) NULL;

CREATE DOMAIN ID_DOMAIN integer NOT NULL;
	
CREATE DOMAIN NAME_DOMAIN varchar(100) NOT NULL;

CREATE DOMAIN NAME_DOMAIN_NULL varchar(100) NULL;

CREATE DOMAIN SCORE_DOMAIN real NOT NULL DEFAULT 0;


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
CREATE TABLE tipo_programa
(
	tipo			CODE_DOMAIN,
	nombre			NAME_DOMAIN
);

ALTER TABLE tipo_programa ADD CONSTRAINT tipo_programa_PK PRIMARY KEY (tipo);
ALTER TABLE tipo_programa ADD CONSTRAINT tipo_programa_UQ UNIQUE (nombre);
---------------------------------------------------------------------
CREATE TABLE carrera
(
	codigo			CODE_DOMAIN,
	nombre			NAME_DOMAIN,
	tipo			CODE_DOMAIN
);

ALTER TABLE carrera ADD CONSTRAINT carrera_PK PRIMARY KEY (codigo);
ALTER TABLE carrera ADD CONSTRAINT carrera_UQ UNIQUE (nombre);
ALTER TABLE carrera ADD CONSTRAINT carrera_2_tipo_programa_FK FOREIGN KEY(tipo) REFERENCES tipo_programa(tipo);
---------------------------------------------------------------------
CREATE TABLE coordinador
(
	codigo				CODE_DOMAIN,
	identificacion		CODE_DOMAIN,
	cod_carrera			CODE_DOMAIN
);

ALTER TABLE coordinador ADD CONSTRAINT coordinador_PK PRIMARY KEY (codigo);
ALTER TABLE coordinador ADD CONSTRAINT coordinador_UQ UNIQUE (cod_carrera);
ALTER TABLE coordinador ADD CONSTRAINT coordinador_2_persona_FK FOREIGN KEY(identificacion) REFERENCES persona(identificacion);
ALTER TABLE coordinador ADD CONSTRAINT coordinador_2_carrera_FK FOREIGN KEY(cod_carrera) REFERENCES carrera(codigo);
---------------------------------------------------------------------
CREATE TABLE profesor
(
	codigo				CODE_DOMAIN,
	identificacion		CODE_DOMAIN,
	numero_contrato		CODE_DOMAIN
);

ALTER TABLE profesor ADD CONSTRAINT profesor_PK PRIMARY KEY (codigo);
ALTER TABLE profesor ADD CONSTRAINT profesor_2_persona_FK FOREIGN KEY(identificacion) REFERENCES persona(identificacion);
---------------------------------------------------------------------
CREATE TABLE asignatura
(
	codigo		CODE_DOMAIN,
	nombre		NAME_DOMAIN,
	creditos	integer			NOT NULL	DEFAULT 3
);

ALTER TABLE asignatura ADD CONSTRAINT asignatura_PK PRIMARY KEY (codigo);
ALTER TABLE asignatura ADD CONSTRAINT asignatura_UQ UNIQUE (nombre);
---------------------------------------------------------------------
CREATE TABLE oferta_asignatura
(
	cod_carrera			CODE_DOMAIN,
	cod_asignatura		CODE_DOMAIN,
	periodo				CODE_DOMAIN
);

ALTER TABLE oferta_asignatura ADD CONSTRAINT oferta_asignatura_PK PRIMARY KEY (cod_carrera, cod_asignatura, periodo);
ALTER TABLE oferta_asignatura ADD CONSTRAINT oferta_asignatura_2_carrera_FK FOREIGN KEY(cod_carrera) REFERENCES carrera(codigo);
ALTER TABLE oferta_asignatura ADD CONSTRAINT oferta_asignatura_2_asignatura_FK FOREIGN KEY(cod_asignatura) REFERENCES asignatura(codigo);
---------------------------------------------------------------------
CREATE TABLE grupo
(
	cod_carrera			CODE_DOMAIN,
	cod_asignatura		CODE_DOMAIN,
	periodo				CODE_DOMAIN,
	grupo				ID_DOMAIN,
	cupos				integer			NOT NULL DEFAULT 0,
	cod_profesor		CODE_DOMAIN_NULL
);

ALTER TABLE grupo ADD CONSTRAINT grupo_PK PRIMARY KEY (cod_carrera, cod_asignatura, periodo, grupo);
ALTER TABLE grupo ADD CONSTRAINT grupo_2_oferta_asignatura_FK FOREIGN KEY(cod_carrera, cod_asignatura, periodo) REFERENCES oferta_asignatura(cod_carrera, cod_asignatura, periodo);
ALTER TABLE grupo ADD CONSTRAINT grupo_2_profesor_FK FOREIGN KEY(cod_profesor) REFERENCES profesor(codigo);
---------------------------------------------------------------------
CREATE TABLE estudiante
(
	codigo				CODE_DOMAIN,
	identificacion		CODE_DOMAIN
);

ALTER TABLE estudiante ADD CONSTRAINT estudiante_PK PRIMARY KEY (codigo);
ALTER TABLE estudiante ADD CONSTRAINT estudiante_2_persona_FK FOREIGN KEY(identificacion) REFERENCES persona(identificacion);
---------------------------------------------------------------------
CREATE TABLE carrera_estudiante
(
	cod_estudiante		CODE_DOMAIN,
	cod_carrera			CODE_DOMAIN,
	activo				boolean			NOT NULL DEFAULT TRUE
);

ALTER TABLE carrera_estudiante ADD CONSTRAINT carrera_estudiante_PK PRIMARY KEY (cod_estudiante, cod_carrera);
ALTER TABLE carrera_estudiante ADD CONSTRAINT carrera_estudiante_2_estudiante_FK FOREIGN KEY(cod_estudiante) REFERENCES estudiante(codigo);
ALTER TABLE carrera_estudiante ADD CONSTRAINT carrera_estudiante_2_carrera_FK FOREIGN KEY(cod_carrera) REFERENCES carrera(codigo);
---------------------------------------------------------------------
CREATE TABLE inscripcion
(
	cod_estudiante		CODE_DOMAIN,
	cod_carrera			CODE_DOMAIN,
	cod_asignatura		CODE_DOMAIN,
	periodo				CODE_DOMAIN,
	grupo				ID_DOMAIN,
	nota1				SCORE_DOMAIN,
	nota2				SCORE_DOMAIN,
	nota3				SCORE_DOMAIN
);

ALTER TABLE inscripcion ADD CONSTRAINT inscripcion_PK PRIMARY KEY (cod_estudiante, cod_carrera, cod_asignatura, periodo, grupo);
ALTER TABLE inscripcion ADD CONSTRAINT inscripcion_2_estudiante_FK FOREIGN KEY(cod_estudiante) REFERENCES estudiante(codigo);
ALTER TABLE inscripcion ADD CONSTRAINT inscripcion_2_ogrupo_FK FOREIGN KEY(cod_carrera, cod_asignatura, periodo, grupo) REFERENCES grupo(cod_carrera, cod_asignatura, periodo, grupo);
---------------------------------------------------------------------
CREATE TABLE log_inscripcion
(
	usuario				CODE_DOMAIN,
	timestamp_log 		timestamp WITH time ZONE DEFAULT now(),
	nombre				text,
	tipo				text,
	nivel				text,
	comando				text,
	cod_estudiante		CODE_DOMAIN,
	cod_carrera			CODE_DOMAIN,
	cod_asignatura		CODE_DOMAIN,
	periodo				CODE_DOMAIN,
	grupo				ID_DOMAIN,
	nota1				SCORE_DOMAIN,
	nota2				SCORE_DOMAIN,
	nota3				SCORE_DOMAIN
);
---------------------------------------------------------------------
CREATE OR REPLACE VIEW facultad.NotasPorEstudiante AS
SELECT 
ins.cod_estudiante, 
per.primer_nombre,
per.segundo_nombre,
per.primer_apellido,
per.segundo_apellido,
ins.cod_asignatura, 
asi.nombre as asignatura,
ins.periodo, 
ins.grupo, 
ins.nota1, ins.nota2, ins.nota3,
(ins.nota1 + ins.nota2 + ins.nota3) / 3 as definitiva
FROM facultad.inscripcion ins
INNER JOIN facultad.estudiante est ON ins.cod_estudiante = est.codigo
INNER JOIN facultad.persona per ON est.identificacion = per.identificacion
INNER JOIN facultad.asignatura asi ON ins.cod_asignatura = asi.codigo
WHERE ins.cod_estudiante :: text = CURRENT_USER;
---------------------------------------------------------------------
CREATE OR REPLACE VIEW facultad.EstudiantePorCurso AS
SELECT 
ins.cod_estudiante, 
per.primer_nombre,
per.segundo_nombre,
per.primer_apellido,
per.segundo_apellido,
ins.cod_asignatura, 
asi.nombre as asignatura,
ins.periodo, 
ins.grupo, 
ins.nota1, ins.nota2, ins.nota3,
(ins.nota1 + ins.nota2 + ins.nota3) / 3 as definitiva
FROM facultad.inscripcion ins
INNER JOIN facultad.grupo gru ON ins.cod_carrera = gru.cod_carrera AND
                        ins.cod_asignatura = gru.cod_asignatura AND
						ins.periodo = gru.periodo AND
						ins.grupo = gru.grupo 
INNER JOIN facultad.estudiante est ON ins.cod_estudiante = est.codigo
INNER JOIN facultad.persona per ON est.identificacion = per.identificacion
INNER JOIN facultad.asignatura asi ON ins.cod_asignatura = asi.codigo
WHERE gru.cod_profesor :: text = CURRENT_USER;
---------------------------------------------------------------------
CREATE OR REPLACE VIEW facultad.ReporteLibros AS
SELECT *
FROM public.dblink('dbname=biblioteca port=5432 user=postgres password=Yesenia_1', 'select * from biblioteca.ReporteLibros')
AS t1 (isbn CODE_DOMAIN, titulo NAME_DOMAIN, editorial NAME_DOMAIN, nombre NAME_DOMAIN);
---------------------------------------------------------------------
CREATE OR REPLACE VIEW facultad.DisponibilidadLibros AS
SELECT *
FROM public.dblink('dbname=biblioteca port=5432 user=postgres password=Yesenia_1', 'select * from biblioteca.DisponibilidadLibros')
AS t1 (isbn CODE_DOMAIN, titulo NAME_DOMAIN, editorial NAME_DOMAIN, nombre NAME_DOMAIN, id ID_DOMAIN);
---------------------------------------------------------------------
CREATE OR REPLACE VIEW facultad.PrestamosPorEstudiante AS
SELECT *
FROM public.dblink('dbname=biblioteca port=5432 user=postgres password=Yesenia_1', 'select * from biblioteca.PrestamosPorEstudiante')
AS t1 (isbn CODE_DOMAIN, titulo NAME_DOMAIN, editorial NAME_DOMAIN, nombre NAME_DOMAIN, id ID_DOMAIN, fecha_prestamo date, fecha_devolucion date);
---------------------------------------------------------------------