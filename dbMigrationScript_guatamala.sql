-- ############################
-- ##############
-- DATABASE PREP
-- ##############
-- ############################


-- --------------------------------------------------------------------------------------------------------------
-- TODO
-- --------------------------------------------------------------------------------------------------------------
/*
	Fix anual interst rate on m_loan
    Fix fromdate in m_loan_repayment_schedule - currently just null
*/





-- INSERT INTO `mifostenant-default`.`m_office` VALUES (1,NULL,'.','1','Head Office','2009-01-01');
INSERT INTO `mifostenant-default`.`m_product_loan` VALUES (1,'crgr','GTQ',2,0,2500.000000,10.000000,25000.000000,NULL,'Credito Grupal','Credito grupal',NULL,'\0','\0',4.000000,0.000000,80.000000,2,48.000000,1,0,0,1,2,8,2,12,NULL,NULL,NULL,0,1,1,NULL,1,0,NULL,NULL,0,NULL,NULL,30,365,1,360,1,15,0,50.00,1,1,1.000000),(2,'2.5','GTQ',2,0,2500.000000,10.000000,25000.000000,NULL,'Credito Grupal 2.5%','Credito grupal 2.5%',NULL,'\0','\0',2.500000,0.000000,80.000000,2,30.000000,1,0,0,1,2,8,2,14,NULL,NULL,NULL,0,1,1,NULL,0,0,NULL,NULL,0,NULL,NULL,NULL,NULL,30,360,0,15,0,0.00,0,1,1.000000),(3,'Grcp','GTQ',2,0,2500.000000,10.000000,40000.000000,NULL,'Credito Grupal Intereses Capitalizables','Credito grupal intereses capitalizables',NULL,'\0','\0',0.000000,0.000000,80.000000,2,0.000000,1,0,0,1,2,8,1,14,NULL,NULL,NULL,0,1,1,NULL,0,0,NULL,NULL,0,NULL,NULL,NULL,NULL,1,360,0,15,0,0.00,0,1,1.000000),(4,'I2y3','GTQ',2,0,6000.000000,10.000000,25000.000000,NULL,'Credito Individual Plan 2 y 3','Credito individual plan 2 y 3',NULL,'\0','\0',4.000000,0.000000,80.000000,2,48.000000,1,0,0,1,2,8,3,12,NULL,NULL,NULL,0,1,1,NULL,0,0,NULL,NULL,0,NULL,NULL,NULL,NULL,30,360,0,15,0,0.00,0,1,1.000000),(5,'Grvr','GTQ',2,0,2500.000000,10.000000,35000.000000,NULL,'Credito grupal con intereses variables','Credito grupal con intereses variables',NULL,'\0','\0',5.000000,0.000000,80.000000,2,60.000000,1,0,0,1,2,8,1,18,NULL,NULL,NULL,0,1,1,NULL,0,0,NULL,NULL,0,NULL,NULL,NULL,NULL,30,360,0,15,0,0.00,0,1,1.000000),(6,'CrIn','GTQ',2,0,6000.000000,10.000000,70000.000000,NULL,'Crédito Individual','Credito individual',NULL,'\0','\0',3.750000,0.000000,80.000000,2,45.000000,1,0,0,1,2,8,3,12,NULL,NULL,NULL,0,1,1,NULL,0,0,NULL,NULL,0,NULL,NULL,NULL,NULL,30,360,0,15,0,0.00,0,1,1.000000),(7,'CINT','GTQ',2,0,6000.000000,100.000000,120000.000000,NULL,'Crédito Individual Nueva Tasa','Credito individual con nueva tasa',NULL,'\0','\0',5.000000,0.000000,80.000000,2,60.000000,1,0,0,1,2,12,3,14,NULL,NULL,NULL,0,1,1,NULL,0,0,NULL,NULL,0,NULL,NULL,NULL,NULL,30,360,0,15,0,0.00,0,1,1.000000),(8,'CICP','GTQ',2,0,6000.000000,10.000000,200000.000000,NULL,'Crédito Invidividual Intereses Capitalizables','Credito individual con intereses capitalizables',NULL,'\0','\0',0.000000,0.000000,80.000000,2,0.000000,1,0,0,1,2,8,1,14,NULL,NULL,NULL,1,1,1,NULL,0,0,NULL,NULL,0,NULL,NULL,NULL,NULL,30,360,0,15,0,0.00,0,1,1.000000),(9,'t','PHP',2,1,6000.000000,NULL,NULL,NULL,'TEST',NULL,NULL,'\0','\0',4.000000,0.000000,80.000000,2,48.000000,0,1,0,1,1,25,NULL,NULL,NULL,NULL,NULL,1,1,1,NULL,0,0,NULL,NULL,0,NULL,NULL,NULL,NULL,1,1,0,NULL,0,0.00,0,0,1.000000),(10,'CriV','GTQ',2,0,6000.000000,10.000000,35000.000000,NULL,'Credito Individual con intereses variables',NULL,NULL,'\0','\0',5.000000,0.000000,80.000000,2,60.000000,1,0,0,1,2,8,1,16,NULL,NULL,NULL,0,1,1,NULL,0,0,NULL,NULL,0,NULL,NULL,NULL,NULL,30,360,0,15,0,0.00,0,1,1.000000);
INSERT INTO `mifostenant-default`.`m_charge` VALUES (1,'1_Seguro Temporal de Vida','GTQ',3,2,1,NULL,7.500000,NULL,NULL,NULL,0,1,1,NULL,NULL,NULL,NULL),(2,'Gastos Administrativos','GTQ',1,1,2,0,6.500000,NULL,NULL,NULL,0,1,0,NULL,NULL,NULL,NULL),(3,'Seguro Temporal de Vida','GTQ',1,8,1,0,7.500000,NULL,NULL,NULL,0,1,0,NULL,NULL,NULL,NULL),(4,'Seguro Temporal de Vida Grupal','GTQ',1,8,1,0,22.500000,NULL,NULL,NULL,0,1,0,NULL,NULL,NULL,NULL),(5,'Migration','GTQ',1,2,1,0,1.000000,NULL,NULL,NULL,0,1,0,NULL,NULL,NULL,NULL);
INSERT INTO `mifostenant-default`.`m_product_loan_charge` VALUES (4,3),(6,3),(7,3),(1,4),(2,4),(5,4);
INSERT INTO `mifostenant-default`.`m_product_loan_configurable_attributes` VALUES (1,1,1,1,1,1,1,1,1,1),(2,2,1,1,1,1,1,1,1,1),(3,3,1,1,1,1,1,1,1,1),(4,4,1,1,1,1,1,1,1,1),(5,5,1,1,1,1,1,1,1,1),(6,6,1,1,1,1,1,1,1,1),(7,7,1,1,1,1,1,1,1,1),(8,8,1,1,1,1,1,1,1,1),(9,9,1,1,1,1,1,1,1,1),(10,10,1,1,1,1,1,1,1,1);


