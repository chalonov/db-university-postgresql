SET search_path = facultad;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION facultad.crear_persona
(
	tipo_identificacion		varchar(20),
	identificacion			varchar(20),
	primer_nombre			varchar(100),
	segundo_nombre			varchar(100),
	primer_apellido			varchar(100),
	segundo_apellido		varchar(100),
	direccion				varchar(100),
	telefono				varchar(100),
	fecha_nacimiento		date
) RETURNS integer AS $$
BEGIN
	INSERT INTO facultad.persona (tipo_identificacion, identificacion, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, direccion, telefono) 
	VALUES(tipo_identificacion, identificacion, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, direccion, telefono);
	
	RETURN 0;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION facultad.crear_estudiante
(
	pcodigo	varchar(20),
	pidentificacion			varchar(20)
) RETURNS integer AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 
				   FROM facultad.persona 
				   WHERE identificacion = pidentificacion) THEN
		RAISE EXCEPTION 'No existe persona con la identificación %.', pidentificacion;
	END IF;
	
	pcodigo = lower(pcodigo);
	
	INSERT INTO facultad.estudiante(codigo, identificacion) VALUES (pcodigo, pidentificacion);
	
	RETURN 0;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION facultad.crear_coordinador
(
	pcodigo			varchar(20),
	pidentificacion	varchar(20),
	pcod_carrera 	varchar(20)	
) RETURNS integer AS $$
BEGIN
	pcodigo = lower(pcodigo);
	
	INSERT INTO facultad.coordinador(codigo, identificacion, cod_carrera) VALUES (pcodigo, pidentificacion, pcod_carrera);
	
	RETURN 0;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION facultad.crear_profesor
(
	pcodigo					varchar(20),
	pidentificacion			varchar(20),
	pnumero_contrato		varchar(20)
) RETURNS integer AS $$
BEGIN
	pcodigo = lower(pcodigo);
	
	INSERT INTO facultad.profesor(codigo, identificacion, numero_contrato) VALUES (pcodigo, pidentificacion, pnumero_contrato);
	
	RETURN 0;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION facultad.get_carrera_coordinador() RETURNS CODE_DOMAIN_NULL AS $$
DECLARE
	carrera_coordinador		CODE_DOMAIN_NULL;
BEGIN
	carrera_coordinador = NULL;
	
	BEGIN
		SELECT cod_carrera INTO STRICT carrera_coordinador 
		FROM facultad.coordinador
		WHERE codigo::text = CURRENT_USER;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION 'El usuario % no es coordinador de ninguna carrera', CURRENT_USER USING HINT = 'Autentíquese como coordinador válido';
        WHEN TOO_MANY_ROWS THEN
            RAISE EXCEPTION 'El usuario % coordina varias carreras', CURRENT_USER USING HINT = 'Autentíquese como coordinador válido';
		WHEN OTHERS THEN
			carrera_coordinador = NULL;
	END;

	RETURN carrera_coordinador;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION facultad.matricular_estudiante_a_carrera
(
	cod_estudiante				varchar(20)
) RETURNS integer AS $$
DECLARE
	carrera_coordinador		CODE_DOMAIN_NULL;
BEGIN
	carrera_coordinador = facultad.get_carrera_coordinador();
	INSERT INTO facultad.carrera_estudiante(cod_estudiante, cod_carrera, activo) VALUES (cod_estudiante, carrera_coordinador, true);

	RETURN 0;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION facultad.deshabilitar_estudiante_a_carrera
(
	pcod_estudiante				varchar(20)
) RETURNS integer AS $$
DECLARE
	carrera_coordinador		CODE_DOMAIN_NULL;
BEGIN
	carrera_coordinador = facultad.get_carrera_coordinador();
	
	UPDATE facultad.carrera_estudiante SET ACTIVO = false
	WHERE cod_estudiante = pcod_estudiante AND cod_carrera = carrera_coordinador;

	RETURN 0;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION facultad.habilitar_estudiante_a_carrera
(
	pcod_estudiante				varchar(20)
) RETURNS integer AS $$
DECLARE
	carrera_coordinador		CODE_DOMAIN_NULL;
BEGIN
	carrera_coordinador = facultad.get_carrera_coordinador();
	
	UPDATE facultad.carrera_estudiante SET ACTIVO = true
	WHERE cod_estudiante = pcod_estudiante AND cod_carrera = carrera_coordinador;

	RETURN 0;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION facultad.inscribir_estudiante
