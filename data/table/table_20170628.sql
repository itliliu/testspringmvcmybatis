ALTER TABLE project_brief
DROP COLUMN powerBI_url ,
DROP COLUMN reject_reason ,
DROP COLUMN cancel_reason;

update Role set Permission ='{"draftForm": {"add": 1,"edit": 1,"delete": 1,"submit": 1,"view": 1},"submitForm": {"edit": 1,"reject": 0,"cancel": 1,"submit": 0,"view": 1},"inProgressForm": {"edit": 0,"complete": 0,"cancel":0,"view": 1},"completeForm": {"edit": 0,"delete": 0,"view": 1},"cancelForm": {"edit": 0,"delete": 0, "view": 1},"draftList": {"delete": 1,"export": 1,"reload": 1,"view": 1},"submitList": {"delete": 0,"export": 1,"reload": 1,"view": 1},"inProgressList": {"export": 0,"reload": 0,"view": 1},"completeList": {"export": 0,"reload": 0,"view": 1},"cancelList": {"export": 0,"reload": 0,"view": 1},"configuration": {"add": 0,"delete": 0,"edit": 0,"view": 0}}'
where RoleID=1;

update Role set Permission ='{"draftForm": {"add": 0,"edit": 0,"delete": 0,"submit": 0,"view": 0},"submitForm": {"edit": 0,"reject": 1,"cancel": 0,"submit": 1,"view": 1},"inProgressForm": {"edit": 1,"complete": 1,"cancel":1,"view": 1},"completeForm": {"edit": 0,"delete": 0,"view": 1},"cancelForm": {"edit": 0,"delete": 0,"view": 1},"draftList": {"delete": 0,"export": 0,"reload": 0,"view": 0},"submitList": {"delete": 0,"export": 1,"reload": 1,"view": 1},"inProgressList": {"export": 1,"reload": 1,"view": 1},"completeList": {"export": 1,"reload": 1,"view": 1},"cancelList": {"export": 0,"reload": 0,"view": 1},"configuration": {"add": 1,"delete": 1,"edit": 1,"view": 1}}'
where RoleID=5;

ALTER TABLE project_brief ADD COLUMN version INT DEFAULT 0;

update Role set RoleName = 'ReportCenter' where RoleID = 5 and RoleName = 'Report Center';

ALTER TABLE project_brief
ADD COLUMN create_by INT(11);

UPDATE project_brief SET create_by = user_id WHERE parent_id = 0;
UPDATE project_brief p left join project_brief pc on p.brief_id = pc.parent_id SET pc.create_by = p.user_id;



