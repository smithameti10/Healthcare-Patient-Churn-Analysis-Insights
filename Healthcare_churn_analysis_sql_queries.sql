-- Q1. Find the total number of patients.
select count(*) from health_churn

-- Q2. Find the number of churned patients.
select count(*) as churned_patients
from health_churn
where churned = 1

-- Q3. Find the number of retained patients.
select count(*) as churned_patients
from health_churn
where churned != 1

-- Q4. Find the average age of patients.
select avg(age) as avg_age
from health_churn

-- Q5. Find patients who are older than 60.
select patientid, age
from health_churn
where age > 60

-- Q6. Find patients from California
select * from health_churn
where state = 'CA'

-- Q7. Find patients with billing issues.
select *
from health_churn
where billing_issues = 1

-- Q8. Find patients who made more than 10 visits last year.
select patientid, visits_last_year
from health_churn
where visits_last_year > 10

-- Q9. Find patients who missed at least 3 appointments.
select patientid, missed_appointments
from health_churn
where missed_appointments >= 3

-- Q10. Find the number of patients in each state.
select state, count(*) total_patients
from health_churn
group by state

-- Q11. Find the number of patients in each specialty.
select specialty, count(*) total_patients
from health_churn
group by specialty

-- Q12. Find the average satisfaction by specialty.
select specialty, avg(overall_satisfaction) avg_satisfaction
from health_churn
group by specialty

-- Q13. Find the churn rate.
select 
	round(
		sum(
			case when churned = 1 then 1
			else 0
			end
		) * 100 / count(*), 2
	) as churn_rate
from health_churn

-- Q14. Find churned patients by gender.
select gender, 
sum(case when churned = 1 then 1 else 0 end) as totalchurn,
round(
	sum(case when churned = 1 then 1 else 0 end) * 100 / count(*)
,2) as churned_rate
from health_churn
group by gender

-- Q15. Find churn rate by insurance type.
select insurance_type,
sum(case when churned = 1 then 1 else 0 end) as totalchurn,
round(
	sum(case when churned = 1 then 1 else 0 end) * 100 / count(*)
,2) as churned_rate
from health_churn
group by insurance_type  -- This helps identify which insurance groups have higher retention risk.

-- Q16. Find churn rate for patients with and without billing issues.
select billing_issues,
sum(case when churned = 1 then 1 else 0 end) as totalchurn,
round(
	sum(case when churned = 1 then 1 else 0 end) * 100 / count(*)
,2) as churned_rate
from health_churn
group by billing_issues  --Patients with billing issues have a noticeably higher churn rate.

-- Q17. Find average visits for churned and retained patients.
select churned, avg(visits_last_year)
from health_churn
group by churned

-- Q18. Find patients whose satisfaction is below the overall average.
select patientid, age, gender, overall_satisfaction
from health_churn
where overall_satisfaction < (
		select avg(overall_satisfaction)
		from health_churn
)

-- Q19. Find specialties having more than 280 patients.
select specialty, count(*) as patient_count
from health_churn
group by specialty
having count(*) > 280

-- Q20. Find the top 5 states by patient count.
select state, count(*) as patient_count
from health_churn
group by state 
order by patient_count desc
limit 5

-- Q21. Find patients who have never missed an appointment.
select patientid, gender, state
from health_churn
where missed_appointments = 0

-- select missed_appointments, count(*) as patient_count
-- from health_churn
-- group by missed_appointments 


-- Q22. Find average satisfaction of churned patients.
select avg(overall_satisfaction) as average_satisfaction
from health_churn
where churned = 1

-- Q23. Find churn rate by age group.
select age_group, sum(case when churned = 1 then 1 else 0 end) as churn_count,
round(
	sum(case when churned = 1 then 1 else 0 end) * 100/count(*)
,2) as churn_rate
from health_churn
group by age_group   --The 18–35 group has the highest observed churn rate, around 74.8%.

-- Q24. Find the top 3 specialties with the highest churn rate.
select specialty, count(*) as total_patients,
sum(case when churned = 1 then 1 else 0 end) as churn_count,
round(
	sum(case when churned = 1 then 1 else 0 end) * 100.0/count(*)
,2) as churn_rate
from health_churn
group by specialty 
order by churn_rate desc limit 3

-- Q25. Rank states according to churn rate.
with churn_cal as (
	select state,
	round(
		sum(case when churned = 1 then 1 else 0 end) * 100.0/count(*)
	,2) as churn_rate
	from health_churn
	group by state
)
select state, churn_rate,
dense_rank() over(order by churn_rate desc) as ranking
from churn_cal

-- Q26. Find the highest-risk patients based on engagement category.
select engagement_category, count(*) as total_patients,
sum(case when churned = 1 then 1 else 0 end) as churn_count,
round(
	sum(case when churned = 1 then 1 else 0 end) * 100.0/count(*)
,2) as churn_rate
from health_churn
group by engagement_category 
order by churn_rate desc   --The At Risk group is particularly valuable because it contains 453 patients, making it much more actionable than the tiny Disengaged group.

-- Q27. Find patients who are At Risk and have billing issues.
select patientid, gender, insurance_type
from health_churn
where engagement_category = 'At Risk' and billing_issues = 1  --This can create a targeted high-priority retention list.

-- Q28. Find patients who are At Risk, have billing issues and live more than 30 miles away.
select patientid, gender, insurance_type
from health_churn
where engagement_category = 'At Risk' and billing_issues = 1 and distance_bins = '30+ miles'

-- Q29. Calculate churn rate by distance category.
select distance_bins, count(*) as total_patients,
sum(case when churned = 1 then 1 else 0 end) as churn_count,
round(
	sum(case when churned = 1 then 1 else 0 end) * 100.0/count(*)
,2) as churn_rate
from health_churn
group by distance_bins 
order by churn_rate desc

-- Q30. Find patients whose visits are above the average but who still churned.
select patientid, gender, state, visits_last_year
from health_churn
where visits_last_year > (
	select avg(visits_last_year)
	from health_churn
)
and churned = 1 --These patients are visiting frequently but still leaving. This suggests that visit frequency alone doesn't guarantee retention

-- Q31. Find patients with high satisfaction but who churned.
select patientid, gender, state, overall_satisfaction
from health_churn
where overall_satisfaction = (
	select max(overall_satisfaction)
	from health_churn
)
and churned = 1  -- This could indicate that other factors such as distance, billing problems, appointment availability, or competitor options may matter

-- Q32. Find the average engagement score for churned vs retained patients.
select churned, avg(engagement_score)
from health_churn
group by churned 

-- Q33. Find the state with the highest churn rate.
select state, count(*) as total_patients,
sum(case when churned = 1 then 1 else 0 end) as churn_count,
round(
	sum(case when churned = 1 then 1 else 0 end) * 100.0/count(*)
,2) as churn_rate
from health_churn
group by state 
order by churn_rate desc
