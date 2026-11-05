-- ============================================================
-- ASSETCONTROL | ESTUDIANTES - ESPACIOS PARA RESOLVER
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: assetcontrol
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

USE assetcontrol;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    a.id AS codigo_activo,
    a.brand AS marca,
    a.model AS modelo,
    a.status AS estado
FROM assets AS a;


-- ------------------------------------------------------------
-- 01. Mostrar el código, marca, modelo y estado de todos los activos, como se trabajó en clase.
-- Respuesta propuesta al ejercicio 01:
SELECT patrimonial_identifier AS codigo, brand AS marca, model AS modelo, status AS estado FROM assets ORDER BY id;





-- ------------------------------------------------------------
-- 02. Mostrar cada equipo junto con el nombre de su tipo. Usar alias a y at y un JOIN.
-- Respuesta propuesta al ejercicio 02:
SELECT a.id, a.patrimonial_identifier, a.brand, a.model, at.name AS tipo
FROM assets AS a JOIN asset_types AS at ON a.asset_type_id = at.id;





-- ------------------------------------------------------------
-- 03. Filtrar los equipos DISPONIBLES que sean de tipo Portátil o Proyector.
-- Respuesta propuesta al ejercicio 03:
SELECT a.id, a.brand, a.model, at.name AS tipo
FROM assets AS a JOIN asset_types AS at ON at.id = a.asset_type_id
WHERE a.status = 'DISPONIBLE' AND at.name IN ('Portátil', 'Proyector');





-- ------------------------------------------------------------
-- 04. Listar los empleados ACTIVOS del departamento Tecnología, con el nombre del departamento. Ordenar por empleado descendente.
-- Respuesta propuesta al ejercicio 04:
SELECT e.id, e.name AS empleado, d.name AS departamento
FROM employees AS e JOIN departments AS d ON d.id = e.department_id
WHERE e.status = 'ACTIVO' AND d.name = 'Tecnología' ORDER BY e.name DESC;





-- ------------------------------------------------------------
-- 05. Listar los equipos comprados entre el 1 de enero de 2025 y el 31 de diciembre de 2025.
-- Respuesta propuesta al ejercicio 05:
SELECT id, patrimonial_identifier, purchase_date FROM assets
WHERE purchase_date BETWEEN '2025-01-01' AND '2025-12-31';





-- ------------------------------------------------------------
-- 06. Mostrar cada equipo junto a la sede y ciudad a las que pertenece.
-- Respuesta propuesta al ejercicio 06:
SELECT a.id, a.brand, a.model, s.name AS sede, s.city AS ciudad
FROM assets AS a JOIN sites AS s ON s.id = a.site_id;





-- ------------------------------------------------------------
-- 07. Mostrar los equipos que tienen una asignación vigente y el nombre del empleado que los tiene.
-- Respuesta propuesta al ejercicio 07:
SELECT a.id, a.patrimonial_identifier, e.name AS empleado, ass.started_at
FROM assets AS a JOIN assignments AS ass ON ass.asset_id = a.id
JOIN employees AS e ON e.id = ass.employee_id WHERE ass.return_date IS NULL;





-- ------------------------------------------------------------
-- 08. Mostrar cada mantenimiento junto con el activo intervenido, el tipo y su costo.
-- Respuesta propuesta al ejercicio 08:
SELECT m.id, a.patrimonial_identifier, a.brand, m.type AS tipo, m.cost AS costo
FROM maintenance AS m JOIN assets AS a ON a.id = m.asset_id;





-- ------------------------------------------------------------
-- 09. Contar los equipos por estado, ordenados de mayor a menor cantidad.
-- Respuesta propuesta al ejercicio 09:
SELECT status, COUNT(*) AS cantidad FROM assets GROUP BY status ORDER BY cantidad DESC;





-- ------------------------------------------------------------
-- 10. Contar los equipos registrados por sede, incluyendo sedes sin equipos. Usar LEFT JOIN.
-- Respuesta propuesta al ejercicio 10:
SELECT s.id, s.name AS sede, COUNT(a.id) AS total_equipos
FROM sites AS s LEFT JOIN assets AS a ON a.site_id = s.id
GROUP BY s.id, s.name ORDER BY total_equipos DESC;





