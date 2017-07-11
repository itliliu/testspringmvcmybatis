#Generate a sql file every day. 
#The file name is
#   table_20170525.sql

#2017-05-25 14:51
#   Alter table ProjectBrief add column IsNeedProposal

ALTER TABLE `we_project`.`ProjectBrief` 
ADD COLUMN `IsNeedProposal` BIT NOT NULL DEFAULT 1;