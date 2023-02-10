#Question 1
--1.write a query to return the first 6 charecters of primarydiagnosis from primarydiagnosis table.

select  substring("PrimaryDiagnosis",1,6) from "PrimaryDiagnosis";

Question2#
--Write a query to return the last 4 digits of the Pulse.

select "Pulse", right(cast(("Pulse") as varchar),4) AS pulse_lastdigits from "AmbulatoryVisits";

 
#Question 3
--3.Write a query using a CTE  to show the first 7 characters from  "PrimaryDiagnosis" 
--and also the lower case version for the Diagnosis_ID=PD005.
 
with Diagnosis_info 
as
  (select 
   	substring("PrimaryDiagnosis", 1, 7), 
    LOWER("Diagnosis_ID")
   FROM "PrimaryDiagnosis"
   where "Diagnosis_ID" = 'PD005' 
  )
   select *From Diagnosis_info;
  
#Question 4
--4.Write a query to display the Count of patients discharged by day of week. 
  
Select DATE_PART('dow',"DischargeDate"), to_char( "DischargeDate"  , 'Day') as "Days of Week" ,
count(distinct "Patient_ID") as "Patient Count"
FROM "Discharges"
group by DATE_PART('dow',"DischargeDate"), to_char( "DischargeDate"  , 'Day');

#Question 5
--5.Write a query to find how many unique patients are there in public."AmbulatoryVisits".

Select count( distinct "Patient_ID") as "Patient Count" from public."AmbulatoryVisits";

#Question 6
--6.Write a query to show the count of patients as per Race.

select  "Race" ,"Patients"."Race_ID", count(distinct "Patient_ID") from "Patients" 
join "Race" on "Patients"."Race_ID" = "Race"."Race_ID" 
group by "Race","Patients"."Race_ID";

#Question 7
--7.write a query using ARRAY_AGG function to get a list of Patient names, Age, Language and Race. 

select 
distinct
"Patient_ID",
ARRAY_AGG("FirstName" ||' '|| "LastName" ||' '|| 
		  AGE(CURRENT_DATE , "DateOfBirth")  ||
		  ' ' || L."Language"||' '||R."Race")
from "Patients" P
join "Language" L on L."Language_ID" = P."Language_ID"
join "Race" R on R."Race_ID" = P."Race_ID"
group by "Patient_ID"
order by "Patient_ID";

#Question 8
--8.Write the query to mark the patient id as ‘high’ if the pulse rate is greater than 80, 
-- ’low’ if pulse rate is less than 60, ‘normal’ if within range.

select 
distinct
"Patient_ID" , 
"Pulse",
case  
when "Pulse" > 80 then 'High'
when "Pulse"< 60 then 'Low'
 else 'Normal'
end as Pulse_Rate
From "AmbulatoryVisits";


#Question 9
--9. Write a query to find out the number of patients with 
-- first name 'Aleshia' who was born on '1960-01-01'.

SELECT  "FirstName", "DateOfBirth", COUNT("Patient_ID")  AS "Number of Patients"
fROM  "Patients" WHERE "FirstName" = 'Aleshia' AND
"DateOfBirth" = '1960-01-01'
GROUP BY "FirstName", "DateOfBirth";

#Question 10
--10.Write a query to return the last record in descending order 
--of patient id with people having same last name. (Hint -Use windows functions).

select "Patient_ID" ,"FirstName","LastName" 
FROM
(SELECT "Patient_ID" ,"FirstName","LastName" , COUNT(*) 
 	OVER (PARTITION BY "LastName"  ORDER BY "Patient_ID" DESC ) as cnt
from "Patients"  ) as p
WHERE cnt >= 2;

#Question 11
--11. Write a query to show for each primary diagnosis, no of patients 
-- admitted and max expected length of stay. (Hint- Use Window functions).

--With Window Function
select  DISTINCT "PrimaryDiagnosis", 
COUNT("Patient_ID") OVER(PARTITION BY "PrimaryDiagnosis") AS "Patient_Count" ,
MAX("ExpectedLOS")  OVER(PARTITION BY "PrimaryDiagnosis") AS "Max_Expected_LOS"
FROM "PrimaryDiagnosis" A JOIN "Discharges" B on A. "Diagnosis_ID" = B. "Diagnosis_ID"
ORDER BY "Max_Expected_LOS";

--Without window function
SELECT  "PrimaryDiagnosis", count("Patient_ID") AS "No. of Patients",
MAX("ExpectedLOS") AS "length of stay"
from "Discharges" DI JOIN "PrimaryDiagnosis" PR ON PR."Diagnosis_ID" = DI."Diagnosis_ID"
group by "PrimaryDiagnosis"
ORDER BY "length of stay";

#Question 12
--12.Find the reason of visit for max number of patients.

select "ReasonForVisit" ,  count("Patient_ID") as "Patient count" from "ReasonForVisit"
 join "EDVisits" on "ReasonForVisit"."Rsv_ID" = "EDVisits"."Rsv_ID"
group by "ReasonForVisit"
order by count("Patient_ID") desc
limit 1;

#Question 13
--13.Write a query to get list of Provider names whose name’s are starting with Mi and ending with rt.

select "ProviderName" from "Providers"
where "ProviderName" like 'Mi%rt';

#Question 14
--14.Write a query to Split provider’s First name and Last name into different column.

Select "ProviderName", REGEXP_REPLACE("ProviderName", '\s+\S+$', '')as FirstName,
                       REGEXP_REPLACE("ProviderName", '.+[\s]', '') as LastName
					   from "Providers";

#Question 15
--15.Write a query to get the list of Patient Names and their Id’s order by their 
--Date of birth to show 1’s who are older ones on top.

select "Patient_ID","FirstName" ||' ' || "LastName" as "Patient Name", "DateOfBirth" from "Patients"  
order by "DateOfBirth" asc;

#Question 16

