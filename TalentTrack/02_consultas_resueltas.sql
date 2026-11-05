-- ============================================================
-- TALENTTRACK | ESTUDIANTES - ESPACIOS PARA RESOLVER
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: talenttrack
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

USE talenttrack;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    c.id AS codigo_curso,
    c.name AS curso,
    c.duration_hours AS horas
FROM courses AS c;


-- ------------------------------------------------------------
-- 01. Mostrar código, nombre y duración en horas de todos los cursos.
-- Respuesta propuesta al ejercicio 01:
SELECT code AS codigo, name AS curso, duration_hours AS horas FROM courses ORDER BY code;





-- ------------------------------------------------------------
-- 02. Listar ediciones en estado ABIERTA o EN_CURSO cuya fecha de inicio sea desde septiembre de 2026.
-- Respuesta propuesta al ejercicio 02:
SELECT id, code, start_date, status FROM editions
WHERE status IN ('ABIERTA','EN_CURSO') AND start_date >= '2026-09-01';





-- ------------------------------------------------------------
-- 03. Mostrar colaboradores ACTIVO de empresas cuyo nombre contenga SAS. Usar JOIN y LIKE.
-- Respuesta propuesta al ejercicio 03:
SELECT co.id, co.name AS colaborador, c.company_name AS empresa
FROM collaborators AS co JOIN companies AS c ON c.id = co.company_id
WHERE co.status = 'ACTIVO' AND c.company_name LIKE '%SAS%';





-- ------------------------------------------------------------
-- 04. Mostrar las tres ediciones con fecha de inicio más reciente. Usar LIMIT.
-- Respuesta propuesta al ejercicio 04:
SELECT id, code, start_date FROM editions ORDER BY start_date DESC, id DESC LIMIT 3;





-- ------------------------------------------------------------
-- 05. Buscar cursos cuyo nombre incluya IA o datos. Usar LIKE y OR.
-- Respuesta propuesta al ejercicio 05:
SELECT id, code, name FROM courses WHERE name LIKE '%IA%' OR name LIKE '%datos%';





-- ------------------------------------------------------------
-- 06. Mostrar cada edición junto con el nombre del curso y el instructor que la imparte.
-- Respuesta propuesta al ejercicio 06:
SELECT ed.id, ed.code AS edicion, c.name AS curso, i.name AS instructor
FROM editions AS ed JOIN courses AS c ON c.id = ed.course_id
JOIN instructors AS i ON i.id = ed.instructor_id;





-- ------------------------------------------------------------
-- 07. Relacionar cada matrícula con colaborador, empresa y edición.
-- Respuesta propuesta al ejercicio 07:
SELECT en.id AS matricula, co.name AS colaborador, c.company_name AS empresa,
       ed.code AS edicion, en.status AS estado
FROM enrollments AS en JOIN collaborators AS co ON co.id = en.collaborator_id
JOIN companies AS c ON c.id = co.company_id
JOIN editions AS ed ON ed.id = en.edition_id;





-- ------------------------------------------------------------
-- 08. Contar los matriculados por edición, incluyendo ediciones sin inscritos. Usar LEFT JOIN.
-- Respuesta propuesta al ejercicio 08:
SELECT ed.id, ed.code, COUNT(en.id) AS matriculados
FROM editions AS ed LEFT JOIN enrollments AS en ON en.edition_id = ed.id
GROUP BY ed.id, ed.code ORDER BY ed.id;





-- ------------------------------------------------------------
-- 09. Contar matrículas agrupadas por su estado.
-- Respuesta propuesta al ejercicio 09:
SELECT status AS estado, COUNT(*) AS cantidad FROM enrollments GROUP BY status;





-- ------------------------------------------------------------
-- 10. Encontrar los cursos que se han ofrecido en dos o más ediciones. Usar HAVING.
-- Respuesta propuesta al ejercicio 10:
SELECT c.id, c.name, COUNT(ed.id) AS ediciones
FROM courses AS c JOIN editions AS ed ON ed.course_id = c.id
GROUP BY c.id, c.name HAVING COUNT(ed.id) >= 2;





-- ------------------------------------------------------------
-- 11. Contar las sesiones programadas en cada edición.
-- Respuesta propuesta al ejercicio 11:
SELECT ed.id, ed.code, COUNT(s.id) AS sesiones
FROM editions AS ed LEFT JOIN sessions AS s ON s.edition_id = ed.id
GROUP BY ed.id, ed.code;





