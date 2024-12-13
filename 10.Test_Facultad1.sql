SET search_path = facultad;
----------------------------------------------------------------
SELECT facultad.crear_persona('CC',
							  '1023417931',
							  'Henry',
							  'Andres',
							  'Tellez',
							  'Uribe',
							  'Madelena',
							  '7777777',
							  '1979-06-06');

SELECT facultad.crear_coordinador('coor1', '1023417931', 'ING_01');

----------------------------------------------------------------
SELECT facultad.crear_persona('CC',
							  '45445454',
							  'María',
							  'Isabella',
							  'Rodríguez',
							  'Rodríguez',
							  'Madelena',
							  '7777777',
							  '2012-08-18');

SELECT facultad.crear_coordinador('coor2', '45445454', 'ING_02');
----------------------------------------------------------------
SELECT facultad.crear_persona('CC',
							 '454454',
							 'Luis',
							 'Angel',
							 'Rodriguez',
							 'Hernandez',
							 'Madelena',
							 '7777777',
							 '1979-06-06');


SELECT facultad.crear_estudiante('estu1', '454454');
----------------------------------------------------------------
SELECT facultad.crear_persona('CC',
							  '445454544',
							  'Daniel',
							  'David',
							  'Leal',
							  'Lara',
							  'Bogotá',
							  '454554',
							  '2000-01-01');

SELECT facultad.crear_profesor('prof1', '445454544', 'CON_7878787');


SELECT * FROM facultad.profesor;
----------------------------------------------------------------
SELECT facultad.crear_persona('CC',
							 '89454212',
							 'Carol',
							 'Andrea',
							 'Rodriguez',
							 'Ubaque',
							 'Suba',
							 '9999999',
							 '1992-09-18');
							 
SELECT facultad.crear_estudiante('estu2', '89454212');

-- Esto se debe ejecutar desde un usuario coordinador
SELECT facultad.matricular_estudiante_a_carrera('estu2');

SELECT facultad.deshabilitar_estudiante_a_carrera('estu2');

-- Esto se debe ejecutar desde un usuario coordinador
SELECT * FROM carrera_estudiante;

SELECT facultad.get_carrera_coordinador()

SELECT facultad.inscribir_estudiante('estu2', '2', '202301', 1);


SELECT facultad.asignar_profesor_a_grupo('ING_03', '2', '202301', 1, 'prof1');


SELECT * FROM facultad.ReporteLibros;
SELECT * FROM facultad.DisponibilidadLibros;
SELECT * FROM facultad.PrestamosPorEstudiante;
