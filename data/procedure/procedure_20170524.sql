#Generate a sql file every day. 
#The file name is
#   procedure_20170524.sql

#2017-05-24 14:51
#   Create procedure GetTemplateDetail
#   Create procedure GetParentClient
#   Create procedure DeleteTemplate

USE we_project;
#Get template detail include base column and isUsed
DROP PROCEDURE IF EXISTS GetTemplateDetail;
DROP PROCEDURE IF EXISTS GetParentClient;
DROP PROCEDURE IF EXISTS DeleteTemplate;

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
    isused, TemplateID AS templateid, TemplateName AS templatename, 
    ReportType AS reporttype,
		Format AS format, Status AS status, ClientID AS clientid, Type AS type,
		Userid AS userid,
		Description AS description, FileUrl AS fileurl,
		PowerBITemplateID AS powerbitemplateid, InsertDate AS insertdate, LastModifyDate AS
		lastmodifydate
		FROM Template
		WHERE TemplateID =templateIDIN;
END $$

DELIMITER $$

CREATE PROCEDURE `GetParentClient`(IN UidIN INT)
BEGIN
DECLARE returnCode INT;
DECLARE roleName VARCHAR(128);
DECLARE isMapDefault INT;
DECLARE t_error INTEGER DEFAULT 0;  
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;  
    SET SQL_SAFE_UPDATES=0; 
    START TRANSACTION;  
        
        SELECT role.RoleName INTO roleName  
            FROM Role role 
            LEFT JOIN User user
            ON user.RoleID = role.RoleID
            WHERE user.Userid = UidIN;
        IF roleName = 'AccountTeam'
        THEN
            SELECT client.ClientID id,client.ClientName name,
            client.Status AS isDeactivated,
            userClientMap.isDefault AS 'default' 
            FROM UserClientMap userClientMap 
            LEFT JOIN Client client 
            ON (userClientMap.ClientID = client.ClientID OR userClientMap.ClientID = client.ParentID )
            WHERE userClientMap.UserID = UidIN AND client.parentId = 0 
            ORDER BY(client.ClientName);
        ELSE 
            
            SELECT count(*) INTO isMapDefault FROM UserClientMap WHERE UserID = UidIN;
            IF isMapDefault = 0
            THEN
            
                SELECT client.ClientID id,client.ClientName name,
                        client.Status AS isDeactivated,
                        0 AS 'default' 
                    FROM Client client 
                    WHERE client.parentId = 0
                    ORDER BY(client.ClientName);
            ELSE
        
                SELECT client.ClientID id,client.ClientName name, 
                    client.Status AS isDeactivated,
                    CASE WHEN userClientMap.isDefault = NULL 
                    THEN 0 
                    WHEN userClientMap.isDefault = 1 
                    THEN 1 
                    ELSE 0 END AS 'default' 
                FROM Client client 
                LEFT JOIN UserClientMap userClientMap 
                ON (userClientMap.ClientID = client.ClientID OR userClientMap.ClientID = client.ParentID ) AND userClientMap.UserID = UidIN
                WHERE client.parentId = 0 
                ORDER BY(client.ClientName);
            END IF;
        END IF;
IF t_error = 1 THEN  
    ROLLBACK;  
    SET returnCode = 0;
ELSE  
    COMMIT;  
    SET returnCode = 1;
END IF;  
END $$

#If template is unused, delete template, return 1;
#If template is used, return -1;
#If an exception occurs while executing the procedure,return 500;
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

START TRANSACTION;

SELECT count(TemplateID) INTO template_count FROM Template WHERE PowerBITemplateID=templateIDIN;

SELECT count(ReportID) INTO report_count FROM Report 
WHERE PowerBITemplateID=templateIDIN OR TilesProTemplateID=templateIDIN;

IF template_count=0 AND report_count=0 THEN
    DELETE FROM Template WHERE TemplateID = templateIDIN;
END IF;

IF t_error = 1 THEN  
    ROLLBACK;  
    SET returnCode = 500;
ELSE  
    SET returnCode = (SELECT ROW_COUNT());
    COMMIT;      
END IF;  
SELECT returnCode;

END $$