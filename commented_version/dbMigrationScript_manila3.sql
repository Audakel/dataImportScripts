
# another thing that may or may not have caused a promblem.accessible
-- AT VERY Beginning
-- admin -> system -> configuration -> disable everything. there will be one that can't be disabled - a rounding one maybe. It's not a big deal.
-- the main one that was killing you: the reschedule- things. when someone makes a repayment, it does all the calculations for the rest of the repayments and everything.



-- ####################################################################################
-- ##############
-- START - Highlight & run to next STOP (~ around line 600 is next stop as of wrting this)
-- ##############
-- ####################################################################################




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
    )), '%Y-%m-%d')                  as ACTIVATION_DATE, # special attention here to date format
    ifnull(o.id, 2)                     as OFFICE_ID,
    COALESCE(ms.id , 1)              as STAFF_ID,
    c.FIRSTNAME                      as FIRST_NAME,
    c.LASTNAME                       as LAST_NAME,
    COALESCE(c.MIDDLENAME, '')       as MIDDLE_NAME, # edge case for missing nmiddle name.
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
    office_joining_date = activation_date, #mamanbu doesnt have these fields.
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

-- Should be done already in base install from manila
   
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- Group Migration 
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
; # some groupnames were duplicate . but this script didn't work perfect all the time.

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
    SELECT * FROM ( #special query looing for mifos couldn't have groups vreated before loan, but mambu allow group created after group loan created.
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
    `hierarchy`= concat('.', parent_id, '.', id, '.'), # mifos uses this for dropdown menus.
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
DROP INDEX `loan_account_no_UNIQUE` ; # loan account numbers can be the same in mambu.


# you first create loan. then apply interest transactions - original interest. then a couple other things.
#this is phase 1 - put entryies in db to crate loan.

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
	-- all these are mifos defaults.
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
	1 as `submittedon_userid`, # this stands for app or magrations
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
set global connect_timeout=60000; # if you do it in one session, this should work fo rthe rest of the time. You can check in settings.

# if you're going to pay back every week, mifos makes entries for each of those weeks.
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

# to get mambu to match Kredits, they had to put fees in. But they didn't actually charge the fees. So not needed.

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- LOAN UPDATE
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------

set global connect_timeout=60000;

UPDATE `mifostenant-default`.m_loan ml
join input_db.loanaccount la on ml.external_id = la.encodedkey
set
	principal_amount_proposed 			= la.LOANAMOUNT, 
	principal_amount 					= la.LOANAMOUNT,
	approved_principal 					= la.LOANAMOUNT, 
	principal_disbursed_derived 		= la.LOANAMOUNT,  
	principal_outstanding_derived 		= la.LOANAMOUNT,
	principal_repaid_derived 			= la.principalpaid, 
	principal_repaid_derived 			= la.principalpaid, 
	interest_repaid_derived 			= la.interestpaid, 
	fee_charges_repaid_derived 			= la.feespaid
; 
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- LOAN DISBURSEMENT TRANSACTIONS. you appy for a loan, get approved, disbursed (interest applied, )
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
        DATE_SUB(curdate(), INTERVAL 10 YEAR))        as `transaction_date`, # take it back 10 years, because if person A ctrated at date xx, he cant have a loan from the day before xx. Mambu allows it. Put the times in an appropriate spot. Mifos api only checks once for that stuff. then we can recreate how mambu had it.
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

UPDATE `mifostenant-default`.m_loan ml
join (
	SELECT 
		PARENTACCOUNTKEY as PARENTACCOUNTKEY, 
		SUM(INTERESTDUE) as interest
	FROM input_db.repayment 
	Group By PARENTACCOUNTKEY
) as t4 on ml.external_id = t4.PARENTACCOUNTKEY
set ml.interest_charged_derived = t4.interest   
; # how much total interest is due. how much they should have paid.

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
	ml.fee_charges_charged_derived = mlc.amount; #mi;ght have been where the fake fees went in. on disbursal had to make fake fees.

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
	principal_outstanding_derived 		= (principal_disbursed_derived - principal_repaid_derived),
	interest_outstanding_derived 		= (interest_charged_derived - interest_repaid_derived),
	fee_charges_outstanding_derived 	= (fee_charges_charged_derived - fee_charges_repaid_derived),
    penalty_charges_outstanding_derived = (penalty_charges_charged_derived - penalty_charges_repaid_derived)
;


-- TOTALS
UPDATE 
	`mifostenant-default`.`m_loan` 
