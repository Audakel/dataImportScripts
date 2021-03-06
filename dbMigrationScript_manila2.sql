-- ####################################################################################
-- ##############
-- START
-- ##############
-- ####################################################################################



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
    
    DO BY HAND IN FUTURE
    - INSERT INTO `mifostenant-default`.`m_fund` 
    - INSERT INTO `mifostenant-default`.`m_holiday`
    - m_holiday_office
    - `m_organisation_currency` 
    - make a python script to make a temp table to clean up reversal keys - then migrate that table
    - _derived fields in m_loan such as fees_written_off_derived needs updating, but how do we calculate that?
    - what do we do about transaction type REPAYMENT_ADJUSTMENT
    - Interest problems:
		-Fix 0000-00-00 date problem in savings account approval date 
        -Why are some of the interest jobs still failing
        -Set the date to start calculating interest to be today
*/


-- create database `mifostenant-default`;

INSERT INTO `mifostenant-default`.`m_fund` VALUES (1,'Mentors Philippines',NULL);

INSERT INTO `mifostenant-default`.`m_organisation_currency` VALUES (23,'PHP',2,NULL,'Philippine Peso',NULL,'currency.PHP');

INSERT INTO `mifostenant-default`.`m_office`
    (`parent_id`, `name`, `opening_date`)
VALUE (1,'OFFICE TBD', current_date())
;


INSERT INTO
    `mifostenant-default`.`m_office` (`parent_id`, `external_id`, `name`, `opening_date`)
SELECT
    1, ENCODEDKEY, name, CREATIONDATE
FROM
    `input_db`.branch
;   


UPDATE
    `mifostenant-default`.`m_office`
SET
    `opening_date`= (SELECT CREATIONDATE FROM input_db.client ORDER BY CREATIONDATE ASC LIMIT 1)
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



-- Back date office openings to avoid api errors
update
    `mifostenant-default`.m_office
set
    opening_date = DATE_SUB(opening_date, INTERVAL 10 YEAR)
where
    name <> ""
;



-- Clean up loan names
UPDATE `mifostenant-default`.`m_product_loan` SET `name`='Special Individual Loan' WHERE `id`='6';
UPDATE `mifostenant-default`.`m_product_loan` SET `name`='Business Opportunity Loan' WHERE `id`='2';


UPDATE `input_db`.`client` SET FIRSTNAME = REPLACE(FIRSTNAME, ',', ' ') LIMIT 60000;
UPDATE `input_db`.`client` SET MIDDLENAME = REPLACE(MIDDLENAME, ',', ' ')LIMIT 60000;
UPDATE `input_db`.`client` SET LASTNAME = REPLACE(LASTNAME, ',', ' ')LIMIT 60000;
UPDATE `input_db`.`user` SET `FIRSTNAME`='Roland' WHERE `ENCODEDKEY`='8a28afc7474813a4014757b332b420e5';


-- m_staff
-- Clean up Mifos Staff -> change geo locatoin to 'STAFF TBD'
UPDATE
    `input_db`.`user`
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
    `input_db`.user
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

