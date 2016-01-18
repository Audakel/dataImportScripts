/* General Errors
 "groupId:The parameter groupId must be greater than 0.	"
  "id:The date on which a loan is submitted cannot be earlier than groups's activation date.	"
"loanTermFrequency:The parameter loanTermFrequency is less than the suggest loan term as indicated by numberOfRepayments and repaymentEvery.	"
"id:Loan product with identifier 0 does not exist	"


General TODO
change senahu in mambu to senahu 1

Have a for loop fix the `mifostenant-default`.m_holiday_office(holiday_id, office_id) issue


FOR MI_GUATAMALA TO FIX
tell gloria to put the staff back in correct offices (out of head)
fix min/max interst rates
*/


-- ############################
-- ##############
-- DATABASE PREP
-- ##############
-- ############################


-- Change senahu in mambu to senahu 1
-- UPDATE `pasig`.`branch` SET `ID`='Senahú 1', `NAME`='Senahú 1' WHERE `ENCODEDKEY`='8abc1aea45eb1c2a0145f78a81e45bd8';


-- Grab all the offices from Mambu and put into Mifos
INSERT INTO `mifostenant-default`.`m_office` VALUES (1,NULL,'.','1','Head Office','2009-01-01');


INSERT INTO 
	`mifostenant-default`.`m_office` (`parent_id`, `external_id`, `name`, `opening_date`) 
SELECT 
	1, ID, name, CREATIONDATE 
FROM 
	`pasig`.branch 
;    


INSERT INTO `mifostenant-default`.`m_office` 
	(`parent_id`, `name`, `opening_date`) 
VALUE (1,'OFFICE TBD', current_date())
; 


UPDATE 
	`mifostenant-default`.`m_office` 
SET 
	`opening_date`= (SELECT CREATIONDATE FROM pasig.client ORDER BY CREATIONDATE ASC LIMIT 1)
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


-- INSERT INTO 
	-- your_table (ID, ISO3, TEXT) SELECT ID, 'JPN', TEXT FROM your_table WHERE ID IN ( list_of_ ids )



-- Open up Interest Rates
UPDATE `mifostenant-default`.`m_product_loan` 
SET `min_nominal_interest_rate_per_period`='0', `max_nominal_interest_rate_per_period`='80' 
WHERE `id`<>'';


-- Clean up loan names
UPDATE `mifostenant-default`.`m_product_loan` SET `name`='Special Individual Loan' WHERE `id`='6';
UPDATE `mifostenant-default`.`m_product_loan` SET `name`='Business Opportunity Loan' WHERE `id`='2';


UPDATE `pasig`.`client` SET FIRSTNAME = REPLACE(FIRSTNAME, ',', ' ') LIMIT 60000;
UPDATE `pasig`.`client` SET MIDDLENAME = REPLACE(MIDDLENAME, ',', ' ')LIMIT 60000;
UPDATE `pasig`.`client` SET LASTNAME = REPLACE(LASTNAME, ',', ' ')LIMIT 60000;


UPDATE `pasig`.`user` SET `FIRSTNAME`='Roland' WHERE `ENCODEDKEY`='8a28afc7474813a4014757b332b420e5';

-- m_staff
INSERT INTO 
	`mifostenant-default`.`m_staff` 
	(`is_loan_officer`, `office_id`, `firstname`, `lastname`, `display_name`) 
SELECT 
	1, 1, firstname, lastname collate utf8_bin, concat(lastname,", ",FIRSTNAME)  as displayname 
FROM 
	`pasig`.user
GROUP BY displayname
;


-- Put all the default TBD stuff in
INSERT INTO `mifostenant-default`.`m_staff` 
	(`is_loan_officer`, `office_id`, `firstname`, `lastname`, `display_name`) 
values (1, 1, 'STAFF', 'TBD', 'STAFF TBD')
;

/*
INSERT INTO `mifostenant-default`.`m_group` -- CENTER
	(`id`, `status_enum`, `activation_date`, `office_id`, `level_id`, `display_name`, `hierarchy`, `activatedon_userid`, `submittedon_date`, `submittedon_userid`, `account_no`) 
VALUES ('1', '300', DATE_SUB(current_date(), INTERVAL 10 YEAR), '1', '1', 'CENTER TBD', '.1.', '1', DATE_SUB(current_date(), INTERVAL 10 YEAR), '1', '000000001');
*/   

    

INSERT INTO `mifostenant-default`.`m_payment_type` 
( `value`, `description`, `is_cash_payment`, `order_position`) 
VALUES ( 'Migration', 'H Migration', '0', '1');


