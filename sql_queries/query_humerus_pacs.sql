SELECT 
    p.patient_id, 
    p.request_type, 
    p.exam_date,
    (
        SELECT COUNT(DISTINCT p2.exam_id) 
        FROM pacs_table p2 
        WHERE p2.patient_id = p.patient_id 
            AND p2.exam_type IN ('NB6AA', 'NB6BA', 'NB6DA', 'NB1AA', 'NB1BA', 'NB1DA') 
            AND ABS(JULIANDAY(p2.exam_date) - JULIANDAY(p.exam_date)) < 100
    ) AS pacs_exam_count,
    (
        SELECT MAX(p3.exam_date) 
        FROM pacs_table p3 
        WHERE p3.patient_id = p.patient_id 
            AND p3.exam_type IN ('NB6AA', 'NB6BA', 'NB6DA', 'NB1AA', 'NB1BA', 'NB1DA') 
            AND ABS(JULIANDAY(p3.exam_date) - JULIANDAY(p.exam_date)) < 100
    ) AS pacs_max_date,
    (
        SELECT COUNT(DISTINCT r.index_date) 
        FROM register_table r 
        WHERE r.patient_id = p.patient_id 
            AND r.diagnosis_code = 'S422' 
            AND ABS(JULIANDAY(r.index_date) - JULIANDAY(p.exam_date)) < 100
    ) AS register_contact_count
FROM pacs_table p 
LEFT JOIN pacs_table p_comp 
    ON p_comp.patient_id = p.patient_id 
    AND p_comp.exam_type IN ('NB6AA', 'NB6BA', 'NB6DA', 'NB1AA', 'NB1BA', 'NB1DA') 
    AND ABS(JULIANDAY(p_comp.exam_date) - JULIANDAY(p.exam_date)) < 100 
    AND p_comp.rownum < p.rownum
WHERE
    p_comp.patient_id IS NULL
    AND p.exam_date > '2011' 
    AND p.exam_date < '2023' 
    AND p.request_date > '2011'
    AND p.exam_type IN ('NB6AA', 'NB6BA', 'NB6DA', 'NB1AA', 'NB1BA', 'NB1DA');

