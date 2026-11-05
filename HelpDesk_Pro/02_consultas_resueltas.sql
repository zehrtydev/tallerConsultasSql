-- ============================================================
-- HELPDESK PRO | ESTUDIANTES - ESPACIOS PARA RESOLVER
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: helpdesk_pro
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

USE helpdesk_pro;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    t.id AS codigo_ticket,
    t.subject AS asunto,
    t.status AS estado
FROM tickets AS t;


-- ------------------------------------------------------------
-- 01. Mostrar el código, asunto, prioridad y estado de todos los tickets, ordenados por código.
-- Respuesta propuesta al ejercicio 01:
SELECT id AS codigo_ticket, subject AS asunto, priority AS prioridad, status AS estado
FROM tickets ORDER BY id;





-- ------------------------------------------------------------
-- 02. Listar los tickets con prioridad ALTA o CRITICA que estén ABIERTO o EN_PROCESO. Usar AND, OR y paréntesis.
-- Respuesta propuesta al ejercicio 02:
SELECT id, subject, priority, status FROM tickets
WHERE priority IN ('ALTA','CRITICA') AND (status = 'ABIERTO' OR status = 'EN_PROCESO');





-- ------------------------------------------------------------
-- 03. Buscar los clientes ACTIVOS cuya razón social contenga SAS. Usar LIKE.
-- Respuesta propuesta al ejercicio 03:
SELECT id, company_name, status FROM clients
WHERE status = 'ACTIVO' AND company_name LIKE '%SAS%';





-- ------------------------------------------------------------
-- 04. Obtener los tres tickets más recientes según su fecha de apertura. Usar ORDER BY y LIMIT.
-- Respuesta propuesta al ejercicio 04:
SELECT id, subject, opened_at FROM tickets ORDER BY opened_at DESC, id DESC LIMIT 3;





-- ------------------------------------------------------------
-- 05. Mostrar tickets cuyo asunto contenga la palabra Red o Servidor. Usar LIKE y OR.
-- Respuesta propuesta al ejercicio 05:
SELECT id, subject FROM tickets WHERE subject LIKE '%Red%' OR subject LIKE '%Servidor%';





-- ------------------------------------------------------------
-- 06. Mostrar el código y asunto de cada ticket junto con el nombre de su contacto. Usar JOIN.
-- Respuesta propuesta al ejercicio 06:
SELECT t.id, t.subject, c.name AS contacto
FROM tickets AS t JOIN contacts AS c ON c.id = t.contact_id ORDER BY t.id;





-- ------------------------------------------------------------
-- 07. Mostrar cada ticket con el cliente que lo reportó y la categoría de soporte. Usar varios JOIN.
-- Respuesta propuesta al ejercicio 07:
SELECT t.id, t.subject, cl.company_name AS cliente, ca.name AS categoria
FROM tickets AS t
JOIN contacts AS c ON c.id = t.contact_id
JOIN clients AS cl ON cl.id = c.client_id
JOIN categories AS ca ON ca.id = t.category_id;





-- ------------------------------------------------------------
-- 08. Listar todos los técnicos y cuántas asignaciones han recibido, incluso si nunca han sido asignados. Usar LEFT JOIN.
-- Respuesta propuesta al ejercicio 08:
SELECT te.id, te.name AS tecnico, COUNT(a.id) AS total_asignaciones
FROM technicians AS te LEFT JOIN assignments AS a ON a.technician_id = te.id
GROUP BY te.id, te.name ORDER BY total_asignaciones DESC;





-- ------------------------------------------------------------
-- 09. Contar cuántos tickets existen por prioridad. Usar GROUP BY.
-- Respuesta propuesta al ejercicio 09:
SELECT priority, COUNT(*) AS cantidad FROM tickets GROUP BY priority;





-- ------------------------------------------------------------
-- 10. Mostrar cuántos tickets se registraron en cada estado, ordenados del más frecuente al menos frecuente.
-- Respuesta propuesta al ejercicio 10:
SELECT status, COUNT(*) AS cantidad FROM tickets GROUP BY status ORDER BY cantidad DESC;





