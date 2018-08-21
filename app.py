import os
import ssl
import json
import web3

from web3 import Web3
# os.environ['INFURA_API_KEY'] = "84d4942df75943d1ae584b98e5d9ff46"
# from web3.auto.infura import w3
# try:
#       _create_unverified_https_context = ssl._create_unverified_context
# except AttributeError:
#       pass
# else:
#       ssl._create_default_https_context = _create_unverified_https_context

def init(me):
    global w3
    w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:7545"))
    global contractAddress
    contractAddress = '0x115f75f4db4571c3A49633aA1276181039B4Df41'
      #w3 = Web3(Web3.HTTPProvider("https://ropsten.infura.io/v3/84d4942df75943d1ae584b98e5d9ff46",request_kwargs={'verify':False}))
      # if not w3.isConnected():
      #   return w3
      #contractAddress = '0xeccE887e777d31039fF67992ACE2ecC729F70A4E'
      #global myAddress
      #myAddress = w3.eth.account.privateKeyToAccount(me)
    global myAddress
    myAddress = w3.eth.account.privateKeyToAccount(me)
    with open('www/build/contracts/Entity.json','r') as abi_def:
        info = json.load(abi_def)
    global contract
    contract = w3.eth.contract(address=contractAddress, abi=info['abi'])
    return myAddress.address

# Example of testnet function call that involves signing with your private key
# def addUser(address, userType):
#     construct_txn = contract.functions.addUser(ad(address),Web3.toInt(userType)).buildTransaction({
#       'from': myAddress.address,
#       'gas': 2000000,
#       'nonce': w3.eth.getTransactionCount(myAddress.address)})
#     signed = myAddress.signTransaction(construct_txn)
#     txHash = w3.eth.sendRawTransaction(signed.rawTransaction)
#     txReceipt = w3.eth.waitForTransactionReceipt(txHash)
#     return txReceipt['blockNumber']
def addUser(address, userType):
    try:
      construct_txn = contract.functions.addUser(ad(address),Web3.toInt(userType)).buildTransaction({
        'from': myAddress.address, 'nonce': w3.eth.getTransactionCount(myAddress.address)
      })
      signed = myAddress.signTransaction(construct_txn)
      txHash = w3.eth.sendRawTransaction(signed.rawTransaction)
      txReceipt = w3.eth.waitForTransactionReceipt(txHash)
      return txReceipt['blockNumber']  
    except:
      return 0
  
def getUser(address):
    return contract.functions.getUser(ad(address)).call()
  
def getRequest(address, index):
    try:
      return contract.functions.getRequest(ad(address),Web3.toInt(index)).call({'from': myAddress.address})
    except:
      return 0
  
def requestClaim(address,claimtype,status,desc,paym):
    try:
      construct_txn = contract.functions.requestClaim(ad(address), Web3.toInt(claimtype), Web3.toInt(status), desc, Web3.toInt(paym)).buildTransaction({
        'from': myAddress.address,'nonce': w3.eth.getTransactionCount(myAddress.address)})
      signed = myAddress.signTransaction(construct_txn)
      txHash = w3.eth.sendRawTransaction(signed.rawTransaction)
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
      txHash = contract.functions.validate(Web3.toInt(index), answer, expl).transact({'from': myAddress.address})
      txReceipt = w3.eth.waitForTransactionReceipt(txHash)
      return txReceipt['blockNumber']
    except:
      return 0
      
def payClaim(index, answer, expl, value):
    try:
      txHash = contract.functions.payClaim(Web3.toInt(index), answer, expl).transact({'from': myAddress.address, 'value':Web3.toInt(value*1000)})
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
      signed = myAddress.signTransaction({
        'from': myAddress.address, 'to':contractAddress, 'value':Web3.toWei(1, "ether"), 'nonce': w3.eth.getTransactionCount(myAddress.address),'gasPrice':w3.eth.gasPrice,'gas':70000
      })
      txHash = w3.eth.sendRawTransaction(signed.rawTransaction)
      txReceipt = w3.eth.waitForTransactionReceipt(txHash)
      return txReceipt['blockNumber']
    except:
       return 0

def setAvg(ctype, amt):
    # try:
      # construct_txn = contract.functions.setAvg(Web3.toInt(ctype), Web3.toInt(amt)).buildTransaction({
      #   'from': myAddress.address,'nonce': w3.eth.getTransactionCount(myAddress.address)})
      # signed = myAddress.signTransaction(construct_txn)
      # txHash = w3.eth.sendRawTransaction(signed.rawTransaction)
      txHash = contract.functions.setAvg(Web3.toInt(ctype),Web3.toInt(amt)).transact({'from': myAddress.address})
      txReceipt = w3.eth.waitForTransactionReceipt(txHash)
      return txReceipt['blockNumber']
    # except:
    #   return 0

def setSd(ctype, amt):
    try:
      # construct_txn = contract.functions.setSd(Web3.toInt(ctype), Web3.toInt(amt)).buildTransaction({
      #   'from': myAddress.address,'nonce': w3.eth.getTransactionCount(myAddress.address)})
      # signed = myAddress.signTransaction(construct_txn)
      # txHash = w3.eth.sendRawTransaction(signed.rawTransaction)
      txHash = contract.functions.setSd(Web3.toInt(ctype),Web3.toInt(amt)).transact({'from': myAddress.address})
      txReceipt = w3.eth.waitForTransactionReceipt(txHash)
      return txReceipt['blockNumber']
    except:
      return 0

def ad(address):
    return Web3.toChecksumAddress(Web3.toHex(hexstr=address))
  
def usr():
    return w3.eth.accounts

def checkUser(address):
    return contract.functions.checkUser(ad(address)).call()

def balance(me):
    return w3.eth.getBalance(me)