--16.Write a query to creating view a on table EDVisits by selecting  PatientID 
--and last 3 columns and also write a query to drop the same View.

CREATE VIEW ED_visits as select "Patient_ID", "EDD_ID", 
"VisitTimestamp","EDDischargeTimestamp" from "EDVisits";

SELECT * from ED_visits where "Patient_ID" =1;

DROP VIEW ED_visits;

#Question 17
--17.Write a query to get list of Patient ID's where Providers ID is 11 
--and Pulse is between 70 to 90 order to view lowest pulse rate on top.

select "Patient_ID", "Provider_ID", "Pulse" from "AmbulatoryVisits" where "Provider_ID" = 11
and  "Pulse" between 70 and 90 
order by "Pulse" ;

#Question 18
--18.Write the query to create Index on table Providers by selecting a column and, 
--also write a query to drop the same index.

Create INDEX ind_Provider_id on "Providers"("Provider_ID");

DROP INDEX ind_Provider_id;


#Question 19
--19. Write a query to Count number of unique patients EDDisposition wise.

select edisp."EDDisposition", count(Distinct evisit."Patient_ID") as "No_of_Patients"
from public."EDVisits" evisit
 join public."EDDisposition" edisp on edisp."EDD_ID"=evisit."EDD_ID"
Group by edisp."EDDisposition";

#Question 20
--20. Write a query to get list of Patient ID's where Visitdepartment ID is 8 or BloodPressureDiastolic is NULL

select distinct "Patient_ID" 
from "AmbulatoryVisits" 
where "VisitDepartmentID" = '8' or "BloodPressureDiastolic" IS NULL;

#Question 21
--21.Write the query to find the number of patients readmitted by Service.

SELECT "Service",COUNT("Patient_ID") AS "NoOfPatients" 
FROM public."ReAdmissionRegistry" rad
left JOIN public."Service" S ON S."Service_ID" = rad."Service_ID" 
GROUP BY "Service";

#Question 22
--22.Write a query to display the data for all 'White Female' patients above the age of 50, with patients full name. (Hint- Firstname + Lastname)
		
SELECT  "FirstName","LastName","Gender",age(NOW(),"DateOfBirth"),"Race"
FROM public."Patients" pat
Left JOIN public."Race" rac ON rac."Race_ID" = pat."Race_ID" 
Left JOIN public."Gender" gen ON gen."Gender_ID" = pat."Gender_ID"
WHERE "Race" = 'White'
AND "Gender" = 'Female' AND
EXTRACT(Years FROM age(NOW(),"DateOfBirth")) >50;

#Question 23
--23.Write a query to calculate the time spent in ED Department for each visit.

SELECT "EDVisit_ID","Patient_ID",("EDDischargeTimestamp"-"VisitTimestamp") AS
Time_spent FROM public."EDVisits";

#Question 24
--24.Write a query to find reasonForVisit with highest count of acuity 5 patients.

SELECT "Acuity", ED."Rsv_ID", COUNT (ED."Rsv_ID") AS highcount, "ReasonForVisit"
FROM "ReasonForVisit" RFV JOIN
"EDVisits" ED ON RFV."Rsv_ID" = ED."Rsv_ID"
WHERE "Acuity" =5
GROUP BY ED."Rsv_ID","Acuity","ReasonForVisit"
ORDER BY highcount desc;

#Question 25
--25.Write a query to show which PrimaryDiagnosis has the biggest difference between maximum and minimum Expected LOS?

SELECT MAX("ExpectedLOS")-MIN("ExpectedLOS") AS difference, Readm."Diagnosis_ID",Pd."PrimaryDiagnosis"
FROM "ReAdmissionRegistry" Readm JOIN "PrimaryDiagnosis" Pd ON Readm."Diagnosis_ID" = Pd."Diagnosis_ID"
GROUP BY Readm."Diagnosis_ID", Pd."PrimaryDiagnosis"
ORDER BY difference DESC
LIMIT 1;

#Question 26
--26.write a query to get the list of patient ids which are not there in ReadmissionRegistry.

SELECT "Patient_ID","FirstName","LastName" FROM public."Patients"
WHERE "Patient_ID" NOT IN
(select "Patient_ID" FROM public."ReAdmissionRegistry");

#Question 27
--27.Write a query to find mean , median and mode for systolic measure.
--Mean

SELECT AVG("BloodPressureSystolic") AS mean_BloodPressureSystolic, 
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY "BloodPressureSystolic") AS median_BloodPressureSystolic, 
mode() WITHIN GROUP (ORDER BY "BloodPressureSystolic") AS mode_BloodPressureSystolic 
FROM public."AmbulatoryVisits";

#Question 28
--28.Write a query to find the 7 characters of PrimaryDiagnosis in lower cases.

select LOWER(LEFT("PrimaryDiagnosis",7)) from public."PrimaryDiagnosis";

#Question 29
--29.Write a query to find the current age of the patients.

SELECT P."FirstName", P."LastName", age(NOW(),P."DateOfBirth") 
FROM "Patients" P; 

#Question 30
--30.Write a query using the Dense_Rank function and display any result of your choice.

SELECT
	"PrimaryDiagnosis"."PrimaryDiagnosis", max("Discharges"."ExpectedMortality"),
	DENSE_RANK () OVER ( 
		ORDER BY MAX("Discharges"."ExpectedMortality") DESC
	) ExpectedMortality_rank 
FROM "PrimaryDiagnosis"
JOIN "Discharges" ON "PrimaryDiagnosis"."Diagnosis_ID" = "Discharges"."Diagnosis_ID"
group by 1;
	
	
#Question 31
--31.Write a query to create a role(any) in postgress via query.

CREATE ROLE dbs
CREATEDB
LOGIN
PASSWORD 'Abcd1234';

CREATE ROLE dev_api2 WITH
LOGIN
PASSWORD 'securePass1'
VALID UNTIL '2030-01-01';

#Question 32
--32.Write a query to list all users in DB.

