USE we_project;

DROP PROCEDURE IF EXISTS `GetParentClient`;
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