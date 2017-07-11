use we_project;

truncate table Format;
truncate table ReportType;
truncate table Role;
truncate table User;
truncate table UserClientMap;
truncate table Client;

insert into Format(FormatID, FormatType, Status, InsertDate, LastModifyDate)
values(1, 'Word', 1, 1494467779, 1494467779),
(2, 'PPT', 1, 1494467779, 1494467779),
(3, 'Excel', 1, 1494467779, 1494467779),
(4, 'Pbix', 1, 1494467779, 1494467779),
(5, 'Other', 1, 1494467779, 1494467779);


insert into ReportType(ReportTypeID, ReportType, Status, InsertDate, LastModifyDate)
values
(1, 'End of Day', 1, 1494467743, 1494467743),
(2, 'End of Momment', 1, 1494467743, 1494467743),
(3, 'Citation', 1, 1494467743, 1494467743),
(4, 'Other', 1, 1494467743, 1494467743);

insert into Role(RoleID, RoleName, Permission, status, InsertDate, LastModifyDate)
values
(1, 'AccountTeam', '{"menu": {"projectConsole": 1,"userTemplateLibrary": 1,"configurationConsole": 0},"projectList": {"add": 1,"view": 1},"projectForm": {"view": 1},"projectBrief": {"add": 1,"edit": 1,"submit": 1,"delete": 1,"view": 1},"projectProposal": {"add": 0,"edit": 0,"submit": 0,"export": 1,"approve": 1,"reject": 1,"view": 1},"projectRequest": {"add": 0,"edit": 0,"commit": 0,"view": 0},"projectReport": {"edit": 1,"reject":1,"complete": 1,"view": 1},"userTemplateList": {"add":0,"edit": 0,"delete": 0,"view":1,"download":1},"userTemplateForm": {"add": 0,"edit": 0,"delete": 0,"view": 1},"roleManagement": {"add": 0,"edit": 0,"delete": 0,"view": 0},"userManagement": {"add": 0,"edit": 0,"delete": 0,"view": 0},"clientManagement": {"add": 0,"edit": 0,"delete": 0,"view": 0}}', 1, 1494467657, 1494467657),
(2, 'Strategist', '{"menu": {"projectConsole": 1,"userTemplateLibrary": 1,"configurationConsole": 0},"projectList": {"add": 0,"view": 1},"projectForm": {"view": 1},"projectBrief": {"add": 0,"edit": 0,"submit": 0,"delete": 0,"view": 1},"projectProposal": {"add": 1,"edit": 1,"submit": 1,"export": 1,"approve": 0,"reject": 0,"view": 1},"projectRequest": {"add": 0,"edit": 0,"commit": 0,"view": 0},"projectReport": {"edit": 0,"reject":0,"complete": 0,"view": 1},"userTemplateList": {"add":0,"edit": 0,"delete": 0,"view":1,"download":1},"userTemplateForm": {"add": 0,"edit": 0,"delete": 0,"view": 1},"roleManagement": {"add": 0,"edit": 0,"delete": 0,"view": 0},"userManagement": {"add": 0,"edit": 0,"delete": 0,"view": 0},"clientManagement": {"add": 0,"edit": 0,"delete": 0,"view": 0}}', 1, 1494467657, 1494467657),
(3, 'ServiceCenter', '{"menu": {"projectConsole": 1,"userTemplateLibrary": 1,"configurationConsole": 0},"projectList": {"add": 0,"view": 1},"projectForm": {"view": 1},"projectBrief": {"add": 0,"edit": 0,"submit": 0,"delete": 0,"view": 1},"projectProposal": {"add": 0,"edit": 0,"submit": 0,"export": 1,"approve": 0,"reject": 0,"view": 1},"projectRequest": {"add": 1,"edit": 1,"commit": 1,"view": 1},"projectReport": {"edit": 0,"reject":0,"complete": 0,"view": 1},"userTemplateList": {"add":1,"edit": 1,"delete": 1,"view":1,"download":1},"userTemplateForm": {"add": 1,"edit": 1,"delete": 1,"view": 1},"roleManagement": {"add": 0,"edit": 0,"delete": 0,"view": 0},"userManagement": {"add": 0,"edit": 0,"delete": 0,"view": 0},"clientManagement": {"add": 0,"edit": 0,"delete": 0,"view": 0}}', 1, 1494467657, 1494467657),
(4, 'Admin', '{"menu": {"projectConsole": 1,"userTemplateLibrary": 1,"configurationConsole": 1},"projectList": {"add": 1,"view": 1},"projectForm": {"view": 1},"projectBrief": {"add": 1,"edit": 1,"submit": 1,"delete": 1,"view": 1},"projectProposal": {"add": 1,"edit": 1,"submit": 1,"export": 1,"approve": 1,"reject": 1,"view": 1},"projectRequest": {"add": 1,"edit": 1,"commit": 1,"view": 1},"projectReport": {"edit": 1,"reject":1,"complete": 1,"view": 1},"userTemplateList": {"add":1,"edit": 1,"delete": 1,"view":1,"download":1},"userTemplateForm": {"add": 1,"edit": 1,"delete": 1,"view": 1},"roleManagement": {"add": 1,"edit": 1,"delete": 1,"view": 1},"userManagement": {"add": 1,"edit": 1,"delete": 1,"view": 1},"clientManagement": {"add": 1,"edit": 1,"delete": 1,"view": 1}}', 1, 1494467657, 1494467657);

insert into User(UserID, UserName, RoleID, Email, Status, InsertDate, LastModifyDate)
values
(1, 'AccountTeamDevDemo1', 1, 'AccountTeamDevDemo1@wetest.com', 1, 1494414005, 1494414005),
(2, 'AccountTeamDevDemo2', 1, 'AccountTeamDevDemo2@wetest.com', 1, 1494414005, 1494414005),
(3, 'StrategistDevDemo1', 2, 'StrategistDevDemo1@wetest.com', 1, 1494414005, 1494414005),
(4, 'StrategistDevDemo2', 2, 'StrategistDevDemo2@wetest.com', 1, 1494414005, 1494414005),
(5, 'ServiceCenterDemo1', 3, 'ServiceCenterDemo1@wetest.com', 1, 1494414005, 1494414005),
(6, 'ServiceCenterDemo2', 3, 'ServiceCenterDemo2@wetest.com', 1, 1494414005, 1494414005),
(7, 'AdminDevDemo', 4, 'AdminCenterDevDemo@wetest.com', 1, 1494414005, 1494414005);

insert into UserClientMap(ClientID, InsertDate, LastModifyDate, UserID, IsDefault)
values(-1, 1494926270, 1494926270, 1, 1),
(-1, 1494926270, 1494926270, 2, 1),
(-1, 1494926270, 1494926270, 3, 1),
(-1, 1494926270, 1494926270, 4, 1),
(-1, 1494926270, 1494926270, 5, 1),
(-1, 1494926270, 1494926270, 6, 1),
(-1, 1494926270, 1494926270, 7, 1);

insert into Client(ClientID, ClientName, Logo, InsertDate, LastModifyDate, ParentID)
values(1, 'Microsoft', null, 1494470215, 1494470215, 0);