INSERT INTO `mifostenant-default`.`m_holiday` VALUES (1,'HOLY WEEK 2008','2008-03-17 00:00:00','2008-03-20 00:00:00','2008-03-21 00:00:00',300,0,'Holy Week 2008'),(2,'CHRISTMAS BREAK 2008','2008-12-22 00:00:00','2009-01-02 00:00:00','2009-01-03 00:00:00',300,0,'Christmas  Break 2008'),(3,'HOLY WEEK 2009','2009-04-06 00:00:00','2009-04-10 00:00:00','2009-04-11 00:00:00',300,0,'Holy  Week 2009'),(4,'CHRISTMAS BREAK 2009','2009-12-21 00:00:00','2010-01-01 00:00:00','2010-01-02 00:00:00',300,0,'CHRISTMAS BREAK 2009'),(5,'HOLY WEEK 2010','2010-03-29 00:00:00','2010-04-02 00:00:00','2010-04-03 00:00:00',300,0,'HOLY WEEK 2010'),(6,'CHRISTMAS BREAK 2010','2010-12-20 00:00:00','2010-12-31 00:00:00','2011-01-01 00:00:00',300,0,'Christmas Break 2010'),(7,'HOLY WEEK 2011','2011-04-18 00:00:00','2011-04-22 00:00:00','2011-04-23 00:00:00',300,0,'Holy Week 2011'),(8,'ALL SAINTS DAY 2011','2011-10-31 00:00:00','2011-11-04 00:00:00','2011-11-05 00:00:00',300,0,'ALL SAINTS DAY 2011'),(9,'CHRISTMAS BREAK 2011','2011-12-19 00:00:00','2012-01-06 00:00:00','2012-01-07 00:00:00',300,0,'CHRISTMAS BREAK 2011'),(10,'HOLY WEEK 2012','2012-04-02 00:00:00','2012-04-06 00:00:00','2012-04-07 00:00:00',300,0,'HOLY WEEK 2012'),(11,'ALL SAINTS DAY 2012','2012-10-29 00:00:00','2012-11-02 00:00:00','2012-11-03 00:00:00',300,0,'ALL SAINTS DAY 2012'),(12,'CHRISTMAS BREAK 2012','2012-12-24 00:00:00','2013-01-04 00:00:00','2013-01-05 00:00:00',300,0,'CHRISTMAS BREAK 2012'),(13,'HOLY WEEK 2013','2013-03-25 00:00:00','2013-03-29 00:00:00','2013-03-30 00:00:00',300,0,'HOLY WEEK 2013'),(14,'ALL SAINTS DAY 2013','2013-10-28 00:00:00','2013-10-28 00:00:00','2013-10-29 00:00:00',600,0,'ALL SAINTS DAY 2013'),(15,'CHRISTMAS BREAK 2013','2013-12-23 00:00:00','2014-01-03 00:00:00','2014-01-04 00:00:00',300,0,'CHRISTMAS BREAK 2013'),(17,'ALL SAINTS DAY 2013_A','2013-10-28 00:00:00','2013-11-01 00:00:00','2013-11-02 00:00:00',300,0,'ALL SAINTS DAY 2013'),(18,'HOLY WEEK 2014','2014-04-14 00:00:00','2014-04-18 00:00:00','2014-04-19 00:00:00',300,0,'HOLY WEEK 2014'),(19,'ALL SAINTS DAY 2014','2014-10-27 00:00:00','2014-10-31 00:00:00','2014-11-01 00:00:00',300,0,'ALL SAINTS DAY 2014'),(20,'CHRISTMAS BREAK 2014','2014-12-22 00:00:00','2015-01-02 00:00:00','2015-01-03 00:00:00',300,0,'CHRISTMAS BREAK  2015'),(21,'HOLY WEEK 2015','2015-03-30 00:00:00','2015-04-03 00:00:00','2015-04-04 00:00:00',300,0,'HOLY WEEK 2015'),(22,'ALL SAINTS DAY 2015','2015-11-02 00:00:00','2015-11-06 00:00:00','2015-11-07 00:00:00',300,0,'ALL SAINTS DAY 2015'),(23,'CHRISTMAS BREAK 2015','2015-12-21 00:00:00','2016-01-01 00:00:00','2016-01-02 00:00:00',300,0,'CHRISTMAS BREAK 2016'),(24,'HOLY WEEK 2016','2016-03-20 00:00:00','2016-03-26 00:00:00','2016-03-27 00:00:00',300,0,'HOLY WEEK 2016'),(25,'ALL SAINTS DAY 2016','2016-10-30 00:00:00','2016-11-05 00:00:00','2016-11-06 00:00:00',300,0,'ALL SAINTS DAY 2016'),(26,'CHRISTMAS BREAK 2016','2016-12-26 00:00:00','2017-01-06 00:00:00','2017-01-07 00:00:00',300,0,'CHRISTMAS BREAK 2016');
-- INSERT INTO `mifostenant-default`.`m_holiday_office` VALUES (1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,10),(1,11),(1,12),(1,13),(1,14),(1,15),(1,16),(1,17),(1,18),(2,2),(2,3),(2,4),(2,5),(2,6),(2,7),(2,8),(2,10),(2,11),(2,12),(2,13),(2,14),(2,15),(2,16),(2,17),(2,18),(3,2),(3,3),(3,4),(3,5),(3,6),(3,7),(3,8),(3,10),(3,11),(3,12),(3,13),(3,14),(3,15),(3,16),(3,17),(3,18),(4,2),(4,3),(4,4),(4,5),(4,6),(4,7),(4,8),(4,10),(4,11),(4,12),(4,13),(4,14),(4,15),(4,16),(4,17),(4,18),(5,2),(5,3),(5,4),(5,5),(5,6),(5,7),(5,8),(5,10),(5,11),(5,12),(5,13),(5,14),(5,15),(5,16),(5,17),(5,18),(6,2),(6,3),(6,4),(6,5),(6,6),(6,7),(6,8),(6,10),(6,11),(6,12),(6,13),(6,14),(6,15),(6,16),(6,17),(6,18),(7,2),(7,3),(7,4),(7,5),(7,6),(7,7),(7,8),(7,10),(7,11),(7,12),(7,13),(7,14),(7,15),(7,16),(7,17),(7,18),(8,2),(8,3),(8,4),(8,5),(8,6),(8,7),(8,8),(8,10),(8,11),(8,12),(8,13),(8,14),(8,15),(8,16),(8,17),(8,18),(9,2),(9,3),(9,4),(9,5),(9,6),(9,7),(9,8),(9,10),(9,11),(9,12),(9,13),(9,14),(9,15),(9,16),(9,17),(9,18),(10,2),(10,3),(10,4),(10,5),(10,6),(10,7),(10,8),(10,10),(10,11),(10,12),(10,13),(10,14),(10,15),(10,16),(10,17),(10,18),(11,2),(11,3),(11,4),(11,5),(11,6),(11,7),(11,8),(11,10),(11,11),(11,12),(11,13),(11,14),(11,15),(11,16),(11,17),(11,18),(12,2),(12,3),(12,4),(12,5),(12,6),(12,7),(12,8),(12,10),(12,11),(12,12),(12,13),(12,14),(12,15),(12,16),(12,17),(12,18),(13,2),(13,3),(13,4),(13,5),(13,6),(13,7),(13,8),(13,10),(13,11),(13,12),(13,13),(13,14),(13,15),(13,16),(13,17),(13,18),(14,2),(14,3),(14,4),(14,5),(14,6),(14,7),(14,8),(14,10),(14,11),(14,12),(14,13),(14,14),(14,15),(14,16),(14,17),(14,18),(15,2),(15,3),(15,4),(15,5),(15,6),(15,7),(15,8),(15,10),(15,11),(15,12),(15,13),(15,14),(15,15),(15,16),(15,17),(15,18),(17,2),(17,3),(17,4),(17,5),(17,6),(17,7),(17,8),(17,10),(17,11),(17,12),(17,13),(17,14),(17,15),(17,16),(17,17),(17,18),(18,2),(18,3),(18,4),(18,5),(18,6),(18,7),(18,8),(18,10),(18,11),(18,12),(18,13),(18,14),(18,15),(18,16),(18,17),(18,18),(19,2),(19,3),(19,4),(19,5),(19,6),(19,7),(19,8),(19,10),(19,11),(19,12),(19,13),(19,14),(19,15),(19,16),(19,17),(19,18),(20,2),(20,3),(20,4),(20,5),(20,6),(20,7),(20,8),(20,10),(20,11),(20,12),(20,13),(20,14),(20,15),(20,16),(20,17),(20,18),(21,2),(21,3),(21,4),(21,5),(21,6),(21,7),(21,8),(21,10),(21,11),(21,12),(21,13),(21,14),(21,15),(21,16),(21,17),(21,18),(22,2),(22,3),(22,4),(22,5),(22,6),(22,7),(22,8),(22,10),(22,11),(22,12),(22,13),(22,14),(22,15),(22,16),(22,17),(22,18),(23,2),(23,3),(23,4),(23,5),(23,6),(23,7),(23,8),(23,10),(23,11),(23,12),(23,13),(23,14),(23,15),(23,16),(23,17),(23,18),(24,2),(24,3),(24,4),(24,5),(24,6),(24,7),(24,8),(24,10),(24,11),(24,12),(24,13),(24,14),(24,15),(24,16),(24,17),(24,18),(25,2),(25,3),(25,4),(25,5),(25,6),(25,7),(25,8),(25,10),(25,11),(25,12),(25,13),(25,14),(25,15),(25,16),(25,17),(25,18),(26,2),(26,3),(26,4),(26,5),(26,6),(26,7),(26,8),(26,10),(26,11),(26,12),(26,13),(26,14),(26,15),(26,16),(26,17),(26,18);


