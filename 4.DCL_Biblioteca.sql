SET search_path = biblioteca;
-----------------------------------------------------------------------------
DO
$do$
BEGIN
	IF NOT EXISTS (SELECT * FROM pg_catalog.pg_roles WHERE rolname = 'role_bibliotecario') THEN
		CREATE role role_bibliotecario;
	END IF;
END
$do$;

GRANT USAGE ON SCHEMA biblioteca TO role_bibliotecario;
GRANT SELECT, INSERT, UPDATE, DELETE ON biblioteca.autor TO role_bibliotecario;
GRANT SELECT, INSERT, UPDATE, DELETE ON biblioteca.libro TO role_bibliotecario;
GRANT SELECT, INSERT, UPDATE, DELETE ON biblioteca.libro_autor TO role_bibliotecario;
GRANT SELECT, INSERT, UPDATE, DELETE ON biblioteca.ejemplar TO role_bibliotecario;
GRANT SELECT, INSERT, UPDATE, DELETE ON biblioteca.prestamo TO role_bibliotecario;
GRANT EXECUTE ON FUNCTION biblioteca.crear_persona TO role_bibliotecario;
GRANT EXECUTE ON FUNCTION biblioteca.crear_estudiante TO role_bibliotecario;
GRANT EXECUTE ON FUNCTION biblioteca.prestar_libro TO role_bibliotecario;
GRANT EXECUTE ON FUNCTION biblioteca.devolver_libro TO role_bibliotecario;
GRANT SELECT ON biblioteca.DisponibilidadLibros TO role_bibliotecario;
GRANT SELECT ON biblioteca.ReporteLibros TO role_bibliotecario;
GRANT SELECT ON biblioteca.PrestamosPorEstudiante TO role_bibliotecario;
-----------------------------------------------------------------------------
DO
$do$
BEGIN
	IF NOT EXISTS (SELECT * FROM pg_catalog.pg_roles WHERE rolname = 'role_profesor') THEN
		CREATE role role_profesor;
	END IF;
END
$do$;

GRANT USAGE ON SCHEMA biblioteca TO role_profesor;
GRANT SELECT ON biblioteca.autor TO role_profesor;
GRANT SELECT ON biblioteca.libro TO role_profesor;
GRANT SELECT ON biblioteca.libro_autor TO role_profesor;
GRANT SELECT ON biblioteca.DisponibilidadLibros TO role_bibliotecario;
GRANT SELECT ON biblioteca.ReporteLibros TO role_bibliotecario;
-----------------------------------------------------------------------------
DO
$do$
BEGIN
	IF NOT EXISTS (SELECT * FROM pg_catalog.pg_roles WHERE rolname = 'role_estudiante') THEN
		CREATE role role_estudiante;
	END IF;
END
$do$;

GRANT USAGE ON SCHEMA biblioteca TO role_estudiante;
GRANT SELECT ON biblioteca.autor TO role_estudiante;
GRANT SELECT ON biblioteca.libro TO role_estudiante;
GRANT SELECT ON biblioteca.libro_autor TO role_estudiante;
GRANT SELECT ON biblioteca.prestamo TO role_estudiante;
GRANT SELECT ON biblioteca.DisponibilidadLibros TO role_estudiante;
GRANT SELECT ON biblioteca.ReporteLibros TO role_estudiante;
GRANT SELECT ON biblioteca.PrestamosPorEstudiante TO role_estudiante;
-----------------------------------------------------------------------------