SELECT usename AS role_name,
CASE
WHEN usesuper AND usecreatedb THEN
CAST('superuser, create database' AS pg_catalog.text)
WHEN usesuper THEN
CAST ('superuser' AS pg_catalog.text)
WHEN usecreatedb THEN
CAST('create database' AS pg_catalog.text)
ELSE
CAST(' ' AS pg_catalog.text )
END role_attributes
FROM pg_catalog.pg_user
ORDER BY role_name desc;

#Question 33
--33.Write a query to display the Mortality Rate by Primary Diagnosis.

SELECT Di."Diagnosis_ID", Pr."Diagnosis_ID", AVG(Di."ExpectedMortality")
FROM "Discharges" Di 
JOIN "PrimaryDiagnosis" Pr
ON Pr."Diagnosis_ID"= Di."Diagnosis_ID"
GROUP BY Di."Diagnosis_ID",Pr."Diagnosis_ID"
ORDER BY Di."Diagnosis_ID";

#Question 34
--34.Write a query to insert a row into the table Primary Diagnosis.

INSERT INTO public."PrimaryDiagnosis"("PrimaryDiagnosis","Diagnosis_ID")
VALUES ('Test Diagnosis','TS006');

SELECT * FROM public."PrimaryDiagnosis";

#Question 35
--35.Write a query to modified a row in the Primary Diagnosis.

UPDATE public."PrimaryDiagnosis"
SET "PrimaryDiagnosis" ='Test Diag id'
WHERE "Diagnosis_ID" = 'TS002';

SELECT * FROM public."PrimaryDiagnosis";

#Question 36
--36.Write a query to find the ProviderName and Provider Speciality for PS_ID = 'PSID02'.

SELECT PR."ProviderName",PS."ProviderSpeciality"
FROM "ProviderSpeciality" PS
Left JOIN "Providers" PR
ON PR."PS_ID"=PS."PS_ID" WHERE PS."PS_ID"='PSID02';

#Question 37
--37.Write a query to find Average age for admission by service.
 	
	SELECT Ser."Service",AVG(AGE(Ser."AdmissionDate",Ser."DateOfBirth")) AS "AvrgAgeOfPatientsAdmitted"
	FROM (Select S."Patient_ID",S."Service",S."AdmissionDate", PT."DateOfBirth" 
	FROM(Select R."Patient_ID", R."Service_ID",S."Service",R."AdmissionDate" 
	FROM "ReAdmissionRegistry" R
	JOIN "Service" S
	ON R."Service_ID" = S."Service_ID") S
	JOIN(Select P."Patient_ID",P."DateOfBirth"
	FROM "Patients" P) PT
	ON S."Patient_ID" = PT."Patient_ID") Ser
 	GROUP BY Ser."Service";
 
 #Question 38
 --38.Write a query to provide month wise count of patients who expired.

SELECT count(D."Patient_ID")AS noofexpired,extract(month from D."DischargeDate") as monthnumber
FROM public."Discharges" D
JOIN public."DischargeDisposition" DD
USING ("Discharge_ID")
WHERE DD."DischargeDisposition"='Expired'
GROUP BY "monthnumber"
ORDER BY "monthnumber";

 #Question 39
 --39.Write a query  to fetch out all details of a patient from system using last name.

select Pa."Patient_ID",Pa."LastName",Pa."FirstName",Pa."DateOfBirth",Ge."Gender",La."Language",Ra."Race"
from public."Patients" Pa
left join public."Gender" Ge using ("Gender_ID")
left join public."Language" La using ("Language_ID")
left join public."Race" Ra using ("Race_ID")
where "LastName" like 'B%';

 #Question 40
 --40.Write a function to find patient  name who used ambulance to visit hospital and provider ID is 2 using "EXIST" Function.  

SELECT Pa."Patient_ID",Pa."FirstName",Pa."LastName"
FROM public."AmbulatoryVisits" Av 
JOIN public."Patients" Pa USING ("Patient_ID")
WHERE
EXISTS(select "Patient_ID" FROM public."AmbulatoryVisits" WHERE "Provider_ID"='2')
AND "Provider_ID"='2';

#Question 41
--41. Write a query to display count of patients by each 
--providers in year 2019.

SELECT "ProviderName",COUNT("Patient_ID") FROM "AmbulatoryVisits" JOIN "Providers"
ON "Providers"."Provider_ID" = "AmbulatoryVisits"."Provider_ID" WHERE DATE_PART ('YEAR',"DateofVisit")=2019
GROUP BY 1;

#Question 42
--42. Write a query to list the providers with
--number of patients they treated.

select "ProviderName",count("Patients"."Patient_ID")
from "AmbulatoryVisits" 
Join "Patients" ON "Patients"."Patient_ID" = "AmbulatoryVisits"."Patient_ID"
Join "Providers" ON "Providers"."Provider_ID" = "AmbulatoryVisits"."Provider_ID"
group by 1;

#Question 43
--43. Write a query to find 5 patients with Random BloodPressueDiastolic.

select "FirstName","LastName","BloodPressureDiastolic" from 
"AmbulatoryVisits" 
Join "Patients" On "Patients"."Patient_ID" = "AmbulatoryVisits"."Patient_ID"
limit 5;

#Question 44
--44.Write a query to get the counts of patients by language.

Select "Language",Count("Patient_ID")
from "Language" join "Patients" 
on "Language"."Language_ID" = "Patients"."Language_ID"
group by 1
order by 2;

#Question 45
--45. Write a query to get the list of patients who were admitted
 --for 5 days in ICU.

select "FirstName","LastName", "Service",noofdays from
(select "FirstName","LastName",dis."Patient_ID", "Service", 
 AGE( DATE("DischargeDate"),"AdmissionDate" ) noofdays from public."Discharges" dis
 join public."Patients" pat on pat."Patient_ID"=dis."Patient_ID"
join public."Service" ser on ser."Service_ID" = dis."Service_ID" where "Service"='ICU') as admissiondays
where noofdays = '5 days';

