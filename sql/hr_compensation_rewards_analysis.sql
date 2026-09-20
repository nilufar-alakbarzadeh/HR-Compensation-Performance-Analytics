-- ============================================================
-- HR Compensation, Rewards & Salary Progression Analysis
-- SQL Engine: DuckDB / SQLShed
-- Tables: employees_updated, snapshots_updated, leave_requests
-- ============================================================

-- ============================================================
-- SECTION 1 — EMPLOYEES_UPDATED: DATA QUALITY & VALIDATION
-- ============================================================

-- #1 Preview employees data
SELECT *
FROM employees_updated
LIMIT 10;

-- #2 Row count and unique employee count
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT employee_id) AS unique_employees
FROM employees_updated;

-- #3 Duplicate employee IDs
SELECT
    employee_id,
    COUNT(*) AS row_count
FROM employees_updated
GROUP BY employee_id
HAVING COUNT(*) > 1;

-- #4 Key-field NULL check
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(employee_id) AS null_employee_id,
    COUNT(*) - COUNT(department) AS null_department,
    COUNT(*) - COUNT(business_unit) AS null_business_unit,
    COUNT(*) - COUNT(job_title) AS null_job_title,
    COUNT(*) - COUNT(job_level) AS null_job_level,
    COUNT(*) - COUNT(employment_status) AS null_employment_status
FROM employees_updated;

-- #5 Compensation/rewards NULL check
SELECT
    COUNT(*) - COUNT(base_salary) AS null_base_salary,
    COUNT(*) - COUNT(bonus_eligible) AS null_bonus_eligible,
    COUNT(*) - COUNT(bonus_pct) AS null_bonus_pct,
    COUNT(*) - COUNT(equity_grant) AS null_equity_grant,
    COUNT(*) - COUNT(equity_pct) AS null_equity_pct,
    COUNT(*) - COUNT(high_potential_flag) AS null_high_potential,
    COUNT(*) - COUNT(promotion_count) AS null_promotion_count
FROM employees_updated;

-- #6 Base salary range
SELECT
    MIN(base_salary) AS min_salary,
    MAX(base_salary) AS max_salary,
    ROUND(AVG(base_salary), 2) AS avg_salary
FROM employees_updated;

-- #7 Bonus and equity percentage ranges
SELECT
    MIN(bonus_pct) AS min_bonus_pct,
    ROUND(AVG(bonus_pct), 4) AS avg_bonus_pct,
    MAX(bonus_pct) AS max_bonus_pct,
    MIN(equity_pct) AS min_equity_pct,
    ROUND(AVG(equity_pct), 4) AS avg_equity_pct,
    MAX(equity_pct) AS max_equity_pct
FROM employees_updated;

-- #8 Bonus eligibility distribution
SELECT
    bonus_eligible,
    COUNT(*) AS employee_count
FROM employees_updated
GROUP BY bonus_eligible
ORDER BY employee_count DESC;

-- #9 Bonus consistency: ineligible employees with positive bonus percentage
SELECT COUNT(*) AS inconsistent_bonus_records
FROM employees_updated
WHERE bonus_eligible = FALSE
  AND bonus_pct > 0;

-- #10 Bonus consistency: eligible employees with zero bonus percentage
SELECT COUNT(*) AS eligible_with_zero_bonus
FROM employees_updated
WHERE bonus_eligible = TRUE
  AND bonus_pct = 0;


-- ============================================================
-- SECTION 2 — SNAPSHOTS_UPDATED: DATA QUALITY & VALIDATION
-- ============================================================

-- #11 Snapshot structure and date coverage
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT employee_id) AS unique_employees,
    MIN(snapshot_date) AS first_snapshot,
    MAX(snapshot_date) AS last_snapshot
FROM snapshots_updated;

-- #12 Duplicate employee-date combinations
SELECT
    employee_id,
    snapshot_date,
    COUNT(*) AS row_count
FROM snapshots_updated
GROUP BY employee_id, snapshot_date
HAVING COUNT(*) > 1;