INSERT INTO `mifostenant-default`.`m_fund` VALUES (1,'Mentors International',NULL),(2,'doTERRA',NULL);
INSERT INTO `mifostenant-default`.`m_organisation_currency` VALUES (26,'GTQ',2,NULL,'Guatemala Quetzal','Q','currency.GTQ');

INSERT INTO `mifostenant-default`.`m_office` 
	(`parent_id`, `name`, `opening_date`) 
VALUE (1,'OFFICE TBD', current_date())
; 


INSERT INTO 
	`mifostenant-default`.`m_office` (`parent_id`, `external_id`, `name`, `opening_date`) 
SELECT 
	1, ENCODEDKEY, name, CREATIONDATE 
FROM 
	`guatemala`.branch 
;    


UPDATE 
	`mifostenant-default`.`m_office` 
SET 
	`opening_date`= (SELECT CREATIONDATE FROM guatemala.client ORDER BY CREATIONDATE ASC LIMIT 1)
WHERE 
	`id`<>''; 
 ;


-- Fix the hierarchy issue in Mifos
UPDATE 
	`mifostenant-default`.`m_office` 
SET 
	`hierarchy`= concat('.', id, '.') 
WHERE 
	`id`<>1;



-- Back date office openings
update 
	`mifostenant-default`.m_office 
set 
	opening_date = DATE_SUB(opening_date, INTERVAL 10 YEAR)
where
	name <> ""
;


-- Clean up loan names
UPDATE `mifostenant-default`.`m_product_loan` SET `name`='Credito Grupal 2.5%' WHERE `id`='2';
UPDATE `mifostenant-default`.`m_product_loan` SET `name`='Crédito Individual Nueva Tasa' WHERE `id`='7';
UPDATE `mifostenant-default`.`m_product_loan` SET `name`='Credito Individual con intereses variables' WHERE `id`='10';
UPDATE `mifostenant-default`.`m_product_loan` SET `name`='Credito grupal con intereses variables' WHERE `id`='5';
UPDATE `mifostenant-default`.`m_product_loan` SET `name`='Credito Grupal' WHERE `id`='1';
UPDATE `mifostenant-default`.`m_product_loan` SET `name`='Credito Grupal Intereses Capitalizables' WHERE `id`='3';
UPDATE `mifostenant-default`.`m_product_loan` SET `name`='Crédito Individual' WHERE `id`='6';
UPDATE `mifostenant-default`.`m_product_loan` SET `name`='Crédito Invidividual Intereses Capitalizables' WHERE `id`='8';

UPDATE `guatemala`.`client` SET FIRSTNAME = REPLACE(FIRSTNAME, ',', ' ') LIMIT 60000;
UPDATE `guatemala`.`client` SET MIDDLENAME = REPLACE(MIDDLENAME, ',', ' ')LIMIT 60000;
UPDATE `guatemala`.`client` SET LASTNAME = REPLACE(LASTNAME, ',', ' ')LIMIT 60000;
UPDATE `guatemala`.`user` SET `LASTNAME`='M' WHERE `ENCODEDKEY`='8a9c49fd49f3bb6e014a0c71dcdb11f2';
UPDATE `guatemala`.`user` SET `FIRSTNAME`='Maria', `LASTNAME`='del Carmen Lara' WHERE `ENCODEDKEY`='8abc1aea45eb1c2a0145f783d6925b67';

UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a28acc84601431f0146056262dc7eba' WHERE `id`='1';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a1a2d2d4cea09a9014d018c134553a1' WHERE `id`='2';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a181b3b499d76ab0149a61db51d22bf' WHERE `id`='5';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a24a44347564bee014759805e8711d0' WHERE `id`='3';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a181b3b499d76ab0149a61cd2e42287' WHERE `id`='10';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a10ca994b09d039014b13c6f29a3b3b' WHERE `id`='4';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a28acc84601431f0146055db2be7bcb' WHERE `id`='6';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a133d884c062904014c0ac9d2196875' WHERE `id`='7';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a28acc84601431f0146055f0cb57c5c' WHERE `id`='8';


-- m_staff
-- Clean up Mifos Staff -> change geo locatoin to 'STAFF TBD' 
UPDATE 
	`guatemala`.`user` 
SET 
	-- `FIRSTNAME`='STAFF',
    `LASTNAME`='(TBD)'
    -- `id` = 42069
WHERE 
	lastname = "" -- To get rid of non people staff - some are just region names
	OR firstname = "Chiantla"
    OR firstname = "Tecpan"
    OR firstname = "Mambu"
    OR firstname = "API"
    OR firstname = "Cole"
limit 500
;


-- Put all the default TBD stuff in
INSERT INTO `mifostenant-default`.`m_staff` 
	(`is_loan_officer`, `office_id`, `firstname`, `lastname`, `display_name`) 
values (1, 1, 'STAFF', 'TBD', 'STAFF TBD')
;

-- Put all the default TBD stuff in
INSERT INTO 
	`mifostenant-default`.`m_staff` 
	(`is_loan_officer`, `office_id`, `firstname`, `lastname`, `display_name`,`external_id`) 
SELECT 
	1, 1, firstname, lastname, concat(lastname,", ",FIRSTNAME) as displayname, ENCODEDKEY 
FROM 
	`guatemala`.user 
/*
where 
 	lastname <> "" -- To get rid of non people staff - some are just region names
  	and firstname <> "Chiantla"
    and firstname <> "Tecpan"
    and firstname <> "Mambu"
    and firstname <> "API"
    and firstname <> "Cole"
*/
group by displayname
;


INSERT INTO `mifostenant-default`.`m_payment_type` 
( `value`, `description`, `is_cash_payment`, `order_position`) 
VALUES ( 'Migration', 'H Migration', '0', '1');



INSERT INTO `mifostenant-default`.`m_group` 
(
	`status_enum`, `activation_date`, `office_id`, `staff_id`, `level_id`, 
	`display_name`, `activatedon_userid`, `submittedon_date`, `submittedon_userid`
) 
VALUES 
( 
	300, DATE_FORMAT(date(DATE_SUB(curdate(),INTERVAL 10 YEAR)), '%Y-%m-%d'), 1,1,1,
	'CENTER TBD', 1,DATE_FORMAT(date(DATE_SUB(curdate(), INTERVAL 10 YEAR)), '%Y-%m-%d'), 1									  
)
;

-- ############################
-- ##############
-- END DATABASE PREP
-- ##############
-- ############################


-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- Client Migration
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
ALTER TABLE `mifostenant-default`.`m_client` 
CHANGE COLUMN `account_no` `account_no` VARCHAR(20) NULL ,
DROP INDEX `account_no_UNIQUE` ;

ALTER TABLE `mifostenant-default`.`m_client` 
DROP INDEX `mobile_no_UNIQUE` ;

INSERT INTO `mifostenant-default`.`m_client` 
	(
		`external_id`, `status_enum`, `mobile_no`, `activation_date`, `office_id`, `staff_id`, 
		`firstname`, `middlename`, `lastname`, `display_name`, `submittedon_userid`, 
		`activatedon_userid`
    ) 
SELECT 
    c.encodedkey                     as EXTERNAL_ID,
    300							 	 as status_enum,
    if(c.MOBILEPHONE1 = '0',
		null,c.mobilephone1) as mobile_no,
    DATE_FORMAT(date(LEAST(
		coalesce(c.CREATIONDATE, CURDATE()),
        coalesce(c.APPROVEDDATE, CURDATE()),
        coalesce(c.ACTIVATIONDATE, CURDATE()),
        coalesce(lad.DISBURSEMENTDATE, CURDATE())
	)), '%Y-%m-%d')                  as ACTIVATION_DATE,
	ifnull(o.id, 2)					 as OFFICE_ID, 
	COALESCE(ms.id , 1) 			 as STAFF_ID, 
	c.FIRSTNAME                      as FIRST_NAME, 
    c.LASTNAME                       as LAST_NAME, 
    COALESCE(c.MIDDLENAME, '')       as MIDDLE_NAME,
    concat(c.FIRSTNAME, ' ', 
		COALESCE(c.MIDDLENAME, ''), ' ',
        c.LASTNAME)					 as DISPLAY_NAME,
	1 								 as submittedon_userid,
    1 								 as activatedon_userid
				
