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
    `phil20160204`.branch
;   


UPDATE
    `mifostenant-default`.`m_office`
SET
    `opening_date`= (SELECT CREATIONDATE FROM phil20160204.client ORDER BY CREATIONDATE ASC LIMIT 1)
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
UPDATE `mifostenant-default`.`m_product_loan` SET `name`='Special Individual Loan' WHERE `id`='6';
UPDATE `mifostenant-default`.`m_product_loan` SET `name`='Business Opportunity Loan' WHERE `id`='2';


UPDATE `phil20160204`.`client` SET FIRSTNAME = REPLACE(FIRSTNAME, ',', ' ') LIMIT 60000;
UPDATE `phil20160204`.`client` SET MIDDLENAME = REPLACE(MIDDLENAME, ',', ' ')LIMIT 60000;
UPDATE `phil20160204`.`client` SET LASTNAME = REPLACE(LASTNAME, ',', ' ')LIMIT 60000;
UPDATE `phil20160204`.`user` SET `FIRSTNAME`='Roland' WHERE `ENCODEDKEY`='8a28afc7474813a4014757b332b420e5';


-- m_staff
-- Clean up Mifos Staff -> change geo locatoin to 'STAFF TBD'
UPDATE
    `phil20160204`.`user`
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
    `phil20160204`.user
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

UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a5cfa8345d40fb80145db5380773d37' WHERE `id`='2';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a9d39cd46a57d740146a6741c601c86' WHERE `id`='8';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a5cfa8345d40fb80145db4f1f4f3b01' WHERE `id`='1';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a180bfa4665813201466a8414712efb' WHERE `id`='7';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a5cfa8345d40fb80145db5b375040fb' WHERE `id`='4';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a28acc84601431f01460367c59337d7' WHERE `id`='5';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a28acc84601431f0146036b4d353828' WHERE `id`='6';
UPDATE `mifostenant-default`.`m_product_loan` SET `external_id`='8a5cfa8345d40fb80145db589e013fff' WHERE `id`='3';


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
    300                                  as status_enum,
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
    phil20160204.client c
    left join phil20160204.branch b on c.ASSIGNEDBRANCHKEY = b.ENCODEDKEY
    left join `mifostenant-default`.m_office o on o.external_id = b.id
    left join phil20160204.user s   on c.ASSIGNEDUSERKEY   = s.ENCODEDKEY
    left join `mifostenant-default`.m_staff ms on s.id = ms.external_id
    left join
    (
        SELECT * FROM (
            SELECT DISBURSEMENTDATE, ACCOUNTHOLDERKEY, ACCOUNTHOLDERTYPE
            FROM phil20160204.loanaccount
            WHERE ACCOUNTHOLDERTYPE = 'CLIENT'
            ORDER BY DISBURSEMENTDATE asc
        ) as t1
        GROUP BY ACCOUNTHOLDERKEY
    ) lad on c.ENCODEDKEY = lad.ACCOUNTHOLDERKEY
   
        -- Get the correct office for the group and give that to the client
    left join phil20160204.groupmember gm on gm.clientkey = c.encodedkey
    left join phil20160204.`group` g on g.ENCODEDKEY = gm.groupkey
    left join phil20160204.centre cn on cn.ENCODEDKEY = g.ASSIGNEDCENTREKEY
    left join phil20160204.branch b2 on cn.ASSIGNEDBRANCHKEY = b2.ENCODEDKEY
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
    b.encodedkey                         as external_id,
    300                                     as status_enum,
    DATE_FORMAT(date(
        b.CREATIONDATE), '%Y-%m-%d')      as ACTIVATION_DATE,
    1                                     as OFFICE_ID,
    1                                     as STAFF_ID,                           
    1                                     as level_id,
    concat('CENTER TBD','(', b.id, ')')  as DISPLAY_NAME,
    1                                     as activatedon_userid,
    DATE_FORMAT(date(
        b.CREATIONDATE), '%Y-%m-%d')      as submittedon_date,
    1                                     as submittedon_userid
from
    phil20160204.branch b
left join
    `mifostenant-default`.m_office mo on mo.external_id = b.id
