library(reticulate)
use_condaenv("chain")
source_python("app.py")
init("0x7Dc3600FE2823a113C5c5439E128ba6d3eA15A41")
accounts <- usr()
accounts[3]
addUser(accounts[2], 2L)
addUser(accounts[3], 3L)
addUser(accounts[4], 4L)
#setU(as.integer(3))
getUser(accounts[10])
stat <- requestClaim(accounts[3], 2, "My Car is broken, need 500$ for repair.")
val<-getValid(accounts[1],0L)
getRequest(val[[1]],1)
payClaim(0L, TRUE, "Request valid.", 10L)
print(5)
stat
getRequest(accounts[4],0L)
validate(0, TRUE, "miaow pue")
#transaction does not return value
typeof(4)
typeof(as.integer(4))
typeof(as.hexmode('0x703'))

