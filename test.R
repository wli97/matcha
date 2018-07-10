library(ether)


set_rpc_address("https://ropsten.infura.io/tHiAeoWz4baZhcLGTtTc")

eth_getStorageAt("0x4203d7819F45b1eB0eC33Bc7C5E2da90Db73E5EA", "0x3")

eth_getTransactionByHash("0xde93588814949d8e91c9c1973d4c594729264becfd4d9e7f93fb319a7e1a08e8")

web3_sha3("0x000000000000000000000000391694e7e0b0cce554cb130d723a9d27458f9298")


eth_sendTransaction <- function(address, position) {
  get_post_response("eth_getCode", list(address, position))
}