UNION
select
    c.ENCODEDKEY                         as external_id,
    300                                     as status_enum,
    DATE_FORMAT(date(
       c.CREATIONDATE), '%Y-%m-%d')      as ACTIVATION_DATE,
    mo.id                                 as OFFICE_ID,
    1                                     as STAFF_ID,                           
    1                                     as level_id,
    c.id                                   as DISPLAY_NAME,
    1                                     as activatedon_userid,
    DATE_FORMAT(date(
       c.CREATIONDATE), '%Y-%m-%d')      as submittedon_date,
    1                                     as submittedon_userid
from
    phil20160204.centre c
left join phil20160204.branch b on b.ENCODEDKEY = c.ASSIGNEDBRANCHKEY
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
update phil20160204.`group`
set groupname = concat(GROUPNAME, ' (2)')
where id in
(
    SELECT id
    FROM (select * from phil20160204.`group`) as groupid
    GROUP BY groupname
    HAVING COUNT(*) > 1
)
limit 10000
;


UPDATE `phil20160204`.`group` SET `GROUPNAME`='CEBU-1162 (3)' WHERE `ENCODEDKEY`='8a8188bc52849d6401528c45516b742a';
UPDATE `phil20160204`.`group` SET `GROUPNAME`=id WHERE `id`='094646451';
UPDATE `phil20160204`.`group` SET `GROUPNAME`=id WHERE `id`='18426';
UPDATE `phil20160204`.`group` SET `GROUPNAME`=id WHERE `id`='639521806';
UPDATE `phil20160204`.`group` SET `GROUPNAME`=id WHERE `groupname`='ILANG-ILANG';


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
    phil20160204.`group` g
left join `mifostenant-default`.m_staff ms on ms.external_id = g.ASSIGNEDUSERKEY
left join `mifostenant-default`.m_group mc on mc.external_id = g.ASSIGNEDCENTREKEY
left join phil20160204.branch b on b.ENCODEDKEY = g.ASSIGNEDBRANCHKEY
left join `mifostenant-default`.m_office mo on mo.external_id = b.encodedkey
left join
(
    SELECT * FROM (
        SELECT DISBURSEMENTDATE, ACCOUNTHOLDERKEY, ACCOUNTHOLDERTYPE
        FROM phil20160204.loanaccount
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
    phil20160204.groupmember gm
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
    `total_waived_derived`, `total_writtenoff_derived`, `total_costofloan_derived`, `loan_transaction_strategy_id`, `is_npa`, `days_in_year_enum`, 
    `interest_recalculation_enabled`,  `loan_product_counter`, `days_in_month_enum`, `version`
)

select
    la.ENCODEDKEY                                            as external_id,
    mg.id                                                     as group_id,
    mpl.id                                                     as product_id,                                                       
    ms.id                                                     as loan_officer_id,
    la.LOANAMOUNT                                            as principal_amount_proposed,
    la.LOANAMOUNT                                            as principal_amount,
    la.LOANAMOUNT                                            as approved_principal,
    la.LOANAMOUNT                                            as principal_disbursed_derived, 
    la.LOANAMOUNT                                            as principal_outstanding_derived,
    if (la.INTERESTCHARGEFREQUENCY = 'EVERY_FOUR_WEEKS',
        ROUND(la.INTERESTRATE * 13 / 12, 6),
        la.INTERESTRATE)                                     as nominal_interest_rate_per_period,
    null                                                     as annual_nominal_interest_rate,
    la.REPAYMENTINSTALLMENTS                                as term_frequency,
    la.REPAYMENTINSTALLMENTS                                as number_of_repayments,
    date(la.DISBURSEMENTDATE)                                 as submittedon_date,
    date(la.DISBURSEMENTDATE)                                 as approvedon_date,
    date(la.DISBURSEMENTDATE)                                 as expected_disbursedon_date,
    date(la.DISBURSEMENTDATE)                                 as disbursedon_date,
    la.INTERESTDUE                                            as interest_charged_derived,
    la.INTERESTDUE                                            as interest_outstanding_derived,
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
    1 as `loan_transaction_strategy_id`,
    0 as `is_npa`,
    360 as `days_in_year_enum`, 
    0 as `interest_recalculation_enabled`, 
    1 as `loan_product_counter`,
    30 as `days_in_month_enum`,
    3 as `version`

from
    phil20160204.loanaccount la
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
    `total_waived_derived`, `total_writtenoff_derived`, `total_costofloan_derived`, `loan_transaction_strategy_id`, `is_npa`, `days_in_year_enum`, 
    `interest_recalculation_enabled`,  `loan_product_counter`, `days_in_month_enum`, `version`
)

 select
    la.ENCODEDKEY                                            as external_id,
    mc.id                                                    as client_id,
    mpl.id                                                   as product_id,                                                       
    ms.id                                                    as loan_officer_id,
    la.LOANAMOUNT                                            as principal_amount_proposed,
    la.LOANAMOUNT                                            as principal_amount,
    la.LOANAMOUNT                                            as approved_principal,
    la.LOANAMOUNT                                            as principal_disbursed_derived, 
    la.LOANAMOUNT                                            as principal_outstanding_derived,
