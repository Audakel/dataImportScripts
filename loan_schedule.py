from datetime import datetime
from decimal import Decimal
import concurrent.futures
import sys
import requests
import csv
import simplejson as json
requests.packages.urllib3.disable_warnings()

import mysql.connector

# Fetch loan ids from Mifos
BASE_URL = 'https://localhost:8443'
API_URL = BASE_URL + '/mifosng-provider/api/v1'
auth_token = {"X-Mifos-Platform-TenantId": 'default'}
auth_res = requests.post(API_URL + '/authentication?username=mifos&password=password', headers=auth_token, verify=False).json()
auth_token["Authorization"] = "Basic %s" %auth_res['base64EncodedAuthenticationKey']
loans = requests.get(API_URL + '/loans?limit=0', headers=auth_token, verify=False).json()
loans = {l['externalId']: l['id'] for l in loans['pageItems']}

class Loan():
    def __init__(self, externalId, schedule):
        self.id = loans[externalId]
        self.schedule = schedule

class Schedule():
    def __init__(self, parent, principal, interest, fee, due):
        self.parent = parent
        self.principal = principal
        self.interest = interest
        self.fee = fee
        self.due = due
    def __str__(self):
        return '{}, {}, {}, {}, {}'.format(self.parent, self.principal, self.interest, self.fee, self.due)
    def __repr__(self):
        return '{}, {}, {}, {}, {}'.format(self.parent, self.principal, self.interest, self.fee, self.due)
    def __unicode__(self):
        return '{}, {}, {}, {}, {}'.format(self.parent, self.principal, self.interest, self.fee, self.due)


# PARENTACCOUNTKEY,
# PRINCIPALDUE,
# INTERESTDUE,
# FEESDUE,
# DUEDATE
update_schedule = """
UPDATE m_loan_schedule 
SET 
    duedate = ?,
    principal_amount = ?,
    interest_amount = ?,
    fee_charges_amount = ?
WHERE
    loan_id = ?
    AND installment = ?
"""

update_summary = """

"""
def updateLoanSchedule(cursor, loan):
    for i, schedule in enumerate(loan.schedule):
        cursor.execute(update_schedule, 
            (schedule.due, schedule.principal, schedule.interest, schedule.fee, loan.id, i+1)
        )

def main(cursor):
    with open('schedules.csv') as c, concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
        lines = csv.reader(c, delimiter=',', quotechar='"')
        current_parent = ''
        history = []
        for line in lines:
            s = Schedule(*line)
            if current_parent != tran.parent:
                # uncomment the two lines to enable threading
                # executor.submit(process_loan, (cursor, Loan(s.parent, history)))
                process_loan(cursor, Loan(s.parent, history))
                history = []
            current_parent = s.parent
            ignore = []
            history.append(s)
        # executor.submit(process_loan, (cursor, Loan(s.parent, history)))
        process_loan(cursor, Loan(s.parent, history))
        executor.shutdown()
    
if __name__ == '__main__':
    try:
        cnx = mysql.connector.connect(
            user='root', password='password',
            host='localhost',
            database='mifostenant-default'
        )
        cursor = cnx.cursor(prepared=True)
        main(cursor)
    finally:
        cnx.close()
            