#This file is procedure_20170526.sql

#2017-05-26 14:11
#   Modify procedure DeleteTemplate

USE we_project;

DROP PROCEDURE IF EXISTS `UserLogin`;

#Get login user info
DELIMITER $$

CREATE PROCEDURE `UserLogin`(
    IN UserNameIN VARCHAR(128)
)
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

            SELECT `user`.UserID AS id, `user`.UserName AS username, `user`.RoleID AS roleID,`user`.RealName AS realname, `user`.Email AS email, `user`.`Status` AS `status`, role.roleName AS role, role.Permission AS permission, 
                'All' AS clientName,
                -1 AS defaultClientID
                FROM User user 
                LEFT JOIN Role role ON user.RoleID = role.RoleID
                LEFT JOIN UserClientMap userClientMap ON user.UserID =  userClientMap.UserID
                LEFT JOIN Client client ON client.ClientID = userClientMap.ClientID
                WHERE user.UserName = UserNameIN LIMIT 1;
        ELSE
            SELECT `user`.UserID AS id, `user`.UserName AS username, `user`.RoleID AS roleID, `user`.RealName AS realname, `user`.Email AS email, `user`.`Status` AS `status`, role.roleName AS role, role.Permission AS permission,
                client.ClientName AS clientName,
                userClientMap.ClientID AS defaultClientID
                FROM User user 
                LEFT JOIN Role role ON user.RoleID = role.RoleID
                LEFT JOIN UserClientMap userClientMap ON user.UserID =  userClientMap.UserID
                LEFT JOIN Client client ON client.ClientID = userClientMap.ClientID
                WHERE user.UserName = UserNameIN AND userClientMap.IsDefault = 1 LIMIT 1;
        END IF;
END $$

