with cu_person_type as (
select 
dp.uuid,
dp.dir_uid,
case  
    when dp.primaryaffiliation = 'Student' then 'Student'
    when dp.primaryaffiliation = 'Faculty' and  daf.edupersonaffiliation = 'Faculty'  and daf.description = 'Student Faculty' then 'Student' 
    when dp.primaryaffiliation = 'Faculty' and  daf.edupersonaffiliation = 'Faculty' and daf.description  != 'Student Faculty' then 'Faculty/Staff' 
    when dp.primaryaffiliation = 'Staff' then 'Faculty/Staff'
    when dp.primaryaffiliation = 'Employee' and daf.edupersonaffiliation = 'Employee' and daf.description = 'Student Employee'  then 'Student'
    when dp.primaryaffiliation = 'Employee' and daf.edupersonaffiliation = 'Employee' and daf.description = 'Student Faculty' then 'Student'
    when dp.primaryaffiliation = 'Employee' and daf.edupersonaffiliation = 'Employee' and daf.description not in ('Student Faculty','Student Employee') then  'Faculty/Staff'  
    when dp.primaryaffiliation = 'Officer/Professional' then 'Faculty/Staff'
      else 'Student'
  end as person_type
from dirsvcs.dir_person dp 
  inner join dirsvcs.dir_affiliation daf
    on daf.uuid = dp.uuid
    and daf.campus = 'Boulder Campus' 
    and dp.primaryaffiliation not in ('Not currently affiliated','Retiree','Affiliate','Member') 
    and daf.description not in ( 'Retiree','Boulder3' ,'Admitted Student', 'Alum','Confirmed Student','Former Student','Member Spouse','Sponsored','Sponsored EFL')
    and daf.description not like 'POI_%'

)
select 
   distinct cpt.dir_uid as username
  ,de.mail as email
  ,cpt.person_type
from cu_person_type cpt
inner join dirsvcs.dir_affiliation daf
    on daf.uuid = cpt.uuid
left join dirsvcs.dir_email de
    on de.uuid = cpt.uuid
    and de.mail_flag = 'M'
    and de.mail is not null
left join dirsvcs.dir_acad_career dac
on dac.uuid = cpt.uuid
where (
    cpt.primaryaffiliation != 'Student'
    and lower(de.mail) not like '%cu.edu'
  ) or (
    cpt.primaryaffiliation = 'Student'
    and dac.career != 'x'
    )

