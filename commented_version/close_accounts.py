from datetime import datetime
from decimal import Decimal
import concurrent.futures
import sys
import requests
import csv
import simplejson as json
import os
requests.packages.urllib3.disable_warnings()

BASE_URL = 'https://localhost:8443'
API_URL = BASE_URL + '/fineract-provider/api/v1'
auth_token = {}
auth_token["fineract-Platform-TenantId"] = 'default'
auth_res = requests.post(API_URL + '/authentication?username=mifos&password=password', headers=auth_token, verify=False).json()
auth_token["Authorization"] = "Basic %s" %auth_res['base64EncodedAuthenticationKey']

DATE_FORMAT = "dd MMMM yyyy"
LOCALE = "en"

def formatDate(date):
    return datetime.strftime(datetime.strptime(date, '%d/%m/%Y'), '%d %B %Y')


def close_loan(transaction):
    data = {
        "locale": LOCALE,
        "dateFormat": DATE_FORMAT,
        "transactionDate": formatDate(transaction.close_date)
    }
    try:
        res = requests.post(API_URL+ '/loans/{}/transactions?command=writeoff'.format(transaction.mifos_id), 
            headers=auth_token, json=data, verify=False, timeout=10).json()
        good = res['changes'] # pause it for a second on good. see if everthing is good. 'changes' might be for good and bad now.
        # maybe if status = 200. they don't send back statuses, they just send back a few parameters.
    except Exception as e:
        print("\nerror: client id: ", loanid, "err res: ",e, "\n", res)# last_repayment = {'id': res['resourceId'], 'amount': transaction.amount}

# ask james about pdb statemants
# import pdb. set interface.

def close_savings(transaction):
    data = {
        "locale": LOCALE,
        "dateFormat": DATE_FORMAT,
        "transactionDate": formatDate(transaction.close_date)
    }
    try:
        res = requests.post(API_URL+ '/savingsaccounts/{}/?command=close'.format(transaction.mifos_id), 
            headers=auth_token, json=data, verify=False, timeout=10).json()
        good = res['changes']
    except Exception as e:
        print("\nerror: client id: ", loanid, "err res: ",e, "\n", res)# last_repayment = {'id': res['resourceId'], 'amount': transaction.amount}


def close_client(transaction):
    data = {
        "locale": LOCALE,
        "dateFormat": DATE_FORMAT,
        "transactionDate": formatDate(transaction.close_date),
        "closureReasonId": "1"
    }
    try:
        res = requests.post(API_URL+ '/clients/{}/?command=close'.format(transaction.mifos_id), 
            headers=auth_token, json=data, verify=False, timeout=10).json()
        good = res['changes']
    except Exception as e:
        print("\nerror: client id: ", loanid, "err res: ",e, "\n", res)# last_repayment = {'id': res['resourceId'], 'amount': transaction.amount}


            
def process_account(transaction):
    # import pdb;pdb.set_trace()
    if transaction._type == 'loan':
        close_loan(transaction)
    elif transaction._type == 'savings':
        close_savings(transaction)
    elif transaction._type == 'client':
        close_client(transaction)        
    

class Transaction():
    def __init__(self, _type, mifos_id, state, close_date):
        self.mifos_id = mifos_id    
        self._type = _type
        self.state = state
        self.close_date = close_date

    def __str__(self):
        return '{}, {}, {}'.format(self._type, self.mifos_id,  self.close_date)
    def __repr__(self):
        return '{}, {}, {}'.format(self._type, self.mifos_id,  self.close_date)
    def __unicode__(self):
        return '{}, {}, {}'.format(self._type, self.mifos_id,  self.close_date)

 

def main():

    with open('loanWriteOff.csv') as c, concurrent.futures.ProcessPoolExecutor(max_workers=8) as executor:
        lines = csv.reader(c, delimiter=',', quotechar='"')
        current_parent = ''
        history = []
        for line in lines:
            tran = Transaction(*line)
            # change the following line to process_account(history) to remove threading
            executor.submit(process_account, tran)
            # process_account(tran)
        executor.submit(process_account, tran)
        # process_account(tran)
        executor.shutdown()
        print('\n\nDONE!!!!\n\n')


def isclose(a, b, rel_tol=1e-09, abs_tol=0.0):
    return abs(a-b) <= max(rel_tol * max(abs(a), abs(b)), abs_tol)
            
if __name__ == "__main__":
    main()
