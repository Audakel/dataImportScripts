from datetime import datetime
from decimal import Decimal
import concurrent.futures
import sys
import requests
import csv
import simplejson as json
import os
from decimal import Decimal
requests.packages.urllib3.disable_warnings()

BASE_URL = 'https://localhost:8443'
API_URL = BASE_URL + '/fineract-provider/api/v1'
auth_token = {}
auth_token["fineract-Platform-TenantId"] = 'default'
auth_res = requests.post(API_URL + '/authentication?username=mifos&password=password', headers=auth_token, verify=False).json()
auth_token["Authorization"] = "Basic %s" %auth_res['base64EncodedAuthenticationKey']

disbursement_fees = []

DATE_FORMAT = "dd MMMM yyyy"
LOCALE = "en"

def formatDate(date):
    return datetime.strftime(datetime.strptime(date, '%d/%m/%Y'), '%d %B %Y')

def extract_other(history):
    return [x for x in history if not x._type.startswith('FEE')]

def extract_fee_sum(history):
    fee_info = next(({'date': x.creation, 'installments': float(x.installments)} for x in history if x._type.startswith('DISBURSMENT')), None)
    fee_info.update({'amount': sum([float(x.amount) for x in history if x._type.startswith('FEE')])})
    return fee_info

def extract_repayments(history):
    return [x for x in history if 'REPAYMENT' in x._type]

def cleanHistory(historyDirty):
    reversalKeys = [x.reversalKey for x in historyDirty if x.reversalKey]
    return [x for x in historyDirty if (not x.reversalKey and x.key not in reversalKeys)]

def errHandle(res, parent, transaction=''):
    pass


def handle_repayment(transaction):
    pass


def handle_fee(transaction):
    pass
       
            
def process_loan(historyDirty):
    try:
        if len(historyDirty) < 1:
            return

        if historyDirty[0].parent == 'PARENTACCOUNTKEY':
            return

        parent = historyDirty[0].parent
        try:
            accountsId = historyDirty[0].mifos_id # look up mifos id with externalId
        except KeyError as e:
            print("\n\t\t\tCan't find key: %s " % parent)
            return
        
        pid = os.getpid()
        # print'\tPID', pid, 'starting savings account', parent

        history = cleanHistory(historyDirty)

        transactions = extract_other(history)
        # transactions = history
        # print('**processing loan ({}T)**: {}'.format(len(transactions), parent))
        res = {}

        # Get first interest posting taken care of
        # requests.post(API_URL+ '/savingsaccounts/{}?command=postInterest'.format(accountsId), headers=auth_token, verify=False, timeout=10).json()

        # import pdb;pdb.set_trace()
        for transaction in transactions:
            if transaction._type == 'DEPOSIT':
                data = {
                    "locale": LOCALE,
                    "dateFormat": DATE_FORMAT,
                    "paymentTypeId": '1',
                    "transactionAmount": transaction.amount,
                    "transactionDate": formatDate(transaction.creation)
                }
                res = requests.post(API_URL+ '/savingsaccounts/{}/transactions?command=deposit'.format(accountsId), headers=auth_token, json=data, verify=False, timeout=10).json()
                if 'savingsId' not in res.keys():
                    print('\nD\n', 'res', res)
                    print(parent) 

            elif transaction._type == 'WITHDRAWAL' or transaction._type == 'TRANSFER' :
                # import pdb;pdb.set_trace()
                data = {
                    "locale": LOCALE,
                    "dateFormat": DATE_FORMAT,
                    "paymentTypeId": '1',
                    "transactionAmount": abs(Decimal(transaction.amount)),
                    "transactionDate": formatDate(transaction.creation)
                }
                res = requests.post(API_URL+ '/savingsaccounts/{}/transactions?command=withdrawal'.format(accountsId), headers=auth_token, json=data, verify=False, timeout=10).json()
                if 'savingsId' not in res.keys():
                    print('\nW', 'res', res, data, '\n', parent, '\n')

            elif transaction._type == 'INTEREST_APPLIED':
            #     res = requests.post(API_URL+ '/savingsaccounts/{}?command=postInterest'.format(accountsId), headers=auth_token, verify=False, timeout=10).json()
            #     if 'savingsId' not in res.keys():
            #         print('\nI', 'res', res)
            #         print(parent)
                data = {
                    "locale": LOCALE,
                    "dateFormat": DATE_FORMAT,
                    "paymentTypeId": '2',
                    "transactionAmount": transaction.amount,
                    "transactionDate": formatDate(transaction.creation)
                }
                res = requests.post(API_URL+ '/savingsaccounts/{}/transactions?command=deposit'.format(accountsId), headers=auth_token, json=data, verify=False, timeout=10).json()
                if 'savingsId' not in res.keys():
                    print('\nD\n', 'res', res)
                    print(parent)  
                    
    except Exception as e:
        print('\t\t\tXXXXXX ERROR XXXXXX', e)
    print('.', end="")
        
        

class Transaction():
    def __init__(self, _type, key, parent, amount, creation, reversalKey, mifos_id):
        self._type = _type
        self.key = key
        self.parent = parent
        self.amount = amount
        self.creation = creation
        self.reversalKey = reversalKey
        self.mifos_id = mifos_id    
    def __str__(self):
        return '{}, {}, {}, {}, {}, {}'.format(self._type, self.key,  self.parent, self.amount, self.creation, self.reversalKey)
    def __repr__(self):
        return '{}, {}, {}, {}, {}, {}'.format(self._type, self.key,  self.parent, self.amount, self.creation, self.reversalKey)
    def __unicode__(self):
        return '{}, {}, {}, {}, {}, {}'.format(self._type, self.key,  self.parent, self.amount, self.creation, self.reversalKey)
        
def main():

    with open('savings.csv') as c, concurrent.futures.ProcessPoolExecutor(max_workers=8) as executor:
        lines = csv.reader(c, delimiter=',', quotechar='"')
        current_parent = ''
        history = []
        for line in lines:
            tran = Transaction(*line)
            if current_parent != tran.parent:
                # change the following line to process_loan(history) to remove threading
                executor.submit(process_loan, history)
                # process_loan(history)
                history = []
            current_parent = tran.parent
            ignore = []
            history.append(tran)
        executor.submit(process_loan, history)
        # process_loan(history)
        executor.shutdown()
        print('\n\nDONE!!!!\n\n')

def isclose(a, b, rel_tol=1e-09, abs_tol=0.0):
    return abs(a-b) <= max(rel_tol * max(abs(a), abs(b)), abs_tol)
            
if __name__ == "__main__":
    main()
