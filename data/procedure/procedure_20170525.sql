#Generate a sql file every day. 
#The file name is
#   procedure_20170525.sql

#2017-05-25 13:44
#   Create procedure SaveProjectBrief
#   Create procedure SubmitProjectBrief
#   Create procedure UpdateLastOperatorDate
#   Create procedure RejectReport
#   create procedure GetProjectBriefByUserIDAndPrimaryKey
#   Modify procedure CompleteReport

DROP PROCEDURE IF EXISTS SaveProjectBrief;
DROP PROCEDURE IF EXISTS SubmitProjectBrief;
DROP PROCEDURE IF EXISTS UpdateLastOperatorDate;
DROP PROCEDURE IF EXISTS RejectReport;
DROP PROCEDURE IF EXISTS GetProjectBriefByUserIDAndPrimaryKey;
DROP PROCEDURE IF EXISTS CompleteReport;
#If projectBriefID is null, add a new project brief data(Status=0).
#If projectBriefID is not null, add a new project brief data(Status=0). Update the project brief data(Status=-1);
DELIMITER $$

CREATE PROCEDURE `we_project`.`SaveProjectBrief`(
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
IN clientID INT(11),
IN isNeedProposalIN BIT
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
 ParentID,UserID,ClientID,LastOperatorDate,IsNeedProposal) VALUES (projectBriefName,objectGuidingPrinciple,
 communicationObjective,businessObjective,outcomes,context,targetAudience,createInsporation,projectType,
 projectLeads,projectID,deliverable,scheduleTimeline,announcementType,
 keyMessage,additionalContent,uSOnlyOrGlobalMetrics,searchTerms,AnyAdditionalData,0,
 @requestedBy,unix_timestamp(now()),unix_timestamp(now()),
 parentIDIN,useridIN,clientID,unix_timestamp(now()),isNeedProposalIN);
 
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
 ParentID,UserID,ClientID,LastOperatorDate,IsNeedProposal) VALUES (projectBriefName,objectGuidingPrinciple ,
 communicationObjective,businessObjective,outcomes,context,targetAudience,createInsporation,projectType,
 projectLeads,projectID,deliverable,scheduleTimeline,announcementType,
 keyMessage,additionalContent,uSOnlyOrGlobalMetrics,searchTerms,AnyAdditionalData,0,
 @requestedBy,old_version + 1,unix_timestamp(now()),unix_timestamp(now()) ,
 parentIDIN,useridIN,clientID,unix_timestamp(now()),isNeedProposalIN);
END IF;

IF t_error = 1 THEN  
            ROLLBACK;  
            SET returnCode = 0;
        ELSE  
            COMMIT;  
            SET returnCode = (SELECT LAST_INSERT_ID());
        END IF;  
        SELECT returnCode;

END $$

#If projectBriefID is null, add a new project brief data(if is need proposal then Status=1 else Status=3).
#If projectBriefID is not null, add a new project brief data(if is need proposal then Status=1 else Status=3).
    #Update the project brief data(Status=-1);
DELIMITER $$

CREATE PROCEDURE `we_project`.`SubmitProjectBrief`(
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
IN clientID INT(11),
IN isNeedProposalIN BIT,
IN statusIN INT(11)
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
 ParentID,UserID,ClientID,LastOperatorDate,IsNeedProposal) VALUES (projectBriefName,objectGuidingPrinciple,
 communicationObjective,businessObjective,outcomes,context,targetAudience,createInsporation,projectType,
 projectLeads,projectID,deliverable,scheduleTimeline,announcementType,
 keyMessage,additionalContent,uSOnlyOrGlobalMetrics,searchTerms,AnyAdditionalData,statusIN,
 @requestedBy,unix_timestamp(now()),unix_timestamp(now()),
 parentIDIN,useridIN,clientID,unix_timestamp(now()),isNeedProposalIN);
ELSE
SET @_sql = 'UPDATE ProjectBrief SET Status = -1 WHERE (ProjectBriefID = ? OR ParentID=?) and Status >=0';
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
 ParentID,UserID,ClientID,LastOperatorDate,IsNeedProposal) VALUES (projectBriefName,objectGuidingPrinciple,
 communicationObjective,businessObjective,outcomes,context,targetAudience,createInsporation,projectType,
 projectLeads,projectID,deliverable,scheduleTimeline,announcementType,
 keyMessage,additionalContent,uSOnlyOrGlobalMetrics,searchTerms,AnyAdditionalData,statusIN,
 @requestedBy,old_version + 1,unix_timestamp(now()),unix_timestamp(now()),
 parentIDIN,useridIN,clientID,unix_timestamp(now()),isNeedProposalIN);
