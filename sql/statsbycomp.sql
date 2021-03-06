-- files ranked by #CA
.print <caption>Defect density and churn by build component ranked by #CAs, since 2013</caption>
with
-- join repos and component2team tables
repoteam as (select rp.comp,rp.name,ct.team 
from repos rp
inner join component2team ct on rp.comp=ct.comp),
-- join gitcommit and filechurn and repoteam for CAs group by uuid
g as (select c.uuid,c.repo,r.comp,r.team,c.date,c.jiratype,c.jiraid,sum(f.added) as sumchurn
from gitcommit c
inner join filechurn f on f.uuid=c.uuid
inner join repoteam r on c.repo=r.name
where c.date > '2013-01-01' and c.jiratype='CA' group by c.uuid),
-- join g with CAs, to get LCM CAs
g2 as (select g.uuid,g.repo,g.comp,g.team,g.date,g.jiratype,g.jiraid,g.sumchurn,CAs.jiraid as lcmjiraid from g left outer join CAs on g.jiraid=CAs.jiraid),
-- Get total loc by repo
f as (select fm.repo,r.comp,r.team,sum(fm.loc) as sumrepoloc from filemap fm inner join repoteam r on fm.repo=r.name group by fm.repo),
-- Get total loc by comp
fc as (select comp,team,sum(sumrepoloc) as sumcomploc from f group by comp),
-- Get num of CAs and churn by repo 
gr as (select g2.comp,count(distinct(g2.jiraid)) as cjid,count(distinct(g2.lcmjiraid)) as lcmcjid,sum(g2.sumchurn) as clc from g2 group by g2.comp)

select gr.comp,gr.cjid as "#CAs",gr.lcmcjid as "#HFXs",gr.clc as "CA LOC churn", fr.sumcomploc as "LOC",round(gr.clc*100/fr.sumcomploc,2) as "% churn",round((1000.0*gr.cjid)/fr.sumcomploc,2) as "#CAs/KLoc",round((1000.0*gr.lcmcjid)/fr.sumcomploc,2) as "#HFXs/KLoc" from  gr inner join fc fr on fr.comp=gr.comp
order by "#CAs" desc;
--select * from fc
--order by comp;