(
	pcod_estudiante		varchar(20),
	pcod_asignatura		CODE_DOMAIN,
	pperiodo			CODE_DOMAIN,
	pgrupo				ID_DOMAIN	
) RETURNS integer AS $$
DECLARE
	carrera_coordinador		CODE_DOMAIN_NULL;
BEGIN
	carrera_coordinador = facultad.get_carrera_coordinador();
	
	INSERT INTO inscripcion(cod_estudiante, cod_carrera, cod_asignatura, periodo, grupo)
	VALUES (pcod_estudiante, carrera_coordinador, pcod_asignatura, pperiodo, pgrupo);

	RETURN 0;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION facultad.asignar_profesor_a_grupo
(
	pcod_carrera		CODE_DOMAIN_NULL,
	pcod_asignatura		CODE_DOMAIN_NULL,
	pperiodo			CODE_DOMAIN_NULL,
	pgrupo				ID_DOMAIN,
	pcod_profesor		CODE_DOMAIN_NULL
) RETURNS integer AS $$
DECLARE
	carrera_coordinador		CODE_DOMAIN_NULL;
BEGIN
	carrera_coordinador = facultad.get_carrera_coordinador();
	
	SELECT facultad.aplicar_control_coordinador(pcod_carrera);
	
	UPDATE grupo SET cod_profesor = pcod_profesor
	WHERE cod_carrera = pcod_carrera AND
	cod_asignatura = pcod_asignatura AND
	periodo = pperiodo AND
	grupo = pgrupo;
	
	RETURN 0;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION facultad.trg_log_inscripcion() RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO facultad.log_inscripcion
	(usuario, timestamp_log, nombre, tipo, nivel, comando, cod_estudiante, cod_carrera, cod_asignatura, periodo, grupo, nota1, nota2, nota3)
	VALUES
	(CURRENT_USER, now(), TG_NAME, TG_WHEN, TG_LEVEL, TG_OP, new.cod_estudiante, new.cod_carrera, new.cod_asignatura, new.periodo, new.grupo, new.nota1, new.nota2, new.nota3);
	
	RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_inscripcion
AFTER INSERT OR UPDATE OR DELETE ON facultad.inscripcion
FOR EACH STATEMENT
EXECUTE PROCEDURE facultad.trg_log_inscripcion();
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION facultad.trg_editar_notas_carrera() RETURNS TRIGGER AS $$
DECLARE
	carrera_coordinador		CODE_DOMAIN_NULL;
	codigo_profesor 		CODE_DOMAIN_NULL;
BEGIN
	carrera_coordinador = NULL;
	
	carrera_coordinador = facultad.get_carrera_coordinador();
	
	IF (new.cod_carrera = carrera_coordinador) THEN
		RETURN new;
	ELSE
		BEGIN
			SELECT cod_profesor INTO STRICT codigo_profesor 
			FROM facultad.grupo gru
			WHERE gru.cod_carrera = new.cod_carrera AND
				  gru.cod_asignatura = new.cod_asignatura AND
				  gru.periodo = new.periodo AND
				  gru.grupo = new.grupo;		
		EXCEPTION
			WHEN OTHERS THEN
				codigo_profesor = NULL;
		END;
		
		IF (cod_profesor::text = CURRENT_USER) THEN
			RETURN new;
		ELSE
			RETURN NULL;
		END IF;		
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_editar_notas_carrera
BEFORE UPDATE ON facultad.inscripcion
FOR EACH ROW
EXECUTE PROCEDURE facultad.trg_editar_notas_carrera();
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION facultad.trg_control_inscripcion() RETURNS TRIGGER AS $$
DECLARE
	cupos_grupo			INTEGER;
	inscritos_grupo		INTEGER;
	carrera_coordinador varchar(20);
	estudiante_activo boolean;