-- #13 Snapshot NULL check
SELECT
    COUNT(*) - COUNT(employee_id) AS null_employee_id,
    COUNT(*) - COUNT(snapshot_date) AS null_snapshot_date,
    COUNT(*) - COUNT(current_salary) AS null_current_salary,
    COUNT(*) - COUNT(performance_rating) AS null_performance_rating,
    COUNT(*) - COUNT(engagement_score) AS null_engagement_score,
    COUNT(*) - COUNT(risk_of_exit_score) AS null_exit_risk,
    COUNT(*) - COUNT(tenure_months) AS null_tenure
FROM snapshots_updated;

-- #14 Snapshot metric ranges
SELECT
    MIN(current_salary) AS min_salary,
    MAX(current_salary) AS max_salary,
    ROUND(AVG(current_salary), 2) AS avg_salary,
    MIN(performance_rating) AS min_performance,
    MAX(performance_rating) AS max_performance,
    ROUND(AVG(performance_rating), 2) AS avg_performance,
    MIN(engagement_score) AS min_engagement,
    MAX(engagement_score) AS max_engagement,
    ROUND(AVG(engagement_score), 2) AS avg_engagement,
    MIN(risk_of_exit_score) AS min_exit_risk,
    MAX(risk_of_exit_score) AS max_exit_risk,
    ROUND(AVG(risk_of_exit_score), 2) AS avg_exit_risk,
    MIN(tenure_months) AS min_tenure,
    MAX(tenure_months) AS max_tenure
FROM snapshots_updated;

-- #15 Employees missing from snapshot history
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.hire_date,
    e.employment_status
FROM employees_updated e
LEFT JOIN snapshots_updated s
    ON e.employee_id = s.employee_id
WHERE s.employee_id IS NULL
ORDER BY e.hire_date;

-- #16 Snapshot count per employee
SELECT
    employee_id,
    COUNT(*) AS snapshot_count,
    MIN(snapshot_date) AS first_snapshot,
    MAX(snapshot_date) AS last_snapshot
FROM snapshots_updated
GROUP BY employee_id
ORDER BY snapshot_count;

-- #17 Snapshot count summary
SELECT
    MIN(snapshot_count) AS min_snapshot_count,
    MAX(snapshot_count) AS max_snapshot_count,
    ROUND(AVG(snapshot_count), 2) AS avg_snapshot_count
FROM (
    SELECT
        employee_id,
        COUNT(*) AS snapshot_count
    FROM snapshots_updated
    GROUP BY employee_id
) snapshot_counts;


-- ============================================================
-- SECTION 3 — LEAVE_REQUESTS: DATA QUALITY & VALIDATION
-- ============================================================

-- #18 Preview leave requests
SELECT *
FROM leave_requests
LIMIT 10;

-- #19 Leave request structure and date coverage
SELECT
    COUNT(*) AS total_requests,
    COUNT(DISTINCT employee_id) AS unique_employees,
    MIN(request_date) AS first_request,
    MAX(request_date) AS last_request
FROM leave_requests;

-- #20 Exact duplicate check
SELECT
    employee_id,
    request_date,
    leave_type,
    approval_status,
    absence_code,
    COUNT(*) AS row_count
FROM leave_requests
GROUP BY
    employee_id,
    request_date,
    leave_type,
    approval_status,
    absence_code
HAVING COUNT(*) > 1;

-- #21 Leave NULL check
SELECT
    COUNT(*) - COUNT(employee_id) AS null_employee_id,
    COUNT(*) - COUNT(request_date) AS null_request_date,
    COUNT(*) - COUNT(leave_type) AS null_leave_type,
    COUNT(*) - COUNT(approval_status) AS null_approval_status,
    COUNT(*) - COUNT(absence_code) AS null_absence_code
FROM leave_requests;

-- #22 Leave type distribution
SELECT
    leave_type,
    COUNT(*) AS request_count
FROM leave_requests
GROUP BY leave_type
ORDER BY request_count DESC;

-- #23 Approval status distribution
SELECT
    approval_status,
    COUNT(*) AS request_count
FROM leave_requests
GROUP BY approval_status
ORDER BY request_count DESC;

-- #24 Absence code distribution
SELECT
    absence_code,
    COUNT(*) AS request_count
FROM leave_requests
GROUP BY absence_code
ORDER BY request_count DESC;

-- #25 Referential integrity: leave employees missing from employees table
SELECT
    COUNT(DISTINCT l.employee_id) AS unmatched_employees
