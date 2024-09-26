SELECT 
    p.patient_id, 
    p.exam_date,
    (
        SELECT COUNT(DISTINCT p2.exam_id) 
        FROM pacs_table p2 
        WHERE p2.patient_id = p.patient_id 
            AND p2.exam_type IN ('ND1AA', 'ND1BA', 'ND1DA') 
            AND ABS(JULIANDAY(p2.exam_date) - JULIANDAY(p.exam_date)) < 60
    ) AS pacs_exam_count,
    (
        SELECT COUNT(DISTINCT r.index_date) 
        FROM register_table r 
        WHERE r.patient_id = p.patient_id 
            AND r.diagnosis_code IN ('S525', 'S526', 'L72') 
            AND ABS(JULIANDAY(r.index_date) - JULIANDAY(p.exam_date)) < 60
    ) AS register_contact_count
FROM pacs_table p 
LEFT JOIN pacs_table p_comp 
    ON p_comp.patient_id = p.patient_id 
    AND p_comp.exam_type IN ('ND1AA', 'ND1BA', 'ND1DA') 
    AND ABS(JULIANDAY(p_comp.exam_date) - JULIANDAY(p.exam_date)) < 60 
    AND p_comp.rownum < p.rownum
WHERE
    p_comp.patient_id IS NULL
    AND p.exam_date > '2011' 
    AND p.exam_date < '2023' 
    AND p.request_date > '2011'
    AND p.exam_type IN ('ND1AA', 'ND1BA', 'ND1DA');