from 
	guatemala.client c
	left join guatemala.branch b on c.ASSIGNEDBRANCHKEY = b.ENCODEDKEY
    left join `mifostenant-default`.m_office o on o.external_id = b.encodedkey
	left join guatemala.user s   on c.ASSIGNEDUSERKEY   = s.ENCODEDKEY
    left join `mifostenant-default`.m_staff ms on s.encodedkey = ms.external_id
    left join
    (
		SELECT * FROM (
			SELECT DISBURSEMENTDATE, ACCOUNTHOLDERKEY, ACCOUNTHOLDERTYPE
			FROM guatemala.loanaccount
			WHERE ACCOUNTHOLDERTYPE = 'CLIENT'
			ORDER BY DISBURSEMENTDATE asc
		) as t1
		GROUP BY ACCOUNTHOLDERKEY
    ) lad on c.ENCODEDKEY = lad.ACCOUNTHOLDERKEY
    
        -- Get the correct office for the group and give that to the client
    left join guatemala.groupmember gm on gm.clientkey = c.encodedkey 
	left join guatemala.`group` g on g.ENCODEDKEY = gm.groupkey
	left join guatemala.centre cn on cn.ENCODEDKEY = g.ASSIGNEDCENTREKEY
	left join guatemala.branch b2 on cn.ASSIGNEDBRANCHKEY = b2.ENCODEDKEY
;

-- fix a few things
update `mifostenant-default`.m_client
set 
	account_no = ID,
    office_joining_date = activation_date,
    submittedon_date = activation_date
where id <> ''
;

-- Update address
insert into `mifostenant-default`.m_note
(client_id, note, note_type_enum)
select
	c.id 										    	as client_id,
     concat('Address: ', a.line1, ' ', a.line2, 
 		', ', a.city, ', ', a.country, ', ', a.region) 	as note,

	100 												as note_type_enum
from `mifostenant-default`.m_client c 
left join `guatemala`.address a 
on a.parentkey = c.external_id 
;

SELECT * from `mifostenant-default`.m_client;
SELECT * from `guatemala`.address;

ALTER TABLE `mifostenant-default`.`m_client` 
CHANGE COLUMN `account_no` `account_no` VARCHAR(20) NOT NULL ,
ADD UNIQUE INDEX `account_no_UNIQUE` (`account_no` ASC);


-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- Center Migration
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
INSERT INTO `mifostenant-default`.`m_group` 
	(
		`external_id`, `status_enum`, `activation_date`, `office_id`, `staff_id`, `level_id`, 
		`display_name`, `activatedon_userid`, `submittedon_date`, `submittedon_userid`
    ) 
SELECT 
	b.encodedkey						 as external_id,
    300									 as status_enum,
    DATE_FORMAT(date(
		b.CREATIONDATE), '%Y-%m-%d') 	 as ACTIVATION_DATE,
	1									 as OFFICE_ID, 
    1	                                 as STAFF_ID,							
    1									 as level_id,
    concat('CENTER TBD','(', b.id, ')')  as DISPLAY_NAME,
    1									 as activatedon_userid,
    DATE_FORMAT(date(
		b.CREATIONDATE), '%Y-%m-%d') 	 as submittedon_date,
	1									 as submittedon_userid
from 
	guatemala.branch b
left join
    `mifostenant-default`.m_office mo on mo.external_id = b.id
UNION
select 
    c.ENCODEDKEY                         as external_id,
	300									 as status_enum,
	DATE_FORMAT(date(
	   c.CREATIONDATE), '%Y-%m-%d') 	 as ACTIVATION_DATE,
	mo.id						         as OFFICE_ID,
    1	                                 as STAFF_ID,							
    1									 as level_id,
    c.id 	                         	 as DISPLAY_NAME,
    1									 as activatedon_userid,
	DATE_FORMAT(date(
	   c.CREATIONDATE), '%Y-%m-%d') 	 as submittedon_date,
	1									 as submittedon_userid
from 
	guatemala.centre c 
left join guatemala.branch b on b.ENCODEDKEY = c.ASSIGNEDBRANCHKEY
left join `mifostenant-default`.m_office mo on mo.external_id = b.encodedkey
;


-- hierarchy, account_no
-- Fix the hierarchy issue in Mifos
UPDATE 
	`mifostenant-default`.`m_group` 
SET 
	`hierarchy`= concat('.', id, '.'),
    account_no = id
WHERE 
	`id`<>'';
    
    
    
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- Group Migration (988)
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
update guatemala.`group` 
set groupname = concat(GROUPNAME, ' (', id, ')')
where id in
(
    SELECT id
	FROM (select * from guatemala.`group`) as groupid
	GROUP BY groupname
	HAVING COUNT(*) > 1
)
limit 10000
;


INSERT INTO `mifostenant-default`.`m_group` 
	(
		`external_id`, `status_enum`, `activation_date`, `office_id`, `staff_id`, `level_id`, `parent_id`, 
		`display_name`, `activatedon_userid`, `submittedon_userid`
    ) 
SELECT 
    g.ENCODEDKEY                         as external_id,
	300									 as status_enum,
	DATE_FORMAT(date(LEAST(
		coalesce(g.CREATIONDATE, CURDATE()),
        coalesce(lad.DISBURSEMENTDATE, CURDATE())
	)), '%Y-%m-%d')                      as ACTIVATION_DATE,
	mo.id						         as OFFICE_ID,
    ms.id	                             as STAFF_ID,							
    2									 as level_id,
	ifnull(mc.id, 1) 					 as parentd_id,
    g.groupname 	                     as DISPLAY_NAME,
    1									 as activatedon_userid,
	1									 as submittedon_userid
from 
	guatemala.`group` g 