FROM leave_requests l
LEFT JOIN employees_updated e
    ON l.employee_id = e.employee_id
WHERE e.employee_id IS NULL;


-- ============================================================
-- SECTION 4 — BUSINESS ANALYSIS: COMPENSATION & REWARDS
-- ============================================================

-- #26 Page 1 KPI summary
SELECT
    COUNT(*) AS total_employees,
    ROUND(AVG(base_salary), 2) AS avg_base_salary,
    ROUND(
        100.0 * SUM(CASE WHEN bonus_eligible = TRUE THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS bonus_eligible_pct
FROM employees_updated;

-- #27 Equity summary
SELECT
    SUM(CASE WHEN equity_grant = TRUE THEN 1 ELSE 0 END) AS equity_grant_employees,
    ROUND(
        100.0 * SUM(CASE WHEN equity_grant = TRUE THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS equity_grant_pct,
    MIN(equity_pct) AS min_equity_pct,
    MAX(equity_pct) AS max_equity_pct,
    ROUND(AVG(equity_pct), 4) AS avg_equity_pct
FROM employees_updated;

-- #28 Average base salary by job level
SELECT
    job_level,
    COUNT(*) AS employee_count,
    ROUND(AVG(base_salary), 2) AS avg_base_salary
FROM employees_updated
GROUP BY job_level
ORDER BY avg_base_salary DESC;

-- #29 Bonus eligibility by department
SELECT
    department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN bonus_eligible = TRUE THEN 1 ELSE 0 END) AS bonus_eligible_employees,
    ROUND(
        100.0 * SUM(CASE WHEN bonus_eligible = TRUE THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS bonus_eligible_pct
FROM employees_updated
GROUP BY department
ORDER BY bonus_eligible_pct DESC;

-- #30 Average base salary by department
SELECT
    department,
    COUNT(*) AS employee_count,
    ROUND(AVG(base_salary), 2) AS avg_base_salary
FROM employees_updated
GROUP BY department
ORDER BY avg_base_salary DESC;

-- #31 Compensation structure by department
SELECT
    department,
    ROUND(AVG(base_salary), 2) AS avg_base_salary,
    ROUND(AVG(bonus_pct) * 100, 2) AS avg_bonus_pct,
    ROUND(AVG(equity_pct) * 100, 2) AS avg_equity_pct
FROM employees_updated
GROUP BY department
ORDER BY avg_base_salary DESC;

-- #32 Compensation structure by job level
SELECT
    job_level,
    COUNT(*) AS employee_count,
    ROUND(AVG(base_salary), 2) AS avg_base_salary,
    ROUND(AVG(bonus_pct) * 100, 2) AS avg_bonus_pct,
    ROUND(AVG(equity_pct) * 100, 2) AS avg_equity_pct
FROM employees_updated
GROUP BY job_level
ORDER BY avg_base_salary DESC;


-- ============================================================
-- SECTION 5 — BUSINESS ANALYSIS: PERFORMANCE & SALARY PROGRESSION
-- ============================================================

-- #33 Latest snapshot KPI summary
SELECT
    COUNT(DISTINCT employee_id) AS active_employees,
    ROUND(AVG(performance_rating), 2) AS avg_performance_rating,
    ROUND(AVG(current_salary), 2) AS avg_current_salary,
    ROUND(AVG(engagement_score), 2) AS avg_engagement_score,
    ROUND(AVG(risk_of_exit_score) * 100, 2) AS avg_exit_risk_pct
FROM snapshots_updated
WHERE snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM snapshots_updated
);

-- #34 Performance rating distribution
SELECT
    CASE
        WHEN performance_rating < 2 THEN '1.00 - 1.99'
        WHEN performance_rating < 3 THEN '2.00 - 2.99'
        WHEN performance_rating < 4 THEN '3.00 - 3.99'
        WHEN performance_rating < 5 THEN '4.00 - 4.99'
        ELSE '5.00'
    END AS performance_band,
    COUNT(*) AS employee_count,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS employee_pct
FROM snapshots_updated
WHERE snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM snapshots_updated
)
GROUP BY performance_band
ORDER BY performance_band;

-- #35 Performance vs current salary
SELECT
    CASE
        WHEN performance_rating < 2 THEN '1.00 - 1.99'
        WHEN performance_rating < 3 THEN '2.00 - 2.99'
        WHEN performance_rating < 4 THEN '3.00 - 3.99'
        WHEN performance_rating < 5 THEN '4.00 - 4.99'
        ELSE '5.00'
    END AS performance_band,
    COUNT(*) AS employee_count,
    ROUND(AVG(current_salary), 2) AS avg_current_salary
FROM snapshots_updated
WHERE snapshot_date = (
    SELECT MAX(snapshot_date)
    FROM snapshots_updated
)
GROUP BY performance_band
ORDER BY performance_band;

-- #36 Average salary trend over time
SELECT
    snapshot_date,
    COUNT(DISTINCT employee_id) AS employee_count,
    ROUND(AVG(current_salary), 2) AS avg_current_salary
FROM snapshots_updated
GROUP BY snapshot_date
ORDER BY snapshot_date;

-- #37 Employee-level salary growth
WITH salary_history AS (
    SELECT
        employee_id,
        snapshot_date,
        current_salary,
        FIRST_VALUE(current_salary) OVER (
            PARTITION BY employee_id
            ORDER BY snapshot_date
        ) AS first_salary,
        FIRST_VALUE(current_salary) OVER (
            PARTITION BY employee_id
            ORDER BY snapshot_date DESC
        ) AS last_salary
    FROM snapshots_updated
)
SELECT DISTINCT
    employee_id,
    first_salary,
    last_salary,
    ROUND(
        100.0 * (last_salary - first_salary) / first_salary,
        2
    ) AS salary_growth_pct
FROM salary_history
ORDER BY salary_growth_pct DESC;

-- #38 Average salary growth KPI
-- Only employees with at least two snapshots are included.
WITH salary_history AS (
    SELECT
        employee_id,
        FIRST_VALUE(current_salary) OVER (
            PARTITION BY employee_id
            ORDER BY snapshot_date
        ) AS first_salary,
        FIRST_VALUE(current_salary) OVER (
            PARTITION BY employee_id
            ORDER BY snapshot_date DESC
        ) AS last_salary,
        COUNT(*) OVER (
            PARTITION BY employee_id
        ) AS snapshot_count
    FROM snapshots_updated
),
employee_growth AS (
    SELECT DISTINCT
        employee_id,
        first_salary,
        last_salary,
        snapshot_count,
        100.0 * (last_salary - first_salary) / first_salary AS salary_growth_pct
    FROM salary_history
)
SELECT
    COUNT(*) AS employees_analyzed,
    ROUND(AVG(salary_growth_pct), 2) AS avg_salary_growth_pct
FROM employee_growth
WHERE snapshot_count > 1;

-- #39 Employees with promotion and high-potential share
-- Note: promotion_rate_pct here means the share of employees with at least
-- one recorded promotion, not an annual promotion rate.
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN promotion_count > 0 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS promotion_rate_pct,
    ROUND(
        100.0 * SUM(CASE WHEN high_potential_flag = TRUE THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS high_potential_pct
FROM employees_updated;

-- #40 Average salary growth by job level
WITH salary_history AS (
    SELECT
        employee_id,
        FIRST_VALUE(current_salary) OVER (
            PARTITION BY employee_id
            ORDER BY snapshot_date
        ) AS first_salary,
        FIRST_VALUE(current_salary) OVER (
            PARTITION BY employee_id
            ORDER BY snapshot_date DESC
        ) AS last_salary,
        COUNT(*) OVER (
            PARTITION BY employee_id
        ) AS snapshot_count
    FROM snapshots_updated
),
employee_growth AS (
    SELECT DISTINCT
        employee_id,
        100.0 * (last_salary - first_salary) / first_salary AS salary_growth_pct
    FROM salary_history
    WHERE snapshot_count > 1
)
SELECT
    e.job_level,
    COUNT(*) AS employee_count,
    ROUND(AVG(g.salary_growth_pct), 2) AS avg_salary_growth_pct
FROM employee_growth g
JOIN employees_updated e
    ON g.employee_id = e.employee_id
GROUP BY e.job_level
ORDER BY e.job_level;

-- ============================================================
-- END OF ANALYSIS
-- ============================================================
