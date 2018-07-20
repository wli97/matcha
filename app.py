import web3
import json
from web3 import Web3

def init(me):
    global w3
    w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:7545", request_kwargs={'timeout': 60}))
    contractAddress = '0x115f75f4db4571c3A49633aA1276181039B4Df41'
    global myAddress
    myAddress = ad(me)
    with open('www/build/contracts/Entity.json','r') as abi_def:
        info = json.load(abi_def)
    global contract 
    contract = w3.eth.contract(contractAddress, abi=info["abi"])
    return getUser(myAddress)

def getUser(address):
    return contract.functions.getUser(address).call()
  
def addUser(address, userType):
    txHash = contract.functions.addUser(ad(address),Web3.toInt(userType)).transact({'from': w3.eth.accounts[0]})
    txReceipt = w3.eth.waitForTransactionReceipt(txHash)
    return txReceipt['blockNumber']
  
def getRequest(address, index):
    try:
      got = contract.functions.getRequest(ad(address),Web3.toInt(index)).call({'from': w3.eth.accounts[0]})
    except:
      got = 0
    return got
  
def requestClaim(address, status, desc):
    txHash = contract.functions.requestClaim(ad(address), Web3.toInt(status), desc).transact({'from': w3.eth.accounts[3]})
    txReceipt = w3.eth.waitForTransactionReceipt(txHash)
    return txReceipt['blockNumber']
  
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
      

def ad(address):
    return Web3.toChecksumAddress(Web3.toHex(hexstr=address))
  
def usr():
    return w3.eth.accounts

def setU(i):
    w3.eth.defaultAccount = w3.eth.accounts[i]



