import pytest
import os
from requests import get
from bitcoinrpc.authproxy import AuthServiceProxy, JSONRPCException


def test_mercury_ping():
	"pequest /ping url from mercury"
	r = get('http://0.0.0.0:18000/ping')
	assert r.status_code == 200

if 'BITCOIN_RPC_USER' in os.environ:
        rpc_user=os.environ['BITCOIN_RPC_USER']
else:
        rpc_user='username'
if 'BITCOIN_RPC_PASSWORD' in os.environ:
        rpc_password=os.environ['BITCOIN_RPC_PASSWORD']
else:
        rpc_password='password'
        

# rpc_user and rpc_password are set in the bitcoin.conf file
uri=("http://%s:%s@0.0.0.0:18332"%(rpc_user, rpc_password))
print(uri)
rpc_con = AuthServiceProxy(uri, timeout=600)
address=rpc_con.getnewaddress()
print("Generate address:")
print(address)
print("Generate blocks")
print(rpc_con.generatetoaddress(1,address))
print("Get balance")
print(rpc_con.getaddressinfo(address))
print(rpc_con.getbalances())
print(rpc_con.getwalletinfo())

os.system(docker exec -it mercury_client wallet_cli -help)



#net_info=rpc_connection.getnetworkinfo()
#print(net_info)
#best_block_hash = rpc_connection.getbestblockhash()
#print(best_block_hash)
#print(rpc_connection.getblock(best_block_hash))

# batch support : print timestamps of blocks 0 to 99 in 2 RPC round-trips:
#commands = [ [ "getblockhash", height] for height in range(100) ]
#block_hashes = rpc_connection.batch_(commands)
#blocks = rpc_connection.batch_([ [ "getblock", h ] for h in block_hashes ])
#block_times = [ block["time"] for block in blocks ]
#print(block_times)