-- ############################
-- ##############
-- END DATABASE PREP
-- ##############
-- ############################



-- ---------------
-- Staff Migration
-- ---------------
/*
 Need to not delete people from m-appuser table
*/






-- ----------------
-- Update office start dates
-- ----------------
/*
Add 'OFFICE TBD'
Change 'Senahu' to 'Senahu 1'
*/




-- ----------------
-- Client Migration
-- ----------------
/*

*/

select * from `mifostenant-default`.`m_office`;
select * from `mifostenant-default`.`m_client`;

INSERT INTO `mifostenant-default`.`m_user` 
	(`external_id`, `status_enum`, `activation_date`, `office_joining_date`, `office_id`, `staff_id`, `firstname`, `middlename`, `lastname`, `display_name`, `submittedon_date`, `submittedon_userid`, `activatedon_userid`) VALUES ('', '', 'fghjkl', '300', '2015-04-15', '2015-04-15', '7', '78', 'CIRILA', 'DADULLA', 'MALLILLIN', 'CIRILA DADULLA MALLILLIN', '2015-04-15', '1', '1');
	(`firstname`, `lastname`, `middlename`, 

select 
	c.FIRSTNAME                      as FIRST_NAME, 
    c.LASTNAME                       as LAST_NAME, 
    COALESCE(c.MIDDLENAME, '')       as MIDDLE_NAME, 
    /*COALESCE((replace(rtrim((ifnull(
		b2.name, b.name))), ' ', '_')),  
        'OFFICE_TBD')				 as OFFICE_NAME, */
	
        
    COALESCE((CONCAT(
		s.FIRSTNAME, ' ', s.LASTNAME
	)), 'STAFF TBD') 				 as STAFF_NAME, 
    c.ID                             as EXTERNAL_ID,
    DATE_FORMAT(date(LEAST(
		coalesce(c.CREATIONDATE, CURDATE()),
        coalesce(c.APPROVEDDATE, CURDATE()),
        coalesce(c.ACTIVATIONDATE, CURDATE()),
        coalesce(lad.DISBURSEMENTDATE, CURDATE())
	)), '%d/%m/%Y')                  as ACTIVATION_DATE,
    'TRUE'                           as ACTIVE
from 
	pasig.client c
	left join pasig.branch b on c.ASSIGNEDBRANCHKEY = b.ENCODEDKEY
	left join pasig.user s   on c.ASSIGNEDUSERKEY   = s.ENCODEDKEY
    left join
    (
		SELECT * FROM (
			SELECT DISBURSEMENTDATE, ACCOUNTHOLDERKEY, ACCOUNTHOLDERTYPE
			FROM pasig.loanaccount
			WHERE ACCOUNTHOLDERTYPE = 'CLIENT'
			ORDER BY DISBURSEMENTDATE asc
		) as t1
		GROUP BY ACCOUNTHOLDERKEY
    ) lad on c.ENCODEDKEY = lad.ACCOUNTHOLDERKEY
    
        -- Get the correct office for the group and give that to the client
    left join pasig.groupmember gm on gm.clientkey = c.encodedkey 
	left join pasig.`group` g on g.ENCODEDKEY = gm.groupkey
	left join pasig.centre cn on cn.ENCODEDKEY = g.ASSIGNEDCENTREKEY
	left join pasig.branch b2 on cn.ASSIGNEDBRANCHKEY = b2.ENCODEDKEY
;


-- ----------------
-- Center Migration
-- ----------------

/*
N.B. that 'STAFF TBD' is inserted for Mifos STAFF_NAME 
	because Mambu does not have staff associated with Centers
*/
SELECT * from branch;

SELECT 
	concat('CENTER TBD',
		'(', b.id, ')')             	 as CENTER_NAME,
    replace(rtrim(b.ID), ' ', '_')       as OFFICE_NAME, 
    'STAFF TBD'                          as STAFF_NAME,
    ''		                             as EXTERNAL_ID,
    'True'                               as ACTIVE,
	DATE_FORMAT(date(b.CREATIONDATE), '%d/%m/%Y') as ACTIVATION_DATE
from branch as b
UNION
select -- DISTINCT
	centre.id                          	 as CENTER_NAME,
    replace(rtrim(b.ID), ' ', '_')       as OFFICE_NAME, 
    'STAFF TBD'                          as STAFF_NAME,
    centre.ID                            as EXTERNAL_ID,
    'True'                               as ACTIVE,
	DATE_FORMAT(date(centre.CREATIONDATE), '%d/%m/%Y') as ACTIVATION_DATE
from 
	centre
	left join branch as b on b.ENCODEDKEY = centre.ASSIGNEDBRANCHKEY
;

-- ----------------
-- Group Migration
-- ----------------
/*
Migrate Groups
	- LOOK FOR N/A
	- add CENTER TBD
    - change all the center names to get rid of location names
    - 'Jessica Gabriela Cabrera Ocoix, de pin' has a comma in it that messes things up
	- have to split clients on comma in excel right now. highlight column -> click data tab -> text to column
	- to get client names with id
		1) Highlight and copy columns with client name and id from clients tab (upload sheet)
        2) Make new tab and paste data into column a and b
        3) Insert row between a and b and put this into it: 
			=LEFT(A1,FIND("(",A1)-1)
        4) highlight range to end of names, ctr + d to copy formula down
        3) Highlight and copy columns with group names from export sheet
        4) Paste into col e (leaves one col for space)
        5) If the largest group size is 3, add on col for space and insert in the next col:
			=IF(E1="","",CONCATENATE(E1,"(",(VLOOKUP(E1,$B$1:$C$3315,2,)),")"))
		6) Drag down to get all the needed rows and columns
        7) Copy paste (special paste as value) the names back into the upload sheet
*/

select DISTINCT 
	g.groupname                      as GROUP_NAME,
 	replace(rtrim(b.ID), ' ', '_')   as OFFICE_NAME, 
 	CONCAT(u.FIRSTNAME, ' ', 
		COALESCE(NULLIF(u.LASTNAME,''), 
		u.FIRSTNAME)) 				 as STAFF_NAME, 
 	COALESCE(cn.id, 
		CONCAT('CENTER TBD',
			'(', b.ID, ')'
	))							     as CENTER_NAME,
 	g.id                             as EXTERNAL_ID,
 	'True'                           as ACTIVE, 
	DATE_FORMAT(date(LEAST(
		coalesce(g.CREATIONDATE, CURDATE()),
        coalesce(lad.DISBURSEMENTDATE, CURDATE())
	)), '%d/%m/%Y')                  as ACTIVATION_DATE,
 	""                               as MEETING_START_DATE,
 	''                               as REPEAT_FLAG,
 	''                               as FREQUENCY,
 	''                               as INTERVAL_NUM,
 	''                               as REPEATS_ON,
 	'','','',

	ifnull(GROUP_CONCAT( DISTINCT 
		CONCAT(
			c.firstname, ' ', 
			if(c.MIDDLENAME IS NULL OR c.MIDDLENAME = '', '', concat(c.MIDDLENAME, ' ')),
			c.lastname 
		) SEPARATOR ','), "") 
	as clientsC 
	
from `group` g 
	left join groupmember gm on g.ENCODEDKEY  = gm.groupkey
	left join `client` c     on gm.clientkey  = c.encodedkey
	left join centre cn      on cn.ENCODEDKEY = g.ASSIGNEDCENTREKEY
	left join branch b       on b.ENCODEDKEY  = g.ASSIGNEDBRANCHKEY
	left join user u         on u.ENCODEDKEY  = g.ASSIGNEDUSERKEY
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
SELECT * from `group` where ASSIGNEDCENTREKEY is null;


-- ##################################
-- end
-- ##################################


-- ----------------
-- Loan Migration
-- ----------------



select * from loanaccount;
select id, productname from loanproduct;


-- --------------------
-- Group Loan Migration
-- --------------------

UPDATE `mifostenant-default`.`m_product_loan` 
SET `min_nominal_interest_rate_per_period`='0', `max_nominal_interest_rate_per_period`='50' 
WHERE `id`<>'';


/*
Some of the groups did not get migrated as the where not found
You may have to add the office Senahu's groups by hand - err with DataImportTool
Make all days workign days in mifos - then change back
You may have to add the fund id, payment id, by hand
change all the interest rates
chagne all the product names to match
*/
 select
    replace(rtrim(b.NAME), ' ', '_') 						as OFFICE_NAME, 
    'Group'													as LOAN_TYPE,
    g.GROUPNAME 											as GROUP_NAME,
	replace(rtrim(CONCAT(UCASE(LEFT(
		lp.PRODUCTNAME, 1)), 
		SUBSTRING(lp.PRODUCTNAME, 2))), ' ', '_') 			as LOAN_PRODUCT,
    CONCAT(u.FIRSTNAME, ' ', u.LASTNAME) 					as STAFF_NAME,
    date(la.DISBURSEMENTDATE) 								as SUBMITTED,
    date(la.DISBURSEMENTDATE) 								as APPROVED,
    date(la.DISBURSEMENTDATE) 								as DISBURSED,
    'Migration' as PAYMENTTYPE, 'Mentors International' 		as 'FUND',
    la.LOANAMOUNT											as PRINCIPAL,
    la.REPAYMENTINSTALLMENTS									as REPAYMENT_INSTALLMENTS,
    if (la.REPAYMENTPERIODCOUNT is null or la.REPAYMENTPERIODCOUNT = 0, 
		'1', la.REPAYMENTPERIODCOUNT)						as 'REPAID',
    if (la.REPAYMENTPERIODCOUNT is null or la.REPAYMENTPERIODCOUNT = 0, 
		'Months', 'Days') 									as 'RPUNIT',
    la.REPAYMENTINSTALLMENTS 								as 'TERM',
    if (la.REPAYMENTPERIODCOUNT is null or la.REPAYMENTPERIODCOUNT = 0, 
		'Months', 'Days') 									as 'LTUNIT',
    if (la.INTERESTCHARGEFREQUENCY = 'EVERY_FOUR_WEEKS', 
		ROUND(la.INTERESTRATE * 13 / 12, 6), la.INTERESTRATE) as 'NOMINAL',
    if (la.INTERESTCHARGEFREQUENCY = 'EVERY_MONTH', 'Per Month', 
		if (la.INTERESTCHARGEFREQUENCY = 'EVERY_FOUR_WEEKS', 
			'Per Month', 'Per Year')) 						as 'FREQUENCY',
    'Equal installments' 									as 'AMORTIZATION',
    'Flat' as 'INTEREST',
    'Same as repayment period', 
        '0', 'Mifos Style', '0', '0', '0',
    '','','','','','','','',la.ENCODEDKEY

from (loanaccount la, user u, loanproduct lp, branch b, `group` g)
where 
    la.ACCOUNTHOLDERKEY = g.ENCODEDKEY
	AND u.ENCODEDKEY = la.ASSIGNEDUSERKEY
-- AND centre.ENCODEDKEY = la.ASSIGNEDCENTREKEY
	AND lp.ENCODEDKEY = la.PRODUCTTYPEKEY
	AND b.ENCODEDKEY = la.ASSIGNEDBRANCHKEY
	AND la.ACCOUNTHOLDERTYPE = 'GROUP'
-- AND b.NAME = 'Pasig'
;




-- -------------------------
-- Individual Loan Migration
-- -------------------------
select id, external_id, firstname, lastname from `mifostenant-default`.m_client;

SELECT 
 
    replace(rtrim(b.NAME), ' ', '_') 						as OFFICE_NAME, 
    'Individual'											as LOAN_TYPE,
    CONCAT(c.firstname, ' ', 
		if(c.middlename is NULL OR c.middlename = '', 
			'', CONCAT(c.middlename, ' ')), 
		c.lastname) 										as `NAME`,
	replace(rtrim(CONCAT(UCASE(LEFT(
		lp.PRODUCTNAME, 1)), 
		SUBSTRING(lp.PRODUCTNAME, 2))), ' ', '_') 			as LOAN_PRODUCT,
    CONCAT(u.FIRSTNAME, ' ', u.LASTNAME) 					as STAFF_NAME,
    date(la.DISBURSEMENTDATE) 								as SUBMITTED,
    date(la.DISBURSEMENTDATE) 								as APPROVED,
    date(la.DISBURSEMENTDATE) 								as DISBURSED,
    'Migration' 											as PAYMENTTYPE, 
    'Mentors International' 								as 'FUND',
    la.LOANAMOUNT											as PRINCIPAL,
    la.REPAYMENTINSTALLMENTS								as REPAYMENT_INSTALLMENTS,
    if (la.REPAYMENTPERIODCOUNT is null or la.REPAYMENTPERIODCOUNT = 0, 
		'1', la.REPAYMENTPERIODCOUNT)						as 'REPAID',
    if (la.REPAYMENTPERIODCOUNT is null or la.REPAYMENTPERIODCOUNT = 0, 
		'Months', 'Days') 									as 'RPUNIT',
    la.REPAYMENTINSTALLMENTS 								as 'TERM',
    if (la.REPAYMENTPERIODCOUNT is null or la.REPAYMENTPERIODCOUNT = 0, 
		'Months', 'Days') 									as 'LTUNIT',
    if (la.INTERESTCHARGEFREQUENCY = 'EVERY_FOUR_WEEKS', 
		ROUND(la.INTERESTRATE * 13 / 12, 6), la.INTERESTRATE) as 'NOMINAL',
    if (la.INTERESTCHARGEFREQUENCY = 'EVERY_MONTH', 'Per Month', 
		if (la.INTERESTCHARGEFREQUENCY = 'EVERY_FOUR_WEEKS', 
			'Per Month', 'Per Year')) 						as 'FREQUENCY',
    'Equal installments' 									as 'AMORTIZATION',
    'Flat' 													as 'INTEREST',
    'Same as repayment period'								as INTEREST_CALC_PERIOD, 
        '0', 'Mifos Style', '0', '0', '0',
    '','','','','','','','',la.ENCODEDKEY

from 
	(loanaccount la, user u, loanproduct lp, `client` c, branch b)
where 
	u.ENCODEDKEY = la.ASSIGNEDUSERKEY
	AND la.PRODUCTTYPEKEY = lp.ENCODEDKEY
	AND la.ASSIGNEDBRANCHKEY =b.ENCODEDKEY
    AND la.ACCOUNTHOLDERKEY = c.ENCODEDKEY
    AND la.ACCOUNTHOLDERTYPE = 'CLIENT'
-- AND b.NAME = 'Pasig'
;

-- 8a10ca994b09d039014b174acc784cc0
select ENCODEDKEY, type, REVERSALTRANSACTIONKEY from guatamala.loantransaction where REVERSALTRANSACTIONKEY is not null;
-- TIPT945

SELECT 
	lt.parentaccountkey
from 
	guatamala.loantransaction lt
group by lt.parentaccountkey
order by (count(lt.parentaccountkey)) desc 
limit 10
;

SELECT id from guatamala.loanaccount where encodedkey = '8a9d7e284b75fe4b014b7a05572a0b1b';

(select 
	lt.TYPE,
	lt.ENCODEDKEY,
    lt.PARENTACCOUNTKEY,
    lt.AMOUNT,
    DATE_FORMAT(date(lt.CREATIONDATE), '%d/%m/%Y') as date,
    ifnull(lt.REVERSALTRANSACTIONKEY,'') as reversalKey
from 
	guatamala.loantransaction lt,
    guatamala.loanaccount la

where 
	lt.parentaccountkey = la.encodedkey
    and la.encodedkey in 
    (
		SELECT 
			lt.parentaccountkey
		from 
			 (guatamala.loantransaction lt, guatamala.loanaccount la)
		where
			la.ENCODEDKEY = lt.PARENTACCOUNTKEY and
            -- la.ACCOUNTSTATE like '%CLOSED%'
			-- la.accountholdertype = 'GROUP'
			-- lt.parentaccountkey= '8a9d7e284b75fe4b014b7a05572a0b1b' or
			-- lt.parentaccountkey= '8a9c4d8c4c2a3654014c2da9018a6e9e' -- or
			-- lt.parentaccountkey= '8a36219649e44d120149e8c4c86f50fa' or
			-- lt.parentaccountkey= '8a9d992d4c1acee0014c2ed7d6cb14ad' or
			-- lt.parentaccountkey= '8a10d7894b2f253a014b317dcb8e0e0d' or
			-- lt.parentaccountkey= '8a9c4d8c4c2a3654014c2d8dd19c45ec' or
			-- lt.parentaccountkey= '8aa85edc4ae70c4a014aefac6cbf5b03' or
            
            -- closed
			(lt.parentaccountkey= '8a9d992d4c1acee0014c2ed7d6cb14ad' or
			lt.parentaccountkey= '8a36219649e44d120149e8c4c86f50fa' or
			lt.parentaccountkey= '8a9d7e284b75fe4b014b7a05572a0b1b')
		group by lt.parentaccountkey
		-- order by (count(lt.parentaccountkey)) desc 
    )    
	-- AND la.ACCOUNTHOLDERTYPE = 'CLIENT'
	-- AND lp.ENCODEDKEY = la.PRODUCTTYPEKEY
	-- AND g.ENCODEDKEY = la.ACCOUNTHOLDERKEY
    -- and l.PARENTACCOUNTKEY = '8a181b3b499d76ab0149af538e714c87'
order by lt.parentaccountkey asc, lt.creationdate asc)
 ;


SELECT * from 
SELECT * from guatamala.loanaccount where ENCODEDKEY = '8a9c4d8c4c2a3654014c2da9018a6e9e';
SELECT * from guatamala.loanaccount where ACCOUNTSTATE like '%CLOSED%';

select lt.type, count(lt.type), round(max(lt.amount)) as max, round(min(lt.amount)) as min, la.ACCOUNTHOLDERTYPE, la.ACCOUNTSTATE 
	from (guatamala.loantransaction lt, guatamala.loanaccount la)
    where la.ENCODEDKEY = lt.PARENTACCOUNTKEY and
    la.accountholdertype = 'CLIENT'
    group by type;
