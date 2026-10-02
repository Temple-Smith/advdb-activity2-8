--- Advanced Database Activity 2
--- Drew Temple-Smith, Kyle Castillo, Brayden Nickel, Ethan Pelletier

BEGIN;

INSERT INTO public.specialty (specialty_name) VALUES
    ('Cardiology'),
    ('Pediatrics'),
    ('Dermatology'),
    ('Orthopedics'),
    ('Family Medicine');

-- Person: ids 1-5 are doctors, ids 6-11 are patients
INSERT INTO public.person (first_name, last_name, date_of_birth, phone, email) VALUES
    ('Sarah',   'Mitchell', '1978-03-14', '416-555-0101', 'sarah.mitchell@clinic.com'),
    ('David',   'Nguyen',   '1983-07-22', '416-555-0102', 'david.nguyen@clinic.com'),
    ('Priya',   'Sharma',   '1980-11-05', '416-555-0103', 'priya.sharma@clinic.com'),
    ('Michael', 'Okafor',   '1975-01-30', '416-555-0104', 'michael.okafor@clinic.com'),
    ('Elena',   'Rossi',    '1986-09-18', '416-555-0105', 'elena.rossi@clinic.com'),
    ('James',   'Anderson', '1990-05-12', '647-555-0201', 'james.anderson@email.com'),
    ('Maria',   'Garcia',   '1985-12-03', '647-555-0202', 'maria.garcia@email.com'),
    ('Liam',    'Chen',     '2015-04-27', '647-555-0203', 'chen.family@email.com'),
    ('Aisha',   'Khan',     '1972-08-09', '647-555-0204', 'aisha.khan@email.com'),
    ('Robert',  'Tremblay', '1960-02-16', '647-555-0205', 'robert.tremblay@email.com'),
    ('Olivia',  'Brown',    '1998-10-21', '647-555-0206', 'olivia.brown@email.com');

INSERT INTO public.doctor (person_id, specialty_id, hire_date, license_no) VALUES
    (1, 1, '2015-06-01', 'ON10001'),
    (2, 2, '2018-09-15', 'ON10002'),
    (3, 3, '2019-03-10', 'ON10003'),
    (4, 4, '2012-01-20', 'ON10004'),
    (5, 5, '2021-07-05', 'ON10005');

INSERT INTO public.patient (person_id, health_card_no, address) VALUES
    (6,  '1234-567-890', '12 Maple St, Toronto, ON'),
    (7,  '2345-678-901', '48 Oak Ave, Toronto, ON'),
    (8,  '3456-789-012', '9 Birch Rd, Mississauga, ON'),
    (9,  '4567-890-123', '77 Pine Cres, Brampton, ON'),
    (10, '5678-901-234', '203 Elm Blvd, Toronto, ON'),
    (11, '6789-012-345', '15 Cedar Ln, Etobicoke, ON');

INSERT INTO public.emergency_contact (patient_id, first_name, last_name, relationship, phone) VALUES
    (1, 'Karen',  'Anderson', 'Mother',  '647-555-0301'),
    (2, 'Carlos', 'Garcia',   'Husband', '647-555-0302'),
    (3, 'Wei',    'Chen',     'Father',  '647-555-0303'),
    (4, 'Omar',   'Khan',     'Brother', '647-555-0304'),
    (5, 'Linda',  'Tremblay', 'Wife',    '647-555-0305'),
    (6, 'Susan',  'Brown',    'Mother',  '647-555-0306');

INSERT INTO public.appointment (patient_id, doctor_id, appointment_datetime, reason, status) VALUES
    (1, 1, '2026-08-05 09:30', 'Chest pain and shortness of breath', 'Completed'),
    (2, 3, '2026-08-12 14:00', 'Persistent skin rash',               'Completed'),
    (3, 2, '2026-09-02 10:15', 'Annual pediatric checkup',           'Completed'),
    (1, 1, '2026-09-16 09:30', 'Blood pressure follow-up',           'Completed'),
    (6, 5, '2026-09-22 11:00', 'Seasonal allergies',                 'Completed'),
    (4, 4, '2026-10-15 13:30', 'Knee pain follow-up',                'Scheduled'),
    (5, 5, '2026-09-20 15:00', 'Flu symptoms',                       'Cancelled'),
    (2, 3, '2026-10-20 14:00', 'Rash follow-up',                     'Scheduled');

