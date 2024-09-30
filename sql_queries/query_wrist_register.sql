SELECT 
    r.patient_id, 
    r.index_date,
    (
        SELECT COUNT(DISTINCT r2.index_date) 
        FROM register_table r2 
        WHERE r2.patient_id = r.patient_id 
            AND r2.diagnosis_code IN ('S525', 'S526', 'L72') 
            AND ABS(JULIANDAY(r2.index_date) - JULIANDAY(r.index_date)) < 60
    ) AS register_contact_count,
    (
        SELECT COUNT(DISTINCT p.exam_id) 
        FROM pacs_table p 
        WHERE p.patient_id = r.patient_id 
            AND p.exam_type IN ('ND1AA', 'ND1BA', 'ND1DA') 
            AND ABS(JULIANDAY(p.exam_date) - JULIANDAY(r.index_date)) < 60
    ) AS pacs_exam_count
FROM register_table r 
LEFT JOIN register_table r_comp 
    ON r_comp.patient_id = r.patient_id 
    AND r_comp.diagnosis_code IN ('S525', 'S526', 'L72') 
    AND ABS(JULIANDAY(r_comp.index_date) - JULIANDAY(r.index_date)) < 365 
    AND r_comp.rownum < r.rownum
WHERE
    r_comp.patient_id IS NULL 
    AND r.diagnosis_code IN ('S525', 'S526', 'L72') 
    AND r.index_date > '2011' 
    AND r.index_date < '2023';

