-- ============================================================
-- SPACEBOOK | ESTUDIANTES - ESPACIOS PARA RESOLVER
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: spacebook
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

USE spacebook;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    r.id AS codigo_sala,
    r.name AS sala,
    r.capacity AS capacidad
FROM rooms AS r;


-- ------------------------------------------------------------
-- 01. Mostrar código, nombre, capacidad y estado de todas las salas.
-- Respuesta propuesta al ejercicio 01:
SELECT code AS codigo, name AS sala, capacity AS capacidad, status AS estado FROM rooms ORDER BY id;





-- ------------------------------------------------------------
-- 02. Buscar salas ACTIVAS con capacidad entre 6 y 12 personas.
-- Respuesta propuesta al ejercicio 02:
SELECT id, code, name, capacity FROM rooms
WHERE status = 'ACTIVA' AND capacity BETWEEN 6 AND 12;





-- ------------------------------------------------------------
-- 03. Mostrar los recursos DISPONIBLES de tipo PROYECTOR o AUDIO. Usar IN.
-- Respuesta propuesta al ejercicio 03:
SELECT id, code, name, type FROM resources
WHERE status = 'DISPONIBLE' AND type IN ('PROYECTOR','AUDIO');





-- ------------------------------------------------------------
-- 04. Mostrar las tres reservas que comienzan primero según la fecha y hora de inicio.
-- Respuesta propuesta al ejercicio 04:
SELECT id, room_id, started_at, status FROM reservations
ORDER BY started_at ASC, id ASC LIMIT 3;





-- ------------------------------------------------------------
-- 05. Buscar salas cuyo nombre contenga Sur o Ágora. Usar LIKE y OR.
-- Respuesta propuesta al ejercicio 05:
SELECT id, code, name FROM rooms WHERE name LIKE '%Sur%' OR name LIKE '%Ágora%';





-- ------------------------------------------------------------
-- 06. Mostrar cada sala con su sede y ciudad.
-- Respuesta propuesta al ejercicio 06:
SELECT r.id, r.name AS sala, s.name AS sede, s.city AS ciudad
FROM rooms AS r JOIN sites AS s ON s.id = r.site_id;





-- ------------------------------------------------------------
-- 07. Mostrar cada reserva con el nombre de la sala y del organizador.
-- Respuesta propuesta al ejercicio 07:
SELECT re.id AS reserva, ro.name AS sala, e.name AS organizador, re.started_at
FROM reservations AS re JOIN rooms AS ro ON ro.id = re.room_id
JOIN employees AS e ON e.id = re.organizer_id;





-- ------------------------------------------------------------
-- 08. Contar reservas por sala, incluyendo salas sin ninguna reserva. Usar LEFT JOIN.
-- Respuesta propuesta al ejercicio 08:
SELECT ro.id, ro.name AS sala, COUNT(re.id) AS reservas
FROM rooms AS ro LEFT JOIN reservations AS re ON re.room_id = ro.id
GROUP BY ro.id, ro.name;





-- ------------------------------------------------------------
-- 09. Contar las reservas por estado.
-- Respuesta propuesta al ejercicio 09:
SELECT status AS estado, COUNT(*) AS cantidad FROM reservations GROUP BY status;





-- ------------------------------------------------------------
-- 10. Encontrar salas que tengan al menos dos reservas registradas. Usar HAVING.
-- Respuesta propuesta al ejercicio 10:
SELECT ro.id, ro.name, COUNT(re.id) AS reservas
FROM rooms AS ro JOIN reservations AS re ON re.room_id = ro.id
GROUP BY ro.id, ro.name HAVING COUNT(re.id) >= 2;





-- ------------------------------------------------------------
-- 11. Mostrar el número de reservas CONFIRMADAS por sala, sin incluir los demás estados.
-- Respuesta propuesta al ejercicio 11:
SELECT ro.id, ro.name, COUNT(re.id) AS confirmadas
FROM rooms AS ro JOIN reservations AS re ON re.room_id = ro.id
WHERE re.status = 'CONFIRMADA'
GROUP BY ro.id, ro.name;





