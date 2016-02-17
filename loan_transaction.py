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
err_count = 0
total_count = 0

# loans = requests.get(API_URL + '/loans?limit=0', headers=auth_token, verify=False).json()

# loans = {l['externalId']: l['id'] for l in loans['pageItems']}
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
    #print('fee_info: {}'.format(fee_info))
    return fee_info

def extract_repayments(history):
    return [x for x in history if 'REPAYMENT' in x._type]

def cleanHistory(historyDirty):
    reversalKeys = [x.reversalKey for x in historyDirty if x.reversalKey]
    return [x for x in historyDirty if (not x.reversalKey and x.key not in reversalKeys)]

def errHandle(res, parent, transaction=''):
    #global total_count
    #global err_count
    #total_count += 1
    return
    # if 'errors' in res.keys():
    #     #err_count += 1
    #     print('\n******************************')
    #     print(res)
    #     print()
    #     print('Mambu Loan Key: {}'.format(parent))
    #     print(transaction)
    #     #print('Errors :{} - Total: {} | {}'.format(err_count, total_count, ((total_count-err_count)/total_count) * 100))
    #     print('******************************\n')
    #     sys.stdout.flush()
    # else:
    #     if transaction:
    #         print('.', end="")
    #         sys.stdout.flush()
    #     else:
    #         print('fee')


def handle_repayment(transaction):
   pass


def handle_fee(transaction):
    pass
    # print('fee')
       
            
def process_loan(historyDirty):
    try:
        if len(historyDirty) < 1:
            return

        if historyDirty[0].parent == 'PARENTACCOUNTKEY':
            return

        parent = historyDirty[0].parent
        try:
            loanid = historyDirty[0].mifos_id # look up mifos id with externalId
        except KeyError as e:
            print("\n\t\t\tCan't find key: %s " % parent)
            return
        
        pid = os.getpid()
        # print('PID', pid, 'starting parent loan', parent)
        history = cleanHistory(historyDirty)


        transactions = extract_other(history)
        # transactions = history
        #print('**processing loan ({}T)**: {}'.format(len(transactions), parent))
        last_repayment = {}
        res = {}
        for transaction in transactions:
            if transaction._type == 'REPAYMENT':
                data = {
                    "locale": LOCALE,
                    "dateFormat": DATE_FORMAT,
                    "paymentTypeId": '1',
                    "transactionAmount": transaction.amount,
                    "transactionDate": formatDate(transaction.creation)
                }
                res = requests.post(API_URL+ '/loans/{}/transactions?command=repayment'.format(loanid), headers=auth_token, json=data, verify=False, timeout=10).json()
                # last_repayment = {'id': res['resourceId'], 'amount': transaction.amount}



            errHandle(res, parent, transaction) 
    except Exception as e:
        print('wee woo we ded', e)
    # print('PID', pid, 'ending parent loan', parent)
        
        

class Transaction():
    def __init__(self, _type, key, parent, amount, creation, reversalKey, installments, mifos_id):
        self._type = _type
        self.key = key
        self.parent = parent
        self.amount = amount
        self.creation = creation
        self.reversalKey = reversalKey
        self.installments = installments
        self.mifos_id = mifos_id    
    def __str__(self):
        return '{}, {}, {}, {}, {}, {}'.format(self._type, self.key,  self.parent, self.amount, self.creation, self.reversalKey, self.installments)
    def __repr__(self):
        return '{}, {}, {}, {}, {}, {}'.format(self._type, self.key,  self.parent, self.amount, self.creation, self.reversalKey, self.installments)
    def __unicode__(self):
        return '{}, {}, {}, {}, {}, {}'.format(self._type, self.key,  self.parent, self.amount, self.creation, self.reversalKey, self.installments)
        
def main():

    with open('transactions.csv') as c, concurrent.futures.ProcessPoolExecutor(max_workers=8) as executor:
        lines = csv.reader(c, delimiter=',', quotechar='"')
        current_parent = ''
        history = []
        for line in lines:
            tran = Transaction(*line)
            if current_parent != tran.parent:
                # change the following line to process_loan(history) to remove threading
                executor.submit(process_loan, history)
                #process_loan(history)
                history = []
            current_parent = tran.parent
            ignore = []
            history.append(tran)
        executor.submit(process_loan, history)
        #process_loan(history)
        executor.shutdown()
        print('\n\nDONE!!!!\n\n')

def isclose(a, b, rel_tol=1e-09, abs_tol=0.0):
    return abs(a-b) <= max(rel_tol * max(abs(a), abs(b)), abs_tol)
            
if __name__ == "__main__":
    main()
