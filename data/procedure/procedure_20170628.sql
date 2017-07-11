
USE we_project;

DROP PROCEDURE IF EXISTS `SaveProjectBrief`;

#Get login user info
DELIMITER $$

CREATE PROCEDURE `SaveProjectBrief`(
    IN briefId INT(11),
    IN briefName VARCHAR(1024),
    IN userId INT(11),
    IN clientId INT(11),
    IN briefContext TEXT,
    IN statusIN INT(1)
)
BEGIN
 DECLARE returnCode INT;
DECLARE old_version INT;
DECLARE count INT;
DECLARE createBy INT;
DECLARE t_error INTEGER DEFAULT 0;  
DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1;
START TRANSACTION;  


UPDATE project_brief SET `status` = -1 WHERE (brief_id=briefId OR (parent_id=briefId and briefID <> 0)) AND `status`>0;
select ROW_COUNT() INTO count;

SELECT MAX(version) INTO old_version FROM project_brief WHERE brief_id=briefId OR parent_id=briefId;

IF count > 0 THEN
	SELECT create_by INTO createBy FROM project_brief WHERE brief_id=briefId;
	INSERT INTO project_brief(user_id,client_id,brief_name,`status`,brief_context,
			 is_star,parent_id,version,create_date,modify_date,create_by)
	VALUES(userId,clientId,briefName,statusIN,briefContext,0,briefId,old_version+1,now(),now(),createBy);
ELSE
  INSERT INTO project_brief(user_id,client_id,brief_name,`status`,brief_context,is_star,create_date,modify_date,create_by)
	VALUES(userId,clientId,briefName,statusIN,briefContext,0,now(),now(),userId);
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