-- ------------------------------------------------------------
-- 12. Mostrar los certificados emitidos junto al nombre del colaborador y el curso.
-- Respuesta propuesta al ejercicio 12:
SELECT cert.code AS certificado, co.name AS colaborador, c.name AS curso, cert.issued_at
FROM certificates AS cert JOIN enrollments AS en ON en.id = cert.enrollment_id
JOIN collaborators AS co ON co.id = en.collaborator_id
JOIN editions AS ed ON ed.id = en.edition_id
JOIN courses AS c ON c.id = ed.course_id;





-- ------------------------------------------------------------
-- 13. Mostrar las sesiones realizadas durante septiembre de 2026, junto a su edición.
-- Respuesta propuesta al ejercicio 13:
SELECT s.id, ed.code AS edicion, s.topic, s.started_at, s.ended_at
FROM sessions AS s JOIN editions AS ed ON ed.id = s.edition_id
WHERE s.started_at >= '2026-09-01 00:00:00' AND s.started_at < '2026-10-01 00:00:00';





-- ------------------------------------------------------------
-- 14. Mostrar todas las asistencias registradas con el colaborador, tema de la sesión y estado.
-- Respuesta propuesta al ejercicio 14:
SELECT a.id, co.name AS colaborador, s.topic AS tema, a.status AS estado
FROM attendance AS a JOIN enrollments AS en ON en.id = a.enrollment_id
JOIN collaborators AS co ON co.id = en.collaborator_id
JOIN sessions AS s ON s.id = a.session_id;





-- ------------------------------------------------------------
-- 15. Contar cuántas asistencias PRESENTE registra cada matrícula con registros de asistencia.
-- Respuesta propuesta al ejercicio 15:
SELECT en.id AS matricula, co.name AS colaborador,
       SUM(CASE WHEN a.status = 'PRESENTE' THEN 1 ELSE 0 END) AS presentes
FROM enrollments AS en JOIN attendance AS a ON a.enrollment_id = en.id
JOIN collaborators AS co ON co.id = en.collaborator_id
GROUP BY en.id, co.name;





-- ------------------------------------------------------------
-- 16. Mostrar ediciones con al menos dos matriculados e indicar su capacidad. Usar HAVING.
-- Respuesta propuesta al ejercicio 16:
SELECT ed.id, ed.code, ed.capacity AS capacidad, COUNT(en.id) AS matriculados
FROM editions AS ed JOIN enrollments AS en ON en.edition_id = ed.id
GROUP BY ed.id, ed.code, ed.capacity HAVING COUNT(en.id) >= 2;





-- ------------------------------------------------------------
-- 17. Mostrar matrículas cuya asistencia registrada tenga al menos 80% PRESENTE. Usar GROUP BY y HAVING.
-- Respuesta propuesta al ejercicio 17:
SELECT en.id AS matricula, co.name AS colaborador, COUNT(a.id) AS registros,
       SUM(CASE WHEN a.status = 'PRESENTE' THEN 1 ELSE 0 END) AS presentes,
       ROUND(100.0 * SUM(CASE WHEN a.status = 'PRESENTE' THEN 1 ELSE 0 END) / COUNT(a.id), 2) AS porcentaje_presente
FROM enrollments AS en JOIN attendance AS a ON a.enrollment_id = en.id
JOIN collaborators AS co ON co.id = en.collaborator_id
GROUP BY en.id, co.name
HAVING 1.0 * SUM(CASE WHEN a.status = 'PRESENTE' THEN 1 ELSE 0 END) / COUNT(a.id) >= 0.80;





-- ------------------------------------------------------------
-- 18 | SUBCONSULTA. SUBCONSULTA: encontrar colaboradores que todavía no se han matriculado en ninguna edición. Usar NOT EXISTS.
-- Respuesta propuesta al ejercicio 18:
SELECT co.id, co.name FROM collaborators AS co
WHERE NOT EXISTS (SELECT 1 FROM enrollments AS en WHERE en.collaborator_id = co.id);





-- ------------------------------------------------------------
-- 19 | SUBCONSULTA. SUBCONSULTA: mostrar ediciones cuya capacidad sea mayor al promedio de capacidades de las ediciones.
-- Respuesta propuesta al ejercicio 19:
SELECT id, code, capacity FROM editions
WHERE capacity > (SELECT AVG(capacity) FROM editions);





-- ------------------------------------------------------------
-- 20 | SUBCONSULTA. SUBCONSULTA: mostrar colaboradores que estén matriculados en alguna edición del curso con código CUR-IA. Usar IN.
-- Respuesta propuesta al ejercicio 20:
SELECT id, name FROM collaborators WHERE id IN (
  SELECT en.collaborator_id FROM enrollments AS en
  JOIN editions AS ed ON ed.id = en.edition_id
  JOIN courses AS c ON c.id = ed.course_id
  WHERE c.code = 'CUR-IA'
);