INSERT INTO `mifostenant-default`.`m_product_loan` (  `id`,  `short_name`,  `currency_code`,  `currency_digits`,  `currency_multiplesof`,  `principal_amount`,  `min_principal_amount`,  `max_principal_amount`,  `arrearstolerance_amount`,  `name`,  `description`,  `fund_id`,  `is_linked_to_floating_interest_rates`,  `nominal_interest_rate_per_period`,  `min_nominal_interest_rate_per_period`,  `max_nominal_interest_rate_per_period`,  `interest_period_frequency_enum`,  `annual_nominal_interest_rate`,  `interest_method_enum`,  `interest_calculated_in_period_enum` ,  `repay_every`,  `repayment_period_frequency_enum`,  `number_of_repayments`,  `min_number_of_repayments`,  `max_number_of_repayments`,  `grace_on_principal_periods`,  `grace_on_interest_periods`,  `grace_interest_free_periods`,  `amortization_method_enum`,  `accounting_type`,  `loan_transaction_strategy_id`,  `external_id`,  `include_in_borrower_cycle`,  `use_borrower_cycle`,  `start_date`,  `close_date`,  `allow_multiple_disbursals`,  `max_disbursals`,  `max_outstanding_loan_balance`,  `grace_on_arrears_ageing`,  `overdue_days_for_npa`,  `days_in_month_enum` ,  `days_in_year_enum` ,  `interest_recalculation_enabled`,  `min_days_between_disbursal_and_first_repayment`,  `hold_guarantee_funds`,  `principal_threshold_for_last_installment` ,  `account_moves_out_of_npa_only_on_arrears_completion`,  `can_define_fixed_emi_amount`,  `instalment_amount_in_multiples_of`) VALUES (1,'GL','PHP',0,0,5000.000000,1000.000000,75000.000000,NULL,'General Loan','Intended for business use only',NULL,'\0',4.333333,4.333333,4.333333,2,51.999996,1,1,1,1,25,9,65,NULL,NULL,NULL,1,1,6,NULL,1,0,NULL,NULL,0,NULL,NULL,0,121,1,1,0,3,0,0.00,0,1,NULL),(2,'BOL','PHP',0,0,5000.000000,1000.000000,5000.000000,0.000000,'Business Loan',NULL,NULL,'\0',7.236667,7.236667,7.236667,2,86.840000,1,1,1,1,12,2,15,NULL,NULL,NULL,1,1,1,NULL,1,0,NULL,NULL,0,NULL,NULL,0,121,1,1,0,3,0,0.00,0,1,NULL),(3,'MPL','PHP',0,0,5000.000000,1000.000000,30000.000000,NULL,'Multi-Purpose Loan',NULL,NULL,'\0',4.333333,4.333333,4.333333,2,52.000000,1,1,1,1,25,20,35,NULL,NULL,NULL,1,1,1,NULL,1,0,NULL,NULL,0,NULL,NULL,0,121,1,1,0,NULL,0,0.00,0,0,NULL),(4,'HUL','PHP',0,0,10000.000000,1000.000000,30000.000000,NULL,'Housing and Utility Loan',NULL,NULL,'\0',2.166667,2.166667,2.166667,2,26.000000,1,1,1,1,50,20,65,NULL,NULL,NULL,1,1,1,NULL,1,0,NULL,NULL,0,NULL,NULL,0,121,1,1,0,3,0,0.00,0,0,NULL),(5,'IL','PHP',0,0,5000.000000,5000.000000,10000.000000,NULL,'Individual Loan',NULL,NULL,'\0',4.333333,4.333333,4.333333,2,52.000000,1,1,1,1,50,25,50,NULL,NULL,NULL,1,1,1,NULL,1,0,NULL,NULL,0,NULL,NULL,0,121,1,1,0,NULL,0,0.00,0,1,NULL),(6,'IL2','PHP',0,0,20000.000000,20000.000000,150000.000000,NULL,'Individual Loan 2',NULL,NULL,'\0',3.250000,3.250000,3.250000,2,39.000000,1,1,1,1,25,12,50,NULL,NULL,NULL,1,1,1,NULL,0,0,NULL,NULL,0,NULL,NULL,0,121,1,1,0,3,0,0.00,0,1,NULL),(7,'GFL','PHP',0,0,1000.000000,500.000000,10000.000000,NULL,'Group Fund Loan',NULL,NULL,'\0',0.000000,0.000000,0.000000,2,0.000000,1,1,1,1,12,1,12,NULL,NULL,NULL,1,1,1,NULL,0,0,NULL,NULL,0,NULL,NULL,0,121,1,1,0,3,0,0.00,0,1,NULL),(8,'CFLA','PHP',0,0,3000.000000,3000.000000,3000.000000,NULL,'Center Fund Loan Assistance',NULL,NULL,'\0',0.000000,0.000000,0.000000,2,0.000000,1,1,1,1,12,12,50,NULL,NULL,NULL,1,1,1,NULL,0,0,NULL,NULL,0,NULL,NULL,0,121,1,1,0,3,0,0.00,0,0,NULL);
INSERT INTO `mifostenant-default`.`m_savings_product` (  `id` ,  `name`,  `short_name`,  `description`,  `deposit_type_enum`,  `currency_code` ,  `currency_digits`,  `currency_multiplesof`,  `nominal_annual_interest_rate`,  `interest_compounding_period_enum`,  `interest_posting_period_enum` ,  `interest_calculation_type_enum`,  `interest_calculation_days_in_year_type_enum`,  `min_required_opening_balance` ,  `lockin_period_frequency` ,  `lockin_period_frequency_enum`,  `accounting_type` ,  `withdrawal_fee_amount`,  `withdrawal_fee_type_enum`,  `withdrawal_fee_for_transfer`,  `allow_overdraft` ,  `overdraft_limit` ,  `min_required_balance`,  `enforce_min_required_balance`,  `min_balance_for_interest_calculation`) VALUES (1,'GF 5%','GF 5','Deduction on every General Loan',100,'PHP',0,0,0.000000,1,4,1,365,50.000000,NULL,NULL,1,NULL,NULL,0,0,NULL,NULL,0,NULL),(2,'Personal Savings','PS','Personal Savings of Clients',100,'PHP',0,0,0.000000,1,5,1,365,50.000000,NULL,NULL,1,NULL,NULL,0,0,0.000000,0.000000,0,1000.000000),(3,'GF Weekly','GFW','GF Savings of Clients',100,'PHP',0,0,0.000000,1,4,1,365,30.000000,NULL,NULL,1,NULL,NULL,0,0,0.000000,0.000000,0,NULL),(4,'Dayong','D','Client Death Benefit',100,'PHP',0,0,0.000000,1,4,1,365,10.000000,NULL,NULL,1,NULL,NULL,0,0,0.000000,0.000000,0,NULL),(5,'Other Fees','Fees','Service Fees',100,'PHP',0,0,0.000000,1,4,1,365,75.000000,NULL,NULL,1,NULL,NULL,0,0,0.000000,0.000000,0,NULL),(6,'Center Fund','CF','Funds use within the center',100,'PHP',0,0,0.000000,1,4,1,365,1.000000,NULL,NULL,1,NULL,NULL,0,0,0.000000,0.000000,0,NULL),(7,'CF 1%','CF1%','Deducted on every Loan Disbursement',100,'PHP',0,0,0.000000,1,4,1,365,50.000000,NULL,NULL,1,NULL,NULL,0,0,0.000000,0.000000,0,NULL),(8,'CF Proceeds','CFP','Used when Center Closure Occurs',100,'PHP',0,0,0.000000,1,4,1,365,10.000000,NULL,NULL,1,NULL,NULL,0,0,0.000000,0.000000,0,NULL),(9,'Dropout Proceeds','DP','Proceeds of Clients GF5% after exit.',100,'PHP',0,0,0.000000,1,4,1,365,10.000000,NULL,NULL,1,NULL,NULL,0,0,0.000000,0.000000,0,NULL),(10,'Security Deposit','SD','Compulsary Savings',100,'PHP',0,0,0.000000,1,4,1,365,5.000000,NULL,NULL,1,NULL,NULL,0,0,0.000000,0.000000,0,NULL);
INSERT INTO `mifostenant-default`.`m_charge` (`id`, `name`, `currency_code`, `charge_applies_to_enum`, `charge_time_enum`, `charge_calculation_enum`, `charge_payment_mode_enum`, `amount`, `is_penalty`, `is_active`, `is_deleted`) VALUES ('3', 'General', 'PHP', '1', '8', '1', '0', '1.000000', '0', '1', '0');

UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a5cfa8345d40fb80145db5380773d37' WHERE `id`='2';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a9d39cd46a57d740146a6741c601c86' WHERE `id`='8';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a5cfa8345d40fb80145db4f1f4f3b01' WHERE `id`='1';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a180bfa4665813201466a8414712efb' WHERE `id`='7';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a5cfa8345d40fb80145db5b375040fb' WHERE `id`='4';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a28acc84601431f01460367c59337d7' WHERE `id`='5';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a28acc84601431f0146036b4d353828' WHERE `id`='6';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a5cfa8345d40fb80145db589e013fff' WHERE `id`='3';

INSERT INTO `mifostenant-default`.`m_product_loan_charge` (`product_loan_id`, `charge_id`) VALUES ('1', '3');
INSERT INTO `mifostenant-default`.`m_product_loan_charge` (`product_loan_id`, `charge_id`) VALUES ('2', '3');
INSERT INTO `mifostenant-default`.`m_product_loan_charge` (`product_loan_id`, `charge_id`) VALUES ('3', '3');
INSERT INTO `mifostenant-default`.`m_product_loan_charge` (`product_loan_id`, `charge_id`) VALUES ('4', '3');
INSERT INTO `mifostenant-default`.`m_product_loan_charge` (`product_loan_id`, `charge_id`) VALUES ('5', '3');
INSERT INTO `mifostenant-default`.`m_product_loan_charge` (`product_loan_id`, `charge_id`) VALUES ('6', '3');
INSERT INTO `mifostenant-default`.`m_product_loan_charge` (`product_loan_id`, `charge_id`) VALUES ('7', '3');
INSERT INTO `mifostenant-default`.`m_product_loan_charge` (`product_loan_id`, `charge_id`) VALUES ('8', '3');


UPDATE `mifostenant-default`.`m_savings_product` SET `description`='8a1fc2624693dad8014693e8724c0015' WHERE `id`='6';
UPDATE `mifostenant-default`.`m_savings_product` SET `description`='8a1fc2624693dad8014693e95fcd001a' WHERE `id`='7';
UPDATE `mifostenant-default`.`m_savings_product` SET `description`='8a1fc2624693dad8014693ea2f26001c' WHERE `id`='8';
UPDATE `mifostenant-default`.`m_savings_product` SET `description`='8a1fc2624693dad8014693e531a90009' WHERE `id`='4';
UPDATE `mifostenant-default`.`m_savings_product` SET `description`='8a1fc2624693dad8014693ead788001f' WHERE `id`='9';
UPDATE `mifostenant-default`.`m_savings_product` SET `description`='8a1fc2624693dad8014693e60fc4000c' WHERE `id`='1';
UPDATE `mifostenant-default`.`m_savings_product` SET `description`='8a1fc2624693dad8014693e4133b0006' WHERE `id`='3';
UPDATE `mifostenant-default`.`m_savings_product` SET `description`='8a1fc2624693dad8014693e76c6d000f' WHERE `id`='5';
UPDATE `mifostenant-default`.`m_savings_product` SET `description`='8aad1cd8468b124401468d13987227c5' WHERE `id`='2';
UPDATE `mifostenant-default`.`m_savings_product` SET `description`='8aab160f499477da01499c81d2ea458a' WHERE `id`='10';


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
    300                              as status_enum,
	if(c.MOBILEPHONE1 = '0',
		null,c.mobilephone1) as mobile_no,
    DATE_FORMAT(date(LEAST(
        coalesce(c.CREATIONDATE, CURDATE()),
        coalesce(c.APPROVEDDATE, CURDATE()),
        coalesce(c.ACTIVATIONDATE, CURDATE()),
        coalesce(lad.DISBURSEMENTDATE, CURDATE())
    )), '%Y-%m-%d')                  as ACTIVATION_DATE,
    ifnull(o.id, 2)                     as OFFICE_ID,
    COALESCE(ms.id , 1)              as STAFF_ID,
    c.FIRSTNAME                      as FIRST_NAME,
    c.LASTNAME                       as LAST_NAME,
    COALESCE(c.MIDDLENAME, '')       as MIDDLE_NAME,
    concat(c.FIRSTNAME, ' ',
        COALESCE(c.MIDDLENAME, ''), ' ',
        c.LASTNAME)                     as DISPLAY_NAME,
    1                                  as submittedon_userid,
    1                                  as activatedon_userid
from
    input_db.client c
    left join input_db.branch b on c.ASSIGNEDBRANCHKEY = b.ENCODEDKEY
    left join `mifostenant-default`.m_office o on o.external_id = b.encodedkey
    left join input_db.user s   on c.ASSIGNEDUSERKEY   = s.ENCODEDKEY
    left join `mifostenant-default`.m_staff ms on s.encodedkey = ms.external_id
    left join
    (
        SELECT * FROM (
            SELECT DISBURSEMENTDATE, ACCOUNTHOLDERKEY, ACCOUNTHOLDERTYPE
            FROM input_db.loanaccount
            WHERE ACCOUNTHOLDERTYPE = 'CLIENT'
            ORDER BY DISBURSEMENTDATE asc
        ) as t1
        GROUP BY ACCOUNTHOLDERKEY
    ) lad on c.ENCODEDKEY = lad.ACCOUNTHOLDERKEY
   
        -- Get the correct office for the group and give that to the client
    left join input_db.groupmember gm on gm.clientkey = c.encodedkey
    left join input_db.`group` g on g.ENCODEDKEY = gm.groupkey
    left join input_db.centre cn on cn.ENCODEDKEY = g.ASSIGNEDCENTREKEY
    left join input_db.branch b2 on cn.ASSIGNEDBRANCHKEY = b2.ENCODEDKEY
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
left join `input_db`.address a 
on a.parentkey = c.external_id 
;

ALTER TABLE `mifostenant-default`.`m_client`
CHANGE COLUMN `account_no` `account_no` VARCHAR(20) NOT NULL ,
ADD UNIQUE INDEX `account_no_UNIQUE` (`account_no` ASC);