--    if (la.INTERESTCHARGEFREQUENCY = 'EVERY_FOUR_WEEKS',
--        ROUND(la.INTERESTRATE * 13 / 12, 6),
--        la.INTERESTRATE)                                      as nominal_interest_rate_per_period,
	la.INTERESTRATE		                                      as nominal_interest_rate_per_period,
    null                                                      as annual_nominal_interest_rate,
    la.REPAYMENTINSTALLMENTS                                  as term_frequency,
    la.REPAYMENTINSTALLMENTS                                  as number_of_repayments,
    date(la.DISBURSEMENTDATE)                                 as submittedon_date,
    date(la.DISBURSEMENTDATE)                                 as approvedon_date,
    date(la.DISBURSEMENTDATE)                                 as expected_disbursedon_date,
    date(la.DISBURSEMENTDATE)                                 as disbursedon_date,
    la.INTERESTDUE                                            as interest_charged_derived,
    la.INTERESTDUE                                            as interest_outstanding_derived,
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
    1 as `loan_transaction_strategy_id`,
    0 as `is_npa`,
    360 as `days_in_year_enum`, 
    0 as `interest_recalculation_enabled`, 
    1 as `loan_product_counter`,
    30 as `days_in_month_enum`,
    3 as `version`

from
    phil20160204.loanaccount la
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
    total_expected_costofloan_derived = interest_charged_derived,
    total_outstanding_derived = (principal_amount + interest_charged_derived)
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
left join phil20160204.loanaccount gla on ml.external_id = gla.encodedkey
left join `mifostenant-default`.m_office mo on gla.assignedbranchkey = mo.external_id
;
--     could add `payment_detail_id` with a script



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
left join phil20160204.loanaccount gla on ml.external_id = gla.encodedkey
left join `mifostenant-default`.m_office mo on gla.assignedbranchkey = mo.external_id
;





-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- LOAN SCHEDULE UPDATE
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
    phil20160204.repayment phr, `mifostenant-default`.m_loan ml
where
     ml.external_id = phr.PARENTACCOUNTKEY
order by
     phr.PARENTACCOUNTKEY, phr.duedate
;


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
    phil20160204.loantransaction lt,
    phil20160204.loanaccount la,
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
-- ?
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
SELECT * from phil20160204.loantransaction group by type;

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
    phil20160204.predefinedfeeamount fa,
    phil20160204.loantransaction lt,
    phil20160204.loanaccount la
    -- phil20160204.repayment r
where
    fa.LOANPREDEFINEDFEEAMOUNTS_ENCODEDKEY_OWN = lt.ENCODEDKEY
    and la.ENCODEDKEY = lt.PARENTACCOUNTKEY
    and lt.`type` = 'FEE'
order by lt.PARENTACCOUNTKEY, lt.CREATIONDATE   
;


SELECT * from `mifostenant-default`.m_loan_transaction group by transaction_type_enum;

SELECT type, count(*) FROM guatemala.loantransaction group by type;
SELECT type, count(*) FROM phil20160204.loantransaction group by type;

select count(*) from phil20160204.repayment;
select * from phil20160204.loantransaction where PARENTACCOUNTKEY = '8a10ca994b09d039014b0e1d85e56713';
select * from phil20160204.loanaccount where REPAYMENTINSTALLMENTS = 1;
select * from phil20160204.predefinedfeeamount;

/**
Repayment query
**/

