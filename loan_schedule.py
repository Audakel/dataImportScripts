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
auth_res = requests.post(API_URL + '/authentication?username=mifos&password=password', headers=auth_token,
                         verify=False).json()
auth_token["Authorization"] = "Basic %s" % auth_res['base64EncodedAuthenticationKey']
loans = requests.get(API_URL + '/loans?limit=0', headers=auth_token, verify=False).json()


# loans = {l['externalId']: l['id'] for l in loans['pageItems']}


class Loan():
    def __init__(self, schedule): #, loan_id=''):
        self.schedule = schedule
        # self.id = loans[loan_id]


class Schedule():
    def __init__(self, loan_id, duedate, principal_amount, interest_amount, completed_derived,
                 createdby_id, created_date, lastmodified_date, lastmodifiedby_id, recalculated_interest_component):
        if loan_id.isdigit():
            self.loan_id = int(loan_id)
        else:
            self.loan_id = loan_id

        self.duedate = duedate
        self.principal_amount = principal_amount
        self.interest_amount = interest_amount
        self.completed_derived = completed_derived
        self.createdby_id = createdby_id
        self.created_date = created_date
        self.lastmodified_date = lastmodified_date
        self.lastmodifiedby_id = lastmodifiedby_id
        self.recalculated_interest_component = recalculated_interest_component

        def __str__(self):
            return '{}, {}, {}'.format(self.loan_id, self.principal_amount, self.duedate)

        def __repr__(self):
            return '{}, {}, {}'.format(self.loan_id, self.principal_amount, self.duedate)

        def __unicode__(self):
            return '{}, {}, {}'.format(self.loan_id, self.principal_amount, self.duedate)

update_schedule = ("UPDATE  m_loan_repayment_schedule"
    "("
      "loan_id, duedate, installment, principal_amount,interest_amount,completed_derived,createdby_id,"
      "created_date,lastmodified_date, lastmodifiedby_id, recalculated_interest_component"
    ")"
    "VALUES"
    "(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)")

"""
      loan_id = '%s',
      duedate = '%s',
      installment = '%s',
      principal_amount = '%s',
      interest_amount = '%s',
      completed_derived = '%s',
      createdby_id = '%s',
      created_date = '%s',
      lastmodified_date = '%s',
      lastmodifiedby_id = '%s',
      recalculated_interest_component = '%s'
    )
"""

def updateLoanSchedule(cursor, loan):
    global cnx
    for i, s in enumerate(loan.schedule):
        tup = (
            s.loan_id,
            s.duedate,
            i + 1,
            s.principal_amount,
            s.interest_amount,
            s.completed_derived,
            s.createdby_id,
            s.created_date,
            s.lastmodified_date,
            s.lastmodifiedby_id,
            s.recalculated_interest_component
        )
        print (update_schedule % tup)
        # try:
        cursor.execute(update_schedule, tup)
        # except Exception as e:
        #     # import pdb; pdb.set_trace()
        #     pass
        cnx.commit()

    print('schedule updated')


def main(cursor):
    with open('schedules.csv') as c, concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
        lines = csv.reader(c, delimiter=',', quotechar='"')
        current_parent = ''
        history = []
        for line in lines:
            s = Schedule(*line)
            if s.loan_id == 'loan_id':
                continue
            # if not s.loan_id in loans:
            #     # skip the error message
            #     continue
            if current_parent != s.loan_id:
                # uncomment the two lines to enable threading
                # executor.submit(updateLoanSchedule, (cursor, Loan(s.parent, history)))
                if current_parent != '':
                    # updateLoanSchedule(cursor, Loan(history, current_parent))
                    # cursor.execute("select * from m_loan limit 1;")
                    # print (cursor.fetchall())
                    updateLoanSchedule(cursor, Loan(history))
                history = []
            current_parent = s.loan_id
            history.append(s)
        # executor.submit(updateLoanSchedule, (cursor, Loan(s.parent, history)))
        updateLoanSchedule(cursor, Loan(history))
        executor.shutdown()


cnx = ''
if __name__ == '__main__':
    try:
        cnx = mysql.connector.connect(
                user='root', password='mysql',
                host='localhost',
                database='mifostenant-default'
        )
        cursor = cnx.cursor(prepared=True)
        # cursor.execute("SET FOREIGN_KEY_CHECKS = 0")
        main(cursor)
        cnx.commit()
    finally:
        if cnx:
            cnx.close()
