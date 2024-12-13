---------------------------------------------------------------------------------
-- Creacion bibliotecario
SET search_path = biblioteca;
---------------------------------------------------------------------------------
-- Creacion bibliotecario
SELECT biblioteca.crear_persona('CC',
								  '79771695',
								  'Gonzalo',
								  'Ricardo',
								  'Novoa',
								  'Fernández',
								  'Galerías',
								  '7777777',
								  '1979-06-06');
								  
SELECT biblioteca.crear_bibliotecario('bib1', '79771695');	


select * from persona where identificacion = '79771695';

select * from biblioteca.bibliotecario;

---------------------------------------------------------------------------------
-- Creacion estudiante
SELECT biblioteca.crear_persona('CC',
								'1022417931',
								'Henry',
								'Andres',
								'Tellez',
								'Uribe',
								'Madelena',
								'9999999',
								'1985-08-09');

SELECT biblioteca.crear_estudiante('estu1', '1022417931');


-- Hora del sistema
select NOW();

-- Creación de un préstamo vencido
INSERT INTO prestamo (isbn, id_ejemplar, codigo_estudiante, fecha_prestamo, dias_prestamo)
VALUES('1533293866', 1, 'estu1', '"2023-10-20', 3);

-- Consulta del préstamo vencido
select * from prestamo where codigo_estudiante = 'estu1';

-- Intento de creación de un préstamo para el mismo usuario
SELECT biblioteca.prestar_libro('8227589300', 1, 'estu1', 2);