#Question 46
--46. Write a query to list Patient names based on the given Provider.

select "FirstName","LastName","ProviderName"
from "Patients"
 Join "AmbulatoryVisits" ON "Patients"."Patient_ID" = "AmbulatoryVisits"."Patient_ID"
 Join "Providers" ON "Providers"."Provider_ID" = "AmbulatoryVisits"."Provider_ID"
group by 1,2,3;

#Question 47
--47. Write a query to get a list of patient ID's
--whose PrimaryDiagnosis is 'Flu'. 

Select "Patient_ID" ,"PrimaryDiagnosis" from "PrimaryDiagnosis"
join "Discharges" on "PrimaryDiagnosis"."Diagnosis_ID"
= "Discharges"."Diagnosis_ID"
where "PrimaryDiagnosis" = 'Flu'
order by 1;

#Question 48
--48. Write a query to get list of Patients 
--order by DateOfBirth ascending order.

select "FirstName","LastName","DateOfBirth"
from public."Patients"
group by 1,2,3
order by 3 asc
limit 5 ;

#Question 49
--49. Write a query to display the Firstname and Lastname of patients who
--speaks ‘Spanish’ language.

SELECT "FirstName","LastName","Language" FROM public."Patients"
JOIN public."Language"ON public."Language"."Language_ID" = public."Patients".
"Language_ID" WHERE "Language" ='Spanish';

#Question 50
--50. Write a query to get list of patient ID's 
--whose PrimaryDiagnosis is 'Heart Failure' and order by patient_ID.

Select "Patient_ID" ,"PrimaryDiagnosis" from "PrimaryDiagnosis"
join "Discharges" on "PrimaryDiagnosis"."Diagnosis_ID"
= "Discharges"."Diagnosis_ID"
where "PrimaryDiagnosis" = 'Heart Failure'
order by 1;

#Question 51
--51. Write a query to find the Patient_ID and Admission_ID 
--for the patients whose Primary diaganosis is ‘Pneumonia’.

Select "Patient_ID","Admission_ID","PrimaryDiagnosis" from "PrimaryDiagnosis"
join "Discharges" on "PrimaryDiagnosis"."Diagnosis_ID"
= "Discharges"."Diagnosis_ID"
where "PrimaryDiagnosis" = 'Pneumonia'
order by 1,2;

#Question 52
--52. Write a query to find the list of patient_ID's discharged with
--Service in SID01, SID02, SID03, SID05.

Select "Patient_ID","Service_ID","DischargeDate"
from public."Discharges"
where "Service_ID" IN ('SID01','SID02','SID03','SID05');

#Question 53
--53. Write a query to display the output as below all male members

Select case when  "Gender"='Male' then 'Mr.' else 'Mrs.' end ||"FirstName" as FirstName,"LastName" from "Patients" pat
join public."Gender" gen on gen."Gender_ID"=pat."Gender_ID";


#Question 54
--54. Write a query to find first 5 outpatients with
--lowest pulse rate by using Fetch.

Select "FirstName","LastName","Pulse" from public."AmbulatoryVisits"
Join public."Patients" 
On public."Patients"."Patient_ID" = public."AmbulatoryVisits"."Patient_ID"
order by "Pulse" asc
fetch first 5 rows only;
 
 #Question 55
--55. Write a query to get list of Patients whose
--gender is ‘Male’ and who speak ‘English’ and whose race is ‘White’.

Select "FirstName","LastName","Race","Language","Gender"
From "Patients"
Join "Gender" on "Patients"."Gender_ID" = "Gender"."Gender_ID"
Join "Race" on "Patients"."Race_ID" = "Race"."Race_ID"
Join "Language" on "Patients"."Language_ID" = "Language"."Language_ID"
where "Race" = 'White' and "Gender"='Male'and "Language" = 'English';

#Question 56
--56. Write a query to get the count of the number of 
--expired patients due to each illness type.

Select "PrimaryDiagnosis",COUNT("ExpectedMortality")  "Expired Patients"
from "Discharges" Join "PrimaryDiagnosis"
on "PrimaryDiagnosis"."Diagnosis_ID" = "Discharges"."Diagnosis_ID"
where "ExpectedMortality" <= '.005'
group by "PrimaryDiagnosis"
order by 2;

#Question 57
--57. Write a query to get the number of patient visiting each day.

Select DATE_PART('dow',"DateofVisit"), to_char( "DateofVisit",'Day') as "Days of Week" ,
count("Patient_ID") 
from  public."AmbulatoryVisits"
group by 1,2
order by 2 ;

#Question 58
--58. Write a query to get the number of patients 
who have at least two visits to the hospital.

SELECT "VisitType",COUNT ("Patient_ID") FROM "AmbulatoryVisits"
JOIN "VisitTypes" on "AmbulatoryVisits"."AMVT_ID" = "VisitTypes"."AMVT_ID"
WHERE "VisitType" = 'Follow Up'
group by 1 order by 2;

#Question 59
--59. Write a query to create a trigger to execute after 
--inserting a record into Patients table. Insert value to display result. 

