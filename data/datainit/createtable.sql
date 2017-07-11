creata database we_project;

use we_project;

delimiter $$

CREATE TABLE `Client` (
  `ClientID` int(11) NOT NULL AUTO_INCREMENT,
  `ClientName` varchar(128) DEFAULT NULL,
  `Logo` varchar(128) DEFAULT NULL,
  `InsertDate` bigint(20) DEFAULT NULL,
  `LastModifyDate` bigint(20) DEFAULT NULL,
  `ParentID` int(11) DEFAULT NULL,
  PRIMARY KEY (`ClientID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1$$



delimiter $$

CREATE TABLE `Format` (
  `FormatID` int(11) NOT NULL AUTO_INCREMENT,
  `FormatType` varchar(256) DEFAULT NULL,
  `Status` int(11) DEFAULT '0',
  `InsertDate` bigint(20) DEFAULT NULL,
  `LastModifyDate` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`FormatID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1$$

delimiter $$

CREATE TABLE `ProjectBrief` (
  `ProjectBriefID` int(11) NOT NULL AUTO_INCREMENT,
  `ProjectBriefName` varchar(1024) DEFAULT NULL,
  `ObjectGuidingPrinciple` varchar(1024) DEFAULT NULL,
  `CommunicationObjective` varchar(1024) DEFAULT NULL,
  `Outcomes` varchar(1024) DEFAULT NULL,
  `Context` varchar(1024) DEFAULT NULL,
  `TargetAudience` varchar(1024) DEFAULT NULL,
  `CreateInsporation` varchar(1024) DEFAULT NULL,
  `ProjectType` varchar(1024) DEFAULT NULL,
  `ProjectLeads` varchar(1024) DEFAULT NULL,
  `ProjectID` varchar(1024) DEFAULT NULL,
  `Deliverable` varchar(1024) DEFAULT NULL,
  `ScheduleTimeline` varchar(1024) DEFAULT NULL,
  `AnnouncementType` varchar(1024) DEFAULT NULL,
  `KeyMessage` varchar(1024) DEFAULT NULL,
  `AdditionalContent` varchar(1024) DEFAULT NULL,
  `USOnlyOrGlobalMetrics` varchar(1024) DEFAULT NULL,
  `SearchTerms` varchar(1024) DEFAULT NULL,
  `AnyAdditionalData` varchar(1024) DEFAULT NULL,
  `RequestedBy` varchar(1024) DEFAULT NULL,
  `Status` int(11) DEFAULT '0',
  `Version` int(11) DEFAULT '1',
  `InsertDate` bigint(20) DEFAULT NULL,
  `LastModifyDate` bigint(20) DEFAULT NULL,
  `ParentID` int(11) DEFAULT NULL,
  `UserID` int(11) DEFAULT NULL,
  `ClientID` int(11) DEFAULT NULL,
  `LastOperatorDate` bigint(20) DEFAULT NULL,
  `BusinessObjective` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`ProjectBriefID`),
  KEY `ProjectBrief_User_id` (`UserID`),
  KEY `ProjectBrief_client_id` (`ClientID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1$$


delimiter $$

CREATE TABLE `ProjectFile` (
  `ProjectFileID` int(11) NOT NULL AUTO_INCREMENT,
  `ProjectBriefID` int(11) DEFAULT NULL,
  `ProjectBriefFileUrl` varchar(128) DEFAULT NULL,
  `ProjectProposalFileUrl` varchar(128) DEFAULT NULL,
  `RequestFormFileUrl` varchar(128) DEFAULT NULL,
  `Status` int(11) DEFAULT NULL,
  `InsertDate` bigint(20) DEFAULT NULL,
  `LastModifyDate` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`ProjectFileID`),
  KEY `ProjectFile_ProjectBrief_id` (`ProjectBriefID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1$$


delimiter $$

CREATE TABLE `ProjectProposal` (
  `ProjectProposalID` int(11) NOT NULL AUTO_INCREMENT,
  `ProjectProposalName` varchar(256) DEFAULT NULL,
  `Situation` varchar(1024) DEFAULT NULL,
  `Objective` varchar(1024) DEFAULT NULL,
  `Approach` varchar(1024) DEFAULT NULL,
  `Deliverables` varchar(1024) DEFAULT NULL,
  `Pricing` varchar(1024) DEFAULT NULL,
  `TimelineMilestones` varchar(1024) DEFAULT NULL,
  `Contact` varchar(1024) DEFAULT NULL,
  `Status` int(11) DEFAULT '0',
  `Version` int(11) DEFAULT '1',
  `Comment` varchar(1024) DEFAULT NULL,
  `ParentID` int(11) DEFAULT NULL,
  `ProjectBriefID` int(11) DEFAULT NULL,
  `InsertDate` bigint(20) DEFAULT NULL,
  `LastModifyDate` bigint(20) DEFAULT NULL,
  `UserID` int(11) DEFAULT NULL,
  `ClientID` int(11) DEFAULT NULL,
  `LastOperatorDate` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`ProjectProposalID`),
  KEY `ProjectProposal_User_id` (`UserID`),
  KEY `ProjectProposal_client_id` (`ClientID`),
  KEY `ProjectProposal_ProjectBrief_id` (`ProjectBriefID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1$$


delimiter $$

CREATE TABLE `Report` (
  `ReportID` int(11) NOT NULL AUTO_INCREMENT,
  `UserID` int(11) DEFAULT NULL,
  `Name` varchar(128) DEFAULT NULL,
  `ProjectID` int(11) DEFAULT NULL,
  `InsertDate` bigint(20) DEFAULT NULL,
  `LastModifyDate` bigint(20) DEFAULT NULL,
  `PowerBITemplateID` int(11) DEFAULT NULL,
  `TilesProTemplateID` int(11) DEFAULT NULL,
  `Comment` varchar(1024) DEFAULT NULL,
  `ReportType` int(11) DEFAULT NULL,
  `DueDate` bigint(20) DEFAULT NULL,
  `Format` int(11) DEFAULT NULL,
  PRIMARY KEY (`ReportID`),
  KEY `Report_User_id` (`UserID`),
  KEY `Report_Template_PowerBITemplateID` (`PowerBITemplateID`),
  KEY `Report_Template_TilesProTemplateID` (`TilesProTemplateID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1$$



delimiter $$

CREATE TABLE `ReportFile` (
  `ReportFileID` int(11) NOT NULL AUTO_INCREMENT,
  `ReportID` int(11) DEFAULT NULL,
  `ReportFileUrl` varchar(128) DEFAULT NULL,
  `PowerBITemplateUrl` varchar(128) DEFAULT NULL,
  `TilesProTemplateUrl` varchar(128) DEFAULT NULL,
  `Status` int(11) DEFAULT NULL,
  `InsertDate` bigint(20) DEFAULT NULL,
  `LastModifyDate` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`ReportFileID`),
  KEY `ReportFile_Report_id` (`ReportID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1$$


delimiter $$

CREATE TABLE `ReportType` (
  `ReportTypeID` int(11) NOT NULL AUTO_INCREMENT,
  `ReportType` varchar(256) DEFAULT NULL,
  `Status` int(11) DEFAULT '0',
  `InsertDate` bigint(20) DEFAULT NULL,
  `LastModifyDate` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`ReportTypeID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1$$


delimiter $$

CREATE TABLE `RequestForm` (
  `RequestFormID` int(11) NOT NULL AUTO_INCREMENT,
  `ContentSearchCategory` varchar(1024) DEFAULT NULL,
  `KeyMessage1` varchar(1024) DEFAULT NULL,
  `KeyMessage2` varchar(1024) DEFAULT NULL,
  `KeyMessage3` varchar(1024) DEFAULT NULL,
  `KeyMessage4` varchar(1024) DEFAULT NULL,
  `KeyMessage5` varchar(1024) DEFAULT NULL,
  `QualifyingEntities` varchar(1024) DEFAULT NULL,
  `SentimentEntities` varchar(1024) DEFAULT NULL,
  `Outlets` varchar(1024) DEFAULT NULL,
  `QualifyingThreshold` int(11) DEFAULT NULL,
  `Status` int(11) DEFAULT '0',
  `Version` int(11) DEFAULT '1',
  `ParentID` int(11) DEFAULT NULL,
  `ProjectProposalID` int(11) DEFAULT NULL,
  `InsertDate` bigint(20) DEFAULT NULL,
  `LastModifyDate` bigint(20) DEFAULT NULL,
  `Uid` int(11) DEFAULT NULL,
  `ClientID` int(11) DEFAULT NULL,
  `ProjectBriefID` int(11) DEFAULT NULL,
  `LastOperatorDate` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`RequestFormID`),
  KEY `RequestForm_User_id` (`Uid`),
  KEY `RequestForm_client_id` (`ClientID`),
  KEY `RequestForm_ProjectProposal_id` (`ProjectBriefID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1$$


delimiter $$

CREATE TABLE `Role` (
  `RoleID` int(11) NOT NULL AUTO_INCREMENT,
  `RoleName` varchar(128) DEFAULT NULL,
  `Permission` varchar(1024) DEFAULT NULL,
  `Status` int(11) DEFAULT '1',
  `InsertDate` bigint(20) DEFAULT NULL,
  `LastModifyDate` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`RoleID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1$$


delimiter $$

CREATE TABLE `Template` (
  `TemplateID` int(11) NOT NULL AUTO_INCREMENT,
  `TemplateName` varchar(128) DEFAULT NULL,
  `ReportType` int(11) DEFAULT NULL,
  `Format` int(11) DEFAULT NULL,
  `Status` int(11) DEFAULT '1',
  `ClientID` int(11) DEFAULT NULL,
  `Type` varchar(128) DEFAULT NULL,
  `Userid` int(11) DEFAULT NULL,
  `InsertDate` bigint(20) DEFAULT NULL,
  `LastModifyDate` bigint(20) DEFAULT NULL,
  `Description` text,
  `FileUrl` varchar(128) DEFAULT NULL,
  `PowerBITemplateID` int(11) DEFAULT NULL,
  PRIMARY KEY (`TemplateID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1$$


delimiter $$

CREATE TABLE `User` (
  `UserID` int(11) NOT NULL AUTO_INCREMENT,
  `UserName` varchar(128) DEFAULT NULL,
  `RoleID` int(11) DEFAULT NULL,
  `Email` varchar(64) DEFAULT NULL,
  `Status` int(11) DEFAULT '1',
  `InsertDate` bigint(20) DEFAULT NULL,
  `LastModifyDate` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`UserID`),
  KEY `User_roles_id` (`RoleID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1$$


delimiter $$

CREATE TABLE `UserClientMap` (
  `MapID` int(11) NOT NULL AUTO_INCREMENT,
  `ClientID` int(11) DEFAULT NULL,
  `InsertDate` bigint(20) DEFAULT NULL,
  `LastModifyDate` bigint(20) DEFAULT NULL,
  `UserID` int(11) DEFAULT NULL,
  `IsDefault` int(11) DEFAULT NULL,
  PRIMARY KEY (`MapID`),
  KEY `UserClientMap_user_id` (`UserID`),
  KEY `UserClientMap_client_id` (`ClientID`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=latin1$$












