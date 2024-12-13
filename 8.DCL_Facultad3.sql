SET search_path = facultad;
-----------------------------------------------------------------------------
DO
$do$
BEGIN
	IF NOT EXISTS (SELECT * FROM pg_catalog.pg_roles WHERE rolname = 'role_coordinador') THEN
		CREATE role role_coordinador WITH CREATEROLE;
	END IF;
END
$do$;

GRANT USAGE ON SCHEMA facultad TO role_coordinador;
GRANT SELECT, INSERT, UPDATE, DELETE ON facultad.persona TO role_coordinador;
GRANT SELECT, INSERT, UPDATE, DELETE ON facultad.estudiante TO role_coordinador;
GRANT SELECT, INSERT, UPDATE, DELETE ON facultad.carrera_estudiante TO role_coordinador;
GRANT SELECT, INSERT, UPDATE, DELETE ON facultad.coordinador TO role_coordinador;
GRANT SELECT, INSERT, UPDATE, DELETE ON facultad.inscripcion TO role_coordinador;
GRANT SELECT, INSERT, UPDATE, DELETE ON facultad.log_inscripcion TO role_coordinador;
GRANT UPDATE (nota1, nota2, nota3) ON facultad.inscripcion TO role_coordinador;
GRANT SELECT, INSERT, UPDATE, DELETE ON facultad.profesor TO role_coordinador;
GRANT SELECT, INSERT, UPDATE, DELETE ON facultad.oferta_asignatura TO role_coordinador;
GRANT SELECT, INSERT, UPDATE, DELETE ON facultad.grupo TO role_coordinador;
GRANT SELECT ON facultad.NotasPorEstudiante TO role_coordinador;
GRANT EXECUTE ON FUNCTION facultad.crear_persona TO role_coordinador;
GRANT EXECUTE ON FUNCTION facultad.crear_estudiante TO role_coordinador;
GRANT EXECUTE ON FUNCTION facultad.crear_profesor TO role_coordinador;
GRANT EXECUTE ON FUNCTION facultad.get_carrera_coordinador TO role_coordinador;
GRANT EXECUTE ON FUNCTION facultad.matricular_estudiante_a_carrera TO role_coordinador;
GRANT EXECUTE ON FUNCTION facultad.deshabilitar_estudiante_a_carrera TO role_coordinador;
GRANT EXECUTE ON FUNCTION facultad.habilitar_estudiante_a_carrera TO role_coordinador;
GRANT EXECUTE ON FUNCTION facultad.inscribir_estudiante TO role_coordinador;
GRANT EXECUTE ON FUNCTION facultad.aplicar_control_coordinador TO role_coordinador;
GRANT EXECUTE ON FUNCTION facultad.asignar_profesor_a_grupo TO role_coordinador;
-----------------------------------------------------------------------------

DO
$do$
BEGIN
	IF NOT EXISTS (SELECT * FROM pg_catalog.pg_roles WHERE rolname = 'role_profesor') THEN
		CREATE role role_profesor;
	END IF;
END
$do$;

GRANT USAGE ON SCHEMA facultad TO role_profesor;
GRANT SELECT ON facultad.inscripcion TO role_profesor;
GRANT UPDATE (nota1, nota2, nota3) ON facultad.inscripcion TO role_profesor;
GRANT SELECT, UPDATE ON facultad.profesor TO role_profesor;
GRANT SELECT ON facultad.EstudiantePorCurso TO role_profesor;
GRANT SELECT ON facultad.NotasPorEstudiante TO role_profesor;
GRANT SELECT ON facultad.ReporteLibros TO role_profesor;
GRANT SELECT ON facultad.DisponibilidadLibros TO role_profesor;
-----------------------------------------------------------------------------
DO
$do$
BEGIN
	IF NOT EXISTS (SELECT * FROM pg_catalog.pg_roles WHERE rolname = 'role_estudiante') THEN
		CREATE role role_estudiante;
	END IF;
END
$do$;

GRANT USAGE ON SCHEMA facultad TO role_estudiante;
GRANT SELECT ON facultad.inscripcion TO role_estudiante;
GRANT SELECT ON facultad.NotasPorEstudiante TO role_estudiante;
GRANT SELECT ON facultad.ReporteLibros TO role_estudiante;
GRANT SELECT ON facultad.DisponibilidadLibros TO role_estudiante;
GRANT SELECT ON facultad.PrestamosPorEstudiante TO role_estudiante;
-----------------------------------------------------------------------------
