#Generate a sql file every day. 
#The file name is
#	function_20170524.sql

#2017-05-24 15:20
#This is a example

DROP TABLE IF EXISTS `we_project`.`Client`;
delimiter $$
CREATE TABLE `Client` (
  `ClientID` int(11) NOT NULL AUTO_INCREMENT,
  `ClientName` varchar(128) DEFAULT NULL,
  `Logo` varchar(128) DEFAULT NULL,
  `InsertDate` bigint(20) DEFAULT NULL,
  `LastModifyDate` bigint(20) DEFAULT NULL,
  `ParentID` int(11) DEFAULT NULL,
  `Status` int(11) DEFAULT '0',
  PRIMARY KEY (`ClientID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1$$