BEGIN
	BEGIN
		SELECT cupos INTO STRICT cupos_grupo
		FROM facultad.grupo gru
		WHERE gru.cod_carrera = new.cod_carrera AND
			  gru.cod_asignatura = new.cod_asignatura AND
			  gru.periodo = new.periodo AND
			  gru.grupo = new.grupo;
	EXCEPTION
		WHEN OTHERS THEN
			cupos_grupo = 0;
	END;
	
	carrera_coordinador = facultad.get_carrera_coordinador();
	
	BEGIN
		SELECT activo INTO STRICT estudiante_activo
		FROM carrera_estudiante ce
		WHERE ce.cod_estudiante = new.cod_estudiante AND ce.cod_carrera = carrera_coordinador;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION 'El estudiante no puede ser inscrito por el coordinador %.', CURRENT_USER;
        WHEN TOO_MANY_ROWS THEN
            RAISE EXCEPTION 'El estudiante no puede ser inscrito por el coordinador %.', CURRENT_USER;
		WHEN OTHERS THEN
			estudiante_activo = false;
	
	END;
	
	IF estudiante_activo = false THEN
		RAISE EXCEPTION 'El estudiante no puede ser inscrito porque no está activo.';
	END IF;
	
	SELECT COUNT(*) INTO STRICT inscritos_grupo
	FROM facultad.inscripcion ins
	WHERE ins.cod_carrera = new.cod_carrera AND
		  ins.cod_asignatura = new.cod_asignatura AND
		  ins.periodo = new.periodo AND
		  ins.grupo = new.grupo;
	
	IF (inscritos_grupo <= cupos_grupo) THEN
		RETURN new;
	ELSE
		RETURN NULL;
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_control_inscripcion
BEFORE INSERT ON facultad.inscripcion
FOR EACH ROW
EXECUTE PROCEDURE facultad.trg_control_inscripcion();
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION facultad.aplicar_control_coordinador
(
	pcod_carrera varchar(20)
) RETURNS integer AS $$
DECLARE
	carreras_coordina	INTEGER;
BEGIN
	SELECT count(*) INTO STRICT carreras_coordina
	FROM facultad.coordinador coor
	WHERE coor.cod_carrera = pcod_carrera AND
		  coor.codigo::text = CURRENT_USER;
			  
	IF (carreras_coordina < 1) THEN
		RAISE EXCEPTION 'El usuario % no es coordinador del programa %', CURRENT_USER, pcod_carrera;
	END IF;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_AI_estudiante()
RETURNS TRIGGER AS $$
BEGIN
	EXECUTE 'CREATE USER "' || NEW.codigo  || '" WITH PASSWORD '''  || NEW.codigo || '''';
	
	EXECUTE 'GRANT role_estudiante to "' || NEW.codigo  || '";';

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_AI_estudiante
AFTER INSERT ON facultad.estudiante
FOR EACH ROW
EXECUTE FUNCTION trg_AI_estudiante();
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_AI_profesor()
RETURNS TRIGGER AS $$
BEGIN
	EXECUTE 'CREATE USER "' || NEW.codigo  || '" WITH PASSWORD '''  || NEW.codigo || '''';
	
	EXECUTE 'GRANT role_profesor to "' || NEW.codigo  || '";';

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_AI_profesor
AFTER INSERT ON facultad.profesor
FOR EACH ROW
EXECUTE FUNCTION trg_AI_profesor();
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_AI_coordinador()
RETURNS TRIGGER AS $$
BEGIN
	EXECUTE 'CREATE USER "' || NEW.codigo  || '" WITH PASSWORD '''  || NEW.codigo || '''';
	
	EXECUTE 'GRANT role_coordinador to "' || NEW.codigo  || '";';

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_AI_coordinador
AFTER INSERT ON facultad.coordinador
FOR EACH ROW
EXECUTE FUNCTION trg_AI_coordinador();
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_BI_coordinador()
RETURNS TRIGGER AS $$
DECLARE
	cantidad_coordinadores	integer;
BEGIN
	BEGIN
		SELECT count(*) INTO STRICT cantidad_coordinadores 
		FROM facultad.coordinador coor
		WHERE coor.cod_carrera = new.cod_carrera;
    EXCEPTION
		WHEN OTHERS THEN
			cantidad_coordinadores = 0;
	END;
	
	IF (cantidad_coordinadores > 0) THEN
		RAISE EXCEPTION 'La carrera % ya tiene coordinador', new.cod_carrera USING HINT = 'Revise el coordinador';	
		RETURN NULL;
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_BI_coordinador
BEFORE INSERT ON facultad.coordinador
FOR EACH ROW
EXECUTE FUNCTION trg_BI_coordinador();
---------------------------------------------------------------------