-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- Center Migration
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
UPDATE `input_db`.`centre` SET `NAME`='SAN BARTOLOME' WHERE `ENCODEDKEY`='8a68b6e44b570fa1014b58c0e71d4a77';
UPDATE `input_db`.`centre` SET `NAME`='SAN BARTOLOME (2)' WHERE `ENCODEDKEY`='8a8189865327144b01532bd18ff11e17';
UPDATE `input_db`.`centre` SET `NAME`='SAN BARTOLOME 1-A (2)' WHERE `ENCODEDKEY`='8a68b6e44b570fa1014b58c0e7534a87';
UPDATE `input_db`.`centre` SET `NAME`='SAN BARTOLOME 1-A' WHERE `ENCODEDKEY`='8a8189865327144b01532bb4eb6715a0';
UPDATE `input_db`.`centre` SET `NAME`='SAN BARTOLOME 2 (2)' WHERE `ENCODEDKEY`='8a68b6e44b570fa1014b58c0e72e4a7b';
UPDATE `input_db`.`centre` SET `NAME`='ARIENDA (2)' WHERE `ENCODEDKEY`='8a62dddb4b51f19d014b6b17f5633475';
UPDATE `input_db`.`centre` SET `NAME`='DOÑA ROSARIO (4)' WHERE `ENCODEDKEY`='8a68b6e44b570fa1014b58c0e7464a83';


update input_db.`centre`
set name = concat(name, ' (3)')
where name in
(
    SELECT name
    FROM (select * from input_db.`centre`) as center_id
    GROUP BY name
    HAVING COUNT(*) > 1
)
limit 10000
;
SELECT * from input_db.`centre`;

DELETE from `input_db`.`centre` where name like '%Test Center%';

SELECT * from  `input_db`.`centre`;
-- Error Code: 1062. Duplicate entry 'ILANG-ILANG-1' for key 'name'
UPDATE `input_db`.`centre` SET `name`= concat(name,'(2)') WHERE `name`='ILANG-ILANG';


INSERT INTO `mifostenant-default`.`m_group`
    (
        `external_id`, `status_enum`, `activation_date`, `office_id`, `staff_id`, `level_id`,
        `display_name`, `activatedon_userid`, `submittedon_date`, `submittedon_userid`
    )

select
    c.ENCODEDKEY                          as external_id,
    300                                   as status_enum,
    DATE_FORMAT(date(
       c.CREATIONDATE), '%Y-%m-%d')       as ACTIVATION_DATE,
    mo.id                                 as OFFICE_ID,
    1                                     as STAFF_ID,                           
    1                                     as level_id,
    c.name                                   as DISPLAY_NAME,
    1                                     as activatedon_userid,
    DATE_FORMAT(date(
       c.CREATIONDATE), '%Y-%m-%d')       as submittedon_date,
    1                                     as submittedon_userid
from
    input_db.centre c
left join input_db.branch b on b.ENCODEDKEY = c.ASSIGNEDBRANCHKEY
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
update input_db.`group`
set groupname = concat(GROUPNAME, ' (2)')
where id in
(
    SELECT id
    FROM (select * from input_db.`group`) as groupid
    GROUP BY groupname
    HAVING COUNT(*) > 1
)
limit 10000
;

-- '18459'
-- '012786216'
-- 'CEBU-1161'
SELECT * from input_db.`group`;

UPDATE `input_db`.`group` SET `GROUPNAME`='CEBU-1162 (3)' WHERE `ENCODEDKEY`='8a8188bc52849d6401528c45516b742a';
UPDATE `input_db`.`group` SET `GROUPNAME`=id WHERE `id`='094646451';
UPDATE `input_db`.`group` SET `GROUPNAME`=id WHERE `id`='18426';
UPDATE `input_db`.`group` SET `GROUPNAME`=id WHERE `id`='639521806';
UPDATE `input_db`.`group` SET `GROUPNAME`=id WHERE `groupname`='ILANG-ILANG';
UPDATE `input_db`.`group` SET `GROUPNAME`='18459 (3)' WHERE `ENCODEDKEY`='8a10ca994b09d039014b15ca757c7fbe';
UPDATE `input_db`.`group` SET `GROUPNAME`='18459 (4)' WHERE `ENCODEDKEY`='8a1a2d044f7082b8014f72f9e2814787';
UPDATE `input_db`.`group` SET `GROUPNAME`='18462 (3)' WHERE `ENCODEDKEY`='8a2abc564c491a32014c49c5a4ac0ed3';
UPDATE `input_db`.`group` SET `GROUPNAME`='CEBU-1162 (3)' WHERE `ENCODEDKEY`='8a68cf2a4bcd8217014be89e6c7f2c82';
UPDATE `input_db`.`group` SET `GROUPNAME`='CEBU-1162 (4)' WHERE `ENCODEDKEY`='8a8188bc52849d6401528c45516b742a';
UPDATE `input_db`.`group` SET `GROUPNAME`='18425 (1)' WHERE `ENCODEDKEY`='8a8189a253f0fbaf0153f3ee885a55bc';

INSERT INTO `mifostenant-default`.`m_group`
    (
        `external_id`, `status_enum`, `activation_date`, `office_id`, `staff_id`, `level_id`, `parent_id`,
        `display_name`, `activatedon_userid`, `submittedon_userid`
    )
SELECT
    g.ENCODEDKEY                         as external_id,
    300                                     as status_enum,
    DATE_FORMAT(date(LEAST(
        coalesce(g.CREATIONDATE, CURDATE()),
        coalesce(lad.DISBURSEMENTDATE, CURDATE())
    )), '%Y-%m-%d')                      as ACTIVATION_DATE,
    mo.id                                 as OFFICE_ID,
    ms.id                                 as STAFF_ID,                           
    2                                     as level_id,
    ifnull(mc.id, 1)                      as parentd_id,
    g.groupname                          as DISPLAY_NAME,
    1                                     as activatedon_userid,
    1                                     as submittedon_userid
from
    input_db.`group` g