-- Visits only exist for Completed appointments (1-5)
INSERT INTO public.visit (appointment_id, diagnosis, treatment, visit_date) VALUES
    (1, 'Mild hypertension',        'Lifestyle changes and low-dose ACE inhibitor', '2026-08-05'),
    (2, 'Contact dermatitis',       'Topical corticosteroid cream for 2 weeks',     '2026-08-12'),
    (3, 'Healthy, up to date',      'Routine vaccinations administered',            '2026-09-02'),
    (4, 'Hypertension, improving',  'Continue current medication',                  '2026-09-16'),
    (5, 'Seasonal allergic rhinitis','Antihistamine as needed',                     '2026-09-22');

-- patient_id / doctor_id match the visit's appointment
INSERT INTO public.bill (visit_id, patient_id, doctor_id, amount, payment_status) VALUES
    (1, 1, 1, 250.00, 'Paid'),
    (2, 2, 3, 180.50, 'Pending'),
    (3, 3, 2, 120.00, 'Paid'),
    (4, 1, 1,  95.00, 'Paid'),
    (5, 6, 5, 110.00, 'Pending');

INSERT INTO public.medical_history (patient_id, visit_id, recorded_on, notes) VALUES
    (1, 1, '2026-08-05', 'Blood pressure 145/92. Advised reduced sodium intake. Recheck in 6 weeks.'),
    (2, 2, '2026-08-12', 'Rash on forearms, likely from new detergent. No known drug allergies.'),
    (3, 3, '2026-09-02', 'Height and weight in normal percentile. MMR booster given.'),
    (1, 4, '2026-09-16', 'Blood pressure 128/82. Responding well to medication.'),
    (6, 5, '2026-09-22', 'Sneezing and itchy eyes each spring. No asthma history.');

COMMIT;

--- Create some more data
BEGIN;

WITH src (patient_id, doctor_id, appt_ts, reason, diagnosis, treatment, amount, pay_status) AS (
    VALUES
    -- May 2026 (2 visits)
    (2, 3, '2026-05-07 09:00'::timestamp, 'Skin check',          'Eczema flare-up',      'Moisturizer and mild steroid cream', 140.00, 'Paid'),
    (4, 4, '2026-05-19 10:30'::timestamp, 'Knee pain',           'Mild osteoarthritis',  'Physiotherapy referral',             210.00, 'Paid'),
    -- June 2026 (1 visit)
    (5, 5, '2026-06-11 13:00'::timestamp, 'Annual physical',     'Healthy',              'No treatment needed',                160.00, 'Paid'),
    -- July 2026 (3 visits)
    (3, 2, '2026-07-08 10:00'::timestamp, 'Ear pain',            'Otitis media',         'Amoxicillin for 7 days',             130.00, 'Paid'),
    (6, 5, '2026-07-14 11:30'::timestamp, 'Sore throat',         'Viral pharyngitis',    'Rest and fluids',                     85.00, 'Paid'),
    (1, 1, '2026-07-22 09:00'::timestamp, 'Routine cardiac screening', 'Borderline blood pressure', 'Monitor and recheck in 2 weeks', 300.00, 'Pending')
),
new_appts AS (
    INSERT INTO public.appointment (patient_id, doctor_id, appointment_datetime, reason, status)
    SELECT patient_id, doctor_id, appt_ts, reason, 'Completed'
    FROM src
    RETURNING appointment_id, patient_id, doctor_id, appointment_datetime
),
new_visits AS (
    INSERT INTO public.visit (appointment_id, diagnosis, treatment, visit_date)
    SELECT a.appointment_id, s.diagnosis, s.treatment, a.appointment_datetime::date
    FROM new_appts a
    JOIN src s
      ON s.patient_id = a.patient_id
     AND s.doctor_id  = a.doctor_id
     AND s.appt_ts    = a.appointment_datetime
    RETURNING visit_id, appointment_id, visit_date
),
new_bills AS (
    INSERT INTO public.bill (visit_id, patient_id, doctor_id, amount, payment_status)
    SELECT v.visit_id, a.patient_id, a.doctor_id, s.amount, s.pay_status
    FROM new_visits v
    JOIN new_appts a ON a.appointment_id = v.appointment_id
    JOIN src s
      ON s.patient_id = a.patient_id
     AND s.doctor_id  = a.doctor_id
     AND s.appt_ts    = a.appointment_datetime
    RETURNING bill_id
)
INSERT INTO public.medical_history (patient_id, visit_id, recorded_on, notes)
SELECT a.patient_id, v.visit_id, v.visit_date, s.diagnosis || '. ' || s.treatment || '.'
FROM new_visits v
JOIN new_appts a ON a.appointment_id = v.appointment_id
JOIN src s
  ON s.patient_id = a.patient_id
 AND s.doctor_id  = a.doctor_id
 AND s.appt_ts    = a.appointment_datetime;

COMMIT;