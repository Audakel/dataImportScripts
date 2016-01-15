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

def extract_other(history):
    return [x for x in history if not x._type.startswith('FEE')]

def extract_fee_sum(history):
    return sum([float(x.amount) for x in history if x._type.startswith('FEE')])

def extract_repayments(history):
    return [x for x in history if 'REPAYMENT' in x._type]

def errHandle(res, parent):
    global total_count
    global err_count
    
    total_count += 1
    if 'errors' in res.keys():
        err_count += 1
        print(res)
        print('Mambu Loan Key: {}'.format(parent))
        print('Errors :{} - Total: {} | {}'.format(err_count, total_count, ((total_count-err_count)/total_count) * 100))
        sys.stdout.flush()
    else:
        print('.', end="")
        sys.stdout.flush()
 

            
def process_loan(history):
    # look up the loan somehow :p
    if len(history) < 1:
        return
    # skip the first row
    if history[0].parent == 'PARENTACCOUNTKEY':
        return
    parent = history[0].parent
    try:
        loanid = loans[parent] # look up mifos id with externalId
    except KeyError as e:
        # error fetching loan from mifos
        print("Can't find key: %s " %parent)
        return
    
    fees = extract_fee_sum(history)
    if not isclose(fees, 0):
        feeDate = requests.get(API_URL + '/loans/{}?limit=0&associations=repaymentSchedule'.format(loanid), 
            headers=auth_token, verify=False).json()['repaymentSchedule']['periods'][-1]['dueDate']
        
        feeDateFormated = '{}-{}-{}'.format(feeDate[0], feeDate[1], feeDate[2])
        # migrate fees
        data = {
            "locale": "en",
            "dateFormat": "dd MMMM yyyy",
            "amount": fees,
            "dueDate": datetime.strftime(datetime.strptime(feeDateFormated, '%Y-%m-%d'), '%d %B %Y'),
            "chargeId": "5"
        }
        res = requests.post(API_URL+ '/loans/{}/charges'.format(loanid), headers=auth_token, json=data, verify=False).json()
        errHandle(res, parent)

    transactions = extract_other(history)
    last_repayment = {}
    res = {}
    for transaction in transactions:
        # migrate repayment
        if 'REPAYMENT' in transaction._type:
            if transaction._type == 'REPAYMENT':
                data = {
                    "locale": "en",
                    "dateFormat": "dd MMMM yyyy",
                    "paymentTypeId": '1',
                    "transactionAmount": transaction.amount,
                    "transactionDate": datetime.strftime(datetime.strptime(transaction.creation, '%Y-%m-%d'), '%d %B %Y')
                }
                res = requests.post(API_URL+ '/loans/{}/transactions?command=repayment'.format(loanid), headers=auth_token, json=data, verify=False).json()
                last_repayment = {'id': res['resourceId'], 'amount': transaction.amount}
            else:
                data = {
                    "locale": "en",
                    "dateFormat": "dd MMMM yyyy",
                    "transactionDate": datetime.strftime(datetime.strptime(transaction.creation, '%Y-%m-%d'), '%d %B %Y'),
                    "transactionAmount": (Decimal(last_repayment['amount']) + Decimal(transaction.amount)).quantize(Decimal(10) ** -3)
                }
                res = requests.post(API_URL+ '/loans/{}/transactions/{}'.format(loanid, last_repayment['id']), headers=auth_token, json=data, verify=False).json()
        else:
            if transaction._type == 'INTEREST_APPLIED':
                pass
            elif transaction._type == 'DEFERRED_INTEREST_PAID':
                
            elif transaction._type == 'DEFERRED_INTEREST_APPLIED':
            
            elif transaction._type == 'INTEREST_REDUCTION_ADJUSTMENT':
            
            elif transaction._type == 'DEFERRED_INTEREST_PAID_ADJUSTMENT':
            
            elif transaction._type == 'INTEREST_DUE_REDUCED':
            
            elif transaction._type == 'DEFERRED_INTEREST_APPLIED_ADJUSTMENT':
            
            elif transaction._type == 'INTEREST_APPLIED_ADJUSTMENT':
            
            else:
                print ('Not covered lel')
        errHandle(res, parent)
        

#0: if(l.TYPE='REPAYMENT','REPAYMENT','FEE')
#1: l.ENCODEDKEY
#2: l.PARENTACCOUNTKEY
#3: l.AMOUNT
#4: l.CREATIONDATE
class Transaction():
    def __init__(self, _type, key, parent, amount, creation):
        self._type = _type
        self.key = key
        self.parent = parent
        self.amount = amount
        self.creation = creation
    def __str__(self):
        return '{}, {}, {}, {}, {}'.format(self._type, self.key,  self.parent, self.amount, self.creation)
    def __repr__(self):
        return '{}, {}, {}, {}, {}'.format(self._type, self.key,  self.parent, self.amount, self.creation)
    def __unicode__(self):
        return '{}, {}, {}, {}, {}'.format(self._type, self.key,  self.parent, self.amount, self.creation)
        
def main():

    with open('loan_repayments_all.csv') as c, concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
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
        executor.shutdown()

def isclose(a, b, rel_tol=1e-09, abs_tol=0.0):
    return abs(a-b) <= max(rel_tol * max(abs(a), abs(b)), abs_tol)
            
if __name__ == "__main__":
    main()