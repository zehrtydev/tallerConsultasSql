-- ============================================================
-- EXAMEN PRACTICO FINAL - MYSQL I
-- INGENIERIA INVERSA Y CONSULTAS DQL
-- ============================================================

-- 01. HelpDesk Pro: clientes activos que requieren atencion prioritaria
USE helpdesk_pro;

SELECT
    c.company_name AS cliente,
    COUNT(t.id) AS total_tickets,
    SUM(CASE WHEN t.status IN ('ABIERTO', 'EN_PROCESO') THEN 1 ELSE 0 END) AS tickets_pendientes,
    SUM(CASE WHEN t.status IN ('ABIERTO', 'EN_PROCESO')
              AND t.priority = 'CRITICA' THEN 1 ELSE 0 END) AS criticos_pendientes,
    MAX(t.opened_at) AS ultima_apertura
FROM clients AS c
JOIN contacts AS ct ON ct.client_id = c.id
JOIN tickets AS t ON t.contact_id = ct.id
WHERE c.status = 'ACTIVO'
GROUP BY c.id, c.company_name
HAVING COUNT(t.id) >= 2
   AND SUM(CASE WHEN t.status IN ('ABIERTO', 'EN_PROCESO') THEN 1 ELSE 0 END) > 0
ORDER BY tickets_pendientes DESC, cliente ASC;

-- 02. HelpDesk Pro: asignaciones vigentes sin comentario del tecnico actual
USE helpdesk_pro;

SELECT
    t.id AS codigo_ticket,
    t.subject AS asunto,
    c.company_name AS cliente,
    te.name AS tecnico,
    t.priority AS prioridad,
    a.started_at AS asignado_desde
FROM tickets AS t
JOIN contacts AS ct ON ct.id = t.contact_id
JOIN clients AS c ON c.id = ct.client_id
JOIN assignments AS a ON a.ticket_id = t.id AND a.ended_at IS NULL
JOIN technicians AS te ON te.id = a.technician_id
WHERE t.status IN ('ABIERTO', 'EN_PROCESO')
  AND NOT EXISTS (
      SELECT 1
      FROM comments AS cm
      WHERE cm.ticket_id = t.id
        AND cm.technician_id = a.technician_id
  )
ORDER BY t.opened_at ASC, t.id ASC;

-- 03. AssetControl: gasto acumulado de mantenimiento por sede
USE assetcontrol;

SELECT
    s.name AS sede,
    s.city AS ciudad,
    COUNT(DISTINCT a.id) AS total_equipos,
    COUNT(DISTINCT CASE WHEN m.id IS NOT NULL THEN a.id END) AS equipos_intervenidos,
    ROUND(COALESCE(SUM(m.cost), 0), 2) AS costo_total,
    ROUND(1.0 * COALESCE(SUM(m.cost), 0) / NULLIF(COUNT(DISTINCT a.id), 0), 2) AS promedio_por_equipo
FROM sites AS s
LEFT JOIN assets AS a ON a.site_id = s.id
LEFT JOIN maintenance AS m ON m.asset_id = a.id
GROUP BY s.id, s.name, s.city
HAVING COUNT(DISTINCT a.id) >= 2
ORDER BY costo_total DESC, sede ASC;

-- 04. AssetControl: equipos vigentes en custodia de otra sede
USE assetcontrol;

SELECT
    a.patrimonial_identifier AS codigo_activo,
    a.brand AS marca,
    e.name AS empleado,
    d.name AS departamento,
    si.name AS sede_inventario,
    sd.name AS sede_departamento,
    ass.started_at AS fecha_asignacion
FROM assignments AS ass
JOIN assets AS a ON a.id = ass.asset_id
JOIN employees AS e ON e.id = ass.employee_id
JOIN departments AS d ON d.id = e.department_id
JOIN sites AS si ON si.id = a.site_id
JOIN sites AS sd ON sd.id = d.site_id
WHERE ass.return_date IS NULL
  AND a.site_id <> d.site_id
ORDER BY a.patrimonial_identifier ASC;

-- 05. CompraFacil: valor ordenado y recibido, sin multiplicar lineas por recepciones
USE comprafacil;