left join `mifostenant-default`.m_staff ms on ms.external_id = g.ASSIGNEDUSERKEY
left join `mifostenant-default`.m_group mc on mc.external_id = g.ASSIGNEDCENTREKEY
left join guatemala.branch b on b.ENCODEDKEY = g.ASSIGNEDBRANCHKEY
left join `mifostenant-default`.m_office mo on mo.external_id = b.encodedkey
left join
(
	SELECT * FROM (
		SELECT DISBURSEMENTDATE, ACCOUNTHOLDERKEY, ACCOUNTHOLDERTYPE
		FROM guatemala.loanaccount
		WHERE ACCOUNTHOLDERTYPE = 'GROUP'
		ORDER BY DISBURSEMENTDATE asc
	) as t1
	GROUP BY ACCOUNTHOLDERKEY
) lad on g.ENCODEDKEY = lad.ACCOUNTHOLDERKEY
group by
	g.encodedkey
;



-- Fix a few things
UPDATE 
	`mifostenant-default`.`m_group` 
SET 
	`hierarchy`= concat('.', parent_id, '.', id, '.'),
    account_no = id,
    submittedon_date = activation_date
WHERE 
	`level_id` = 2;
    
    
    
-- change back to Group.id after filling up groups
INSERT INTO `mifostenant-default`.m_group_client
	(`group_id`, `client_id`)
SELECT 
	mg.id		as group_id, 
    mc.id		as client_id 
FROM 
	guatemala.groupmember gm
left join `mifostenant-default`.m_group mg on mg.external_id = gm.groupkey
left join `mifostenant-default`.m_client mc on mc.external_id = gm.clientkey
;




-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- Group Loan Migration
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
ALTER TABLE `mifostenant-default`.`m_loan` 
CHANGE COLUMN `account_no` `account_no` VARCHAR(20) NULL DEFAULT NULL ,
DROP INDEX `loan_account_no_UNIQUE` ;



-- NEED TO ADD AT TTHE END OF THIS CALL!!!!
-- `total_expected_repayment_derived`, `total_expected_costofloan_derived`, `total_outstanding_derived`, account_no
-- Fix a few things
INSERT INTO `mifostenant-default`.m_loan 
( 
	`external_id`, `group_id`, `client_id`, `product_id`, `loan_officer_id`,  `principal_amount_proposed`, 
	`principal_amount`, `approved_principal`, `principal_disbursed_derived`,  `principal_outstanding_derived`,
	`nominal_interest_rate_per_period`, `annual_nominal_interest_rate`,`term_frequency`,  `number_of_repayments`, 
	`submittedon_date`, `approvedon_date`, `expected_disbursedon_date`, `disbursedon_date`, `interest_charged_derived`,

 -- DEFAULTS
 	`loan_status_id`,`fund_id`,`loan_type_enum`, `currency_code`,`currency_digits`, `currency_multiplesof`,`interest_calculated_in_period_enum`, 
	`allow_partial_period_interest_calcualtion`, `interest_period_frequency_enum`,`interest_method_enum`, `term_period_frequency_enum`, 
	`repay_every`, `repayment_period_frequency_enum`,`repayment_frequency_day_of_week_enum`, `amortization_method_enum`, `submittedon_userid`, 
	`approvedon_userid`, `disbursedon_userid`,  `total_charges_due_at_disbursement_derived`, `total_repayment_derived`, `principal_repaid_derived`, 
	`principal_writtenoff_derived`,`interest_repaid_derived`, `interest_waived_derived`,  `interest_writtenoff_derived`,`fee_charges_charged_derived`, 
	`fee_charges_repaid_derived`,`fee_charges_waived_derived`,`fee_charges_writtenoff_derived`, `fee_charges_outstanding_derived`, `penalty_charges_charged_derived`,
	`penalty_charges_repaid_derived`, `penalty_charges_waived_derived`,`penalty_charges_writtenoff_derived`, `penalty_charges_outstanding_derived`, 
	`total_waived_derived`, `total_writtenoff_derived`, `total_costofloan_derived`, total_outstanding_derived,`loan_transaction_strategy_id`, `is_npa`, `days_in_year_enum`,  
    `interest_recalculation_enabled`,  `loan_product_counter`, `days_in_month_enum`, `version`
)

select
	la.ENCODEDKEY											as external_id, 
	if(la.ACCOUNTHOLDERTYPE = 'CLIENT',null, mg.id)		 	as group_id,
	if(la.ACCOUNTHOLDERTYPE = 'CLIENT',mc.id, null)		 	as client_id,
	mpl.id										 			as product_id,														
	ms.id								 					as loan_officer_id,
	la.LOANAMOUNT											as principal_amount_proposed, 
	la.LOANAMOUNT											as principal_amount,
	la.LOANAMOUNT											as approved_principal, 
	la.LOANAMOUNT											as principal_disbursed_derived,  
	la.LOANAMOUNT											as principal_outstanding_derived,
