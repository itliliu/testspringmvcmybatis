USE we_project;

DROP PROCEDURE IF EXISTS `SearchBriefList`;
DROP PROCEDURE IF EXISTS `GetBriefInfo`;

DELIMITER $$
CREATE PROCEDURE `SearchBriefList`(
    IN `userIDIN` INT(11),
	IN `clientIDIN` INT(11),
	IN `statusIN` INT(1),
	IN `keyword` VARCHAR(128), 
	IN `orderBy` VARCHAR(10),
	IN `isModify` BIT,
	IN `pageIndex` INT,
	IN `pageSize` INT
)
BEGIN
DECLARE pageNumber INT;
	SET pageNumber = pageSize * (pageIndex - 1); 
	
	DROP TEMPORARY TABLE IF EXISTS tmp_client;
  CREATE TEMPORARY TABLE tmp_client (
			client_id INT(11) NOT NULL,
      client_name VARCHAR(128) NOT NULL);
	
	SELECT r.RoleName INTO @role_name FROM `User` u LEFT JOIN Role r ON u.RoleID=r.RoleID WHERE u.UserID=userIDIN;
	
  set @final_sql = '';
	set @final_sql_number = '';

	SET @_sql = 'SELECT p.brief_id AS briefID, p.user_id AS userID, p.client_id AS clientID, 
					c.client_name AS client, p.brief_name AS briefName,
					p.is_star AS isStar, p.create_date AS createDate, p.modify_date AS modifyDate,
					p.parent_id AS parentID,
					p.brief_context AS briefContext,p.`status`
			  FROM project_brief p LEFT JOIN tmp_client c ON p.client_id=c.client_id
				WHERE status > 0 AND c.client_name IS NOT NULL';
	SET @sql_number ='SELECT COUNT(p.brief_id) AS pageNumber
			  FROM project_brief p LEFT JOIN tmp_client c ON p.client_id=c.client_id
				WHERE status > 0 AND c.client_name IS NOT NULL';
	
	IF @role_name ='AccountTeam' THEN

		-- if client id is null or 0, it's search
		IF clientIDIN = 0 OR clientIDIN = -1 OR clientIDIN IS NULL THEN
			-- get user's client
 			INSERT INTO tmp_client (client_id,client_name) 
			SELECT c.ClientID,c.ClientName FROM `User` u 
				LEFT JOIN UserClientMap ucm ON u.UserID = ucm.UserID
				LEFT JOIN Client c ON ucm.ClientID = c.ClientID
				WHERE u.UserID=userIDIN AND ucm.ClientID <> -1 AND c.ClientID IS NOT NULL;
			
			IF keyword IS NOT NULL AND keyword <> '' THEN
				SET @_condition = CONCAT(' AND (
							(p.brief_id like \'%',keyword,'%\') OR
	            (p.brief_name like \'%',keyword,'%\') OR
			        (c.client_name like \'%',keyword,'%\')
					)');
				SET @_sql = CONCAT(@_sql,@_condition);
				SET @sql_number = CONCAT(@sql_number,@_condition);
			END IF;

			IF statusIN <> -1 AND statusIN IS NOT NULL THEN
				SET @_sql = CONCAT(@_sql,' AND p.status=',statusIN);
				SET @sql_number = CONCAT(@sql_number,' AND p.status=',statusIN);
			END IF;
			
			IF LOWER(orderBy) = 'asc' THEN
				SET @_sql = CONCAT(@_sql, ' ORDER BY p.modify_date');
			ELSE
				SET @_sql = CONCAT(@_sql, ' ORDER BY p.modify_date DESC');
			END IF;

			SET @_sql = CONCAT(@_sql, ' LIMIT ',pageNumber, ', ', pageSize );

			SET @final_sql = CONCAT(@final_sql,@_sql);
		  SET @final_sql_number = CONCAT(@final_sql_number,@sql_number);
			
		ELSE 
				-- if is modify, need userid
				IF isModify = 1 THEN
					SET @sql_select = CONCAT('SELECT p.brief_id AS briefID, p.user_id AS userID, p.client_id AS clientID, 
						c.ClientName AS client, p.brief_name AS briefName,p.`status`,
						p.is_star AS isStar, p.create_date AS createDate, p.modify_date AS modifyDate,
						p.parent_id AS parentID,
						p.brief_context AS briefContext
					FROM project_brief p LEFT JOIN Client c ON p.client_id=c.ClientID
					WHERE p.create_by = ',userIDIN,' AND p.client_id = ',clientIDIN,' AND p.`status` > 0');
          
          SET @sql_select_number = CONCAT('SELECT COUNT(p.brief_id) AS pageNumber
					FROM project_brief p LEFT JOIN Client c ON p.client_id=c.ClientID
					WHERE p.create_by = ',userIDIN,' AND p.client_id = ',clientIDIN,' AND p.`status` > 0');
					
					
					IF statusIN <> -1 AND statusIN IS NOT NULL THEN
						SET @sql_select = CONCAT(@sql_select,' AND p.status=',statusIN);
						SET @sql_select_number = CONCAT(@sql_select_number,' AND p.status=',statusIN);
					END IF;

					IF LOWER(orderBy) = 'asc' THEN
						SET @sql_select = CONCAT(@sql_select, ' ORDER BY p.modify_date');
					ELSE
						SET @sql_select = CONCAT(@sql_select, ' ORDER BY p.modify_date DESC');
					END IF;

					SET @sql_select = CONCAT(@sql_select, ' LIMIT ',pageNumber, ', ', pageSize );
	
			
					SET @final_sql = CONCAT(@final_sql,@sql_select);
		      SET @final_sql_number = CONCAT(@final_sql_number,@sql_select_number);
			
				ELSE 
					INSERT INTO tmp_client (client_id,client_name)
					SELECT ClientID,ClientName FROM Client WHERE ClientID=clientIDIN;

					IF keyword IS NOT NULL AND keyword <> '' THEN
						SET @_condition = CONCAT(' AND (
									(p.brief_id like \'%',keyword,'%\') OR
									(p.brief_name like \'%',keyword,'%\') OR
									(c.client_name like \'%',keyword,'%\')
							)');
						SET @_sql = CONCAT(@_sql,@_condition);
            SET @sql_number = CONCAT(@sql_number,@_condition);
					END IF;

					IF statusIN <> -1 AND statusIN IS NOT NULL THEN
						SET @_sql = CONCAT(@_sql,' AND p.status=',statusIN);
						SET @sql_number = CONCAT(@sql_number,' AND p.status=',statusIN);
					END IF;
					
					IF LOWER(orderBy) = 'asc' THEN
						SET @_sql = CONCAT(@_sql, ' ORDER BY p.modify_date');
					ELSE
						SET @_sql = CONCAT(@_sql, ' ORDER BY p.modify_date DESC');
					END IF;

					SET @_sql = CONCAT(@_sql, ' LIMIT ',pageNumber, ', ', pageSize );

					SET @final_sql = CONCAT(@final_sql,@_sql);
		      SET @final_sql_number = CONCAT(@final_sql_number,@sql_number);
				END IF;
		END IF;

  ELSE 
		IF clientIDIN = 0 OR clientIDIN = -1 OR  clientIDIN IS NULL THEN
			-- get user's client
 			INSERT INTO tmp_client (client_id,client_name) 
			SELECT ClientID,ClientName FROM Client;	
		ELSE 	
			INSERT INTO tmp_client (client_id,client_name) 
			SELECT ClientID,ClientName FROM Client WHERE ClientID=clientIDIN;	
		END IF;

		IF keyword IS NOT NULL AND keyword <> '' THEN
			SET @_condition = CONCAT(' AND (
						(p.brief_id like \'%',keyword,'%\') OR
	          (p.brief_name like \'%',keyword,'%\') OR
		        (c.client_name like \'%',keyword,'%\')
				)');
			SET @_sql = CONCAT(@_sql,@_condition);
			SET @sql_number = CONCAT(@sql_number,@_condition);
		END IF;

		IF statusIN <> -1 AND statusIN IS NOT NULL THEN
			SET @_sql = CONCAT(@_sql,' AND p.status=',statusIN);
			SET @sql_number = CONCAT(@sql_number,' AND p.status=',statusIN);
		END IF;
		
		IF LOWER(orderBy) = 'asc' THEN
			SET @_sql = CONCAT(@_sql, ' ORDER BY p.modify_date');
		ELSE
			SET @_sql = CONCAT(@_sql, ' ORDER BY p.modify_date DESC');
		END IF;

		SET @_sql = CONCAT(@_sql, ' LIMIT ',pageNumber, ', ', pageSize );

		SET @final_sql = CONCAT(@final_sql,@_sql);
		SET @final_sql_number = CONCAT(@final_sql_number,@sql_number);
			
  END IF;

	PREPARE stmt FROM @final_sql;
	EXECUTE stmt; 
	DEALLOCATE PREPARE stmt;

	PREPARE stmt FROM @final_sql_number;
	EXECUTE stmt; 
	DEALLOCATE PREPARE stmt;
END $$

DELIMITER $$
CREATE PROCEDURE `GetBriefInfo`(
    IN `parentID` INT
)
BEGIN

	SELECT version INTO @version FROM project_brief 
	WHERE (parent_ID=parentID OR brief_id=parentID) AND `status` > 0;
	
	IF @version = 1 THEN
		SELECT brief_id AS briefID, user_id AS userID, client_id AS clientID, brief_name AS briefName,
			`status`, create_date AS createDate, modify_date AS modifyDate,
			is_star AS isStar, parent_id AS parentID, version, brief_context AS briefContext,
      create_by AS createBy,'' AS lastBriefContext, '' AS lastBriefName
		FROM project_brief 
		WHERE (parent_ID=parentID OR brief_id=parentID ) AND `status` > 0;
	ELSE
    SELECT brief_name INTO @last_brief_name
		FROM project_brief WHERE (parent_id=parentID OR brief_id=parentID) AND version=@version-1;

		SELECT  brief_context INTO @last_brief_context 
		FROM project_brief WHERE (parent_id=parentID OR brief_id=parentID) AND version=@version-1;

		SELECT brief_id AS briefID, user_id AS userID, client_id AS clientID, brief_name AS briefName,
			`status`, create_date AS createDate, modify_date AS modifyDate,
			is_star AS isStar, parent_id AS parentID, version, brief_context AS briefContext,
      create_by AS createBy,@last_brief_context AS lastBriefContext, @last_brief_name AS lastBriefName
		FROM project_brief 
		WHERE (parent_ID=parentID OR brief_id=parentID) AND `status` > 0;
	END IF;
END $$