-- ------------------------------------------------------------
-- 12. Mostrar los empleados invitados a cada reserva, indicando motivo y respuesta.
-- Respuesta propuesta al ejercicio 12:
SELECT re.id AS reserva, e.name AS invitado, re.reason AS motivo, rp.response AS respuesta
FROM reservation_participants AS rp
JOIN reservations AS re ON re.id = rp.reservation_id
JOIN employees AS e ON e.id = rp.employee_id;





-- ------------------------------------------------------------
-- 13. Listar reservas CONFIRMADAS del 3 de noviembre de 2026. Usar BETWEEN.
-- Respuesta propuesta al ejercicio 13:
SELECT id, room_id, started_at, ended_at, status FROM reservations
WHERE status = 'CONFIRMADA'
  AND started_at BETWEEN '2026-11-03 00:00:00' AND '2026-11-03 23:59:59';





-- ------------------------------------------------------------
-- 14. Mostrar recursos asociados a reservas, indicando el organizador de la reserva.
-- Respuesta propuesta al ejercicio 14:
SELECT re.id AS reserva, rs.name AS recurso, e.name AS organizador
FROM reservation_resources AS rr
JOIN resources AS rs ON rs.id = rr.resource_id
JOIN reservations AS re ON re.id = rr.reservation_id
JOIN employees AS e ON e.id = re.organizer_id;





-- ------------------------------------------------------------
-- 15. Contar participantes invitados por reserva, incluyendo reservas sin participantes.
-- Respuesta propuesta al ejercicio 15:
SELECT re.id, re.reason, COUNT(rp.employee_id) AS invitados
FROM reservations AS re LEFT JOIN reservation_participants AS rp ON rp.reservation_id = re.id
GROUP BY re.id, re.reason;





-- ------------------------------------------------------------
-- 16. Mostrar los bloqueos de salas junto con la sede donde ocurren.
-- Respuesta propuesta al ejercicio 16:
SELECT rb.id, ro.name AS sala, s.name AS sede, rb.started_at, rb.ended_at, rb.reason
FROM room_blocks AS rb JOIN rooms AS ro ON ro.id = rb.room_id
JOIN sites AS s ON s.id = ro.site_id;





-- ------------------------------------------------------------
-- 17. Encontrar empleados con dos o más invitaciones ACEPTADA. Usar HAVING.
-- Respuesta propuesta al ejercicio 17:
SELECT e.id, e.name, COUNT(rp.reservation_id) AS aceptadas
FROM employees AS e JOIN reservation_participants AS rp ON rp.employee_id = e.id
WHERE rp.response = 'ACEPTADA'
GROUP BY e.id, e.name HAVING COUNT(rp.reservation_id) >= 2;





-- ------------------------------------------------------------
-- 18 | SUBCONSULTA. SUBCONSULTA: encontrar empleados que nunca han organizado una reserva. Usar NOT EXISTS.
-- Respuesta propuesta al ejercicio 18:
SELECT e.id, e.name FROM employees AS e
WHERE NOT EXISTS (SELECT 1 FROM reservations AS re WHERE re.organizer_id = e.id);





-- ------------------------------------------------------------
-- 19 | SUBCONSULTA. SUBCONSULTA: mostrar salas cuya capacidad sea mayor al promedio de capacidades de todas las salas.
-- Respuesta propuesta al ejercicio 19:
SELECT id, name, capacity FROM rooms
WHERE capacity > (SELECT AVG(capacity) FROM rooms);





-- ------------------------------------------------------------
-- 20 | SUBCONSULTA. SUBCONSULTA: listar recursos nunca solicitados en una reserva CONFIRMADA. Usar NOT EXISTS.
-- Respuesta propuesta al ejercicio 20:
SELECT rs.id, rs.name FROM resources AS rs
WHERE NOT EXISTS (
  SELECT 1 FROM reservation_resources AS rr
  JOIN reservations AS re ON re.id = rr.reservation_id
  WHERE rr.resource_id = rs.id AND re.status = 'CONFIRMADA'
);



