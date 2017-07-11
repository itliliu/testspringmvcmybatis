delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `CompleteReport`(IN ProjectIDIN INT)
BEGIN
        DECLARE returnCode INT;
        DECLARE t_error INTEGER DEFAULT 0;  
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;  
            SET SQL_SAFE_UPDATES=0; 
            START TRANSACTION;  
                UPDATE ProjectBrief SET Status = 5,LastModifyDate=unix_timestamp(now()),
                       LastOperatorDate=unix_timestamp(now()) 
                WHERE (ParentID = ProjectIDIN OR ProjectBriefID = ProjectIDIN) AND Status > 0;
                
                UPDATE ProjectProposal SET Status = 5,LastModifyDate=unix_timestamp(now()),
                       LastOperatorDate=unix_timestamp(now()) 
                WHERE (ProjectBriefID = ProjectIDIN) AND Status > 0;
            
        IF t_error = 1 THEN  
            ROLLBACK;  
            SET returnCode = 0;
        ELSE  
            COMMIT;  
            SET returnCode = 1;
        END IF;  
        SELECT returnCode;
    END$$


delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `CreateReportFile`(IN ReportIDIN INT, TileProTemplateIDIN INT,
                IN PowerBITemplateIDIN INT, IN ReportUrlIN VARCHAR(128))
BEGIN
        DECLARE count INT;
        DECLARE returnCode INT;
        DECLARE t_error INTEGER DEFAULT 0;  
        DECLARE powerbitemplateUrlIN VARCHAR(128);
        DECLARE tilesprotemplateUrlIN VARCHAR(128);
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;  
            SET SQL_SAFE_UPDATES=0; 
            START TRANSACTION;  
               SELECT FileUrl INTO powerbitemplateUrlIN FROM Template 
               WHERE TemplateID = PowerBITemplateIDIN;
               
               SELECT FileUrl INTO tilesprotemplateUrlIN FROM Template 
               WHERE TemplateID = TileProTemplateIDIN;
               
               UPDATE ReportFile 
               SET PowerBITemplateUrl=powerbitemplateUrlIN, 
                   TilesProTemplateUrl=tilesprotemplateUrlIN,
                   LastModifyDate=unix_timestamp(now())
               WHERE ReportID=ReportIDIN;
               
               SELECT ROW_COUNT() INTO count;
            
               IF count=0 THEN
                    INSERT INTO ReportFile(ReportID, ReportFileUrl, PowerBITemplateUrl, TilesProTemplateUrl, 
                        Status, InsertDate, LastModifyDate)
                    VALUES(ReportIDIN, ReportUrlIN, powerbitemplateUrlIN, tilesprotemplateUrlIN,
                        1, unix_timestamp(now()), unix_timestamp(now()));
               END IF;
            
        IF t_error = 1 THEN  
            ROLLBACK;  
            SET returnCode = 0;
        ELSE  
            COMMIT;  
            SET returnCode = 1;
        END IF;  
        SELECT returnCode;
    END$$


delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `finalizeRequestForm`(IN id_in INT, IN start_date_in TIMESTAMP, 
    IN event_name_in VARCHAR(100), IN end_date_in TIMESTAMP,
    IN overview_in VARCHAR(500), IN content_in VARCHAR(4000), 
    IN version_in INT, IN status_in INT, IN qualifying_entities_in VARCHAR(500),
    IN sentiment_entities_in VARCHAR(500), IN outlet_entities_in VARCHAR(500), 
    IN additional_requirements_in VARCHAR(500), IN request_type_in VARCHAR(50), 
    IN request_Template_in VARCHAR(50), IN report_due_date_in TIMESTAMP, IN uid_in VARCHAR(10), IN parent_id INT, OUT returnCode INT)
BEGIN
        DECLARE returnCode INT;
        DECLARE t_error INTEGER DEFAULT 0;  
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;  
        
        START TRANSACTION;  
        
        UPDATE requestForm SET status = -1, lastmodifydate = now() WHERE id = id_in;
        INSERT INTO requestForm (`start_date`, `event_name`,
            `end_date`, `overview`, `content`,
            `qualifying_entities`, `sentiment_entities`, `outlet_entities`, `additional_requirements`,
            `request_type`, `request_Template`, `report_due_date`,
            `uid`, `version`, `status`, `parent_id`)
            VALUES (start_date_in, event_name_in, end_date_in, overview_in, content_in, qualifying_entities_in,
            sentiment_entities_in, outlet_entities_in, additional_requirements_in, request_type_in, 
            request_Template_in, report_due_date_in, uid_in, version + 1, 1, parent_id);
        
        IF t_error = 1 THEN  
            ROLLBACK;  
            SET returnCode = -1;
        ELSE  
            COMMIT;  
            SELECT LAST_INSERT_ID() INTO returnCode;
        END IF;  
        SELECT returnCode;
    END$$

delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `getAllProjectListAndPageNumber`(
IN uid INT(11),
IN clientID INT(11),
IN page_index INT
)
BEGIN
-- no use this procedure
DECLARE current_number INT;
DECLARE page_size INT;
SET page_index = 1;
SET page_size = 5;

IF (page_index - 1) * page_size <= 0 THEN
    SET current_number = 0;
ELSE 
    SET current_number = (page_index - 1) * page_size;
END IF;

SELECT COUNT(ProjectBriefID) AS total_page_number from ProjectBrief 
                            WHERE Uid = uid AND ClientID = clientID AND Status NOT IN(-1,-2);
SET @_sql='SELECT brief.ProjectBriefID,brief.ParentID,
CASE brief.Status WHEN 0 THEN brief.ProjectBriefName ELSE proposal.ProjectProposalName END AS Name,
brief.Status,client.ClientName,brief.Uid,
CASE brief.Status When 1 THEN proposal.`Comment` WHEN 3 THEN report.`Comment` ELSE null END AS `Comment` 
FROM ProjectBrief brief 
LEFT JOIN ProjectProposal proposal ON brief.ProjectBriefID = proposal.ProjectBriefID
LEFT JOIN Client client ON brief.ClientID = client.ClientID
LEFT JOIN Report report ON brief.ParentID = report.ProjectID
WHERE brief.Uid = ? AND brief.ClientID = ?
AND brief.Status NOT IN(-1,-2) ORDER BY brief.LastModifyDate
LIMIT ?,?';

prepare stmt FROM @_sql;
SET @current_number = current_number;
SET @page_size = page_size;
SET @uid= uid;
SET @clientID = clientID;
EXECUTE stmt USING @uid,@clientID,@current_number,@page_size;
DEALLOCATE PREPARE stmt;
END$$


delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `getInitWorkSpaceMenubar`(IN uid_in VARCHAR(10))
BEGIN
    DECLARE total INT;
    SELECT COUNT(id) INTO total FROM workspace WHERE uid = uid_in ORDER BY id DESC LIMIT 1, 5;
    IF total = 0
    THEN
        SELECT id, name, requestForm_id FROM workspace WHERE uid = uid_in ORDER BY id DESC LIMIT 1, 5;
    ELSE
        SELECT id, name, requestForm_id FROM workspace WHERE uid = uid_in ORDER BY id DESC LIMIT 1, 5;
        SELECT * from configuration where uid is null;
    END IF;
END$$


delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `GetParentClient`(IN UidIN INT)
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
                    SELECT client.ClientID id,client.ClientName name,userClientMap.isDefault AS 'default' 
                    FROM UserClientMap userClientMap 
                    LEFT JOIN Client client 
                    ON (userClientMap.ClientID = client.ClientID OR userClientMap.ClientID = client.ParentID )
                    WHERE userClientMap.UserID = UidIN AND client.parentId = 0 
                    ORDER BY(client.ClientName);
               ELSE 
                    
                    SELECT count(*) INTO isMapDefault FROM UserClientMap WHERE UserID = UidIN;
                    IF isMapDefault = 0
                    THEN
                  
                        SELECT client.ClientID id,client.ClientName name,0 AS 'default' 
                            FROM Client client 
                            WHERE client.parentId = 0
                            ORDER BY(client.ClientName);
                    ELSE
              
                        SELECT client.ClientID id,client.ClientName name, 
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
    END$$


delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `GetProjectBriefByUserIDAndPrimaryKey`(
    IN uid INT(11),
    IN briefID INT(11)
)
BEGIN

SELECT DISTINCT(brief.ProjectBriefID), brief.ProjectBriefName,
            brief.ObjectGuidingPrinciple,
            brief.CommunicationObjective,brief.BusinessObjective,
            brief.Outcomes,
            brief.Context, brief.TargetAudience,
            brief.CreateInsporation,
            brief.ProjectType,
            brief.ProjectLeads,
            brief.ProjectID,
            brief.Deliverable,
            brief.ScheduleTimeline, brief.AnnouncementType,
            brief.KeyMessage,
            brief.AdditionalContent,
            brief.USOnlyOrGlobalMetrics,
            brief.SearchTerms, brief.AnyAdditionalData,
            brief.RequestedBy, brief.Status, brief.Version,brief.ParentID,
            brief.UserID,
            brief.ClientID,proposal.ProjectProposalID,
            proposal.ParentID AS ProposalParentID,
            proposal.ProjectProposalName
FROM ProjectBrief brief
LEFT JOIN ProjectProposal proposal
            ON brief.ParentID = proposal.ProjectBriefID
            OR brief.ProjectBriefID = proposal.ProjectBriefID
WHERE brief.ProjectBriefID=briefID
    AND brief.Status>=0 AND(proposal.Status>0 OR proposal.Status IS NULL);
        
END$$


delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `GetProjectListByStatusOrKeyword`(
    IN uid INT(11),
    IN statusIN INT(11),
    IN clientIDIN INT(11),
    IN keyword VARCHAR(250),
    IN pageIndex INT(11),
    IN pageSize INT(11)
)
BEGIN
DECLARE current_number INT;
SET current_number = (pageIndex -1)*pageSize;
SET @currentNumber = current_number;
SET @pageSize = pageSize;


DROP TEMPORARY TABLE IF EXISTS tmp_Client;
CREATE TEMPORARY TABLE tmp_Client (
      ClientID INT(11) NOT NULL, 
      ClientName VARCHAR(128) NOT NULL,
      ParentID INT(11) DEFAULT NULL
);

SET @roleID = (SELECT RoleID FROM User WHERE UserID=uid);
IF @roleID=1 THEN -- AccountTeam
    IF clientIDIN = -1 THEN
        INSERT INTO tmp_Client(SELECT Client.ClientID,Client.ClientName,Client.ParentID 
                FROM Client LEFT JOIN UserClientMap ucm on Client.ClientID=ucm.ClientID 
                WHERE ucm.UserID=uid);
    ELSE 
        INSERT INTO tmp_Client(SELECT Client.ClientID,Client.ClientName,Client.ParentID 
                FROM Client LEFT JOIN UserClientMap ucm ON Client.ClientID=ucm.ClientID 
                WHERE ucm.UserID=uid 
                AND (Client.ClientID=clientIDIN OR Client.ParentID=clientIDIN));
    END IF;
ELSE
    IF clientIDIN = -1 THEN
        INSERT INTO tmp_Client(SELECT ClientID,ClientName,ParentID 
                FROM Client);
    ELSE 
        INSERT INTO tmp_Client(SELECT ClientID,ClientName,ParentID 
                FROM Client
                WHERE ClientID=clientIDIN OR Client.ParentID=clientIDIN);
    END IF;
END IF;

SET @_sql = 'FROM ProjectBrief brief LEFT JOIN ProjectProposal proposal 
            ON brief.ParentID = proposal.ProjectBriefID 
                OR brief.ProjectBriefID = proposal.ProjectBriefID
            LEFT JOIN tmp_Client client on brief.ClientID = client.ClientID
            LEFT JOIN Report report ON (brief.ParentID = report.ProjectID OR brief.ProjectBriefID = report.ProjectID)
            WHERE client.ClientID IS NOT NULL ';

IF clientIDIN <> -1 THEN
    SET @_sql=CONCAT(@_sql,'AND (brief.ClientID=',clientIDIN,
            ' OR client.ParentID=',clientIDIN,') ');
END IF;

-- statusIn = -1, get all status
IF statusIN = -1 THEN
    SET @_sql=CONCAT(@_sql,'AND brief.Status>=0 AND (proposal.Status>0 OR proposal.Status is null) ');
ELSE
    SET @_sql=CONCAT(@_sql,'AND brief.Status=',statusIN,' AND (proposal.Status>0 OR proposal.Status is null) ');
END IF;

SET @keyword = IFNULL(keyword,'');
IF LENGTH(keyword) > 0 THEN
    SET @_sql=CONCAT(@_sql,'AND ((CASE ISNULL(brief.ParentID) WHEN 1 THEN brief.ProjectBriefID like \'',keyword,'\'',
                ' ELSE brief.ParentID like \'',keyword,'\' END)',
                ' OR (brief.Status=0 AND brief.ProjectBriefName like \'%',keyword,'%\')'
                ' OR (brief.Status > 0 AND CASE ISNULL(proposal.ProjectProposalName) 
                WHEN 0 THEN proposal.ProjectProposalName ELSE brief.ProjectBriefName END like \'%',keyword,'%\')'
                ' OR client.ClientName like \'%',keyword,'%\')');
END IF;

SET @_sql = CONCAT(@_sql,' ORDER BY brief.LastModifyDate DESC');

SET @sql_count = CONCAT('SELECT COUNT(DISTINCT(brief.ProjectBriefID)) AS total_page_number ',@_sql);

