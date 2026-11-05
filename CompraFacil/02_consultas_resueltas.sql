-- ============================================================
-- COMPRAFÁCIL | ESTUDIANTES - ESPACIOS PARA RESOLVER
-- Archivo 02/02 - 20 ejercicios DQL
-- Base de datos: comprafacil
-- Instrucciones: ejecutar primero el archivo 01_base_datos.sql.
-- Consultas 18, 19 y 20: obligatoriamente con subconsultas.
-- No modificar los datos semilla durante esta evaluacion.
-- Alias y etiquetas visibles al cliente pueden estar en espanol.
-- ============================================================

USE comprafacil;

-- EJEMPLO DE CLASE (no calificable)
SELECT
    p.id AS codigo_producto,
    p.name AS producto,
    p.active AS activo
FROM products AS p;


-- ------------------------------------------------------------
-- 01. Mostrar el código, nombre y correo de los empleados que pueden solicitar compras.
-- Respuesta propuesta al ejercicio 01:
SELECT code AS codigo, name AS empleado, email AS correo FROM employees ORDER BY code;





-- ------------------------------------------------------------
-- 02. Mostrar los productos activos y su unidad de medida. Usar WHERE.
-- Respuesta propuesta al ejercicio 02:
SELECT sku, name AS producto, unit_of_measure AS unidad FROM products WHERE active = TRUE;





-- ------------------------------------------------------------
-- 03. Listar órdenes con estado PARCIAL o EMITIDA. Usar OR.
-- Respuesta propuesta al ejercicio 03:
SELECT id, request_id, issued_at, status FROM purchase_orders
WHERE status = 'PARCIAL' OR status = 'EMITIDA';





-- ------------------------------------------------------------
-- 04. Mostrar las solicitudes creadas entre el 1 y el 5 de septiembre de 2026. Usar BETWEEN.
-- Respuesta propuesta al ejercicio 04:
SELECT id, employee_id, created_at, status FROM requests
WHERE created_at BETWEEN '2026-09-01 00:00:00' AND '2026-09-05 23:59:59';





-- ------------------------------------------------------------
-- 05. Buscar productos cuyo nombre contenga Cable o Teclado. Usar LIKE.
-- Respuesta propuesta al ejercicio 05:
SELECT sku, name FROM products WHERE name LIKE '%Cable%' OR name LIKE '%Teclado%';





-- ------------------------------------------------------------
-- 06. Mostrar cada solicitud con el empleado que la creó, su fecha y estado.
-- Respuesta propuesta al ejercicio 06:
SELECT r.id AS solicitud, e.name AS empleado, r.created_at AS fecha, r.status AS estado
FROM requests AS r JOIN employees AS e ON e.id = r.employee_id;





-- ------------------------------------------------------------
-- 07. Mostrar cada orden de compra junto con el proveedor y la justificación de la solicitud que originó la orden.
-- Respuesta propuesta al ejercicio 07:
SELECT po.id AS orden, s.company_name AS proveedor, r.justification AS justificacion
FROM purchase_orders AS po JOIN suppliers AS s ON s.id = po.supplier_id
JOIN requests AS r ON r.id = po.request_id;





-- ------------------------------------------------------------
-- 08. Mostrar productos y cantidades requeridas de cada solicitud. Usar JOIN.
-- Respuesta propuesta al ejercicio 08:
SELECT ri.request_id AS solicitud, p.name AS producto, ri.requested_quantity AS cantidad
FROM request_items AS ri JOIN products AS p ON p.id = ri.product_id
ORDER BY ri.request_id, ri.id;





-- ------------------------------------------------------------
-- 09. Contar las solicitudes por estado.
-- Respuesta propuesta al ejercicio 09:
SELECT status AS estado, COUNT(*) AS cantidad FROM requests GROUP BY status;





-- ------------------------------------------------------------
-- 10. Calcular el valor total de cada orden sumando cantidad ordenada multiplicada por precio unitario.
-- Respuesta propuesta al ejercicio 10:
SELECT po.id AS orden, SUM(oi.ordered_quantity * oi.unit_price) AS valor_total
FROM purchase_orders AS po JOIN order_items AS oi ON oi.order_id = po.id
GROUP BY po.id ORDER BY po.id;





-- ------------------------------------------------------------
-- 11. Mostrar cada recepción con su número de remisión y proveedor.
-- Respuesta propuesta al ejercicio 11:
SELECT re.id, re.delivery_note AS remision, re.received_at, s.company_name AS proveedor
FROM receipts AS re JOIN purchase_orders AS po ON po.id = re.order_id
JOIN suppliers AS s ON s.id = po.supplier_id;





