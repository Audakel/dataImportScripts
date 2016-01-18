from datetime import datetime
from decimal import Decimal
import concurrent.futures
import sys
import requests
import csv
import simplejson as json
requests.packages.urllib3.disable_warnings()

BASE_URL = 'https://localhost:8443'
API_URL = BASE_URL + '/mifosng-provider/api/v1'
auth_token = {}
auth_token["X-Mifos-Platform-TenantId"] = 'default'
auth_res = requests.post(API_URL + '/authentication?username=mifos&password=password', headers=auth_token, verify=False).json()
auth_token["Authorization"] = "Basic %s" %auth_res['base64EncodedAuthenticationKey']
err_count = 0
total_count = 0
loans = requests.get(API_URL + '/loans?limit=0', headers=auth_token, verify=False).json()

loans = {l['externalId']: l['id'] for l in loans['pageItems']}
DATE_FORMAT = "dd MMMM yyyy"
LOCALE = "en"

def formatDate(date):
    return datetime.strftime(datetime.strptime(date, '%d/%m/%Y'), '%d %B %Y')

def extract_other(history):
    return [x for x in history if not x._type.startswith('FEE')]

def extract_fee_sum(history):
    return sum([float(x.amount) for x in history if x._type.startswith('FEE')])

def extract_repayments(history):
    return [x for x in history if 'REPAYMENT' in x._type]

def cleanHistory(historyDirty):
    reversalKeys = [x.reversalKey for x in historyDirty if x.reversalKey]
    return [x for x in historyDirty if (not x.reversalKey and x.key not in reversalKeys)]

def errHandle(res, parent, transaction=''):
    global total_count
    global err_count
    total_count += 1
    if 'errors' in res.keys():
        err_count += 1
        print('\n******************************')
        print(res)
        print()
        print('Mambu Loan Key: {}'.format(parent))
        print(transaction)
        print('Errors :{} - Total: {} | {}'.format(err_count, total_count, ((total_count-err_count)/total_count) * 100))
        print('******************************\n')
        sys.stdout.flush()
    else:
        if transaction:
            # print('transaction ({})'.format(transaction._type))
            print('.', end="")
            sys.stdout.flush()
        else:
            print('fee')



def handle_repayment(transaction):
   return res


def handle_fee(transaction):
    print('fee')
       
            