PREPARE stmt FROM @sql_count;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql_select=CONCAT('SELECT DISTINCT(brief.ProjectBriefID),brief.ParentID,
CASE brief.Status 
    WHEN 0 THEN brief.ProjectBriefName 
    ELSE 
      CASE LENGTH(IFNULL(proposal.ProjectProposalName,\'\'))
        WHEN 0 THEN brief.ProjectBriefName 
        ELSE proposal.ProjectProposalName
      END
END AS Name,brief.Status,client.ClientName,brief.UserID,
CASE brief.Status 
WHEN 1 THEN proposal.`Comment` 
WHEN 3 THEN report.`Comment` 
ELSE \'\' END AS `Comment` ',@_sql,' LIMIT ?,?');

PREPARE stmt FROM @sql_select;
EXECUTE stmt USING @currentNumber,@pageSize;
DEALLOCATE PREPARE stmt;

END$$



delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `getRecentlyReportConsoleWorkSpace`(IN uid_in VARCHAR(10))
BEGIN
    
    SELECT id, name, requestForm_id FROM workspace WHERE uid = uid_in;
    SELECT id, parent_id, status, event_name FROM requestForm WHERE uid = uid_in AND status >= 0;
    SELECT id, name from configuration WHERE uid = uid_in;

END$$

delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `GetRecentProject`(IN UidIN INT, IN ClientIDIN INT)
BEGIN
        DECLARE returnCode INT;
        DECLARE roleName VARCHAR(128);
        DECLARE updateRowSize INT;
        DECLARE t_error INTEGER DEFAULT 0;  
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;  
            SET SQL_SAFE_UPDATES=0; 
            START TRANSACTION;  
                
              
              SELECT role.RoleName INTO roleName  
                    FROM Role role 
                    LEFT JOIN User user
                    ON user.RoleID = role.RoleID
                    WHERE user.UserID = UidIN;
              
              IF roleName = 'AccountTeam'
              THEN
                
                IF ClientIDIN = -1
                THEN
                    SELECT pb.ProjectBriefID id,pb.ParentID parentId,pb.Userid userid,
                        IFNULL(pp.ProjectProposalName,pb.ProjectBriefName) AS 'name',
                        pb.`Status` AS 'status' ,
                        client.ClientName AS 'client' 
                    FROM (ProjectBrief pb LEFT JOIN ProjectProposal pp
                          ON pp.ProjectBriefID=pb.ProjectBriefID 
                            OR pp.ProjectBriefID=pb.ParentID) 
                    LEFT JOIN (SELECT Client.ClientID,Client.ClientName,Client.ParentID 
                               FROM Client LEFT JOIN UserClientMap ucm 
                               on Client.ClientID=ucm.ClientID 
                               WHERE ucm.UserID=UidIN) client
                    ON pb.ClientID = client.ClientID
                    WHERE client.ClientID IS NOT NULL AND pb.status >= 0 AND (pp.Status >0 OR pp.Status IS NULL)
                    ORDER BY pb.LastOperatorDate DESC limit 5;
                ELSE
                    SELECT pb.ProjectBriefID id,pb.ParentID parentId,pb.Userid userid,
                            IFNULL(pp.ProjectProposalName,pb.ProjectBriefName) AS 'name',
                            pb.`Status` AS 'status' ,
                            client.ClientName AS 'client' 
                        FROM (ProjectBrief pb LEFT JOIN ProjectProposal pp
                        ON pp.ProjectBriefID = pb.ProjectBriefID 
                            OR pp.ProjectBriefID=pb.ParentID) 
                        LEFT JOIN (SELECT Client.ClientID,Client.ClientName,Client.ParentID 
                               FROM Client LEFT JOIN UserClientMap ucm 
                               on Client.ClientID=ucm.ClientID 
                               WHERE ucm.UserID=UidIN
                                AND (Client.ClientID=ClientIDIN OR Client.ParentID=ClientIDIN)) client
                        ON pb.ClientID = client.ClientID
                        WHERE (pb.ClientID=ClientIDIN OR pb.ClientID=ClientIDIN)
                            AND pb.status >= 0 AND (pp.Status >0 OR pp.Status IS NULL)
                        ORDER BY pb.LastOperatorDate DESC
                        limit 5;
                END IF;
                
              ELSE
                
                IF ClientIDIN = -1
                THEN
                    SELECT pb.ProjectBriefID id,pb.ParentID parentId,pb.Userid userid,
                        IFNULL(pp.ProjectProposalName,pb.ProjectBriefName) AS 'name',
                        pb.`Status` AS 'status' ,
                        Client.ClientName AS 'client' 
                    FROM (ProjectBrief pb LEFT JOIN ProjectProposal pp
                          ON pp.ProjectBriefID = pb.ProjectBriefID 
                          OR pp.ProjectBriefID = pb.ParentID) 
                    LEFT JOIN Client 
                    ON pb.ClientID = Client.ClientID
                    WHERE pb.status >= 0 AND (pp.Status >0 OR pp.Status IS NULL)
                    ORDER BY pb.LastOperatorDate DESC limit 5;
                ELSE
                    SELECT pb.ProjectBriefID id,pb.ParentID parentId,pb.Userid userid,
                            IFNULL(pp.ProjectProposalName,pb.ProjectBriefName) AS 'name',
                            pb.`Status` AS 'status' ,
                            Client.ClientName AS 'client' 
                    FROM (ProjectBrief pb LEFT JOIN ProjectProposal pp
                          ON pp.ProjectBriefID = pb.ProjectBriefID OR pp.ProjectBriefID = pb.ParentID) 
                    LEFT JOIN Client 
                    ON pb.ClientID = Client.ClientID
                    WHERE (pb.ClientID=ClientIDIN OR Client.ParentID=ClientIDIN) 
                        AND pb.status >= 0 AND (pp.Status >0 OR pp.Status IS NULL)
                        ORDER BY pb.LastOperatorDate DESC
                        limit 5;
                END IF;
                
              END IF;
              
              
              
        IF t_error = 1 THEN  
            ROLLBACK;  
            SET returnCode = 0;
        ELSE  
            COMMIT;  
            SET returnCode = 1;
        END IF;  
    END$$


delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `GetRecentTemplate`(IN UidIN INT, IN ClientIDIN INT, IN TypeIN VARCHAR(128))
BEGIN
       DECLARE returnCode INT;
        
        DECLARE updateRowSize INT;
        DECLARE roleName VARCHAR(128);
        DECLARE t_error INTEGER DEFAULT 0;  
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;  
        SET SQL_SAFE_UPDATES=0; 
        START TRANSACTION;  
                
                
        SELECT role.RoleName INTO roleName  
            FROM Role role 
            LEFT JOIN User user
            ON user.RoleID = role.RoleID
            WHERE user.UserID = UidIN;
                
        IF roleName = 'AccountTeam'
        THEN         
            IF TypeIN = 'public'
            THEN
                IF ClientIDIN = -1
                THEN
                    SELECT template.TemplateID id, template.userid userid, template.TemplateName name,
                           client.ClientName client
                    FROM Template template 
                    LEFT JOIN Client client 
                    ON template.ClientID = client.ClientID
                    WHERE template.userid != UidIN
                        AND template.ClientID IN (
                            SELECT c.ClientID FROM Client c
                            LEFT JOIN UserClientMap usm
                            ON usm.ClientID = c.ClientID
                            WHERE usm.UserId = UidIN)
                            ORDER BY(template.LastModifyDate) DESC
                            LIMIT 5;
                ELSE
                    SELECT template.TemplateID id, template.userid userid, template.TemplateName name,
                            client.ClientName client
                    FROM Template template 
                    LEFT JOIN Client client 
                    ON template.ClientID = client.ClientID
                    WHERE (template.userid != UidIN AND client.ClientID = ClientIDIN) 
                    OR (template.userid != UidIN AND client.ParentID = ClientIDIN)
                    ORDER BY(template.LastModifyDate) DESC
                    LIMIT 5;
                END IF;
            ELSE
                IF ClientIDIN = -1
                THEN
                    SELECT template.TemplateID id, template.userid userid, template.TemplateName name,
                            client.ClientName client
                    FROM Template template 
                    LEFT JOIN Client client 
                    ON template.ClientID= client.ClientID 
                    WHERE template.userid = UidIN 
                    ORDER BY(template.LastModifyDate) DESC
                    LIMIT 5;
                ELSE 
                    SELECT template.TemplateID id, template.userid userid, template.TemplateName name,
                            client.ClientName client
                    FROM Template template 
                    LEFT JOIN Client client 
                    ON template.ClientID = client.ClientID
                    WHERE (template.userid = UidIN AND client.ClientID = ClientIDIN) 
                        OR (template.userid = UidIN AND client.ParentID = ClientIDIN)
                    ORDER BY(template.LastModifyDate) DESC
                    LIMIT 5;
                END IF;
            END IF;
        ELSE
            IF TypeIN = 'public'
            THEN
                IF ClientIDIN = -1
                    THEN
                    SELECT template.TemplateID id, template.userid userid, template.TemplateName name,
                            client.ClientName client
                    FROM Template template 
                    LEFT JOIN Client client 
                    ON template.ClientID = client.ClientID
                    WHERE template.userid != UidIN                                    
                    ORDER BY(template.LastModifyDate) DESC
                    LIMIT 5;
                ELSE
                    SELECT template.TemplateID id, template.userid userid, template.TemplateName name,
                            client.ClientName client
                    FROM Template template 
                    LEFT JOIN Client client 
                    ON template.ClientID = client.ClientID
                    WHERE (template.userid != UidIN AND client.ClientID = ClientIDIN) 
                    OR (template.userid != UidIN AND client.ParentID = ClientIDIN)
                    ORDER BY(template.LastModifyDate) DESC
                    LIMIT 5;
                END IF;
            ELSE
                IF ClientIDIN = -1 
                THEN
                    SELECT template.TemplateID id, template.userid userid, template.TemplateName name,
                            client.ClientName client
                    FROM Template template 
                    LEFT JOIN Client client 
                    ON template.ClientID= client.ClientID 
                    WHERE template.userid = UidIN 
                    ORDER BY(template.LastModifyDate) DESC
                    LIMIT 5;
                ELSE 
                    SELECT template.TemplateID id, template.userid userid, template.TemplateName name,
                            client.ClientName client
                    FROM Template template 
                    LEFT JOIN Client client 
                    ON template.ClientID = client.ClientID
                    WHERE (template.userid = UidIN AND client.ClientID = ClientIDIN) 
                        OR (template.userid = UidIN AND client.ParentID = ClientIDIN)
                    ORDER BY(template.LastModifyDate) DESC
                    LIMIT 5;
                END IF;
            END IF;
        END IF;
        IF t_error = 1 THEN  
            ROLLBACK;  
            SET returnCode = 0;
        ELSE  
            COMMIT;  
            SET returnCode = 1;
        END IF;  
    END$$



delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `getRequestForm`(IN uid VARCHAR(10), IN pageIndex INT, IN pageSize INT, IN status_in INT)
BEGIN
        DECLARE current_number INT;
        SET current_number = (pageIndex - 1) * pageSize;
        IF status_in = -1
        THEN
          
            PREPARE getRFSQLSentence FROM '
            SELECT
                requestFromTable.id as id,
                requestFromTable.uid,
                requestFromTable.start_date,
                requestFromTable.event_name,
                requestFromTable.end_date,
                requestFromTable.overview,
                requestFromTable.content,
                requestFromTable.version,
                requestFromTable.status,
                requestFromTable.qualifying_entities,
                requestFromTable.sentiment_entities,
                requestFromTable.outlet_entities,
                requestFromTable.additional_requirements,
                requestFromTable.request_type,
                requestFromTable.request_Template,
                requestFromTable.report_due_date,
                requestFromTable.parent_id,
                workspacetable.id as reportid
            FROM requestForm as requestFromTable LEFT JOIN workspace as workspacetable on
            requestFromTable.id = workspacetable.requestForm_id 
            WHERE requestFromTable.uid = ? and requestFromTable.status >= 0  
            ORDER BY requestFromTable.lastmodifydate DESC LIMIT ?, ?';
            SET @uid = uid;
            SET @start = current_number;
            SET @number = pageSize;
            EXECUTE getRFSQLSentence USING @uid, @start, @number;
            DEALLOCATE PREPARE getRFSQLSentence;    
        ELSE
            PREPARE getRFSQLSentence FROM '
            SELECT
                requestFromTable.id as id,
                requestFromTable.uid,
                requestFromTable.start_date,
                requestFromTable.event_name,
                requestFromTable.end_date,
                requestFromTable.overview,
                requestFromTable.content,
                requestFromTable.version,
                requestFromTable.status,
                requestFromTable.qualifying_entities,
                requestFromTable.sentiment_entities,
                requestFromTable.outlet_entities,
                requestFromTable.additional_requirements,
                requestFromTable.request_type,
                requestFromTable.request_Template,
                requestFromTable.report_due_date,
                requestFromTable.parent_id,
                workspacetable.id as reportid
            FROM requestForm as requestFromTable LEFT JOIN workspace as workspacetable on
            requestFromTable.id = workspacetable.requestForm_id 
            WHERE requestFromTable.uid = ? and requestFromTable.status = ?
            ORDER BY requestFromTable.lastmodifydate DESC LIMIT ?, ?';
            SET @uid = uid;
            SET @status = status_in;
            SET @start = current_number;
            SET @number = pageSize;
            EXECUTE getRFSQLSentence USING @uid, @status, @start, @number;
            DEALLOCATE PREPARE getRFSQLSentence;    
        END IF;
    END$$




delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `getTotalRequestForm`(IN uid VARCHAR(10), IN status_in INT, IN keyword_in VARCHAR(100))
BEGIN
        IF status_in = -1
        THEN
            IF keyword_in = ''
            THEN
                PREPARE getRFSQLSentence FROM '
                SELECT
                    COUNT(*)
                FROM `we_project`.`requestForm` WHERE uid = ? and status >= 0';
                SET @uid = uid;
                EXECUTE getRFSQLSentence USING @uid;
                DEALLOCATE PREPARE getRFSQLSentence;
            ELSE
                
                PREPARE getRFSQLSentence FROM '
                SELECT
                    COUNT(*)
                FROM `we_project`.`requestForm` WHERE uid = ? and status >= 0 and (id = ? or event_name = ?)';
                SET @uid = uid;
                SET @keyword = keyword_in;
                EXECUTE getRFSQLSentence USING @uid, @keyword, @keyword;
                DEALLOCATE PREPARE getRFSQLSentence;
            END IF;
            
               
        ELSE
            IF keyword_in = ''
            THEN
                PREPARE getRFSQLSentence FROM '
                SELECT
                    COUNT(*)
                FROM `we_project`.`requestForm` WHERE uid = ? AND status = ?';
                SET @uid = uid;
                SET @status = status_in;
                EXECUTE getRFSQLSentence USING @uid, @status;
                DEALLOCATE PREPARE getRFSQLSentence; 
            ELSE
                PREPARE getRFSQLSentence FROM '
                SELECT
                    COUNT(*)
                FROM `we_project`.`requestForm` WHERE uid = ? AND status = ? and (id = ? or event_name = ?)';
                SET @uid = uid;
                SET @status = status_in;
                EXECUTE getRFSQLSentence USING @uid, @status, @keyword, @keyword;
                DEALLOCATE PREPARE getRFSQLSentence; 
            END IF;
               
        END IF;
    END$$



delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `InsertClient`(IN ClientNameIN VARCHAR(128), IN LogoIN VARCHAR(128), IN ParentIDIN INT)
BEGIN
        DECLARE returnCode INT;
        DECLARE isReladyExists INT;
        DECLARE t_error INTEGER DEFAULT 0;  
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;  
            SET SQL_SAFE_UPDATES=0; 
            START TRANSACTION;  
            IF ParentIDIN = 0
            THEN
                SELECT count(*) INTO isReladyExists FROM Client WHERE ClientName = ClientNameIN AND ParentID = 0;
            ELSE
                SELECT count(*) INTO isReladyExists FROM Client WHERE ClientName = ClientNameIN AND ParentID = ParentIDIN;
            END IF;
           
            IF isReladyExists = 0
            THEN
                INSERT INTO Client(ClientName, Logo, InsertDate, LastModifyDate, ParentID) values(ClientNameIN, LogoIN, unix_timestamp(now()), unix_timestamp(now()), ParentIDIN);
                
            END IF;
            
            
        IF t_error = 1 THEN  
            ROLLBACK;  
            SET returnCode = 0;
        ELSE  
            COMMIT; 
            IF isReladyExists = 0
            THEN
                SET returnCode = (SELECT LAST_INSERT_ID()); 
            ELSE
                SET returnCode = -1;
            END IF;
            
        END IF;  
        SELECT returnCode;
    END$$



delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `RejectReport`(IN ProjectIDIN INT, IN CommentIN VARCHAR(1024))
BEGIN
        DECLARE returnCode INT;
        DECLARE t_error INTEGER DEFAULT 0;  
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;  
            SET SQL_SAFE_UPDATES=0; 
            START TRANSACTION;  
                UPDATE Report SET `Comment` = CommentIN,LastModifyDate=unix_timestamp(now())
                WHERE ProjectID = ProjectIDIN;
                
                UPDATE ProjectBrief SET Status = 3,LastModifyDate=unix_timestamp(now()),
                       LastOperatorDate=unix_timestamp(now())
                WHERE (ParentID = ProjectIDIN OR ProjectBriefID = ProjectIDIN) AND Status > 0;
                
                UPDATE ProjectProposal SET Status = 3,LastModifyDate=unix_timestamp(now()),
  		                 LastOperatorDate=unix_timestamp(now()) 
                WHERE (ParentID = ProjectIDIN OR ProjectProposalID = ProjectIDIN) AND Status > 0;
            
        IF t_error = 1 THEN  
            ROLLBACK;  
            SET returnCode = 0;
        ELSE  
            COMMIT;  
            SET returnCode = 1;
        END IF;  
        SELECT returnCode;
    END$$


delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `saveOrUpdateWorkspace`(IN uid_in VARCHAR(10), IN configurationContent_in VARCHAR(4000), IN name_in VARCHAR(100),
    IN requestFormId_in INT)
BEGIN
        DECLARE count INT;
        DECLARE returnCode INT;
        
        DECLARE t_error INTEGER DEFAULT 0;  
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;  
        
            START TRANSACTION;  
            UPDATE workspace SET configuration_content = configurationContent_in, name = name_in, lastmodifydate = now() WHERE requestForm_id = requestFormId_in and uid = uid_in;
            SELECT ROW_COUNT() INTO count;
            
            IF count = 0
            THEN
                INSERT INTO workspace(uid, configuration_content, name, requestForm_id, lastmodifydate)
                    VALUES(uid_in, configurationContent_in, name_in, requestFormId_in, now());
          
            END IF;
        IF t_error = 1 THEN  
            ROLLBACK;  
            SET returnCode = 0;
        ELSE  
            COMMIT;  
            SET returnCode = 1;
        END IF;  
        SELECT returnCode;
    END$$


delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `SaveProjectBrief`(
    IN briefID INT(11),
IN projectBriefName VARCHAR(1024),
IN objectGuidingPrinciple VARCHAR(1024),
IN communicationObjective VARCHAR(1024),
IN businessObjective VARCHAR(1024),
IN outcomes VARCHAR(1024),
IN context VARCHAR(1024),
IN targetAudience VARCHAR(1024),
IN createInsporation VARCHAR(1024),
IN projectType VARCHAR(1024),
IN projectLeads VARCHAR(1024),
IN projectID VARCHAR(1024),
IN deliverable VARCHAR(1024),
IN scheduleTimeline VARCHAR(1024),
IN announcementType VARCHAR(1024),
IN keyMessage VARCHAR(1024),
IN additionalContent VARCHAR(1024),
IN uSOnlyOrGlobalMetrics VARCHAR(1024),
IN searchTerms VARCHAR(1024),
IN anyAdditionalData VARCHAR(1024),
IN requestedBy VARCHAR(1024),
IN parentIDIN INT(11),
IN useridIN INT(11),
IN clientID INT(11)
)
BEGIN
DECLARE returnCode INT;
DECLARE old_version INT;
DECLARE t_error INTEGER DEFAULT 0;  
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;
SET @requestedBy = (SELECT UserName FROM User where UserID= useridIN);
START TRANSACTION;  
IF briefID IS NULL THEN
INSERT INTO ProjectBrief(ProjectBriefName,ObjectGuidingPrinciple ,
 CommunicationObjective,BusinessObjective,Outcomes,Context,TargetAudience,CreateInsporation,ProjectType,
 ProjectLeads,ProjectID,Deliverable,ScheduleTimeline,AnnouncementType,
 KeyMessage,AdditionalContent,USOnlyOrGlobalMetrics,SearchTerms,AnyAdditionalData,Status,
 RequestedBy,InsertDate,LastModifyDate,
 ParentID,UserID,ClientID,LastOperatorDate) VALUES (projectBriefName,objectGuidingPrinciple,
 communicationObjective,businessObjective,outcomes,context,targetAudience,createInsporation,projectType,
 projectLeads,projectID,deliverable,scheduleTimeline,announcementType,
 keyMessage,additionalContent,uSOnlyOrGlobalMetrics,searchTerms,AnyAdditionalData,0,
 @requestedBy,unix_timestamp(now()),unix_timestamp(now()),
 parentIDIN,useridIN,clientID,unix_timestamp(now()));
 
ELSE
SET @_sql = 'UPDATE ProjectBrief SET Status = -1 WHERE (ProjectBriefID = ? OR ParentID=?) and Status = 0';
SET @briefID = briefID;
PREPARE stmt FROM @_sql;
EXECUTE stmt USING @briefID,@briefID;
DEALLOCATE PREPARE stmt;

SET old_version = (SELECT COUNT(Version) FROM ProjectBrief WHERE (ProjectBriefID = parentIDIN OR ParentID =parentIDIN));

INSERT INTO ProjectBrief(ProjectBriefName,ObjectGuidingPrinciple ,
 CommunicationObjective,BusinessObjective,Outcomes,Context,TargetAudience,CreateInsporation,ProjectType,
 ProjectLeads,ProjectID,Deliverable,ScheduleTimeline,AnnouncementType,
 KeyMessage,AdditionalContent,USOnlyOrGlobalMetrics,SearchTerms,AnyAdditionalData,Status,
 RequestedBy,Version,InsertDate,LastModifyDate,
 ParentID,UserID,ClientID,LastOperatorDate) VALUES (projectBriefName,objectGuidingPrinciple ,
 communicationObjective,businessObjective,outcomes,context,targetAudience,createInsporation,projectType,
 projectLeads,projectID,deliverable,scheduleTimeline,announcementType,
 keyMessage,additionalContent,uSOnlyOrGlobalMetrics,searchTerms,AnyAdditionalData,0,
 @requestedBy,old_version + 1,unix_timestamp(now()),unix_timestamp(now()) ,
 parentIDIN,useridIN,clientID,unix_timestamp(now()) );
END IF;

IF t_error = 1 THEN  
            ROLLBACK;  
            SET returnCode = 0;
        ELSE  
            COMMIT;  
            SET returnCode = (SELECT LAST_INSERT_ID());
        END IF;  
        SELECT returnCode;

END$$



delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `SaveProjectProposal`(
IN proposalID INT(11), 
IN projectProposalName VARCHAR(256),
IN situation VARCHAR(1024), 
IN objective VARCHAR(1024), 
IN approach VARCHAR(1024), 
IN deliverables VARCHAR(1024), 
IN pricing VARCHAR(1024), 
IN timelineMilestones VARCHAR(1024),
IN contact VARCHAR(1024),
IN pro_comment VARCHAR(1024),
IN parentID INT(11),  
IN projectBriefIDIN INT(11), 
IN userid INT(11), 
IN clientID INT(11)
)
BEGIN
DECLARE returnCode INT;
DECLARE old_version INT;
DECLARE t_error INTEGER DEFAULT 0;  
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;
SET @briefID = projectBriefIDIN;

START TRANSACTION;  
IF proposalID IS NULL THEN
INSERT INTO ProjectProposal(ProjectProposalName, Situation, Objective, Approach, Deliverables, 
    Pricing, TimelineMilestones, Contact, `Comment`, ParentID, ProjectBriefID, Status,
    InsertDate, LastModifyDate, UserID, ClientID, LastOperatorDate) VALUES (projectProposalName,
    situation, objective, approach, deliverables, 
    pricing, timelineMilestones, contact, pro_comment, parentID, projectBriefIDIN,1, 
    unix_timestamp(now()), unix_timestamp(now()) , userid, clientID, unix_timestamp(now()) );
ELSE
SET @_sql = 'UPDATE ProjectProposal SET Status = -1 WHERE (ProjectBriefID=?) AND Status > 0 ';
PREPARE stmt FROM @_sql;
EXECUTE stmt USING @briefID;
DEALLOCATE PREPARE stmt;

SET old_version = (SELECT COUNT(Version) FROM ProjectProposal 
                            WHERE ProjectBriefID= projectBriefIDIN);
INSERT INTO ProjectProposal(ProjectProposalName, Situation, Objective, Approach, Deliverables, 
    Pricing, TimelineMilestones, Contact, Version, `Comment`, ParentID, ProjectBriefID, Status,
    InsertDate, LastModifyDate, UserID, ClientID, LastOperatorDate) VALUES (projectProposalName,
    situation, objective, approach, deliverables, 
    pricing, timelineMilestones, contact, old_version + 1, pro_comment, parentID, projectBriefIDIN, 1,
    unix_timestamp(now()), unix_timestamp(now()) , userid, clientID, unix_timestamp(now()) );
END IF;

SET @_sql = 'UPDATE ProjectBrief SET LastOperatorDate=unix_timestamp(now()),
                        LastModifyDate=unix_timestamp(now()) 
                    WHERE (ProjectBriefID=? OR ParentID=?) AND Status > 0 ';
PREPARE stmt FROM @_sql;
EXECUTE stmt USING @briefID,@briefID;
DEALLOCATE PREPARE stmt;


SET @new_proposal_id = (SELECT LAST_INSERT_ID());

IF t_error = 1 THEN  
            ROLLBACK;  
            SET returnCode = 0;
        ELSE  
            COMMIT;  
            SELECT @new_proposal_id INTO returnCode;
        END IF;  
        SELECT returnCode;
END$$



delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `searchRequestForm`(IN uid VARCHAR(10), IN pageIndex INT, IN pageSize INT, IN status_in INT, IN keyword VARCHAR(1000))
BEGIN
        DECLARE current_number INT;
        DECLARE keyword_in VARCHAR(1000);
        SET current_number = (pageIndex - 1) * pageSize;
        SET keyword_in = concat('%',keyword,'%');
        IF status_in = -1
        THEN
            PREPARE getRFSQLSentence FROM '
            SELECT
                `requestForm`.`id`,
                `requestForm`.`uid`,
                `requestForm`.`start_date`,
                `requestForm`.`event_name`,
                `requestForm`.`end_date`,
                `requestForm`.`overview`,
                `requestForm`.`content`,
                `requestForm`.`version`,
                `requestForm`.`status`,
                `requestForm`.`qualifying_entities`,
                `requestForm`.`sentiment_entities`,
                `requestForm`.`outlet_entities`,
                `requestForm`.`additional_requirements`,
                `requestForm`.`request_type`,
                `requestForm`.`request_Template`,
                `requestForm`.`report_due_date`,
                 `requestForm`.`parent_id`
            FROM `we_project`.`requestForm` WHERE uid = ? AND status >= 0 AND (((parent_id is null AND id like ?) OR event_name like ?)  OR ((parent_id is not null AND parent_id like ?) OR event_name like ?))
            ORDER BY lastmodifydate DESC LIMIT ?, ?';
            SET @uid = uid;
            SET @start = current_number;
            SET @number = pageSize;
            SET @keyword = keyword_in;
            EXECUTE getRFSQLSentence USING @uid, @keyword, @keyword, @keyword, @keyword, @start, @number;
            DEALLOCATE PREPARE getRFSQLSentence;    
        ELSE
            PREPARE getRFSQLSentence FROM '
            SELECT
                `requestForm`.`id`,
                `requestForm`.`uid`,
                `requestForm`.`start_date`,
                `requestForm`.`event_name`,
                `requestForm`.`end_date`,
                `requestForm`.`overview`,
                `requestForm`.`content`,
                `requestForm`.`version`,
                `requestForm`.`status`,
                `requestForm`.`qualifying_entities`,
                `requestForm`.`sentiment_entities`,
                `requestForm`.`outlet_entities`,
                `requestForm`.`additional_requirements`,
                `requestForm`.`request_type`,
                `requestForm`.`request_Template`,
                `requestForm`.`report_due_date`,
                 `requestForm`.`parent_id`
            FROM `we_project`.`requestForm` WHERE uid = ? AND status = ? AND (((parent_id is null AND id like ?) OR event_name like ?)  OR ((parent_id is not null AND parent_id like ?) OR event_name like ?))
            ORDER BY lastmodifydate DESC LIMIT ?, ?';
            SET @uid = uid;
            SET @status = status_in;
            SET @start = current_number;
            SET @number = pageSize;
            SET @keyword = keyword_in;
            EXECUTE getRFSQLSentence USING @uid, @status, @keyword, @keyword,@keyword, @keyword, @start, @number;
            DEALLOCATE PREPARE getRFSQLSentence;    
        END IF;
    END$$


delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `SetDefaultClient`(IN UidIN INT, IN ClientIDIN INT)
BEGIN
        DECLARE returnCode INT;
        DECLARE roleName VARCHAR(128);
        DECLARE updateRowSize INT;
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
                    UPDATE UserClientMap SET IsDefault = 0 WHERE UserID = UidIN;
										IF ClientIDIN <> -1
										THEN 
											UPDATE UserClientMap SET IsDefault = 1 WHERE UserID = UidIN AND ClientID = ClientIDIN;
										END IF;
                    SELECT ROW_COUNT() INTO updateRowSize;
                    IF updateRowSize = 0
                    THEN
                        INSERT INTO UserClientMap(ClientID, UserID, ISDefault, InsertDate, LastModifyDate) 
                            VALUES(ClientIDIN, UidIN, 1, current_timestamp(), current_timestamp());
                    END IF;
               ELSE 
										IF ClientIDIN = -1
										THEN 
											 UPDATE UserClientMap SET IsDefault = 0 WHERE UserID = UidIN;
										ELSE
											UPDATE UserClientMap SET IsDefault = 1, ClientID = ClientIDIN WHERE UserID = UidIN;
                    END IF;
										SELECT ROW_COUNT() INTO updateRowSize;
                    IF updateRowSize = 0
                    THEN
                        INSERT INTO UserClientMap(ClientID, UserID, ISDefault, InsertDate, LastModifyDate) 
                            VALUES(ClientIDIN, UidIN, 1, current_timestamp(), current_timestamp());
                    END IF;
                    
               END IF;
        IF t_error = 1 THEN  
            ROLLBACK;  
            SET returnCode = 0;
        ELSE  
            COMMIT;  
            SET returnCode = 1;
        END IF;  
        SELECT returnCode;
    END$$


delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `SubmitProjectBrief`(
IN briefID INT(11),
IN projectBriefName VARCHAR(1024),
IN objectGuidingPrinciple VARCHAR(1024),
IN communicationObjective VARCHAR(1024),
IN businessObjective VARCHAR(1024),
IN outcomes VARCHAR(1024),
IN context VARCHAR(1024),
IN targetAudience VARCHAR(1024),
IN createInsporation VARCHAR(1024),
IN projectType VARCHAR(1024),
IN projectLeads VARCHAR(1024),
IN projectID VARCHAR(1024),
IN deliverable VARCHAR(1024),
IN scheduleTimeline VARCHAR(1024),
IN announcementType VARCHAR(1024),
IN keyMessage VARCHAR(1024),
IN additionalContent VARCHAR(1024),
IN uSOnlyOrGlobalMetrics VARCHAR(1024),
IN searchTerms VARCHAR(1024),
IN anyAdditionalData VARCHAR(1024),
IN requestedBy VARCHAR(1024),
IN parentIDIN INT(11),
IN useridIN INT(11),
IN clientID INT(11)
)
BEGIN
DECLARE returnCode INT;
DECLARE return_brief_id INT;
DECLARE old_version INT;
DECLARE t_error INTEGER DEFAULT 0;  
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;
SET @requestedBy = (SELECT UserName FROM User where UserID= useridIN);
START TRANSACTION;  
IF briefID IS NULL THEN
INSERT INTO ProjectBrief(ProjectBriefName,ObjectGuidingPrinciple ,
 CommunicationObjective,BusinessObjective,Outcomes,Context,TargetAudience,CreateInsporation,ProjectType,
 ProjectLeads,ProjectID,Deliverable,ScheduleTimeline,AnnouncementType,
 KeyMessage,AdditionalContent,USOnlyOrGlobalMetrics,SearchTerms,AnyAdditionalData,Status,
 RequestedBy,InsertDate,LastModifyDate,
 ParentID,UserID,ClientID,LastOperatorDate) VALUES (projectBriefName,objectGuidingPrinciple,
 communicationObjective,businessObjective,outcomes,context,targetAudience,createInsporation,projectType,
 projectLeads,projectID,deliverable,scheduleTimeline,announcementType,
 keyMessage,additionalContent,uSOnlyOrGlobalMetrics,searchTerms,AnyAdditionalData,1,
 @requestedBy,unix_timestamp(now()),unix_timestamp(now()),
 parentIDIN,useridIN,clientID,unix_timestamp(now()));
ELSE
SET @_sql = 'UPDATE ProjectBrief SET Status = -1 WHERE (ProjectBriefID = ? OR ParentID=?) and Status =0';
SET @briefID = briefID;
PREPARE stmt FROM @_sql;
EXECUTE stmt USING @briefID,@briefID;
DEALLOCATE PREPARE stmt;

SET old_version = (SELECT COUNT(Version) FROM ProjectBrief WHERE ProjectBriefID = parentIDIN OR ParentID = parentIDIN);
INSERT INTO ProjectBrief(ProjectBriefName,ObjectGuidingPrinciple ,
 CommunicationObjective,BusinessObjective,Outcomes,Context,TargetAudience,CreateInsporation,ProjectType,
 ProjectLeads,ProjectID,Deliverable,ScheduleTimeline,AnnouncementType,
 KeyMessage,AdditionalContent,USOnlyOrGlobalMetrics,SearchTerms,AnyAdditionalData,Status,
 RequestedBy,Version,InsertDate,LastModifyDate,
 ParentID,UserID,ClientID,LastOperatorDate) VALUES (projectBriefName,objectGuidingPrinciple,
 communicationObjective,businessObjective,outcomes,context,targetAudience,createInsporation,projectType,
 projectLeads,projectID,deliverable,scheduleTimeline,announcementType,
 keyMessage,additionalContent,uSOnlyOrGlobalMetrics,searchTerms,AnyAdditionalData,1,
 @requestedBy,old_version + 1,unix_timestamp(now()),unix_timestamp(now()),
 parentIDIN,useridIN,clientID,unix_timestamp(now()));
END IF;

IF t_error = 1 THEN  
            ROLLBACK;  
            SET returnCode = 0;
        ELSE  
            COMMIT;  
            SET returnCode = (SELECT LAST_INSERT_ID());
        END IF;  
        SELECT returnCode;
END$$


delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `SubmitProjectProposal`(
IN projectProposalIDIN INT(11), 
IN projectProposalName VARCHAR(256),
IN situation VARCHAR(1024), 
IN objective VARCHAR(1024), 
IN approach VARCHAR(1024), 
IN deliverables VARCHAR(1024), 
IN pricing VARCHAR(1024), 
IN timelineMilestones VARCHAR(1024),
IN contact VARCHAR(1024),
IN pro_comment VARCHAR(1024),
IN parentID INT(11),  
IN projectBriefIDIN INT(11), 
IN userid INT(11), 
IN clientID INT(11)
)
BEGIN
DECLARE returnCode INT;
DECLARE return_proposal_id INT;
DECLARE old_version INT;
DECLARE t_error INTEGER DEFAULT 0;  
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;

START TRANSACTION;  
IF projectProposalIDIN IS NULL THEN
INSERT INTO ProjectProposal(ProjectProposalName, Situation, Objective, Approach, Deliverables, 
    Pricing, TimelineMilestones, Contact, `Comment`, ParentID, ProjectBriefID, Status,
    InsertDate, LastModifyDate, UserID, ClientID, LastOperatorDate) VALUES (projectProposalName,
    situation, objective, approach, deliverables, 
    pricing, timelineMilestones, contact, pro_comment, parentID, projectBriefIDIN,2,
    unix_timestamp(now()), unix_timestamp(now()) , 
    userid, clientID, unix_timestamp(now()) );
ELSE
UPDATE ProjectProposal SET Status = -1 WHERE ProjectProposalID = projectProposalIDIN;

SET old_version = (SELECT COUNT(Version) FROM ProjectProposal 
                            WHERE projectBriefID = projectBriefIDIN);
INSERT INTO ProjectProposal(ProjectProposalName, Situation, Objective, Approach, Deliverables, 
    Pricing, TimelineMilestones, Contact, Version, `Comment`, ParentID, ProjectBriefID, 
    Status,InsertDate, LastModifyDate, UserID, ClientID, LastOperatorDate) VALUES (projectProposalName,
    situation, objective, approach, deliverables, 
    pricing, timelineMilestones, contact, old_version + 1, pro_comment, parentID, projectBriefIDIN, 
    2,unix_timestamp(now()), unix_timestamp(now()) , 
    userid, clientID, unix_timestamp(now()));
END IF;

SET @briefID = projectBriefIDIN;
SET @_sql ='UPDATE ProjectBrief SET Status = 2,LastOperatorDate=unix_timestamp(now()),
                LastModifyDate=unix_timestamp(now()) 
            WHERE (ProjectBriefID = ? OR ParentID = ?)
                AND Status > 0';
prepare stmt FROM @_sql;
EXECUTE stmt USING @briefID,@briefID;
DEALLOCATE PREPARE stmt;

IF t_error = 1 THEN  
    ROLLBACK;  
    SET returnCode = 0;
ELSE  
    COMMIT; 
    SELECT LAST_INSERT_ID() INTO returnCode;
END IF;  
    SELECT returnCode;
END$$




delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `UpdateLastOperatorDate`(
    IN userIDIN INT,
    IN prijectBriefIDIN INT
)
BEGIN
DECLARE returnCode INT;
DECLARE t_error INTEGER DEFAULT 0;  
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;

UPDATE ProjectBrief SET LastOperatorDate=unix_timestamp(now()) 
WHERE (ProjectBriefID=prijectBriefIDIN 
                   OR ParentID=prijectBriefIDIN) AND Status>=0;

UPDATE ProjectProposal SET LastOperatorDate=unix_timestamp(now())
WHERE ProjectBriefID = prijectBriefIDIN AND Status>0;

IF t_error = 1 THEN  
    ROLLBACK;  
    SET returnCode = 0;
ELSE  
    COMMIT;  
    SET returnCode = 1;
END IF;  
SELECT returnCode;

END$$


delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `UpdateReportFile`(IN ReportIDIN INT, IN ReportUrlIN VARCHAR(128))
BEGIN
        DECLARE returnCode INT;
        DECLARE t_error INTEGER DEFAULT 0;  
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;  
            SET SQL_SAFE_UPDATES=0; 
            START TRANSACTION;  
               UPDATE ReportFile SET ReportFileUrl = ReportUrlIN WHERE ReportID = ReportIDIN;
            
        IF t_error = 1 THEN  
            ROLLBACK;  
            SET returnCode = 0;
        ELSE  
            COMMIT;  
            SET returnCode = 1;
        END IF;  
        SELECT returnCode;
    END$$


delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `updateRequestForm`(IN id_in INT, IN start_date_in TIMESTAMP, 
    IN event_name_in VARCHAR(100), IN end_date_in TIMESTAMP,
    IN overview_in VARCHAR(500), IN content_in VARCHAR(4000), 
    IN version_in INT, IN status_in INT, IN qualifying_entities_in VARCHAR(500),
    IN sentiment_entities_in VARCHAR(500), IN outlet_entities_in VARCHAR(500), 
    IN additional_requirements_in VARCHAR(500), IN request_type_in VARCHAR(50), 
    IN request_Template_in VARCHAR(50), IN report_due_date_in TIMESTAMP, IN uid_in VARCHAR(10), IN parent_id INT, OUT returnCode INT)
BEGIN
        
        DECLARE returnCode INT;
        DECLARE t_error INTEGER DEFAULT 0;  
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;  
        
        START TRANSACTION;  
        
        UPDATE requestForm SET status = -1, lastmodifydate = now() WHERE id = id_in;
    
        INSERT INTO requestForm (`start_date`, `event_name`,
            `end_date`, `overview`, `content`,
            `qualifying_entities`, `sentiment_entities`, `outlet_entities`, `additional_requirements`,
            `request_type`, `request_Template`, `report_due_date`,
            `uid`, `version`, `parent_id`, `status`)
            VALUES (start_date_in, event_name_in, end_date_in, overview_in, content_in, qualifying_entities_in,
            sentiment_entities_in, outlet_entities_in, additional_requirements_in, request_type_in, 
            request_Template_in, report_due_date_in, uid_in, version + 1, parent_id, status_in);
        
        IF t_error = 1 THEN  
            ROLLBACK;  
            SET returnCode = -1;
        ELSE  
            COMMIT;  
            SELECT LAST_INSERT_ID() INTO returnCode;
        END IF;  
        SELECT returnCode;
    END$$

delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `UserLogin`(IN UserNameIN VARCHAR(128))
BEGIN
       
        DECLARE clientTotal int;
        SELECT COUNT(userClientMap.ClientID) INTO clientTotal
            FROM User user 
            LEFT JOIN Role role ON user.RoleID = role.RoleID
            LEFT JOIN UserClientMap userClientMap ON user.UserID =  userClientMap.UserID
            LEFT JOIN Client client ON client.ClientID = userClientMap.ClientID
            WHERE user.UserName = UserNameIN and userClientMap.IsDefault = 1;
         
        IF clientTotal = 0
        THEN

            SELECT user.UserID AS id, user.UserName AS username, user.RoleID AS roleID, user.Email AS email, user.Status AS status, role.roleName AS role, role.Permission AS permission, 
                'All' AS clientName,
                -1 AS defaultClientID
                FROM User user 
                LEFT JOIN Role role ON user.RoleID = role.RoleID
                LEFT JOIN UserClientMap userClientMap ON user.UserID =  userClientMap.UserID
                LEFT JOIN Client client ON client.ClientID = userClientMap.ClientID
                WHERE user.UserName = UserNameIN LIMIT 1;
        ELSE
            SELECT user.UserID AS id, user.UserName AS username, user.RoleID AS roleID, user.Email AS email, user.Status AS status, role.roleName AS role, role.Permission AS permission,
                client.ClientName AS clientName,
                userClientMap.ClientID AS defaultClientID
                FROM User user 
                LEFT JOIN Role role ON user.RoleID = role.RoleID
                LEFT JOIN UserClientMap userClientMap ON user.UserID =  userClientMap.UserID
                LEFT JOIN Client client ON client.ClientID = userClientMap.ClientID
                WHERE user.UserName = UserNameIN AND userClientMap.IsDefault = 1;
        END IF;
    END$$


delimiter $$

CREATE DEFINER=`weadmin`@`%` PROCEDURE `ValidateUser`(IN username_in VARCHAR(100), IN password_in VARCHAR(100), OUT client_out VARCHAR(100), OUT privilege_out INT, OUT uid_out VARCHAR(10))
BEGIN
        DECLARE client_out VARCHAR(100);
        DECLARE privilege_out INT;
        DECLARE uid_out VARCHAR(10);
        SELECT uid, client, privilege INTO uid_out, client_out, privilege_out  FROM user WHERE username = username_in and password = password_in and status = 1;
        SELECT client_out, privilege_out, uid_out;
    END$$










