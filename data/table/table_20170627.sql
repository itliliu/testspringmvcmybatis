#The file name is
#   table_20170627.sql

#2017-06-27 11:51
#   Alter table User add column RealName

ALTER TABLE `we_project`.`User` 
ADD RealName VARCHAR(128);

INSERT INTO we_project.Role(RoleName,`Status`,InsertDate, LastModifyDate) 
VALUES('Report Center', 1,unix_timestamp(now()),unix_timestamp(now()));

INSERT INTO `User`(UserName,RoleID,Email,Status,InsertDate,LastModifyDate,RealName)
VALUES ('ReportCenterDemo1',5,'ReportCenterDemo1@wetest.com',1,unix_timestamp(now()),unix_timestamp(now()),'Report Center1 ');

INSERT INTO `User`(UserName,RoleID,Email,Status,InsertDate,LastModifyDate,RealName)
VALUES ('ReportCenterDemo2',5,'ReportCenterDemo2@wetest.com',1,unix_timestamp(now()),unix_timestamp(now()),'Report Center2');

ALTER TABLE project_brief
ADD parent_id INT DEFAULT 0,
ADD powerBI_url VARCHAR(128),
ADD reject_reason VARCHAR(1024),
ADD cancel_reason VARCHAR(1024);

update Role set Permission ='{"menu": {"configuration": 0},"briefForm": {"createBrief": 1,"submitBrief": 1,"returnBrief": 0,"toWorkBrief": 0,"completeBrief":0,"cancelBrief":1,"saveBrief":0},"draftList": {"delete": 1,"export": 1,"reload": 1,"view": 1},"submitList": {"delete": 1,"export": 1,"reload": 1,"view": 1},"inProgressList": {"export": 0,"reload": 0,"view": 1},"completeList": {"export": 0,"reload": 0,"view": 1},"cancelList": {"export": 0,"reload": 0,"view": 1},"configuration": {"add": 0,"delete": 0,"update": 0,"view": 0}}'
where RoleID=1;

update Role set Permission ='{"menu": {"configuration": 1},"briefForm": {"createBrief": 0,"submitBrief": 0,"returnBrief": 1,"toWorkBrief": 1,"completeBrief":1,"cancelBrief":1,"saveBrief":1},"draftList": {"delete": 0,"export": 0,"reload": 0,"view": 0},"submitList": {"delete": 0,"export": 1,"reload": 1,"view": 1},"inProgressList": {"export": 1,"reload": 1,"view": 1},"completeList": {"export": 1,"reload": 1,"view": 1},"cancelList": {"export": 1,"reload": 1,"view": 1},"configuration": {"add": 1,"delete": 1,"update": 1,"view": 1}}'
where RoleID=5;


