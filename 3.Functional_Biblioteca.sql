SET search_path = biblioteca;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION biblioteca.crear_persona
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
	INSERT INTO biblioteca.persona (tipo_identificacion, identificacion, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, direccion, telefono) 
	VALUES(tipo_identificacion, identificacion, primer_nombre, segundo_nombre, primer_apellido, segundo_apellido, direccion, telefono);
	
	RETURN 0;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION biblioteca.crear_bibliotecario
(
	pcodigo				varchar(20),
	pidentificacion		varchar(20)
) RETURNS integer AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 
				   FROM biblioteca.persona 
				   WHERE identificacion = pidentificacion) THEN
		RAISE EXCEPTION 'No existe persona con la identificación %', pidentificacion;
	END IF;

	pcodigo = lower(pcodigo);
	
	INSERT INTO biblioteca.bibliotecario(codigo, identificacion) VALUES (pcodigo, pidentificacion);
	
	RETURN 0;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION biblioteca.crear_estudiante
(
	pcodigo				varchar(20),
	pidentificacion		varchar(20)
) RETURNS integer AS $$
BEGIN
	IF NOT EXISTS (SELECT 1 
				   FROM biblioteca.persona 
				   WHERE identificacion = pidentificacion) THEN
		RAISE EXCEPTION 'No existe persona con la identificación %', pidentificacion;
	END IF;
	
	pcodigo = lower(pcodigo);
	
	INSERT INTO biblioteca.estudiante(codigo, identificacion) VALUES (pcodigo, pidentificacion);
	
	RETURN 0;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION biblioteca.prestar_libro
(
	isbn				varchar(20),
	id_ejemplar			INTEGER,
	codigo_estudiante	varchar(20),
	dias_prestamo		integer
) RETURNS integer AS $$
BEGIN
	INSERT INTO biblioteca.prestamo(isbn, id_ejemplar, codigo_estudiante, fecha_prestamo, dias_prestamo) VALUES(isbn, id_ejemplar, codigo_estudiante, now(), dias_prestamo);
    
	RETURN 0;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION biblioteca.devolver_libro
(
	pisbn				varchar(20),
	pid_ejemplar			INTEGER
) RETURNS integer AS $$
BEGIN
	UPDATE biblioteca.prestamo SET fecha_devolucion = now()
	WHERE biblioteca.prestamo.isbn = pisbn AND prestamo.id_ejemplar = pid_ejemplar;
	
	RETURN 0;
END;
$$ LANGUAGE plpgsql;
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_verificar_existencia_bibliotecario()
RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS (SELECT 1 FROM biblioteca.bibliotecario) THEN
		RAISE EXCEPTION 'Ya existe un bibliotecario. No se puede crear otro.';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verificar_existencia_bibliotecario
BEFORE INSERT ON biblioteca.bibliotecario
FOR EACH ROW
EXECUTE FUNCTION trg_verificar_existencia_bibliotecario();
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_prestamo()
RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS (SELECT 1 
			 FROM biblioteca.prestamo 
			 WHERE codigo_estudiante = NEW.codigo_estudiante
			 AND CAST(fecha_prestamo as date) + CAST(dias_prestamo || ' days' as interval) < current_date AND fecha_devolucion IS NULL) THEN
		RAISE EXCEPTION 'No se puede realizar préstamos al estudiante % porque tiene préstamos vencidos.', NEW.codigo_estudiante;
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prestamo
BEFORE INSERT ON biblioteca.prestamo
FOR EACH ROW
EXECUTE FUNCTION trg_prestamo();
---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_AI_bibliotecario()
RETURNS TRIGGER AS $$
BEGIN
	EXECUTE 'CREATE USER "' || NEW.codigo  || '" WITH PASSWORD '''  || NEW.codigo || '''';
	
	EXECUTE 'GRANT role_bibliotecario to "' || NEW.codigo  || '";';

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_AI_bibliotecario
AFTER INSERT ON biblioteca.bibliotecario
FOR EACH ROW
EXECUTE FUNCTION trg_AI_bibliotecario();
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
AFTER INSERT ON biblioteca.estudiante
FOR EACH ROW
EXECUTE FUNCTION trg_AI_estudiante();
---------------------------------------------------------------------
