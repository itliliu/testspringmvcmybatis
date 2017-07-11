USE we_project;

TRUNCATE Template;
INSERT INTO Template
(TemplateName,Description,`Status`,InsertDate,LastModifyDate)
VALUES
('Competitive Intrusion','test',1,unix_timestamp(now()) *1000,unix_timestamp(now()) *1000),
('Company Brand','test',1,unix_timestamp(now()) *1000,unix_timestamp(now()) *1000),
('Company + Competitor Brands','test',1,unix_timestamp(now()) *1000,unix_timestamp(now()) *1000),
('Products','test',1,unix_timestamp(now()) *1000,unix_timestamp(now()) *1000),
('Influencers','test',1,unix_timestamp(now()) *1000,unix_timestamp(now()) *1000);