-- ------------------------------------------------------------
-- 12. Mostrar los productos recibidos, su cantidad recibida y la remisión correspondiente.
-- Respuesta propuesta al ejercicio 12:
SELECT re.delivery_note AS remision, p.name AS producto, ri.received_quantity AS cantidad_recibida
FROM receipt_items AS ri JOIN receipts AS re ON re.id = ri.receipt_id
JOIN order_items AS oi ON oi.id = ri.order_item_id
JOIN request_items AS reqi ON reqi.id = oi.request_item_id
JOIN products AS p ON p.id = reqi.product_id;





-- ------------------------------------------------------------
-- 13. Calcular la cantidad pendiente por renglón de orden: cantidad ordenada menos lo recibido. Mostrar también los renglones sin recepción.
-- Respuesta propuesta al ejercicio 13:
SELECT oi.id AS renglon, oi.order_id AS orden, oi.ordered_quantity AS cantidad_ordenada,
       COALESCE(SUM(ri.received_quantity),0) AS cantidad_recibida,
       oi.ordered_quantity - COALESCE(SUM(ri.received_quantity),0) AS cantidad_pendiente
FROM order_items AS oi LEFT JOIN receipt_items AS ri ON ri.order_item_id = oi.id
GROUP BY oi.id, oi.order_id, oi.ordered_quantity;





-- ------------------------------------------------------------
-- 14. Contar las órdenes por proveedor, incluyendo proveedores que todavía no tienen órdenes.
-- Respuesta propuesta al ejercicio 14:
SELECT s.id, s.company_name, COUNT(po.id) AS total_ordenes
FROM suppliers AS s LEFT JOIN purchase_orders AS po ON po.supplier_id = s.id
GROUP BY s.id, s.company_name;





-- ------------------------------------------------------------
-- 15. Mostrar empleados que hayan realizado dos o más solicitudes. Usar HAVING.
-- Respuesta propuesta al ejercicio 15:
SELECT e.id, e.name, COUNT(r.id) AS solicitudes
FROM employees AS e JOIN requests AS r ON r.employee_id = e.id
GROUP BY e.id, e.name HAVING COUNT(r.id) >= 2;





-- ------------------------------------------------------------
-- 16. Mostrar productos presentes en dos o más renglones de órdenes de compra.
-- Respuesta propuesta al ejercicio 16:
SELECT p.id, p.name, COUNT(oi.id) AS renglones
FROM products AS p JOIN request_items AS reqi ON reqi.product_id = p.id
JOIN order_items AS oi ON oi.request_item_id = reqi.id
GROUP BY p.id, p.name HAVING COUNT(oi.id) >= 2;





-- ------------------------------------------------------------
-- 17. Mostrar los tres renglones de órdenes con mayor valor total (cantidad por precio). Usar LIMIT.
-- Respuesta propuesta al ejercicio 17:
SELECT id, order_id, ordered_quantity, unit_price,
       ordered_quantity * unit_price AS valor_renglon
FROM order_items ORDER BY valor_renglon DESC, id LIMIT 3;





-- ------------------------------------------------------------
-- 18 | SUBCONSULTA. SUBCONSULTA: encontrar renglones cuyo precio unitario sea superior al precio unitario promedio.
-- Respuesta propuesta al ejercicio 18:
SELECT id, order_id, unit_price FROM order_items
WHERE unit_price > (SELECT AVG(unit_price) FROM order_items);





-- ------------------------------------------------------------
-- 19 | SUBCONSULTA. SUBCONSULTA: listar productos que nunca han aparecido en una orden de compra. Usar NOT EXISTS.
-- Respuesta propuesta al ejercicio 19:
SELECT p.id, p.sku, p.name FROM products AS p
WHERE NOT EXISTS (
  SELECT 1 FROM request_items AS ri JOIN order_items AS oi ON oi.request_item_id = ri.id
  WHERE ri.product_id = p.id
);





-- ------------------------------------------------------------
-- 20 | SUBCONSULTA. SUBCONSULTA: listar proveedores que tengan al menos una orden PARCIAL. Usar IN.
-- Respuesta propuesta al ejercicio 20:
SELECT id, company_name FROM suppliers
WHERE id IN (SELECT supplier_id FROM purchase_orders WHERE status = 'PARCIAL');



