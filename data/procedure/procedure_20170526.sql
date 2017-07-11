#This file is procedure_20170526.sql

#2017-05-26 14:11
#   Modify procedure DeleteTemplate
#   Create procedure UpdateTemplate
#   Create procedure UpdateClient
#   Modify procedure GetTemplateDetail

USE we_project;

DROP PROCEDURE IF EXISTS `DeleteTemplate`;
DROP PROCEDURE IF EXISTS `UpdateTemplate`;
DROP PROCEDURE IF EXISTS `UpdateClient`;
DROP PROCEDURE IF EXISTS `GetTemplateDetail`;

#If a template is used by project or other template, then the template can not be deleted.
#Else the template can be deleted.
DELIMITER $$

CREATE PROCEDURE `DeleteTemplate`(
    IN templateIDIN INT
)
BEGIN
DECLARE template_count INT;
DECLARE report_count INT;
DECLARE returnCode INT;
DECLARE t_error INTEGER DEFAULT 0;  
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;

SET returnCode = -1;
START TRANSACTION;

SELECT count(TemplateID) INTO template_count FROM Template WHERE PowerBITemplateID=templateIDIN;

SELECT count(ReportID) INTO report_count FROM Report 
WHERE PowerBITemplateID=templateIDIN OR TilesProTemplateID=templateIDIN;

IF template_count=0 AND report_count=0 THEN
    DELETE FROM Template WHERE TemplateID = templateIDIN;
    SET returnCode = (SELECT ROW_COUNT());
END IF;

IF t_error = 1 THEN  
    ROLLBACK;  
    SET returnCode = 500;
ELSE  
    COMMIT;      
END IF;  
SELECT returnCode;

END $$

#Update template. If PowerBITemplateID of report template is modified, update Report's PowerBITemplateID 
#   and update ReportFile's PowerBITemplateUrl
DELIMITER $$

CREATE PROCEDURE `UpdateTemplate`(
    IN TemplateIDIN INT(11),
		IN TemplateNameIN VARCHAR(128),
		IN ReportTypeIN INT(11),
		IN FormatIN INT(11),
		IN StatusIN INT(11),
		IN ClientIDIN INT(11),
		IN TypeIN VARCHAR(128),
		IN useridIN INT(11),
		IN DescriptionIN TEXT,
		IN FileUrlIN VARCHAR(128),
		IN PowerBITemplateidIN INT(11)
)
BEGIN
 DECLARE count INT;
 DECLARE returnCode INT;
 DECLARE t_error INTEGER DEFAULT 0;  
 DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1; 
 
 SELECT PowerBITemplateID INTO @powerBITempID 
 FROM Template WHERE TemplateID=TemplateIDIN;

 UPDATE Template
 SET TemplateName=TemplateNameIN,
		ReportType=ReportTypeIN,
		Format=FormatIN,
		Status = StatusIN,
		ClientID =ClientIDIN,
		Type = TypeIN,
		Userid =useridIN,
		LastModifyDate = unix_timestamp(now()),
    Description =DescriptionIN,
    FileUrl = FileUrlIN, 
    PowerBITemplateID=PowerBITemplateidIN
		WHERE TemplateID =TemplateIDIN;
    
 SELECT ROW_COUNT() INTO count;
    
 IF count<>0 AND PowerBITemplateidIN IS NOT NULL AND PowerBITemplateidIN<>0 AND PowerBITemplateidIN<>@powerBITempID THEN
    UPDATE Report rp 
    LEFT JOIN ReportFile rf ON rp.ReportID=rf.ReportID 
    LEFT JOIN Template tl ON rp.PowerBITemplateID= tl.TemplateID
    LEFT JOIN ProjectBrief brief ON rp.ProjectID=brief.ParentID OR rp.ProjectID=brief.ProjectBriefID
    SET rp.PowerBITemplateID=PowerBITemplateidIN,
        rf.PowerBITemplateUrl=tl.FileUrl
    WHERE rp.TilesProTemplateID=TemplateIDIN AND (brief.Status>=0 AND brief.Status<5);
 END IF;
 IF t_error = 1 THEN  
    ROLLBACK;  
    SET returnCode = 0;
 ELSE  
    COMMIT;  
    SET returnCode = 1;
 END IF;  
 SELECT returnCode;
END $$

#Update Client
DELIMITER $$

CREATE PROCEDURE `UpdateClient`(
    IN clientIDIN INT(11),
		IN clientNameIN VARCHAR(128),
		IN parentIDIN INT(11),
		IN statusIN INT(11),
    IN type VARCHAR(128)   -- edit or deactivated
)
BEGIN
 DECLARE count INT;
 DECLARE returnCode INT;
 DECLARE t_error INTEGER DEFAULT 0;  
 DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1; 
 
 SET returnCode=-1;
 
 SELECT Status INTO @status FROM Client WHERE ClientID=clientIDIN;
 
 SET count=0;
 -- if activated change to deactivated, 
 --   check the number of project brief status >=0 and stats <5  
 IF @status=0 AND statusIN=1 THEN
    SELECT COUNT(ProjectBriefID) INTO count
    FROM ProjectBrief
    WHERE ClientID=clientIDIN AND (Status!=5 AND Status>=0);
 END IF;
 
 IF count=0 THEN
    IF type='edit' THEN
        UPDATE Client 
        SET ClientName=clientNameIN,
            ParentID=parentIDIN,
            LastModifyDate=unix_timestamp(now()),
            Status=statusIN
        WHERE ClientID=clientIDIN;
        SET returnCode=(SELECT ROW_COUNT());
    ELSE
        UPDATE Client 
        SET LastModifyDate=unix_timestamp(now()),
            Status=statusIN
        WHERE ClientID=clientIDIN;
        
        SET returnCode=(SELECT ROW_COUNT());
    END IF;
 END IF;
 
 IF t_error = 1 THEN  
    ROLLBACK;  
    SET returnCode = 500;
 ELSE  
    COMMIT;  
 END IF;  
 SELECT returnCode;

END $$

#Get template detail
DELIMITER $$

CREATE PROCEDURE `GetTemplateDetail`(
    IN templateIDIN INT
)
BEGIN
DECLARE template_count INT;
DECLARE report_count INT;
DECLARE isused INT;

-- Check if template is used.
SET isused = 0;
SELECT count(TemplateID) INTO template_count FROM Template WHERE PowerBITemplateID=templateIDIN;

SELECT count(ReportID) INTO report_count FROM Report 
WHERE PowerBITemplateID=templateIDIN OR TilesProTemplateID=templateIDIN;
    
IF template_count <> 0 OR report_count <> 0 THEN
   SET isused = 1; 
END IF;

SELECT
    isused, 
    tl.TemplateID AS templateid, 
    tl.TemplateName AS templatename, 
    tl.ReportType AS reporttype,
		tl.Format AS format, 
    tl.Status AS status, 
    tl.ClientID AS clientid, 
    tl.Type AS type,
		tl.Userid AS userid,
		tl.Description AS description, 
    tl.FileUrl AS fileurl,
		tl.PowerBITemplateID AS powerbitemplateid, 
    tl.InsertDate AS insertdate, 
    tl.LastModifyDate AS lastmodifydate,
    cl.Status AS isdeactivated
		FROM Template tl LEFT JOIN Client cl
        ON tl.ClientID = cl.ClientID
		WHERE TemplateID =templateIDIN;
END $$