-- 	if (la.INTERESTCHARGEFREQUENCY = 'EVERY_FOUR_WEEKS', 
-- 		ROUND(la.INTERESTRATE * 13 / 12, 6), 
--         la.INTERESTRATE) 									as nominal_interest_rate_per_period,
	la.INTERESTRATE 										as nominal_interest_rate_per_period,
    null 		    										as annual_nominal_interest_rate,
	la.REPAYMENTINSTALLMENTS								as term_frequency,
	la.REPAYMENTINSTALLMENTS								as number_of_repayments,
	date(la.DISBURSEMENTDATE) 								as submittedon_date, 
    date(la.DISBURSEMENTDATE) 								as approvedon_date, 
    date(la.DISBURSEMENTDATE) 								as expected_disbursedon_date, 
    date(la.DISBURSEMENTDATE) 								as disbursedon_date, 
	0														as interest_charged_derived,
    -- ------------------------------------------------------------------------------------
	-- ------------------------------------------------------------------------------------
	300 as `loan_status_id`,
	1 as `fund_id`,
	if(la.ACCOUNTHOLDERTYPE = 'CLIENT',1,2) as `loan_type_enum`, 
	'GTQ' as `currency_code`,
	2 as `currency_digits`,
	0 as `currency_multiplesof`,
	1 as `interest_calculated_in_period_enum`, 
	0 as `allow_partial_period_interest_calcualtion`, 
	2 as `interest_period_frequency_enum`,
	1 as `interest_method_enum`, 
	2 as `term_period_frequency_enum`, 
	1 as `repay_every`, 
	2 as `repayment_period_frequency_enum`,
	0 as `repayment_frequency_day_of_week_enum`, 
	1 as `amortization_method_enum`, 
	1 as `submittedon_userid`, 
	1 as `approvedon_userid`, 
	1 as `disbursedon_userid`, 
	-- ------------------------------------------------------------------------------------
	0 as `total_charges_due_at_disbursement_derived`, 
	0 as total_repayment_derived, 
	la.principalpaid as principal_repaid_derived, 
	0 as `principal_writtenoff_derived`,
	la.interestpaid as interest_repaid_derived, 
	0 as `interest_waived_derived`,  
	0 as `interest_writtenoff_derived`,
	0 as `fee_charges_charged_derived`, 
	la.feespaid as fee_charges_repaid_derived,
	0 as `fee_charges_waived_derived`,
	0 as `fee_charges_writtenoff_derived`, 
	0 as `fee_charges_outstanding_derived`, 
	0 as `penalty_charges_charged_derived`,
	0 as `penalty_charges_repaid_derived`, 
	0 as `penalty_charges_waived_derived`,
	0 as `penalty_charges_writtenoff_derived`, 
	0 as `penalty_charges_outstanding_derived`, 
	0 as `total_waived_derived`, 
	0 as `total_writtenoff_derived`, 
	0 as `total_costofloan_derived`, 
    0 as `total_outstanding_derived`,
	-- ------------------------------------------------------------------------------------   
	1 as `loan_transaction_strategy_id`, 
	0 as `is_npa`, 
    360 as `days_in_year_enum`,  
	0 as `interest_recalculation_enabled`,  
	1 as `loan_product_counter`, 
	30 as `days_in_month_enum`, 
	3 as `version`

from
	guatemala.loanaccount la
left join `mifostenant-default`.m_group mg on mg.external_id = la.ACCOUNTHOLDERKEY 
left join `mifostenant-default`.m_client mc on mc.external_id = la.ACCOUNTHOLDERKEY 
left join `mifostenant-default`.m_staff ms on ms.external_id = la.ASSIGNEDUSERKEY
left join `mifostenant-default`.m_product_loan mpl on mpl.external_id = la.PRODUCTTYPEKEY	
;



-- Fix a few things
UPDATE 
	`mifostenant-default`.`m_loan` 
SET 
	account_no = id
WHERE 
	id <> '';
    

ALTER TABLE `mifostenant-default`.`m_loan` 
CHANGE COLUMN `account_no` `account_no` VARCHAR(20) NOT NULL ,
ADD UNIQUE INDEX `account_no_UNIQUE` (`account_no` ASC);



-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- LOAN DISBURSEMENT TRANSACTIONS
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------

INSERT INTO `mifostenant-default`.`m_loan_transaction`
 (
	`loan_id`,  `office_id`,  `amount`, `outstanding_loan_balance_derived`,`is_reversed`, `transaction_type_enum`, 
	`appuser_id`, `manually_adjusted_or_reversed`, `transaction_date`,`submitted_on_date`, `created_date`
 ) 

SELECT 
	ml.id											as `loan_id`, 
    ifnull(mo.id,2)									as `office_id`, 
    ml.principal_outstanding_derived				as `amount`, 
	ml.principal_outstanding_derived				as `outstanding_loan_balance_derived`,
	0												as `is_reversed`, 
    1												as `transaction_type_enum`, 
	1												as `appuser_id`,
    0												as `manually_adjusted_or_reversed`, 
    ifnull(ml.disbursedon_date,	
		DATE_SUB(curdate(), INTERVAL 10 YEAR))		as `transaction_date`,
	ifnull(ml.disbursedon_date,	
		DATE_SUB(curdate(), INTERVAL 10 YEAR))		as `submitted_on_date`, 
	ifnull(ml.disbursedon_date,	
		DATE_SUB(curdate(), INTERVAL 10 YEAR))		as `created_date` 
from 
	`mifostenant-default`.m_loan ml
left join guatemala.loanaccount gla on ml.external_id = gla.encodedkey
left join `mifostenant-default`.m_office mo on gla.assignedbranchkey = mo.external_id
;
-- 	could add `payment_detail_id` with a script