WITH ordenado AS (
    SELECT
        oi.order_id,
        SUM(oi.ordered_quantity * oi.unit_price) AS valor
    FROM order_items AS oi
    GROUP BY oi.order_id
),
recibido AS (
    SELECT
        r.order_id,
        SUM(ri.received_quantity * oi.unit_price) AS valor
    FROM receipts AS r
    JOIN receipt_items AS ri ON ri.receipt_id = r.id
    JOIN order_items AS oi ON oi.id = ri.order_item_id
                          AND oi.order_id = r.order_id
    GROUP BY r.order_id
)
SELECT
    po.id AS codigo_orden,
    s.company_name AS proveedor,
    po.status AS estado,
    ROUND(COALESCE(o.valor, 0), 2) AS valor_ordenado,
    ROUND(COALESCE(r.valor, 0), 2) AS valor_recibido,
    ROUND(COALESCE(o.valor, 0) - COALESCE(r.valor, 0), 2) AS saldo_pendiente
FROM purchase_orders AS po
JOIN suppliers AS s ON s.id = po.supplier_id
LEFT JOIN ordenado AS o ON o.order_id = po.id
LEFT JOIN recibido AS r ON r.order_id = po.id
WHERE po.status <> 'ANULADA'
ORDER BY saldo_pendiente DESC, po.id ASC;

-- 06. CompraFacil: productos repetidos en solicitudes con cantidad sin ordenar
USE comprafacil;

WITH cantidades_ordenadas AS (
    SELECT
        oi.request_item_id,
        SUM(oi.ordered_quantity) AS cantidad
    FROM order_items AS oi
    JOIN purchase_orders AS po ON po.id = oi.order_id
    JOIN request_items AS ri ON ri.id = oi.request_item_id
                            AND ri.request_id = po.request_id
    GROUP BY oi.request_item_id
)
SELECT
    p.sku AS sku,
    p.name AS producto,
    COUNT(DISTINCT ri.request_id) AS solicitudes,
    SUM(ri.requested_quantity) AS cantidad_solicitada,
    COALESCE(SUM(co.cantidad), 0) AS cantidad_ordenada,
    SUM(ri.requested_quantity) - COALESCE(SUM(co.cantidad), 0) AS cantidad_no_ordenada
FROM products AS p
JOIN request_items AS ri ON ri.product_id = p.id
LEFT JOIN cantidades_ordenadas AS co ON co.request_item_id = ri.id
GROUP BY p.id, p.sku, p.name
HAVING COUNT(DISTINCT ri.request_id) >= 2
   AND SUM(ri.requested_quantity) > COALESCE(SUM(co.cantidad), 0)
ORDER BY cantidad_no_ordenada DESC, sku ASC;

-- 07. TalentTrack: aptitud para certificacion por matricula y edicion
USE talenttrack;

WITH sesiones AS (
    SELECT edition_id, COUNT(*) AS total
    FROM sessions
    GROUP BY edition_id
),
asistencias AS (
    SELECT
        en.id AS enrollment_id,
        COUNT(DISTINCT at.session_id) AS registradas,
        COUNT(DISTINCT CASE WHEN at.status = 'PRESENTE' THEN at.session_id END) AS presentes
    FROM enrollments AS en
    JOIN sessions AS se ON se.edition_id = en.edition_id
    JOIN attendance AS at ON at.enrollment_id = en.id
                         AND at.session_id = se.id
    GROUP BY en.id
)
SELECT
    en.id AS codigo_matricula,
    co.name AS colaborador,
    ed.code AS edicion,
    COALESCE(se.total, 0) AS sesiones_programadas,
    COALESCE(a.registradas, 0) AS asistencias_registradas,
    COALESCE(a.presentes, 0) AS presencias,
    COALESCE(ROUND(100.0 * COALESCE(a.presentes, 0) / NULLIF(se.total, 0), 2), 0.00) AS porcentaje_asistencia,
    CASE
        WHEN ed.status = 'FINALIZADA'
             AND COALESCE(se.total, 0) > 0
             AND COALESCE(a.registradas, 0) = se.total
             AND 100 * COALESCE(a.presentes, 0) >= 80 * se.total
        THEN 'SI' ELSE 'NO'
    END AS apto_para_certificado,
    CASE WHEN cert.id IS NOT NULL THEN 'SI' ELSE 'NO' END AS certificado_emitido
