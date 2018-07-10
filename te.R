library(reticulate)
use_condaenv("chain")
source_python("app.py")
init(me)
myAddress
accounts <- usr()
getUser(coin())
addUser(accounts[2], 2L)
#setU(as.integer(3))
getUser(accounts[3])
stat <- requestClaim(accounts[3], 2, "My Car is broken, need 500$ for repair.")
print(5)
stat
accounts[1]
getRequest(accounts[4],0L)
#transaction does not return value
typeof(4)
typeof(as.integer(4))
typeof(as.hexmode('0x703'))