-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- INTEREST TRANSACTIONS
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
INSERT INTO `mifostenant-default`.`m_loan_transaction`
 (
	`loan_id`,  `office_id`,  `amount`, `interest_portion_derived`,`is_reversed`, `transaction_type_enum`, 
	`appuser_id`, `manually_adjusted_or_reversed`, `transaction_date`,`submitted_on_date`, `created_date`
 ) 

SELECT 
	ml.id											as `loan_id`, 
    ifnull(mo.id,2)									as `office_id`, 
    ml.interest_charged_derived						as `amount`, 
	ml.interest_charged_derived						as `interest_portion_derived`,
	0												as `is_reversed`, 
    10												as `transaction_type_enum`, 
	1												as `appuser_id`,
    0												as `manually_adjusted_or_reversed`, 
    ifnull(ml.disbursedon_date,	
		DATE_SUB(curdate(), INTERVAL 10 YEAR))		as `transaction_date`,
	ifnull(ml.disbursedon_date,	
		DATE_SUB(curdate(), INTERVAL 10 YEAR))		as `submitted_on_date`, 
	ifnull(ml.disbursedon_date,	
		DATE_SUB(curdate(), INTERVAL 10 YEAR))		as `created_date` 
from 
	`mifostenant-default`.m_loan ml
left join guatemala.loanaccount gla on ml.external_id = gla.encodedkey
left join `mifostenant-default`.m_office mo on gla.assignedbranchkey = mo.external_id
;

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- LOAN SCHEDULE UPDATE
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------

INSERT INTO `mifostenant-default`.`m_loan_repayment_schedule`
(
    `loan_id`, `fee_charges_amount`, `duedate`, `principal_amount`,
    `interest_amount`, `completed_derived`, `createdby_id`,
    `created_date`, `lastmodified_date`, `lastmodifiedby_id`, `recalculated_interest_component`
 )

SELECT
	ml.id				                                as loan_id,
    phr.feesdue											as fee_charges_amount,
    DATE_FORMAT(date(phr.DUEDATE), '%Y-%m-%d')         	as duedate,
    phr.PRINCIPALDUE                                 	as principal_amount,
    phr.INTERESTDUE                                     as interest_amount,
    0                                                	as completed_derived,
    1                                                 	as createdby_id,
    current_timestamp()                             	as created_date,
    current_timestamp()                             	as lastmodified_date,
    1                                                 	as lastmodifiedby_id,
    0                                                 	as recalculated_interest_component
from
    guatemala.repayment phr, `mifostenant-default`.m_loan ml
where
     ml.external_id = phr.PARENTACCOUNTKEY
order by
     phr.PARENTACCOUNTKEY, phr.duedate
;


SET SQL_SAFE_UPDATES = 0;

drop table if exists`mifostenant-default`.table2 ;

CREATE TEMPORARY TABLE IF NOT EXISTS `mifostenant-default`.table2 AS 
(
	SELECT id, loan_id as l, duedate as d, 
	(
		select COUNT(*) + 1 from  `mifostenant-default`.`m_loan_repayment_schedule`
		where loan_id = l
		and duedate < d
	) as c 
	FROM `mifostenant-default`.`m_loan_repayment_schedule`
	group by id
);


UPDATE `mifostenant-default`.`m_loan_repayment_schedule`
JOIN `mifostenant-default`.table2 t2 on t2.id = `mifostenant-default`.`m_loan_repayment_schedule`.id
SET installment = t2.c
where `mifostenant-default`.m_loan_repayment_schedule.created_date <> ''
;

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- FEES
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
select
    lt.TYPE,
    lt.ENCODEDKEY,
    lt.PARENTACCOUNTKEY,
    lt.AMOUNT,
    DATE_FORMAT(date(lt.CREATIONDATE), '%d/%m/%Y') as date,
    ifnull(lt.REVERSALTRANSACTIONKEY,'') as reversalKey,
    la.REPAYMENTINSTALLMENTS,
	ml.id
from
    guatemala.loantransaction lt,
    guatemala.loanaccount la,
    `mifostenant-default`.m_loan ml
where
    lt.parentaccountkey = la.encodedkey
    and ml.external_id = la.ENCODEDKEY
    and la.ENCODEDKEY = lt.PARENTACCOUNTKEY
    and lt.type not like '%INTEREST%'
order by lt.parentaccountkey asc, lt.creationdate asc
 ;

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- GET CORRECT INTEREST
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------


CREATE TEMPORARY TABLE IF NOT EXISTS `mifostenant-default`.table3 AS (
SELECT PARENTACCOUNTKEY, SUM(INTERESTDUE) as interest
FROM guatemala.repayment 
Group By PARENTACCOUNTKEY
);


UPDATE `mifostenant-default`.m_loan ml
join `mifostenant-default`.table3 t3 on t3.PARENTACCOUNTKEY = ml.external_id
set ml.interest_charged_derived = t3.interest   
;
SET SQL_SAFE_UPDATES = 0;


-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- OUTSTANDING && TOTALS
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------

-- OUTSTANDING
UPDATE 
	`mifostenant-default`.`m_loan` 
SET 
	principal_outstanding_derived = (principal_disbursed_derived - principal_repaid_derived),
	interest_outstanding_derived = (interest_charged_derived - interest_repaid_derived),
	fee_charges_outstanding_derived = (fee_charges_charged_derived - fee_charges_repaid_derived),
    penalty_charges_outstanding_derived = (penalty_charges_charged_derived - penalty_charges_repaid_derived)