SET 
	total_expected_repayment_derived 	= (principal_disbursed_derived 
											+ interest_charged_derived 
											+ fee_charges_charged_derived 
											+ penalty_charges_charged_derived),
    total_repayment_derived 			= (principal_repaid_derived 
											+ interest_repaid_derived 
											+ fee_charges_repaid_derived 
											+ penalty_charges_repaid_derived),
    total_waived_derived 				= (interest_waived_derived + fee_charges_waived_derived + penalty_charges_waived_derived),
    total_writtenoff_derived 			= (principal_writtenoff_derived + interest_writtenoff_derived + fee_charges_writtenoff_derived + penalty_charges_writtenoff_derived),
    total_outstanding_derived 			= (principal_outstanding_derived + interest_outstanding_derived + fee_charges_outstanding_derived + penalty_charges_outstanding_derived)
    
    -- ?? Where is this used ??
    -- total_expected_costofloan_derived = 666
;
# not totally necessary. The scripts take care of it.

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- REPAYMENTS  
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------

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
#		and la.ASSIGNEDBRANCHKEY = '8a2b82e6455edd890145bbc90f6c75af'
		and la.DISBURSEMENTDATE is null
        GROUP BY ml.id) as tableID
        
) 
;


update `mifostenant-default`.c_configuration
set enabled = 1
where name = 'allow-transactions-on-holiday'
;

-- Error Code: 1064. You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '' at line 18

-- ####################################################################################
-- ##############
-- STOP 1 (MAKE BACKUP of db B4 this next step) 
-- Run the next  'EXPORT' comand and export this next query to transactions.csv and 
--    then run the loan_transactions.py script
-- ##############
-- ####################################################################################

-- Speed tests - should be no less than ~20 transactions/second while py script is running
--    you can run this command, take note of the time and number of transactions. About a min or so latter
--    repeat, and look at the diference to calculate transactions/second. 
SELECT * FROM `mifostenant-default`.m_loan_transaction where transaction_type_enum = 2;

-- 
-- ##### EXPORT ####
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
#    and la.ASSIGNEDBRANCHKEY = '8a2b82e6455edd890145bbc90f6c75af'
order by lt.parentaccountkey asc, lt.creationdate asc
 ;




-- ####################################################################################
-- ##############
-- Start again mysql query - Highlight & run to next STOP
-- ##############
-- ####################################################################################

SET SQL_SAFE_UPDATES = 0;


UPDATE `mifostenant-default`.m_client mc
join input_db.client c on c.encodedkey = mc.external_id
join `mifostenant-default`.m_office o on o.external_id = c.ASSIGNEDBRANCHKEY
join `mifostenant-default`.m_staff s on s.external_id = c.ASSIGNEDUSERKEY
set 
	mc.office_id = o.id,
    mc.staff_id = s.id
; # needed easier way to connect back to mambu ids. Maybe some clients needed to be fixed.
# instead of having mambu ids, its switching them over to mifos ids.

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- CREATE SAVINGS ACCOUNTS
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------

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
# where
#    sa.ASSIGNEDBRANCHKEY = '8a2b82e6455edd890145bbc90f6c75af'
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
VALUES ('2', 'Interest Hack', 'Hack', '0'); # cash, bank card, etc. Tehre was something to do with rounding that was causing errors. Or needed a payment type, to classiffy the payment as. 


-- ####################################################################################
-- ##############
-- STOP 2 (MAKE BACKUP of db B4 this next step) Run the next comand 'EXPORT' and 
-- export the next step to savings.csv and then run saving_transaction.py
-- ##############
-- ####################################################################################

-- ############## Export ############## 
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
#    and sa.ASSIGNEDBRANCHKEY = '8a2b82e6455edd890145bbc90f6c75af'
order by st.parentaccountkey asc, st.creationdate asc
 ;
 
 
-- ####################################################################################
-- ##############
-- Start 
-- ##############
-- ####################################################################################

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
; # they need at least 1000 php to get interest. anything below, they won't get interest calculated.

update `mifostenant-default`.m_savings_product
set min_balance_for_interest_calculation = 1000
;

# try putting any loans with 'amount' as null to amount = 0. That should stop the amount cannot be null errors.

-- ####################################################################################
-- ##############
-- STOP 3 Run the next comand 'EXPORT' and export the next step to loanWriteOff.csv and then run close_accounts.py
-- ##############
-- ####################################################################################

-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- 	Close accounts to match Mambu
-- ----------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------
-- ############## Export ############## 
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
-- ####################################################################################
-- ##############
-- Start 
-- ##############
-- ####################################################################################

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
# might not have even worked. Trying to create a user that could only see pasig accounts. So when the user logs in, they don't see all the laons, only the ones in pasig.

-- ####################################################################################
-- ##############
-- STOP 
-- ##############
-- ####################################################################################


-- To do
-- admin -> system -> scheduler jobs 
-- click all then run selected jobs.accessible

-- then refresh and look at previous run status.accessible
-- "update loans summary" - important one. fixes all those totals at bottom.