-- ------------------------------------------------------------
-- 11. Mostrar los tickets con asignación todavía abierta y el técnico responsable. Usar IS NULL.
-- Respuesta propuesta al ejercicio 11:
SELECT t.id, t.subject, te.name AS responsable, a.started_at
FROM assignments AS a JOIN tickets AS t ON t.id = a.ticket_id
JOIN technicians AS te ON te.id = a.technician_id
WHERE a.ended_at IS NULL;





-- ------------------------------------------------------------
-- 12. Buscar tickets abiertos desde el 1 hasta el 5 de septiembre de 2026, incluyendo todo el día 5. Usar BETWEEN.
-- Respuesta propuesta al ejercicio 12:
SELECT id, subject, opened_at FROM tickets
WHERE opened_at BETWEEN '2026-09-01 00:00:00' AND '2026-09-05 23:59:59';





-- ------------------------------------------------------------
-- 13. Mostrar los comentarios escritos por técnicos con el nombre del autor y el asunto del ticket.
-- Respuesta propuesta al ejercicio 13:
SELECT co.id, co.content, te.name AS autor, t.subject AS asunto
FROM comments AS co JOIN technicians AS te ON te.id = co.technician_id
JOIN tickets AS t ON t.id = co.ticket_id;





-- ------------------------------------------------------------
-- 14. Contar los comentarios por ticket, incluyendo tickets sin comentarios.
-- Respuesta propuesta al ejercicio 14:
SELECT t.id, t.subject, COUNT(co.id) AS total_comentarios
FROM tickets AS t LEFT JOIN comments AS co ON co.ticket_id = t.id
GROUP BY t.id, t.subject ORDER BY t.id;





-- ------------------------------------------------------------
-- 15. Mostrar las empresas que hayan reportado dos o más tickets. Usar GROUP BY y HAVING.
-- Respuesta propuesta al ejercicio 15:
SELECT cl.id, cl.company_name, COUNT(t.id) AS total_tickets
FROM clients AS cl JOIN contacts AS c ON c.client_id = cl.id
JOIN tickets AS t ON t.contact_id = c.id
GROUP BY cl.id, cl.company_name HAVING COUNT(t.id) >= 2;





-- ------------------------------------------------------------
-- 16. Encontrar las categorías con al menos dos tickets registrados. Usar HAVING.
-- Respuesta propuesta al ejercicio 16:
SELECT ca.id, ca.name, COUNT(t.id) AS total_tickets
FROM categories AS ca JOIN tickets AS t ON t.category_id = ca.id
GROUP BY ca.id, ca.name HAVING COUNT(t.id) >= 2;





-- ------------------------------------------------------------
-- 17. Mostrar cada cambio de estado con el asunto del ticket y el nombre del técnico, incluyendo cambios automáticos.
-- Respuesta propuesta al ejercicio 17:
SELECT sh.id, t.subject, sh.previous_status, sh.new_status, sh.changed_at,
       COALESCE(te.name, 'Sistema automático') AS responsable
FROM status_history AS sh JOIN tickets AS t ON t.id = sh.ticket_id
LEFT JOIN technicians AS te ON te.id = sh.technician_id ORDER BY sh.changed_at;





-- ------------------------------------------------------------
-- 18 | SUBCONSULTA. SUBCONSULTA: encontrar los tickets abiertos después de la fecha de apertura del ticket con id 4.
-- Respuesta propuesta al ejercicio 18:
SELECT id, subject, opened_at FROM tickets
WHERE opened_at > (SELECT opened_at FROM tickets WHERE id = 4);





-- ------------------------------------------------------------
-- 19 | SUBCONSULTA. SUBCONSULTA: mostrar los técnicos que no han escrito ningún comentario. Usar NOT EXISTS.
-- Respuesta propuesta al ejercicio 19:
SELECT te.id, te.name FROM technicians AS te
WHERE NOT EXISTS (SELECT 1 FROM comments AS co WHERE co.technician_id = te.id);





-- ------------------------------------------------------------
-- 20 | SUBCONSULTA. SUBCONSULTA: consultar los tickets que tengan una prioridad igual a la de los tickets 1 o 2, excluyendo esos dos tickets. Usar IN.
-- Respuesta propuesta al ejercicio 20:
SELECT id, subject, priority FROM tickets
WHERE id NOT IN (1,2) AND priority IN (SELECT priority FROM tickets WHERE id IN (1,2));



