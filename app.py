import os
import ssl
import json
import web3
from web3 import Web3

try:
      _create_unverified_https_context = ssl._create_unverified_context
except AttributeError:
      pass
else:
      ssl._create_default_https_context = _create_unverified_https_context

def init(me):
    # Crucial SSL issue, necessary for requests
    try:
      _create_unverified_https_context = ssl._create_unverified_context
    except AttributeError:
      pass
    else:
      ssl._create_default_https_context = _create_unverified_https_context

    global w3
    w3 = Web3(Web3.HTTPProvider("https://ropsten.infura.io/v3/84d4942df75943d1ae584b98e5d9ff46"))
    contractAddress = '0xeccE887e777d31039fF67992ACE2ecC729F70A4E'
    global myAddress
    myAddress = w3.eth.account.privateKeyToAccount(me)
    with open('www/build/contracts/Entity.json','r') as abi_def:
        info = json.load(abi_def)
    global contract
    contract = w3.eth.contract(address=contractAddress, abi=info['abi'])
    return contract.all_functions()

def test():
    construct_txn = contract.constructor().buildTransaction({
      'from': acct.address,
      'nonce': w3.eth.getTransactionCount(acct.address)})
    signed = acct.signTransaction(construct_txn)
    w3.eth.sendRawTransaction(signed.rawTransaction)
    return acct
  
def getUser(address):
    return contract.functions.getUser(address).call()

  
def addUser(address, userType):
    construct_txn = contract.functions.addUser(ad(address),Web3.toInt(userType)).buildTransaction({
      'from': myAddress.address,
      'nonce': w3.eth.getTransactionCount(myAddress.address)})
    signed = myAddress.signTransaction(construct_txn)
    txHash = w3.eth.sendRawTransaction(signed.rawTransaction)
    txReceipt = w3.eth.waitForTransactionReceipt(txHash)
    return txReceipt['blockNumber']
  
def getRequest(address, index):
    try:
      got = contract.functions.getRequest(ad(address),Web3.toInt(index)).call({'from': myAddress})
    except:
      got = 0
    return got
  
def requestClaim(address,claimtype,status,desc,paym):
    try:
      txHash = contract.functions.requestClaim(ad(address), Web3.toInt(claimtype), Web3.toInt(status), desc, Web3.toInt(paym)).transact({'from': myAddress})
      txReceipt = w3.eth.waitForTransactionReceipt(txHash)
      return txReceipt['blockNumber']
    except:
      return 0
    
  
def getValid(address, index):
    try:
      return contract.functions.validations(ad(address), Web3.toInt(index)).call()
    except:
      return 0
      
def validate(index, answer, expl):
    try:
      txHash = contract.functions.validate(Web3.toInt(index), answer, expl).transact({'from': myAddress})
      txReceipt = w3.eth.waitForTransactionReceipt(txHash)
      return txReceipt['blockNumber']
    except:
      return 0
      
def payClaim(index, answer, expl, value):
    try:
      txHash = contract.functions.payClaim(Web3.toInt(index), answer, expl).transact({'from': myAddress, 'value':Web3.toInt(value)})
      txReceipt = w3.eth.waitForTransactionReceipt(txHash)
      return txReceipt['blockNumber']
    except:
      return 0
      
def checkFund():
    try:
      return Web3.fromWei(contract.functions.checkFund().call()/1000000, "ether")*1000000
    except:
      return 0
      
def inject():
    try:
      txHash = w3.eth.sendTransaction({'from': myAddress, 'to':ad('0xeccE887e777d31039fF67992ACE2ecC729F70A4E'), 'value':Web3.toWei(2, "ether")})
      txReceipt = w3.eth.waitForTransactionReceipt(txHash)
      return txReceipt['blockNumber']
    except:
      return 0

def ad(address):
    return Web3.toChecksumAddress(Web3.toHex(hexstr=address))
  
def usr():
    return w3.eth.accounts

def setU(i):
    w3.eth.defaultAccount = w3.eth.accounts[i]