FROM enrollments AS en
JOIN collaborators AS co ON co.id = en.collaborator_id
JOIN editions AS ed ON ed.id = en.edition_id
LEFT JOIN sesiones AS se ON se.edition_id = ed.id
LEFT JOIN asistencias AS a ON a.enrollment_id = en.id
LEFT JOIN certificates AS cert ON cert.enrollment_id = en.id
ORDER BY ed.code ASC, co.name ASC;

-- 08. TalentTrack: efectividad de certificacion por empresa activa
USE talenttrack;

SELECT
    c.company_name AS empresa,
    COUNT(DISTINCT col.id) AS colaboradores_matriculados,
    COUNT(DISTINCT en.id) AS total_matriculas,
    COUNT(DISTINCT ed.course_id) AS cursos_distintos,
    COUNT(DISTINCT cert.id) AS certificados_emitidos,
    ROUND(100.0 * COUNT(DISTINCT cert.id) / NULLIF(COUNT(DISTINCT en.id), 0), 2) AS tasa_certificacion
FROM companies AS c
JOIN collaborators AS col ON col.company_id = c.id
JOIN enrollments AS en ON en.collaborator_id = col.id
JOIN editions AS ed ON ed.id = en.edition_id
LEFT JOIN certificates AS cert ON cert.enrollment_id = en.id
WHERE c.status = 'ACTIVA'
GROUP BY c.id, c.company_name
HAVING COUNT(DISTINCT en.id) >= 2
ORDER BY tasa_certificacion DESC, empresa ASC;

-- 09. SpaceBook: salas activas sin reservas confirmadas ni bloqueos solapados
USE spacebook;

SELECT
    rm.code AS codigo_sala,
    rm.name AS sala,
    s.name AS sede,
    s.city AS ciudad,
    rm.capacity AS capacidad
FROM rooms AS rm
JOIN sites AS s ON s.id = rm.site_id
WHERE rm.status = 'ACTIVA'
  AND NOT EXISTS (
      SELECT 1
      FROM reservations AS r
      WHERE r.room_id = rm.id
        AND r.status = 'CONFIRMADA'
        AND r.started_at < '2026-11-03 09:30:00'
        AND r.ended_at > '2026-11-03 08:30:00'
  )
  AND NOT EXISTS (
      SELECT 1
      FROM room_blocks AS b
      WHERE b.room_id = rm.id
        AND b.started_at < '2026-11-03 09:30:00'
        AND b.ended_at > '2026-11-03 08:30:00'
  )
ORDER BY s.name ASC, rm.name ASC;

-- 10. SpaceBook: participacion, recursos y porcentaje de aforo de reservas confirmadas
USE spacebook;

WITH participacion AS (
    SELECT
        rp.reservation_id,
        COUNT(DISTINCT rp.employee_id) AS invitados,
        COUNT(DISTINCT CASE WHEN rp.response = 'ACEPTADA' THEN rp.employee_id END) AS aceptados,
        COUNT(DISTINCT CASE WHEN rp.response = 'RECHAZADA' THEN rp.employee_id END) AS rechazados
    FROM reservation_participants AS rp
    GROUP BY rp.reservation_id
),
recursos AS (
    SELECT
        rr.reservation_id,
        COUNT(DISTINCT rr.resource_id) AS total
    FROM reservation_resources AS rr
    GROUP BY rr.reservation_id
)
SELECT
    r.id AS codigo_reserva,
    rm.name AS sala,
    e.name AS organizador,
    rm.capacity AS capacidad,
    COALESCE(p.invitados, 0) AS invitados,
    COALESCE(p.aceptados, 0) AS aceptados,
    COALESCE(p.rechazados, 0) AS rechazados,
    COALESCE(rc.total, 0) AS recursos,
    1 + COALESCE(p.aceptados, 0) AS asistentes_confirmados,
    ROUND(100.0 * (1 + COALESCE(p.aceptados, 0)) / NULLIF(rm.capacity, 0), 2) AS porcentaje_aforo
FROM reservations AS r
JOIN rooms AS rm ON rm.id = r.room_id
JOIN employees AS e ON e.id = r.organizer_id
LEFT JOIN participacion AS p ON p.reservation_id = r.id
LEFT JOIN recursos AS rc ON rc.reservation_id = r.id
WHERE r.status = 'CONFIRMADA'
ORDER BY porcentaje_aforo DESC, r.id ASC;
