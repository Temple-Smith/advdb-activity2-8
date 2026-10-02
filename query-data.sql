--- Advanced Database Activity 2
--- Drew Temple-Smith, Kyle Castillo, Brayden Nickel, Ethan Pelletier

--- 1. Aggregation
SELECT
    COUNT(*)                AS total_bills,
    SUM(amount)             AS total_billing,
    ROUND(AVG(amount), 2)   AS average_bill
FROM bill;


--- 2. Subqueries and JOINs: patients, what they were billed, and their doctors
-- DISTINCT stops a patient with several appointments with the same doctor
-- from showing up as duplicate rows.
SELECT DISTINCT
    pt.patient_id,
    pp.first_name,
    pp.last_name,
    billing.total_billed,
    dp.first_name AS doctor_first_name,
    dp.last_name  AS doctor_last_name
FROM patient pt
JOIN person pp
    ON pt.person_id = pp.person_id
LEFT JOIN (
    SELECT
        patient_id,
        SUM(amount) AS total_billed
    FROM bill
    GROUP BY patient_id
) billing
    ON pt.patient_id = billing.patient_id
LEFT JOIN appointment a
    ON pt.patient_id = a.patient_id
LEFT JOIN doctor d
    ON a.doctor_id = d.doctor_id
LEFT JOIN person dp
    ON d.person_id = dp.person_id
ORDER BY pt.patient_id, doctor_last_name;


--- 3. GROUP BY with HAVING: doctors with more than $200 in billing
SELECT
    d.doctor_id,
    p.first_name,
    p.last_name,
    SUM(b.amount) AS total_billed
FROM doctor d
JOIN person p
    ON d.person_id = p.person_id
JOIN bill b
    ON d.doctor_id = b.doctor_id
GROUP BY
    d.doctor_id,
    p.first_name,
    p.last_name
HAVING SUM(b.amount) > 200;


--- 4. View: doctor billing summary
CREATE OR REPLACE VIEW doctor_billing_summary AS
SELECT
    d.doctor_id,
    p.first_name,
    p.last_name,
    COUNT(b.bill_id)                    AS total_bills,
    COALESCE(SUM(b.amount), 0)          AS total_billed,
    COALESCE(ROUND(AVG(b.amount), 2), 0) AS average_bill
FROM doctor d
JOIN person p
    ON d.person_id = p.person_id
LEFT JOIN bill b
    ON d.doctor_id = b.doctor_id
GROUP BY
    d.doctor_id,
    p.first_name,
    p.last_name;

--- Using the view
SELECT *
FROM doctor_billing_summary
ORDER BY total_billed DESC;


--- 5. For each doctor, who are their two highest-billed patients?
WITH patient_billing AS (
    SELECT
        b.doctor_id,
        b.patient_id,
        SUM(b.amount) AS total_billed
    FROM bill b
    GROUP BY
        b.doctor_id,
        b.patient_id
),
ranked_patients AS (
    SELECT
        pb.doctor_id,
        dp.first_name AS doctor_first_name,
        dp.last_name  AS doctor_last_name,
        pb.patient_id,
        pp.first_name AS patient_first_name,
        pp.last_name  AS patient_last_name,
        pb.total_billed,
        ROW_NUMBER() OVER (
            PARTITION BY pb.doctor_id
            ORDER BY pb.total_billed DESC, pb.patient_id
        ) AS patient_rank
    FROM patient_billing pb
    JOIN doctor d
        ON pb.doctor_id = d.doctor_id
    JOIN person dp
        ON d.person_id = dp.person_id
    JOIN patient pt
        ON pb.patient_id = pt.patient_id
    JOIN person pp
        ON pt.person_id = pp.person_id
)
SELECT *
FROM ranked_patients
WHERE patient_rank <= 2
ORDER BY doctor_id, patient_rank;


--- 6. How did visits and billing change from month to month?
WITH monthly_stats AS (
    SELECT
        TO_CHAR(v.visit_date, 'YYYY-MM')    AS visit_month,
        COUNT(DISTINCT v.visit_id)          AS total_visits,
        COALESCE(SUM(b.amount), 0)          AS total_billing
    FROM visit v
    LEFT JOIN bill b
        ON v.visit_id = b.visit_id
    GROUP BY TO_CHAR(v.visit_date, 'YYYY-MM')
),
monthly_changes AS (
    SELECT
        visit_month,
        total_visits,
        total_billing,
        LAG(total_visits)  OVER (ORDER BY visit_month) AS previous_visits,
        LAG(total_billing) OVER (ORDER BY visit_month) AS previous_billing
    FROM monthly_stats
)
SELECT
    visit_month,
    total_visits,
    total_billing,
    total_visits  - previous_visits  AS visit_change,
    total_billing - previous_billing AS billing_change
FROM monthly_changes
ORDER BY visit_month;


--- 7. Doctors who bill more than the average doctor, and their share of all clinic billing
-- The share is calculated BEFORE filtering. A window function in the same
-- SELECT as the WHERE would only add up the doctors that passed the filter.
WITH doctor_totals AS (
    SELECT
        d.doctor_id,
        p.first_name,
        p.last_name,
        COALESCE(SUM(b.amount), 0) AS total_billed
    FROM doctor d
    JOIN person p
        ON d.person_id = p.person_id
    LEFT JOIN bill b
        ON d.doctor_id = b.doctor_id
    GROUP BY
        d.doctor_id,
        p.first_name,
        p.last_name
),
doctor_shares AS (
    SELECT
        doctor_id,
        first_name,
        last_name,
        total_billed,
        ROUND(
            100.0 * total_billed / NULLIF(SUM(total_billed) OVER (), 0),
            2
        ) AS clinic_billing_share_pct
    FROM doctor_totals
)
SELECT *
FROM doctor_shares
WHERE total_billed > (SELECT AVG(total_billed) FROM doctor_totals)
ORDER BY total_billed DESC;