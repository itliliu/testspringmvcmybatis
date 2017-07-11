DROP TABLE IF EXISTS `we_project`.`ProjectBriefLibrary`;
delimiter $$

CREATE TABLE `ProjectBriefLibrary` (
  `LibraryID` int(11) NOT NULL AUTO_INCREMENT,
  `BriefID` int(11) NOT NULL,
  `UserID` int(11) NOT NULL,
  `InsertDate` bigint(20) DEFAULT NULL,
  `LastModifyDate` bigint(20) DEFAULT NULL,
  `Status` int(1) DEFAULT '0',
  PRIMARY KEY (`LibraryID`),
  UNIQUE KEY `BriefID` (`BriefID`,`UserID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1$$