-- ------------------------------------------------------------
-- 11. Calcular el costo total de mantenimientos por activo. Mostrar solo activos con mantenimiento.
-- Respuesta propuesta al ejercicio 11:
SELECT a.id, a.patrimonial_identifier, SUM(m.cost) AS costo_total
FROM assets AS a JOIN maintenance AS m ON m.asset_id = a.id
GROUP BY a.id, a.patrimonial_identifier;





-- ------------------------------------------------------------
-- 12. Contar cuántos equipos vigentes tiene cada empleado, incluyendo los que no tienen ninguno.
-- Respuesta propuesta al ejercicio 12:
SELECT e.id, e.name, COUNT(ass.id) AS equipos_vigentes
FROM employees AS e LEFT JOIN assignments AS ass
ON ass.employee_id = e.id AND ass.return_date IS NULL
GROUP BY e.id, e.name;





-- ------------------------------------------------------------
-- 13. Encontrar los tipos de equipo que tengan dos o más activos. Usar HAVING.
-- Respuesta propuesta al ejercicio 13:
SELECT at.id, at.name, COUNT(a.id) AS total_activos
FROM asset_types AS at JOIN assets AS a ON a.asset_type_id = at.id
GROUP BY at.id, at.name HAVING COUNT(a.id) >= 2;





-- ------------------------------------------------------------
-- 14. Calcular el costo promedio de mantenimiento por tipo: PREVENTIVO o CORRECTIVO.
-- Respuesta propuesta al ejercicio 14:
SELECT type AS tipo, AVG(cost) AS costo_promedio
FROM maintenance WHERE type IN ('PREVENTIVO','CORRECTIVO') GROUP BY type;





-- ------------------------------------------------------------
-- 15. Mostrar los tres mantenimientos más costosos, con su descripción y costo.
-- Respuesta propuesta al ejercicio 15:
SELECT id, description, cost FROM maintenance ORDER BY cost DESC, id LIMIT 3;





-- ------------------------------------------------------------
-- 16. Consultar el nombre y departamento de quienes tienen equipos asignados actualmente.
-- Respuesta propuesta al ejercicio 16:
SELECT DISTINCT e.id, e.name AS empleado, d.name AS departamento
FROM employees AS e JOIN departments AS d ON d.id = e.department_id
JOIN assignments AS ass ON ass.employee_id = e.id WHERE ass.return_date IS NULL;





-- ------------------------------------------------------------
-- 17. Mostrar los activos que actualmente no tienen ninguna asignación abierta, usando LEFT JOIN e IS NULL.
-- Respuesta propuesta al ejercicio 17:
SELECT a.id, a.patrimonial_identifier, a.brand, a.model
FROM assets AS a LEFT JOIN assignments AS ass
ON ass.asset_id = a.id AND ass.return_date IS NULL
WHERE ass.id IS NULL;





-- ------------------------------------------------------------
-- 18 | SUBCONSULTA. SUBCONSULTA: mostrar mantenimientos con costo superior al costo promedio de todos los mantenimientos.
-- Respuesta propuesta al ejercicio 18:
SELECT id, asset_id, description, cost FROM maintenance
WHERE cost > (SELECT AVG(cost) FROM maintenance);





-- ------------------------------------------------------------
-- 19 | SUBCONSULTA. SUBCONSULTA: buscar empleados que figuren en asignaciones vigentes mediante IN.
-- Respuesta propuesta al ejercicio 19:
SELECT id, name FROM employees
WHERE id IN (SELECT employee_id FROM assignments WHERE return_date IS NULL);





-- ------------------------------------------------------------
-- 20 | SUBCONSULTA. SUBCONSULTA: encontrar activos que nunca han tenido un mantenimiento mediante NOT EXISTS.
-- Respuesta propuesta al ejercicio 20:
SELECT a.id, a.patrimonial_identifier, a.brand FROM assets AS a
WHERE NOT EXISTS (SELECT 1 FROM maintenance AS m WHERE m.asset_id = a.id);



