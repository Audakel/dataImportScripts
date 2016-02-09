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


INSERT INTO `mifostenant-default`.`m_client` 
	(
		`external_id`, `status_enum`, `activation_date`, `office_id`, `staff_id`, 
		`firstname`, `middlename`, `lastname`, `display_name`, `submittedon_userid`, 
		`activatedon_userid`
    ) 
SELECT 
    c.encodedkey                     as EXTERNAL_ID,
    300							 	 as status_enum,
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
    left join `mifostenant-default`.m_office o on o.external_id = b.id
	left join guatemala.user s   on c.ASSIGNEDUSERKEY   = s.ENCODEDKEY
    left join `mifostenant-default`.m_staff ms on s.id = ms.external_id
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
		FROM loanaccount
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

INSERT INTO `mifostenant-default`.m_loan 
( 
	`external_id`, `group_id`, `product_id`, `loan_officer_id`,  `principal_amount_proposed`, 
	`principal_amount`, `approved_principal`, `principal_disbursed_derived`,  `principal_outstanding_derived`,
	`nominal_interest_rate_per_period`, `annual_nominal_interest_rate`,`term_frequency`,  `number_of_repayments`, 
	`submittedon_date`, `approvedon_date`, `expected_disbursedon_date`, `disbursedon_date`, `interest_charged_derived`,  `interest_outstanding_derived`,

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
	mg.id		 											as group_id,
	mpl.id										 			as product_id,														
	ms.id								 					as loan_officer_id,
	la.LOANAMOUNT											as principal_amount_proposed, 
	la.LOANAMOUNT											as principal_amount,
	la.LOANAMOUNT											as approved_principal, 
	la.LOANAMOUNT											as principal_disbursed_derived,  
	la.LOANAMOUNT											as principal_outstanding_derived,
	if (la.INTERESTCHARGEFREQUENCY = 'EVERY_FOUR_WEEKS', 
		ROUND(la.INTERESTRATE * 13 / 12, 6), 
        la.INTERESTRATE) 									as nominal_interest_rate_per_period,
    null 		    										as annual_nominal_interest_rate,
	la.REPAYMENTINSTALLMENTS								as term_frequency,
	la.REPAYMENTINSTALLMENTS								as number_of_repayments,
	date(la.DISBURSEMENTDATE) 								as submittedon_date, 
    date(la.DISBURSEMENTDATE) 								as approvedon_date, 
    date(la.DISBURSEMENTDATE) 								as expected_disbursedon_date, 
    date(la.DISBURSEMENTDATE) 								as disbursedon_date, 
	la.INTERESTDUE											as interest_charged_derived, 
	la.INTERESTDUE											as interest_outstanding_derived,
    -- ------------------------------------------------------------------------------------
	-- ------------------------------------------------------------------------------------
	300 as `loan_status_id`,
	1 as `fund_id`,
	2 as `loan_type_enum`, 
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
	0 as `total_charges_due_at_disbursement_derived`, 
	0 as `total_repayment_derived`, 
	0 as `principal_repaid_derived`, 
	0 as `principal_writtenoff_derived`,
	0 as `interest_repaid_derived`, 
	0 as `interest_waived_derived`,  
	0 as `interest_writtenoff_derived`,
	0 as `fee_charges_charged_derived`, 
	0 as `fee_charges_repaid_derived`,
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
      as total_outstanding_derived,
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
left join `mifostenant-default`.m_staff ms on ms.external_id = la.ASSIGNEDUSERKEY
left join `mifostenant-default`.m_product_loan mpl on mpl.external_id = la.PRODUCTTYPEKEY
where 
	la.ACCOUNTHOLDERTYPE = 'GROUP'
;


-- NEED TO ADD AT TTHE END OF THIS CALL!!!!
-- `total_expected_repayment_derived`, `total_expected_costofloan_derived`, `total_outstanding_derived`, account_no
-- Fix a few things
/*
UPDATE 
	`mifostenant-default`.`m_loan` 
SET 
	account_no = id,
    total_expected_repayment_derived = (principal_amount + interest_charged_derived),
    total_expected_costofloan_derived = interest_charged_derived,
    total_outstanding_derived = (principal_amount + interest_charged_derived)
WHERE 
	id <> '';
*/    
    
    
    
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- INDIVIDUAL LOANS
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
INSERT INTO `mifostenant-default`.m_loan 
( 
	`external_id`, `client_id`, `product_id`, `loan_officer_id`,  `principal_amount_proposed`, 
	`principal_amount`, `approved_principal`, `principal_disbursed_derived`,  `principal_outstanding_derived`,
	`nominal_interest_rate_per_period`, `annual_nominal_interest_rate`,`term_frequency`,  `number_of_repayments`, 
	`submittedon_date`, `approvedon_date`, `expected_disbursedon_date`, `disbursedon_date`, `interest_charged_derived`,  `interest_outstanding_derived`,

 -- DEFAULTS
 	`loan_status_id`,`fund_id`,`loan_type_enum`, `currency_code`,`currency_digits`, `currency_multiplesof`,`interest_calculated_in_period_enum`, 
	`allow_partial_period_interest_calcualtion`, `interest_period_frequency_enum`,`interest_method_enum`, `term_period_frequency_enum`, 
	`repay_every`, `repayment_period_frequency_enum`,`repayment_frequency_day_of_week_enum`, `amortization_method_enum`, `submittedon_userid`, 
	`approvedon_userid`, `disbursedon_userid`,  `total_charges_due_at_disbursement_derived`, `total_repayment_derived`, `principal_repaid_derived`, 
	`principal_writtenoff_derived`,`interest_repaid_derived`, `interest_waived_derived`,  `interest_writtenoff_derived`,`fee_charges_charged_derived`, 
	`fee_charges_repaid_derived`,`fee_charges_waived_derived`,`fee_charges_writtenoff_derived`, `fee_charges_outstanding_derived`, `penalty_charges_charged_derived`,
	`penalty_charges_repaid_derived`, `penalty_charges_waived_derived`,`penalty_charges_writtenoff_derived`, `penalty_charges_outstanding_derived`, 
	`total_waived_derived`, `total_writtenoff_derived`, `total_costofloan_derived`, total_outstanding_derived, `loan_transaction_strategy_id`, `is_npa`, `days_in_year_enum`,  
    `interest_recalculation_enabled`,  `loan_product_counter`, `days_in_month_enum`, `version`
)

select
	la.ENCODEDKEY											as external_id, 
	mc.id		 											as client_id,
	mpl.id										 			as product_id,														
	ms.id								 					as loan_officer_id,
	la.LOANAMOUNT											as principal_amount_proposed, 
	la.LOANAMOUNT											as principal_amount,
	la.LOANAMOUNT											as approved_principal, 
	la.LOANAMOUNT											as principal_disbursed_derived,  
	la.LOANAMOUNT											as principal_outstanding_derived,
	if (la.INTERESTCHARGEFREQUENCY = 'EVERY_FOUR_WEEKS', 
		ROUND(la.INTERESTRATE * 13 / 12, 6), 
        la.INTERESTRATE) 									as nominal_interest_rate_per_period,
    null 		    										as annual_nominal_interest_rate,
	la.REPAYMENTINSTALLMENTS								as term_frequency,
	la.REPAYMENTINSTALLMENTS								as number_of_repayments,
	date(la.DISBURSEMENTDATE) 								as submittedon_date, 
    date(la.DISBURSEMENTDATE) 								as approvedon_date, 
    date(la.DISBURSEMENTDATE) 								as expected_disbursedon_date, 
    date(la.DISBURSEMENTDATE) 								as disbursedon_date, 
	la.INTERESTDUE											as interest_charged_derived, 
	la.INTERESTDUE											as interest_outstanding_derived,
    -- ------------------------------------------------------------------------------------
	-- ------------------------------------------------------------------------------------
	300 as `loan_status_id`,
	1 as `fund_id`,
	1 as `loan_type_enum`, 
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
	0 as `total_charges_due_at_disbursement_derived`, 
	0 as `total_repayment_derived`, 
	0 as `principal_repaid_derived`, 
	0 as `principal_writtenoff_derived`,
	0 as `interest_repaid_derived`, 
	0 as `interest_waived_derived`,  
	0 as `interest_writtenoff_derived`,
	0 as `fee_charges_charged_derived`, 
	0 as `fee_charges_repaid_derived`,
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
    la.  as total_outstanding_derived,
	1 as `loan_transaction_strategy_id`, 
	0 as `is_npa`, 
    360 as `days_in_year_enum`,  
	0 as `interest_recalculation_enabled`,  
	1 as `loan_product_counter`, 
	30 as `days_in_month_enum`, 
	3 as `version`

from
	guatemala.loanaccount la
left join `mifostenant-default`.m_client mc on mc.external_id = la.ACCOUNTHOLDERKEY 
left join `mifostenant-default`.m_staff ms on ms.external_id = la.ASSIGNEDUSERKEY
left join `mifostenant-default`.m_product_loan mpl on mpl.external_id = la.PRODUCTTYPEKEY
where 
	la.ACCOUNTHOLDERTYPE = 'CLIENT'
;

-- Fix a few things
UPDATE 
	`mifostenant-default`.`m_loan` 
SET 
	account_no = id,
    total_expected_repayment_derived = (principal_amount + interest_charged_derived),
    total_expected_costofloan_derived = interest_charged_derived
    -- ,
    -- total_outstanding_derived = (principal_amount + interest_charged_derived)
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
-- FEES
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------

select * from `mifostenant-default`.m_loan_transaction; -- 5358

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


    -- la.ACCOUNTSTATE like '%CLOSED%'
	-- la.accountholdertype = 'GROUP'
	-- lt.parentaccountkey= '8a9d7e284b75fe4b014b7a05572a0b1b' or
	-- lt.parentaccountkey= '8a9c4d8c4c2a3654014c2da9018a6e9e' or
	-- lt.parentaccountkey= '8a36219649e44d120149e8c4c86f50fa' or
	-- lt.parentaccountkey= '8a9d992d4c1acee0014c2ed7d6cb14ad' or
	-- lt.parentaccountkey= '8a10d7894b2f253a014b317dcb8e0e0d' or
	-- lt.parentaccountkey= '8a9c4d8c4c2a3654014c2d8dd19c45ec' or
	-- lt.parentaccountkey= '8aa85edc4ae70c4a014aefac6cbf5b03' or
	-- closed
	-- lt.parentaccountkey= '8a9d992d4c1acee0014c2ed7d6cb14ad' or
	-- lt.parentaccountkey= '8a36219649e44d120149e8c4c86f50fa' or
	-- lt.parentaccountkey= '8a8188ae51f3d72d0151f90675461d5f'



SELECT * from 
SELECT * from guatemala.loanaccount where ENCODEDKEY = '8a9c4d8c4c2a3654014c2da9018a6e9e';
SELECT * from guatemala.loanaccount where ACCOUNTSTATE like '%CLOSED%';

select lt.type, count(lt.type), round(max(lt.amount)) as max, round(min(lt.amount)) as min, la.ACCOUNTHOLDERTYPE, la.ACCOUNTSTATE 
	from (guatemala.loantransaction lt, guatemala.loanaccount la)
    where la.ENCODEDKEY = lt.PARENTACCOUNTKEY and
    la.accountholdertype = 'CLIENT'
    group by type;



-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- LOAN SCHEDULE UPDATE
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------

INSERT INTO `mifostenant-default`.`m_loan_repayment_schedule`
(
    `loan_id`, `duedate`, `principal_amount`,
    `interest_amount`, `completed_derived`, `createdby_id`,
    `created_date`, `lastmodified_date`, `lastmodifiedby_id`, `recalculated_interest_component`

 )

SELECT
	ml.id				                                as loan_id,
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


CREATE TEMPORARY TABLE IF NOT EXISTS table2 AS (
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
JOIN table2 t2 on t2.id = `mifostenant-default`.`m_loan_repayment_schedule`.id
SET installment = t2.c
where m_loan_repayment_schedule.created_date <> ''
;



SELECT * from `mifostenant-default-api`.m_loan_repayment_schedule;
SELECT * from guatemala.repayment;



-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- ?
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
SELECT 
	la.ID,
	lt.`TYPE`,
    fa.AMOUNT as pdf_amt,
    lt.AMOUNT as lt_amt,
    if((lt.AMOUNT < 0), lt.AMOUNT, fa.AMOUNT) as real_amt,
    la.REPAYMENTINSTALLMENTS,
    lt.REVERSALTRANSACTIONKEY,
    fa.LOANPREDEFINEDFEEAMOUNTS_ENCODEDKEY_OWN,
    lt.PARENTACCOUNTKEY
FROM 
	guatemala.predefinedfeeamount fa,
    guatemala.loantransaction lt,
    guatemala.loanaccount la
    -- guatemala.repayment r
where
	fa.LOANPREDEFINEDFEEAMOUNTS_ENCODEDKEY_OWN = lt.ENCODEDKEY
    and la.ENCODEDKEY = lt.PARENTACCOUNTKEY
    and lt.`type` = 'FEE'
order by lt.PARENTACCOUNTKEY, lt.CREATIONDATE	
;

select * from guatemala.repayment;
select * from guatemala.loantransaction where PARENTACCOUNTKEY = '8a10ca994b09d039014b0e1d85e56713';
select * from guatemala.loanaccount where REPAYMENTINSTALLMENTS = 1;
select * from guatemala.predefinedfeeamount;


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


update `mifostenant-default`.m_loan
set ()
	


select * from guatemala.loantransaction where type = 'REPAYMENT'; -- 8023
select * from guatemala.loantransaction where type = 'REPAYMENT' and BRANCHKEY is null; -- 0
select * from guatemala.loantransaction where type = 'REPAYMENT' and PARENTACCOUNTKEY is null; -- 0
