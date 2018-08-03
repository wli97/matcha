library(reticulate)
use_virtualenv('chain', required = TRUE)
source_python("app.py")

x <- "source chain/bin/activate"
system(x)
init("b4b0316b7be9664ee5790f5afc1152e5df37eea929810f0bcb1b51118bb80c36")
test()
ac[1]
accounts <- usr()
accounts[3]
addUser(accounts[2], 2L)
addUser(accounts[3], 3L)
addUser("0xA204C05534BfFC38cB355CA0cBEE45086bAc2075", 4L)
inject()
#setU(as.integer(3))
getUser("0xA204C05534BfFC38cB355CA0cBEE45086bAc2075")
stat <- requestClaim(accounts[3], 0,2, "My Car is broken, need 500$ for repair.")
val<-getValid(accounts[2],0L)
getRequest(val[[1]],0)
payClaim(0L, TRUE, "Request valid.", 10L)
print(5)
stat
getRequest(accounts[4],0L)
validate(0, TRUE, "miaow pue")
#transaction does not return value
typeof(4)
typeof(as.integer(4))
typeof(as.hexmode('0x703'))