END IF;

IF t_error = 1 THEN  
            ROLLBACK;  
            SET returnCode = 0;
        ELSE  
            COMMIT;  
            SET returnCode = (SELECT LAST_INSERT_ID());
        END IF;  
        SELECT returnCode;
END $$

#update project brief last operator date.
#if is need proposal, update proejct proposal last operator date.
DELIMITER $$

CREATE PROCEDURE `we_project`.`UpdateLastOperatorDate`(
    IN userIDIN INT,
    IN projectBriefIDIN INT
)
BEGIN
DECLARE returnCode INT;
DECLARE t_error INTEGER DEFAULT 0;  
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;

UPDATE ProjectBrief SET LastOperatorDate=unix_timestamp(now()) 
WHERE (ProjectBriefID=projectBriefIDIN 
                   OR ParentID=projectBriefIDIN) AND Status>=0;

SELECT IsNeedProposal INTO @isNeedProposal
FROM ProjectBrief 
WHERE (ProjectBriefID=projectBriefIDIN OR ParentID=projectBriefIDIN) AND Status>=0;

IF @isNeedProposal=1 THEN
    UPDATE ProjectProposal SET LastOperatorDate=unix_timestamp(now())
    WHERE ProjectBriefID = projectBriefIDIN AND Status>0;
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

DELIMITER $$

CREATE PROCEDURE `we_project`.`RejectReport`(IN ProjectIDIN INT, IN CommentIN VARCHAR(1024))
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
            
            SELECT IsNeedProposal INTO @isNeedProposal
            FROM ProjectBrief 
            WHERE (ProjectBriefID=ProjectIDIN OR ParentID=ProjectIDIN) AND Status>=0;
            
            IF @isNeedProposal=1 THEN
                UPDATE ProjectProposal SET Status = 3,LastModifyDate=unix_timestamp(now()),
                        LastOperatorDate=unix_timestamp(now()) 
                WHERE (ProjectBriefID = ProjectIDIN) AND Status > 0;
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

DELIMITER $$

CREATE PROCEDURE `we_project`.`GetProjectBriefByUserIDAndPrimaryKey`(
    IN uid INT(11),
    IN briefID INT(11)
)
BEGIN

SELECT brief.ProjectBriefID, brief.ProjectBriefName,
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
            brief.ClientID,
            brief.IsNeedProposal,
            proposal.ProjectProposalID,
            proposal.ParentID AS ProposalParentID,
            proposal.ProjectProposalName
FROM ProjectBrief brief
LEFT JOIN ProjectProposal proposal
            ON brief.ParentID = proposal.ProjectBriefID
            OR brief.ProjectBriefID = proposal.ProjectBriefID
WHERE brief.ProjectBriefID=briefID
    AND brief.Status>=0 AND(proposal.Status>0 OR proposal.Status IS NULL);
        
END $$

DELIMITER $$

CREATE PROCEDURE `we_project`.`CompleteReport`(IN ProjectIDIN INT)
BEGIN
        DECLARE returnCode INT;
        DECLARE t_error INTEGER DEFAULT 0;  
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;  
            SET SQL_SAFE_UPDATES=0; 
            START TRANSACTION;  
                UPDATE ProjectBrief SET Status = 5,LastModifyDate=unix_timestamp(now()),
                       LastOperatorDate=unix_timestamp(now()) 
                WHERE (ParentID = ProjectIDIN OR ProjectBriefID = ProjectIDIN) AND Status > 0;
                
                SELECT IsNeedProposal INTO @isNeedProposal
                FROM ProjectBrief 
                WHERE (ProjectBriefID=ProjectIDIN OR ParentID=ProjectIDIN) AND Status>=0;
                
                IF @isNeedProposal=1 THEN
                    UPDATE ProjectProposal SET Status = 5,LastModifyDate=unix_timestamp(now()),
                            LastOperatorDate=unix_timestamp(now()) 
                    WHERE (ProjectBriefID = ProjectIDIN) AND Status > 0;
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
