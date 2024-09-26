SELECT 
    r.patient_id, 
    r.index_date,
    r.diagnosis_code,
    p.exam_type,
    (
        SELECT COUNT(DISTINCT r2.index_date) 
        FROM register_table r2 
        WHERE r2.patient_id = r.patient_id 
            AND r2.diagnosis_code IN ('S422') 
            AND ABS(JULIANDAY(r2.index_date) - JULIANDAY(r.index_date)) < 100
    ) AS register_contact_count,
    (
        SELECT COUNT(DISTINCT p2.exam_id) 
        FROM pacs_table p2 
        WHERE p2.patient_id = r.patient_id 
            AND p2.exam_type IN ('NB6AA', 'NB6BA', 'NB6DA', 'NB1AA', 'NB1BA', 'NB1DA') 
            AND ABS(JULIANDAY(p2.exam_date) - JULIANDAY(r.index_date)) < 100
    ) AS pacs_exam_count
FROM register_table r 
LEFT JOIN register_table r_comp 
    ON r_comp.patient_id = r.patient_id 
    AND r_comp.diagnosis_code IN ('S422') 
    AND ABS(JULIANDAY(r_comp.index_date) - JULIANDAY(r.index_date)) < 365 
    AND r_comp.rownum < r.rownum
LEFT JOIN pacs_table p 
    ON r.patient_id = p.patient_id  
    AND ABS(JULIANDAY(r.index_date) - JULIANDAY(p.exam_date)) < 100 
    AND p.exam_type IN ('NB6AA', 'NB6BA', 'NB6DA', 'NB1AA', 'NB1BA', 'NB1DA')
LEFT JOIN pacs_table p_comp 
    ON p_comp.patient_id = p.patient_id 
    AND p_comp.exam_type IN ('NB6AA', 'NB6BA', 'NB6DA', 'NB1AA', 'NB1BA', 'NB1DA') 
    AND ABS(JULIANDAY(p_comp.exam_date) - JULIANDAY(r.index_date)) < 100 
    AND p_comp.rownum < p.rownum
WHERE
    r_comp.patient_id IS NULL 
    AND p_comp.patient_id IS NULL
    AND r.diagnosis_code IN ('S422') 
    AND r.index_date > '2011' 
    AND r.index_date < '2023';