;


-- TOTALS
UPDATE 
	`mifostenant-default`.`m_loan` 
SET 
	total_expected_repayment_derived = (principal_disbursed_derived + interest_charged_derived + fee_charges_charged_derived + penalty_charges_charged_derived),
    total_repayment_derived = (principal_repaid_derived + interest_repaid_derived + fee_charges_repaid_derived + penalty_charges_repaid_derived),
    total_waived_derived = (interest_waived_derived + fee_charges_waived_derived + penalty_charges_waived_derived),
    total_writtenoff_derived = (principal_writtenoff_derived + interest_writtenoff_derived + fee_charges_writtenoff_derived + penalty_charges_writtenoff_derived),
    total_outstanding_derived = (principal_outstanding_derived + interest_outstanding_derived + fee_charges_outstanding_derived + penalty_charges_outstanding_derived)
    
    -- ?? Where is this used ??
    -- total_expected_costofloan_derived = 666
;
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- REPAYMENTS
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
select
    lt.TYPE,
    lt.ENCODEDKEY,
    lt.PARENTACCOUNTKEY,
    lt.AMOUNT,
    DATE_FORMAT(date(lt.CREATIONDATE), '%d/%m/%Y') as date,
    ifnull(lt.REVERSALTRANSACTIONKEY,'') as reversalKey,
    la.REPAYMENTINSTALLMENTS,
    ml.id,
    la.DISBURSEMENTDATE,
    la.CREATIONDATE
from
    guatemala.loantransaction lt,
    guatemala.loanaccount la,
    `mifostenant-default`.m_loan ml
where
    lt.parentaccountkey = la.encodedkey
    and ml.external_id = la.ENCODEDKEY
    and la.ENCODEDKEY = lt.PARENTACCOUNTKEY
    and lt.type = 'REPAYMENT'
order by lt.parentaccountkey asc, lt.creationdate asc
;
/*SELECT 
	-- la.ID,
	lt.`TYPE`,
    fa.AMOUNT as pdf_amt,
    lt.AMOUNT as lt_amt,
    if((lt.AMOUNT < 0), lt.AMOUNT, fa.AMOUNT) as real_amt,
    la.REPAYMENTINSTALLMENTS,
    lt.REVERSALTRANSACTIONKEY,
    fa.LOANPREDEFINEDFEEAMOUNTS_ENCODEDKEY_OWN,
    lt.PARENTACCOUNTKEY
FROM 
    guatemala.loantransaction lt,
    guatemala.loanaccount la
    -- guatemala.repayment r
where
    la.ENCODEDKEY = lt.PARENTACCOUNTKEY
    and lt.`type` = 'FEE'
order by lt.PARENTACCOUNTKEY, lt.CREATIONDATE	
;



insert into 
	`mifostenant-default`.m_loan_transaction 
	(
		loan_id,
		office_id,
		external_id,
		transaction_date,
		amount,
		submitted_on_date,
		created_date,
		appuser_id,
        transaction_type_enum,
        outstanding_loan_balance_derived,
        principal_portion_derived,
		interest_portion_derived
	)
 select 
	ml.id as loan_id,
    mo.id as office_id,
    glt.encodedkey as external_id,
    glt.entrydate as transaction_date,
    glt.amount as amount,
    glt.creationdate as submitted_on_date,
    glt.creationdate as created_date,
    1 as appuser_id,
    2 as transaction_type_enum,
    glt.balance as outstanding_loan_balance_derived,
    glt.principalamount as principal_portion_derived,
    glt.interestamount as interest_amount_derived
from 
    guatemala.loantransaction glt,
	`mifostenant-default`.m_loan ml,
    `mifostenant-default`.m_office mo
where
	glt.PARENTACCOUNTKEY = ml.external_id 
AND (
		glt.BRANCHKEY = mo.external_id
		or glt.BRANCHKEY is null
    )
AND glt.type = 'REPAYMENT'
order by glt.ENTRYDATE, glt.creationdate 
;

*/

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- 	FIX ID ISSUES 
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
update `mifostenant-default`.m_loan
set loan_status_id = 600 where principal_outstanding_derived = 0;

SET SQL_SAFE_UPDATES = 0;


-- people
update `mifostenant-default`.m_client mc
join guatemala.`client` c on mc.external_id = c.encodedkey
set mc.external_id = c.id
;

-- revert people
-- update `mifostenant-default`.m_client mc
-- join guatemala.`client` c on mc.external_id = c.id
-- set mc.external_id = c.encodedkey
-- ;

-- groups
update `mifostenant-default`.m_group mc
join guatemala.`group` c on mc.external_id = c.encodedkey
set mc.external_id = c.id
;

-- centers -> may have issues with double ids
update `mifostenant-default`.m_group mc
join guatemala.`centre` c on mc.external_id = c.encodedkey
set mc.external_id = c.id
;

-- loan accounts
update `mifostenant-default`.m_loan mc
join guatemala.`loanaccount` c on mc.external_id = c.encodedkey
set mc.external_id = c.id
;

-- savings accounts
update `mifostenant-default`.m_savings_account mc
join guatemala.`savingsaccount` c on mc.external_id = c.encodedkey
set mc.external_id = c.id
;