def process_loan(historyDirty):
    # look up the loan somehow :p
    if len(historyDirty) < 1:
        return

    # skip the first row
    if historyDirty[0].parent == 'PARENTACCOUNTKEY':
        return

    parent = historyDirty[0].parent
    try:
        loanid = loans[parent] # look up mifos id with externalId
    except KeyError as e:
        # error fetching loan from mifos
        print("Can't find key: %s " %parent)
        return
    
    history = cleanHistory(historyDirty)

    fees = extract_fee_sum(history)
    if not isclose(fees, 0):
        feeDate = requests.get(API_URL + '/loans/{}?limit=0&associations=repaymentSchedule'.format(loanid),
            headers=auth_token, verify=False).json()['repaymentSchedule']['periods'][-1]['dueDate']
        feeDateFormated = '{}-{}-{}'.format(feeDate[0], feeDate[1], feeDate[2])
        # migrate fees
        data = {
            "locale": LOCALE,
            "dateFormat": DATE_FORMAT,
            "amount": fees,
            "dueDate": datetime.strftime(datetime.strptime(feeDateFormated, '%Y-%m-%d'), '%d %B %Y'),
            "chargeId": "5"
        }
        res = requests.post(API_URL + '/loans/{}/charges'.format(loanid), headers=auth_token, json=data, verify=False).json()
        errHandle(res, parent)

    transactions = extract_other(history)
    # transactions = history
    print('**processing loan ({}T)**: {}'.format(len(transactions), parent))
    last_repayment = {}
    res = {}
    for transaction in transactions:
        if transaction._type == 'REPAYMENT' or transaction._type == 'DEFERRED_INTEREST_PAID':
            data = {
                "locale": LOCALE,
                "dateFormat": DATE_FORMAT,
                "paymentTypeId": '1',
                "transactionAmount": transaction.amount,
                "transactionDate": formatDate(transaction.creation)
            }
            res = requests.post(API_URL+ '/loans/{}/transactions?command=repayment'.format(loanid), headers=auth_token, json=data, verify=False).json()
            # last_repayment = {'id': res['resourceId'], 'amount': transaction.amount}

        # elif transaction._type == 'DEFERRED_INTEREST_PAID':
        #     data = {
        #         "locale": LOCALE,
        #         "dateFormat": DATE_FORMAT,
        #         "transactionDate": formatDate(transaction.creation),
        #         "transactionAmount": transaction.amount,
        #     }
        #     res = requests.post(API_URL+ '/loans/{}/transactions?command=waiveInterest'.format(loanid), headers=auth_token, json=data, verify=False).json()

        elif 'REPAYMENT' in transaction._type:
            data = {
                "locale": LOCALE ,
                "dateFormat": DATE_FORMAT,
                "transactionDate": formatDate(transaction.creation),
                "transactionAmount": (Decimal(last_repayment['amount']) + Decimal(transaction.amount)).quantize(Decimal(10) ** -3)
            }
            res = requests.post(API_URL+ '/loans/{}/transactions/{}'.format(loanid, last_repayment['id']), headers=auth_token, json=data, verify=False).json()
    

        elif transaction._type == 'INTEREST_APPLIED':
            ('handle for {}'.format(transaction._type))
        elif transaction._type == 'DEFERRED_INTEREST_PAID':
            ('handle for {}'.format(transaction._type))
        elif transaction._type == 'DEFERRED_INTEREST_APPLIED':
            ('handle for {}'.format(transaction._type))
        else:
            ('no handle for {}'.format(transaction._type))
        errHandle(res, parent, transaction) 
            # if transaction._type == 'INTEREST_APPLIED':
            #     pass
            # elif transaction._type == 'DEFERRED_INTEREST_PAID':
                
            # elif transaction._type == 'DEFERRED_INTEREST_APPLIED':
            
            # elif transaction._type == 'INTEREST_REDUCTION_ADJUSTMENT':
            
            # elif transaction._type == 'DEFERRED_INTEREST_PAID_ADJUSTMENT':
            
            # elif transaction._type == 'INTEREST_DUE_REDUCED':
            
            # elif transaction._type == 'DEFERRED_INTEREST_APPLIED_ADJUSTMENT':
            
            # elif transaction._type == 'INTEREST_APPLIED_ADJUSTMENT':
            
            # else:
            #     print ('Not covered lel')
        
        

#0: if(l.TYPE='REPAYMENT','REPAYMENT','FEE')
#1: l.ENCODEDKEY
#2: l.PARENTACCOUNTKEY
#3: l.AMOUNT
#4: l.CREATIONDATE
class Transaction():
    def __init__(self, _type, key, parent, amount, creation, reversalKey):
        self._type = _type
        self.key = key
        self.parent = parent
        self.amount = amount
        self.creation = creation
        self.reversalKey = reversalKey
    def __str__(self):
        return '{}, {}, {}, {}, {}, revKey:{}'.format(self._type, self.key,  self.parent, self.amount, self.creation, self.reversalKey)
    def __repr__(self):
        return '{}, {}, {}, {}, {}, revKey:{}'.format(self._type, self.key,  self.parent, self.amount, self.creation, self.reversalKey)
    def __unicode__(self):
        return '{}, {}, {}, {}, {}, revKey:{}'.format(self._type, self.key,  self.parent, self.amount, self.creation, self.reversalKey)
        
def main():

    with open('testingLoanAccounts.csv') as c, concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
        lines = csv.reader(c, delimiter=',', quotechar='"')
        current_parent = ''
        history = []
        for line in lines:
            tran = Transaction(*line)
            if current_parent != tran.parent:
                # change the following line to process_loan(history) to remove threading
                # executor.submit(process_loan, history)
                print('calling proc lona with {} transactions'.format(len(history)))
                process_loan(history)
                print('gotback')
                history = []
            current_parent = tran.parent
            ignore = []
            history.append(tran)
        executor.shutdown()

def isclose(a, b, rel_tol=1e-09, abs_tol=0.0):
    return abs(a-b) <= max(rel_tol * max(abs(a), abs(b)), abs_tol)
            
if __name__ == "__main__":
    main()