left join `mifostenant-default`.m_staff ms on ms.external_id = g.ASSIGNEDUSERKEY
left join `mifostenant-default`.m_group mc on mc.external_id = g.ASSIGNEDCENTREKEY
left join input_db.branch b on b.ENCODEDKEY = g.ASSIGNEDBRANCHKEY
left join `mifostenant-default`.m_office mo on mo.external_id = b.encodedkey
left join
(
    SELECT * FROM (
        SELECT DISBURSEMENTDATE, ACCOUNTHOLDERKEY, ACCOUNTHOLDERTYPE
        FROM input_db.loanaccount
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
    mg.id        as group_id,
    mc.id        as client_id
FROM
    input_db.groupmember gm
left join `mifostenant-default`.m_group mg on mg.external_id = gm.groupkey
left join `mifostenant-default`.m_client mc on mc.external_id = gm.clientkey
;




-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- Group Loan Migration
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
ALTER TABLE `mifostenant-default`.`m_loan` 
CHANGE COLUMN `account_no` `account_no` VARCHAR(20) NULL COMMENT '' ,
DROP INDEX `loan_account_no_UNIQUE` ;




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
);

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
	'PHP' as `currency_code`,
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
	input_db.loanaccount la
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
-- LOAN SCHEDULE INSERT
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
set global connect_timeout=60000;

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
    input_db.repayment phr, `mifostenant-default`.m_loan ml
where
     ml.external_id = phr.PARENTACCOUNTKEY
order by
     phr.PARENTACCOUNTKEY, phr.duedate
;


SET SQL_SAFE_UPDATES = 0;
CREATE TEMPORARY TABLE IF NOT EXISTS `mifostenant-default`.table2 AS (
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
where m_loan_repayment_schedule.created_date <> ''
;
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- FEES - I guess PH doesn't need this?
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
/**
select
    lt.TYPE,
    lt.ENCODEDKEY,
    lt.PARENTACCOUNTKEY,
    lt.AMOUNT,
    DATE_FORMAT(date(lt.entrydate), '%d/%m/%Y') as date,
    ifnull(lt.REVERSALTRANSACTIONKEY,'') as reversalKey,
    la.REPAYMENTINSTALLMENTS,
	ml.id
from
    input_db.loantransaction lt,
    input_db.loanaccount la,
    `mifostenant-default`.m_loan ml
where
    lt.parentaccountkey = la.encodedkey
    and ml.external_id = la.ENCODEDKEY
    and la.ENCODEDKEY = lt.PARENTACCOUNTKEY
    and lt.type not like '%INTEREST%'

order by lt.parentaccountkey asc, lt.creationdate asc
;
*/



-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- LOAN UPDATE
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------

set global connect_timeout=60000;
UPDATE `mifostenant-default`.m_loan ml
join input_db.loanaccount la on ml.external_id = la.encodedkey
set
	principal_amount_proposed = la.LOANAMOUNT, 
	principal_amount = la.LOANAMOUNT,
	approved_principal = la.LOANAMOUNT, 
	principal_disbursed_derived = la.LOANAMOUNT,  
	principal_outstanding_derived = la.LOANAMOUNT,
	principal_repaid_derived = la.principalpaid, 
	principal_repaid_derived = la.principalpaid, 
	interest_repaid_derived = la.interestpaid, 
	fee_charges_repaid_derived = la.feespaid
;
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
    ml.id                                            as `loan_id`,
    ifnull(mo.id,2)                                    as `office_id`,
    ml.principal_outstanding_derived                as `amount`,
    ml.principal_outstanding_derived                as `outstanding_loan_balance_derived`,
    0                                                as `is_reversed`,
    1                                                as `transaction_type_enum`,
    1                                                as `appuser_id`,
    0                                                as `manually_adjusted_or_reversed`,
    ifnull(ml.disbursedon_date,   
        DATE_SUB(curdate(), INTERVAL 10 YEAR))        as `transaction_date`,
    ifnull(ml.disbursedon_date,   
        DATE_SUB(curdate(), INTERVAL 10 YEAR))        as `submitted_on_date`,
    ifnull(ml.disbursedon_date,   
        DATE_SUB(curdate(), INTERVAL 10 YEAR))        as `created_date`
from
    `mifostenant-default`.m_loan ml
left join input_db.loanaccount gla on ml.external_id = gla.encodedkey
left join `mifostenant-default`.m_office mo on gla.assignedbranchkey = mo.external_id
;
--     could add `payment_detail_id` with a script

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- GET CORRECT PAID INTEREST
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------

/*
CREATE TEMPORARY TABLE IF NOT EXISTS `mifostenant-default`.table3 AS (
SELECT 
	PARENTACCOUNTKEY as PARENTACCOUNTKEY, 
	SUM(INTERESTDUE) as interest
FROM input_db.repayment 
Group By PARENTACCOUNTKEY
);
*/

UPDATE `mifostenant-default`.m_loan ml
join (
	SELECT 
		PARENTACCOUNTKEY as PARENTACCOUNTKEY, 
		SUM(INTERESTDUE) as interest
	FROM input_db.repayment 
	Group By PARENTACCOUNTKEY
) as t4 on ml.external_id = t4.PARENTACCOUNTKEY
set ml.interest_charged_derived = t4.interest   
;

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- ORIGINAL INTEREST TRANSACTIONS
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
INSERT INTO `mifostenant-default`.`m_loan_transaction`
 (
    `loan_id`,  `office_id`,  `amount`, `interest_portion_derived`,`is_reversed`, `transaction_type_enum`,
    `appuser_id`, `manually_adjusted_or_reversed`, `transaction_date`,`submitted_on_date`, `created_date`
 )

SELECT
    ml.id                                            as `loan_id`,
    ifnull(mo.id,2)                                    as `office_id`,
    ml.interest_charged_derived                        as `amount`,
    ml.interest_charged_derived                        as `interest_portion_derived`,
    0                                                as `is_reversed`,
    10                                                as `transaction_type_enum`,
    1                                                as `appuser_id`,
    0                                                as `manually_adjusted_or_reversed`,
    ifnull(ml.disbursedon_date,   
        DATE_SUB(curdate(), INTERVAL 10 YEAR))        as `transaction_date`,
    ifnull(ml.disbursedon_date,   
        DATE_SUB(curdate(), INTERVAL 10 YEAR))        as `submitted_on_date`,
    ifnull(ml.disbursedon_date,   
        DATE_SUB(curdate(), INTERVAL 10 YEAR))        as `created_date`
from
    `mifostenant-default`.m_loan ml
left join input_db.loanaccount gla on ml.external_id = gla.encodedkey
left join `mifostenant-default`.m_office mo on gla.assignedbranchkey = mo.external_id
;


-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- GET ORIGNAL AMT OF FEES
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
UPDATE 
	`mifostenant-default`.`m_loan` ml
join
	`mifostenant-default`.m_loan_charge mlc on mlc.loan_id = ml.id
SET 
	ml.fee_charges_charged_derived = mlc.amount;

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- OUTSTANDING && TOTALS
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- OVERDUE
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
-- REPAYMENTS (MAKE BACKUP B4 this step) 
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- Fix loans with no disbursement dates
update `mifostenant-default`.m_loan ml
join input_db.loanaccount la on ml.external_id = la.ENCODEDKEY
set ml.disbursedon_date = la.creationdate
where ml.id in 
(
	select * FROM 
    (select
		ml.id
	from
		input_db.loantransaction lt,
		input_db.loanaccount la,
		`mifostenant-default`.m_loan ml
	where
		lt.parentaccountkey = la.encodedkey
		and ml.external_id = la.ENCODEDKEY
		and la.ENCODEDKEY = lt.PARENTACCOUNTKEY
		and lt.type = 'REPAYMENT'
		and la.ASSIGNEDBRANCHKEY = '8a2b82e6455edd890145bbc90f6c75af'
		and la.DISBURSEMENTDATE is null
        GROUP BY ml.id) as tableID
        
) 
;


-- ####################################################################################
-- ##############
-- STOP 
-- ##############
-- ####################################################################################
-- Speed tests - should be no less than 20-30 transactions/second
SELECT * FROM `mifostenant-default`.m_loan_transaction where transaction_type_enum = 2;

-- Export this next query to transactions.csv and then run the loan_transactions.py script
select
    lt.TYPE,
    lt.ENCODEDKEY,
    lt.PARENTACCOUNTKEY,
    lt.AMOUNT,
    DATE_FORMAT(date(lt.entrydate), '%d/%m/%Y') as date,
    ifnull(lt.REVERSALTRANSACTIONKEY,'') as reversalKey,
    la.REPAYMENTINSTALLMENTS,
	ml.id,
    la.DISBURSEMENTDATE,
    la.CREATIONDATE
from
    input_db.loantransaction lt,
    input_db.loanaccount la,
    `mifostenant-default`.m_loan ml
where
    lt.parentaccountkey = la.encodedkey
    and ml.external_id = la.ENCODEDKEY
    and la.ENCODEDKEY = lt.PARENTACCOUNTKEY
    and lt.type = 'REPAYMENT'
    and la.ASSIGNEDBRANCHKEY = '8a2b82e6455edd890145bbc90f6c75af'
order by lt.parentaccountkey asc, lt.creationdate asc
 ;




-- ####################################################################################
-- ##############
-- Start again mysql query 
-- ##############
-- ####################################################################################

SET SQL_SAFE_UPDATES = 0;

SELECT * FROM `mifostenant-default`.m_client;
/**
Repayment query
**/
UPDATE `mifostenant-default`.m_client mc
join input_db.client c on c.encodedkey = mc.external_id
join `mifostenant-default`.m_office o on o.external_id = c.ASSIGNEDBRANCHKEY
join `mifostenant-default`.m_staff s on s.external_id = c.ASSIGNEDUSERKEY
set 
	mc.office_id = o.id,
    mc.staff_id = s.id
;
--
--     input_db.client c
--     left join input_db.branch b on c.ASSIGNEDBRANCHKEY = b.ENCODEDKEY
--     left join `mifostenant-default`.m_office o on o.external_id = b.encodedkey
--     left join input_db.user s   on c.ASSIGNEDUSERKEY   = s.ENCODEDKEY
--     left join `mifostenant-default`.m_staff ms on s.encodedkey = ms.external_id


-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- CREATE SAVINGS ACCOUNTS
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
/**
ALTER TABLE `mifostenant-default`.`m_savings_account` 
CHANGE COLUMN `account_no` `account_no` VARCHAR(20) NULL COMMENT '' ,
DROP INDEX `account_no_UNIQUE` ;
*/

ALTER TABLE `mifostenant-default`.`m_savings_account` 
CHANGE COLUMN `account_no` `account_no` VARCHAR(20) NULL COMMENT '' ,
DROP INDEX `sa_account_no_UNIQUE` ;

update `mifostenant-default`.m_savings_product
set currency_digits = 2;

INSERT into `mifostenant-default`.m_savings_account
(
	`external_id`,  `client_id`,  `group_id`,  `product_id`,  `field_officer_id`,    `account_type_enum`,  `deposit_type_enum`,    `submittedon_date`,  `approvedon_date`,  `rejectedon_date`,  `withdrawnon_date`,  `activatedon_date`,  `closedon_date`,  `start_interest_calculation_date`,  `lockedin_until_date_derived`,    `currency_code`,  `currency_digits`,  `currency_multiplesof`,    `nominal_annual_interest_rate`,  `interest_compounding_period_enum`,  `interest_posting_period_enum`,  `interest_calculation_type_enum`,  `interest_calculation_days_in_year_type_enum`,    `min_required_opening_balance`,  `lockin_period_frequency`,  `lockin_period_frequency_enum`,  `withdrawal_fee_for_transfer`,  `allow_overdraft`,  `overdraft_limit`,  `nominal_annual_interest_rate_overdraft`,  `min_overdraft_for_interest_calculation`,    `total_deposits_derived`, 
	`total_withdrawals_derived`,  `total_withdrawal_fees_derived`,  `total_fees_charge_derived`,  `total_penalty_charge_derived`,  `total_annual_fees_derived`,  `total_interest_earned_derived`,  `total_interest_posted_derived`,  `total_overdraft_interest_derived`,  `account_balance_derived`,    `min_required_balance`,  `enforce_min_required_balance`,  `min_balance_for_interest_calculation`,  `on_hold_funds_derived`,    `submittedon_userid`,  `approvedon_userid`,  `rejectedon_userid`,  `withdrawnon_userid`,  `activatedon_userid`,  `closedon_userid`
)

SELECT
  sa.encodedkey 			as `external_id`,
  mc.id 					as `client_id`,
  mg.id 					as `group_id`,
  msp.id 					as `product_id`,
  ms.id 					as `field_officer_id`,
-- ----------------------------------------------------------------------------------------------------
  1							as `account_type_enum`,
  msp.deposit_type_enum 	as `deposit_type_enum`,
-- ----------------------------------------------------------------------------------------------------  
  sa.approveddate			as `submittedon_date`,
  sa.approveddate			as `approvedon_date`,
  null						as `rejectedon_date`,
  null						as `withdrawnon_date`,
  sa.activationdate			as `activatedon_date`,
  sa.closeddate 			as `closedon_date`,
  null						as `start_interest_calculation_date`,
  null 						as `lockedin_until_date_derived`,
-- ----------------------------------------------------------------------------------------------------  
  msp.currency_code			as `currency_code`,
  2							as `currency_digits`,
  msp.currency_multiplesof	as `currency_multiplesof`,
-- ----------------------------------------------------------------------------------------------------  
  sa.interestrate						as `nominal_annual_interest_rate`,
  msp.interest_compounding_period_enum  as `interest_compounding_period_enum`,
  msp.interest_posting_period_enum 		as`interest_posting_period_enum`,
  msp.interest_calculation_type_enum 	as `interest_calculation_type_enum`,
  msp.interest_calculation_days_in_year_type_enum
										as `interest_calculation_days_in_year_type_enum`,
-- ----------------------------------------------------------------------------------------------------  
  msp.min_required_opening_balance 		as `min_required_opening_balance`,
  msp.lockin_period_frequency 			as `lockin_period_frequency`,
  msp.lockin_period_frequency_enum 		as `lockin_period_frequency_enum`,
  msp.withdrawal_fee_for_transfer 		as `withdrawal_fee_for_transfer`,
  msp.allow_overdraft 					as `allow_overdraft`,
  msp.overdraft_limit 					as `overdraft_limit`,
  msp.nominal_annual_interest_rate_overdraft as `nominal_annual_interest_rate_overdraft`,
  msp.min_overdraft_for_interest_calculation as 	`min_overdraft_for_interest_calculation`,
-- ----------------------------------------------------------------------------------------------------  
  0 									as `total_deposits_derived`,
  0 									as `total_withdrawals_derived`,
  0 									as `total_withdrawal_fees_derived`,
  0 									as `total_fees_charge_derived`,
  0 									as `total_penalty_charge_derived`,
  0 									as `total_annual_fees_derived`,
  0 									as `total_interest_earned_derived`,
  0 									as `total_interest_posted_derived`,
  0 									as `total_overdraft_interest_derived`,
  0 									as `account_balance_derived`,
-- ----------------------------------------------------------------------------------------------------  
  msp.min_required_balance  			as `min_required_balance`,
  msp.enforce_min_required_balance 		as `enforce_min_required_balance`,
  msp.min_balance_for_interest_calculation as `min_balance_for_interest_calculation`,
  null						 			as `on_hold_funds_derived`,
-- ----------------------------------------------------------------------------------------------------  
  1 									as `submittedon_userid`,
  1										as `approvedon_userid`,
  null 									as `rejectedon_userid`,
  null 									as `withdrawnon_userid`,
  1										as `activatedon_userid`,
  null 									as `closedon_userid`
  
from
	input_db.savingsaccount sa
left join `mifostenant-default`.m_group mg on mg.external_id = sa.ACCOUNTHOLDERKEY 
left join `mifostenant-default`.m_client mc on mc.external_id = sa.ACCOUNTHOLDERKEY 
left join `mifostenant-default`.m_staff ms on ms.external_id = sa.ASSIGNEDUSERKEY
left join `mifostenant-default`.m_savings_product msp on msp.description = sa.PRODUCTTYPEKEY
where
    sa.ASSIGNEDBRANCHKEY = '8a2b82e6455edd890145bbc90f6c75af'
;

-- Fix a few things
UPDATE `mifostenant-default`.`m_savings_account`
SET account_no = id
WHERE id <> '';
   


ALTER TABLE `mifostenant-default`.`m_savings_account` 
CHANGE COLUMN `account_no` `account_no` VARCHAR(20) NOT NULL COMMENT '' ,
ADD UNIQUE INDEX `account_no_UNIQUE` (`account_no` ASC)  COMMENT '';


-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- 	BACKDATE DATES TO AVOID API ISSUES
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
update `mifostenant-default`.m_client
set 
	activation_date = DATE_SUB(activation_date , INTERVAL 100 YEAR),
	office_joining_date = DATE_SUB(office_joining_date, INTERVAL 100 YEAR)
;
    
 update `mifostenant-default`.m_savings_account
 set activatedon_date = DATE_SUB(activatedon_date, INTERVAL 100 YEAR)
 where approvedon_date is not null
;

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- 	GET SAVIGNS TRANSACTIONS 
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
INSERT INTO `mifostenant-default`.`m_payment_type` 
(`id`, `value`, `description`, `is_cash_payment`) 
VALUES ('2', 'Interest Hack', 'Hack', '0');


-- ####################################################################################
-- ##############
-- STOP 
-- ##############
-- ####################################################################################
-- Export the next step to savings.csv and then run saving_transaction.py
select
    st.TYPE,
    st.ENCODEDKEY,
    st.PARENTACCOUNTKEY,
    st.AMOUNT,
    DATE_FORMAT(date(st.entrydate), '%d/%m/%Y') as date,
    ifnull(st.REVERSALTRANSACTIONKEY,'') as reversalKey,
	msa.id
from
    input_db.savingstransaction st,
    input_db.savingsaccount sa,
    `mifostenant-default`.m_savings_account msa
where
    st.parentaccountkey = sa.encodedkey
    and msa.external_id = sa.ENCODEDKEY
    and sa.ENCODEDKEY = st.PARENTACCOUNTKEY
    and sa.ASSIGNEDBRANCHKEY = '8a2b82e6455edd890145bbc90f6c75af'
order by st.parentaccountkey asc, st.creationdate asc
 ;
 
 
-- ####################################################################################
-- ##############
-- Start 
-- ##############
-- ####################################################################################
-- Export the next step to savings.csv and then run saving_transaction.py
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- 	REVERT DATES 
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
update `mifostenant-default`.m_client
set 
	activation_date = date_add(activation_date , INTERVAL 100 YEAR),
	office_joining_date = date_add(office_joining_date, INTERVAL 100 YEAR)
;
    
update `mifostenant-default`.m_savings_account
set activatedon_date = date_add(activatedon_date, INTERVAL 100 YEAR)
;

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- 	FIX INTERST NUMBER HACK
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
update `mifostenant-default`.m_savings_account_transaction mst
join `mifostenant-default`.m_payment_detail mpd on mpd.id = mst.payment_detail_id
set 
	mst.transaction_type_enum = 3,
    mst.overdraft_amount_derived = null, 
	-- mst.balance_end_date_derived = null, 
	-- mst.balance_number_of_days_derived = null, 
	mst.cumulative_balance_derived = null 
where mpd.payment_type_id = 2;

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- 	FIX MIN ALOWED BALANCE 
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
update `mifostenant-default`.m_savings_account
set min_balance_for_interest_calculation = 1000
;

update `mifostenant-default`.m_savings_product
set min_balance_for_interest_calculation = 1000
;

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- 	Close accounts to match Mambu
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- savings
SELECT
	'savings' as `type`,
	ms.id, 
    s.accountstate, 
    DATE_FORMAT(date(s.CLOSEDDATE), '%d/%m/%Y') as date
from input_db.loanaccount s, `mifostenant-default`.m_savings_account ms
where ms.external_id = s.encodedkey
and s.accountstate = 'CLOSED'
union

-- loans
SELECT 
	'loan' as `type`,
	ml.id, 
    l.accountstate, 
    DATE_FORMAT(date(l.CLOSEDDATE), '%d/%m/%Y') as date
from input_db.loanaccount l, `mifostenant-default`.m_loan ml
where ml.external_id = l.encodedkey
and l.accountstate = 'CLOSED_WRITTEN_OFF'
union

-- people
SELECT 
	'client' as `type`,
	mc.id, 
    c.state, 
    DATE_FORMAT(date(c.CLOSEDDATE), '%d/%m/%Y') as date
from input_db.`client` c, `mifostenant-default`.m_client mc
where mc.external_id = c.encodedkey
and c.state = 'EXITED'
;

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- 	FIX ID ISSUES 
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- people
update `mifostenant-default`.m_client mc
join input_db.`client` c on mc.external_id = c.encodedkey
set mc.external_id = c.id
;

-- groups
update `mifostenant-default`.m_group mc
join input_db.`group` c on mc.external_id = c.encodedkey
set mc.external_id = c.id
;

-- centers -> may have issues with double ids
-- update `mifostenant-default`.m_group mc
-- join input_db.`centre` c on mc.external_id = c.encodedkey
-- set mc.external_id = c.id
;

-- loan accounts
update `mifostenant-default`.m_loan mc
join input_db.`loanaccount` c on mc.external_id = c.encodedkey
set mc.external_id = c.id
;

-- savings accounts
update `mifostenant-default`.m_savings_account mc
join input_db.`savingsaccount` c on mc.external_id = c.encodedkey
set mc.external_id = c.id
;
-- 

-- get savings transactions
-- fix entry date issue
-- 

INSERT INTO `mifostenant-default`.`m_appuser` 
(`id`, `is_deleted`, `office_id`, `username`, `firstname`, `lastname`, `password`, `email`,
 `firsttime_login_remaining`, `nonexpired`, `nonlocked`, `nonexpired_credentials`, 
 `enabled`, `last_time_password_updated`, `password_never_expires`,
 `is_self_service_user`) 
 VALUES ('3', '0', '6', 'pasig', 'pasig', 'pasig', 'abfb14da425c938e77bf3d7d13959535cbe0248cb09455b597a965d019a54664', 'pasig@pasig', 0, 1, 1, 1, 1, '2016-04-20', '0', 0);