CREATE TABLE IF NOT EXISTS public."NewPatientLog"
(
    "Patient_ID" integer NOT NULL,
    "FirstName" text COLLATE pg_catalog."default",
    "LastName" text COLLATE pg_catalog."default",
    "DateOfBirth" date,
    "Gender_ID" text COLLATE pg_catalog."default",
    "Race_ID" text COLLATE pg_catalog."default",
    "Language_ID" text COLLATE pg_catalog."default",
    CONSTRAINT "NewPatientLog_pkey" PRIMARY KEY ("Patient_ID"),
    CONSTRAINT "NewPatientLogGender_ID_FK" FOREIGN KEY ("Gender_ID")
        REFERENCES public."Gender" ("Gender_ID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "NewPatientLogLangugae_ID_FK" FOREIGN KEY ("Language_ID")
        REFERENCES public."Language" ("Language_ID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "NewPatientLogRace_ID_FK" FOREIGN KEY ("Race_ID")
        REFERENCES public."Race" ("Race_ID") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."NewPatientLog"
    OWNER to postgres;
-- Index: fki_Gender_ID_FK

 --DROP INDEX IF EXISTS public."NewPatientLogfki_Gender_ID_FK";
 
 CREATE INDEX IF NOT EXISTS "NewPatientLogfki_Gender_ID_FK"
    ON public."NewPatientLog" USING btree
    ("Gender_ID" COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: fki_Langugae_ID_FK

-- DROP INDEX IF EXISTS public."NewPatientLogfki_Langugae_ID_FK";

CREATE INDEX IF NOT EXISTS "NewPatientLogfki_Langugae_ID_FK"
    ON public."NewPatientLog" USING btree
    ("Language_ID" COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: fki_Race_ID_FK

-- DROP INDEX IF EXISTS public."NewPatientLogfki_Race_ID_FK";

CREATE OR REPLACE FUNCTION record_insert()
RETURNS TRIGGER AS
$$
BEGIN
INSERT INTO public."NewPatientLog"("Patient_ID", "FirstName", "LastName", "DateOfBirth", "Gender_ID", "Race_ID", "Language_ID")
VALUES (NEW."Patient_ID", NEW."FirstName", NEW."LastName", NEW."DateOfBirth", NEW."Gender_ID", NEW."Race_ID", NEW."Language_ID");
RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE TRIGGER New_patient_record
 AFTER INSERT
 ON public."Patients"
 FOR EACH ROW
 EXECUTE PROCEDURE record_insert();
 
 
  INSERT INTO public."Patients" VALUES (999, 'Nitin', 'B', NULL, 'G001', 'R01', 'L_01');
 INSERT INTO public."Patients" VALUES (1000, 'Swati', 'B', NULL, 'G002', 'R01', 'L_02');
 INSERT INTO public."Patients" VALUES (1001, 'Sahaj', 'B', NULL, 'G002', 'R01', 'L_01');

 
 COMMIT;
 rollback
 
Select * from public."Patients" where "Patient_ID"='999';
Select * from public."NewPatientLog";




#Question 60
--60. Write a query to find the patients whose reason
--for visit is ‘stomach ache’ and ‘shortness of breath’.
--Display patientid, firstname, lastname, DOB, gender, reason of visit.
 

SELECT "Patients"."Patient_ID","FirstName","LastName","DateOfBirth",
"Gender","ReasonForVisit" FROM "Patients"
JOIN "EDVisits" ON "EDVisits"."Patient_ID" = "Patients"."Patient_ID"
JOIN "Gender" ON"Patients"."Gender_ID" = "Gender"."Gender_ID" 
JOIN "ReasonForVisit" ON "ReasonForVisit"."Rsv_ID" = "EDVisits"."Rsv_ID"
WHERE "ReasonForVisit" IN ('Stomach Ache','Shortness of Breath');

#Question 61
--61.Write a query to display the male patient names and ages whose age is between 30-60.
Select "FirstName","LastName", Gender, age from
(Select "FirstName","LastName",gen."Gender" Gender, Extract(year from (AGE(now(),"DateOfBirth"))) age
From public."Patients" p
Join public."Gender" gen on gen."Gender_ID" = p."Gender_ID"
Where "Gender"='Male') malepatage 
where age Between '30' AND '60'
order by age;

#Question 62
--62. Write a query to show which patient has the 3rd highest expected length of stay for the primary diagnosis Fever. 
--Display the patient’s Firstname, Last name, Gender, Race, Expected LOS, Primary diagnosis.
Select "FirstName","LastName","Gender","Race","ExpectedLOS","PrimaryDiagnosis" 
from
(Select "FirstName","LastName","Gender","Race","ExpectedLOS",
       dense_rank() over(order by "ExpectedLOS" desc) "expected length of stay","PrimaryDiagnosis" 
from public."Patients" pat
join public."Discharges" dis on dis."Patient_ID"=pat."Patient_ID"
join public."PrimaryDiagnosis" pdia on pdia."Diagnosis_ID"=dis."Diagnosis_ID"
Join public."Gender" gen on gen."Gender_ID" = pat."Gender_ID"
join public."Race" rac on rac."Race_ID"=pat."Race_ID"
where  "PrimaryDiagnosis"='Fever' ) as patdetailsforFever 
where "expected length of stay" = 3

#Question 63
--63.Write a query to create view on table Provider on columns PS_ID and ProviderName.

CREATE VIEW ProvidersInfo As
Select "PS_ID", "ProviderName"
From public."Providers";

#Question 64
--64. Write a query to classify the patients based on blood pressure levels using the below conditions:
--Display patient name, Id, blood pressure systolic, blood pressure diastolic and BPRisk.
--if BloodPressureSystolic >=120 and BloodPressureSystolic <130 and BloodPressureDiastolic < 80:
--   	BPrisk = 'Elevated BP'
--	if (BloodPressureSystolic >=130 and BloodPressureSystolic < 140) or (BloodPressureDiastolic >= 80 and BloodPressureDiastolic < 90):
--   	BPrisk = 'Stage 1 Hypertension'
--	if BloodPressureSystolic>=140 or BloodPressureDiastolic >= 90:
--    	BPrisk ='Stage 2 Hypertension'

Select "FirstName","LastName",amv."Patient_ID" as "Id","BloodPressureSystolic","BloodPressureDiastolic",
CASE 
        WHEN "BloodPressureSystolic" >=120 and "BloodPressureSystolic" <130 and "BloodPressureDiastolic" < 80 THEN 'Elevated BP' 
        WHEN ("BloodPressureSystolic" >=130 and "BloodPressureSystolic" < 140) or ("BloodPressureDiastolic" >= 80 and "BloodPressureDiastolic" < 90) THEN 'Stage 1 Hypertension'
        WHEN "BloodPressureSystolic" >=140 or "BloodPressureDiastolic" >= 90 THEN 'Stage 2 Hypertension'
        END "BPrisk"
from public."Patients" pat
join public."AmbulatoryVisits" amv on amv."Patient_ID"=pat."Patient_ID"
order by "BPrisk"

#Question 65
--65.Write a query to get a list the patients who were admitted in ICU for ‘Pneumonia’.

Select "FirstName","LastName","Service","PrimaryDiagnosis" from public."Patients" pat
join public."Discharges" dis on dis."Patient_ID"=pat."Patient_ID"
join public."PrimaryDiagnosis" pdia on pdia."Diagnosis_ID"=dis."Diagnosis_ID"
join public."Service" ser on ser."Service_ID"=dis."Service_ID"
where "Service"='ICU' and "PrimaryDiagnosis"='Pneumonia'
#Question 66
--66.Write a query to get which month had the highest number of readmissions in the year 2018.

Select "MonthOfHighestReadmission", "NoOfReadmissions"
from
(select Count("ReadmissionFlag") "NoOfReadmissions"
        ,TO_CHAR("AdmissionDate",'Month') as "MonthOfHighestReadmission"
        ,RANK () OVER (ORDER BY Count("ReadmissionFlag") desc) rank_number
  from public."ReAdmissionRegistry" 
where "ReadmissionFlag"='1'
group by "MonthOfHighestReadmission","ReadmissionFlag") as noofReadmMonthly
where rank_number=1

#Question 67
--67. Write a query to get List of female patients over the age of 40 who have undergone surgery from January-March 2019.

SELECT P."FirstName", P."LastName", AGE(P."DateOfBirth"), G."Gender", Ps."ProviderSpeciality", A."DateofVisit" 
FROM "Patients" P 
Left JOIN "Gender" G ON G."Gender_ID" = P."Gender_ID"
Left JOIN "AmbulatoryVisits" A ON A."Patient_ID" = P."Patient_ID"
Left JOIN "Providers" Pr ON Pr."Provider_ID" = A."Provider_ID"
Left JOIN "ProviderSpeciality" Ps ON Ps."PS_ID" = Pr."PS_ID"
WHERE (EXTRACT(YEAR FROM "DateofVisit") - EXTRACT(YEAR FROM "DateOfBirth")) > '40' AND G."Gender" = 'Female' AND Ps."PS_ID" = 'PSID02'
AND A."DateofVisit" BETWEEN '2019-01-01' AND '2019-03-31';

#Question 68
--68. Write a query to display the count of patients whose Readmissionflag is 1.
SELECT "ReadmissionFlag", COUNT("Patient_ID") 
FROM public."ReAdmissionRegistry"
WHERE "ReadmissionFlag" = '1'
group by "ReadmissionFlag" ;

#Question 69
--69.Write a query to display  which Service has the highest number of Patients. 

Select "Service", "Highest_Number of Patients" 
from 
(Select "Service", count("Patient_ID") AS "Highest_Number of Patients", 
       RANK () OVER (ORDER BY Count("Patient_ID") desc) rank_number 
From public."Discharges" dis 
join public."Service" ser on ser."Service_ID"=dis."Service_ID"
GROUP BY "Service") as noofpatbyService
Where rank_number=1

#Question 70
--70.Write a query to show which Primary Diagnosis has the highest LOS.

Select "PrimaryDiagnosis","ExpectedLOS",ELOS_Rank 
from (
Select "PrimaryDiagnosis","ExpectedLOS", rank() over(order by "ExpectedLOS" desc) ELOS_Rank 
from public."Discharges" dis
join public."PrimaryDiagnosis" pd on pd."Diagnosis_ID" = dis."Diagnosis_ID"
group by "PrimaryDiagnosis","ExpectedLOS") as ExpLOSforPD
where ELOS_Rank = 1;


#Question 71
--71.Write a Query to get list of Male patients.

SELECT "FirstName","LastName","Gender"
FROM public."Patients" pat
join public."Gender" gen on gen."Gender_ID"=pat."Gender_ID"
WHERE "Gender"='Male'

#Question 72
--72.Write a query to get a list of patient ID's who were discharged to home.

Select  dis."Patient_ID", dsp."DischargeDisposition"
from public."Discharges" dis 
left outer join public."DischargeDisposition" dsp on dis."Discharge_ID" = dsp."Discharge_ID"
where "DischargeDisposition" = 'Home'; 

#Question 73
--73.Write a query to find the category of illness(Stomach Ache or Migrane) that has maximum number of patient.

select * from (
    select "ReasonForVisit",count(distinct "Patient_ID") patient_cnt,
        rank() over(order by count(distinct "Patient_ID") desc) patient_cnt_rnk
        from public."EDVisits" vis 
        left outer join public."ReasonForVisit" res on res."Rsv_ID" = vis."Rsv_ID"
        where ("ReasonForVisit" = 'Stomach Ache' or "ReasonForVisit" ='Migraine')
    group by   "ReasonForVisit" ) as pat_vis
where patient_cnt_rnk = 1;

#Question 74
--74.Write a query to get list of New Patient ID's.

select  pat."Patient_ID",vtyp."VisitType"
    from public."Patients" pat  
    left outer join public."AmbulatoryVisits" vis on vis."Patient_ID" = pat."Patient_ID"
    left outer join public."VisitTypes" vtyp on vtyp."AMVT_ID" = vis."AMVT_ID"
    where "VisitType" = 'New'
   order by pat."Patient_ID";

#Question 75
--75.Select all providers with a name starting 'h' followed by any character ,followed by 'r', followed by any character,followed by 'y'

Select "ProviderName"
from "Providers"
where LOWER("ProviderName") like 'h_r_y%';

#Question 76
--76.Write a query to show the list of the patients who have cancelled their appointment
   select  "FirstName","LastName","VisitStatus"
    from public."Patients" pat  
    left outer join public."AmbulatoryVisits" avis on avis."Patient_ID" = pat."Patient_ID"
    left  join public."VisitStatus" stat on stat."VisitStatus_ID" = avis."VisitStatus_ID"
    where stat."VisitStatus" = 'Canceled';

#Question 77
--77.Write a query to get list of ProviderName's with a name starting 'ted'

SELECT "ProviderName"
FROM "Providers"
WHERE "ProviderName" like  INITCAP('ted%');

#Question 78
--78. Write a query to show position of letter 'r' in first name of the Patients.

SELECT "FirstName", "LastName" , POSITION('r' IN "FirstName") positionofr
FROM public."Patients"
WHERE POSITION('r' IN "FirstName")>0;

#Question 79
--79. Write is query to find the list outpatient names whose first name start with 'W' and categorize Age group wise 
--Hint : less than 40 are Young Adult ,age between 59-40 are Middle Age Adult and age 60 and greater than are "Old Adult" )

Select "FirstName","LastName", CASE 
        WHEN age < '40' THEN 'Young Adult' 
        WHEN age BETWEEN '40' and '59' THEN 'Middle Age Adult'
        WHEN age >= '60' THEN 'Old Adult'end
        from
(Select "FirstName","LastName",Extract(Year from AGE("DateofVisit","DateOfBirth")) age from public."Patients" pat
join public."AmbulatoryVisits" amv on amv."Patient_ID"=pat."Patient_ID"
join public."VisitStatus" vs on vs."VisitStatus_ID"=amv."VisitStatus_ID"
where "VisitStatus"= 'Completed' and "FirstName" like 'W%') as outpatients
where "FirstName" like 'W%' 

#Question 80
--80.Write a query to find the Provider(s) who has most experience based on Provider Date On Staff.

Select "ProviderName", nofYrsofExp from 
(select "ProviderName", AGE(now(), "ProviderDateOnStaff") nofYrsofExp,
 rank() over(order by AGE(now(), "ProviderDateOnStaff") desc) highestExp
from public."Providers") as provnoofexp
where highestExp = 1;

#Question 81
--81.Write a query to show Providers who share same LastName.

Select "LastName", cnt from
 (Select "LastName", COUNT("LastName") cnt from
  (Select
  split_part("ProviderName"::TEXT,' ', 2) "LastName",
  split_part("ProviderName"::TEXT,' ', 1) "FirstName" 
  from public."Providers" prov) as plist
  group by "LastName")as plistfinal
where  cnt>1;

#Question 82
--82.Write a query to create a view without using any schema or table and check the created view using select statement.
create or replace view getNow  as 
select now() as sysdate;

select * from getNow;

#Question 83
--83.Write a query to get unique list of Patient Id's whose reason for visit is ‘car accident’.
select  distinct pat."Patient_ID","ReasonForVisit"
    from public."Patients" pat 
    left outer join public."EDVisits" vis on vis."Patient_ID" = pat."Patient_ID"
    left outer join public."ReasonForVisit" res on res."Rsv_ID" = vis."Rsv_ID"
    where  "ReasonForVisit" = 'Car Accident'     
    order by pat."Patient_ID";

#Question 84
--84.Write a query to get the list of patient names whose primary diagnosis as 'Spinal Cord injury' having Expected LOS is greater than 15

select P."FirstName", P."LastName", pd."PrimaryDiagnosis", dis."ExpectedLOS"
from "Patients" P 
left outer join public."Discharges" dis ON dis."Patient_ID" = P."Patient_ID"
left outer join public."PrimaryDiagnosis" pd ON pd."Diagnosis_ID" = dis."Diagnosis_ID"
where pd."PrimaryDiagnosis" = 'Spinal Cord Injury' AND dis."ExpectedLOS" > 15

#Question 85
--85.Write a query to get list of Patient names who haven't been discharged.

Select P."FirstName" as "Patient_FirstName",P."LastName" as "Patient_LastName" 
from "Patients" P
Where P."Patient_ID" NOT IN (Select D."Patient_ID" from "Discharges" D)

#Question 86
--86.Write a query to get list of Provider names whose ProviderSpecialty is Pediatrics.
select prov."ProviderName", provSp."ProviderSpeciality"
from public."Providers" prov
left join public."ProviderSpeciality" provSp ON provSp."PS_ID"= prov."PS_ID"
where provSp."ProviderSpeciality" = 'Pediatrics'

#Question 87
--87.Write a query to get list of patient ID's who has admitted on 1/7/2018 and discharged on 1/15/2018.
Select "Patient_ID","AdmissionDate",DATE("DischargeDate") DischargeDate 
from public."Discharges" dis
where "AdmissionDate" = '2018-01-07' and DATE("DischargeDate") ='2018-01-15'

#Question 88
--88.Write a query to find outpatients vs inpatients by monthwise (hint: consider readmission/discharges and ambulatory visits table for inpatients and outpatients).
Select T1."OutPatients",T2."InPatients",T1."InMonthOf"
from (Select count(public."AmbulatoryVisits"."Patient_ID") as "OutPatients",
      TO_CHAR("AmbulatoryVisits"."DateofVisit",'Month') as "InMonthOf" 
      from public."AmbulatoryVisits" 
      Where "VisitStatus_ID"  = 'VS002' and  
      public."AmbulatoryVisits"."Patient_ID" not in
      (select public."Discharges"."Patient_ID" from public."Discharges")
      Group by "InMonthOf") T1
Left Join (SELECT Count("Patient_ID") as "InPatients",TO_CHAR("AdmissionDate",'Month') AS "InMonthOf"
          from "Discharges"
          Group by "InMonthOf") as T2
on T1."InMonthOf" = T2."InMonthOf";

#Question 89
--89.Write a query to get list of Number of Ambulatory Visits by Provider Speciality per month. 
Select "ProviderSpeciality", MonthOfVisit,numberOfAmvVisits from
(Select ps."ProviderSpeciality",  TO_CHAR(amv."DateofVisit",'Month') as MonthOfVisit ,Count(amv."AMVT_ID") numberOfAmvVisits from public."AmbulatoryVisits" amv
left outer join public."Providers" prov on prov."Provider_ID"=amv."Provider_ID"
left outer join public."ProviderSpeciality" ps on ps."PS_ID"=prov."PS_ID"
group by ps."ProviderSpeciality", MonthOfVisit) as visitbyPovSpec
order by MonthOfVisit 

#Question 90
--90.Write a query to get list of patient with their full names whose names contains "Ma".
Select P."PatientFullName"
from (Select concat("FirstName",' ',"LastName") AS "PatientFullName"
From "Patients") P 
where P."PatientFullName" Like '%Ma%'

#Question 91
--91.Write a query to do Partition the table according to Service_ID and use windows function to  calculate percent rank Order by ExpectedLOS. 

--On Discharges table

select "Patient_ID","Service_ID","ExpectedLOS",
PERCENT_RANK() OVER(partition by "Service_ID" order by "ExpectedLOS") as "Percent_Rank"
from "Discharges";

--On ReAdmissionRegistry table
select "Patient_ID","Service_ID","ExpectedLOS",
PERCENT_RANK() OVER(partition by "Service_ID" order by "ExpectedLOS") as "Percent_Rank"
from "ReAdmissionRegistry";

#Question 92
--92.Write a query by using common table expressions and case statements to  display year of birth ranges. (Ex: 1960-1970)
WITH "cte_PatientsAgeGroup" As (
 select "Patient_ID","FirstName","LastName","DateOfBirth",
       CASE 
        WHEN Extract(Year from "DateOfBirth") <=  1966 THEN 'OlderAdulthood' 
        WHEN Extract(Year from "DateOfBirth") BETWEEN 1965 and 1986 THEN 'MiddleAge'
        WHEN Extract(Year from "DateOfBirth") BETWEEN 1987 and 2004 THEN 'YoungAdulthood'
        END "BirthYearRangeCategory"
 from "Patients")
select * from "cte_PatientsAgeGroup";

#Question 93
--93.Write a query to get list of Provider names whose ProviderSpeciality is Surgery. 
select prov."ProviderName", provSp."ProviderSpeciality"
from public."Providers" prov
left join public."ProviderSpeciality" provSp ON provSp."PS_ID"= prov."PS_ID"
where provSp."ProviderSpeciality" = 'Surgery'

#Question 94
--94.Write a query to get List of patients from rows 11-20 without using WHERE condition. 
select "FirstName","LastName"
from public."Patients" offset 10 row Fetch FIRST 10 rows only;

#Question 95
--95.Write a query as to how to find triggers from table AmbulatoryVisits.

CREATE TABLE IF NOT EXISTS public."AmbulatoryVisitsPatientBPLog"
(
     "Patient_ID" integer,
     "BloodPressureSystolic" real,
    "BloodPressureDiastolic" real
)
TABLESPACE pg_default;
	 
-- Alter the Created table if needed.

ALTER TABLE IF EXISTS public."AmbulatoryVisitsPatientBPLog"
    OWNER to postgres;
	
--selecting "AmbulatoryVisitsPatientBPLog" to display the newly created table "AmbulatoryVisitsPatientBPLog"
	
Select * from public."AmbulatoryVisitsPatientBPLog"
	
-- Creating a Trigger Function to be called when trigger is invoked to insert the records in the newly created 
-- "AmbulatoryVisitsPatientBPLog" table
CREATE OR REPLACE FUNCTION PatientBP_insert() 
  RETURNS trigger AS $Insert_BP$
BEGIN
INSERT INTO public."AmbulatoryVisitsPatientBPLog"("Patient_ID","BloodPressureSystolic","BloodPressureDiastolic")
VALUES(NEW."Patient_ID",NEW."BloodPressureSystolic",New."BloodPressureDiastolic");
RETURN Null;
END;
$Insert_BP$
LANGUAGE 'plpgsql';

-- Creating the Trigger Insert_BP to insert the bp records to the "AmbulatoryVisits" Table
CREATE or replace TRIGGER Insert_BP
AFTER INSERT
  ON public."AmbulatoryVisits"
  FOR EACH ROW
  EXECUTE FUNCTION PatientBP_insert();
  
  Commit;
--  Inserting new record into table public."AmbulatoryVisits"

INSERT INTO public."AmbulatoryVisits" VALUES (957,103,5,'2019-02-18','2019-01-24 11:50:26',12,'AMVT002',150,99,90,'VS003');

-- Displaying the new table with records inserted successfully with the created trigger
Select * from public."AmbulatoryVisitsPatientBPLog" ;

#Question 96
--96.Recreate the below expected output using Substring. 

SELECT "Gender", SUBSTRING("Gender", 1, 1 ) AS gender
FROM public."Gender"
    
#Question 97
--97.Obtain the below output by grouping the patients. 
Select "Patient_ID","FirstName", SUBSTRING("FirstName", 1, 1 ) AS patient_group 
from public."Patients" where "FirstName" Like 'L%'

#Question 98
--98.Please go through the below screenshot and create the exact output. 
Select "FirstName", CHAR_LENGTH("FirstName") AS unknown
from public."Patients"

#Question 99
--99.Please go through the below screenshot and create the exact output.

select "BloodPressureDiastolic","Pulse",
       trunc("BloodPressureDiastolic"+1) as "bpd",trunc("Pulse") as "HeartRate" 
from "AmbulatoryVisits" offset 1 row Fetch next 21 rows only;

#Question 100
--100.Please go through the below screenshot and create the exact output.
select "BloodPressureSystolic",'The Systolic Blood pressure is '|| to_char("BloodPressureSystolic",'999.99')
        as "Message"
from "AmbulatoryVisits";



















