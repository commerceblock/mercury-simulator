import json
import os
import bitcoin
import bitcoin.rpc
import asyncio
import pytest
from requests import get

def get_bitcoin():
        bitcoin.SelectParams("regtest")
        return bitcoin.rpc.Proxy(btc_conf_file="/srv/bitcoin/.bitcoin/bitcoin.conf")

def test_mercury_ping():
	"pequest /ping url from mercury"
	r = get('http://127.0.0.1:8000/ping')
	assert r.status_code == 200

def test_bitcoin_address():
        btc=get_bitcoin()
        address=btc.getnewaddress()
        print(address)
        addr_info=btc.validateaddress(address)
        assert addr_info["isvalid"]

        
