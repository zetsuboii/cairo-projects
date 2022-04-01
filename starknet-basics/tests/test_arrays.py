import os
import pytest
from starkware.starknet.testing.starknet import Starknet

async def contract_factory(file):
    starknet = await Starknet.empty()
    contract = await starknet.deploy(file)
    return starknet, contract

CONTRACT_FILE = os.path.join('contracts', 'arrays.cairo')

print(CONTRACT_FILE)

@pytest.mark.asyncio
async def test_read_array():
  _starknet, contract = await contract_factory(CONTRACT_FILE)

  exec_info = await contract.read_array(idx=0).call()  
  assert exec_info.result == (3,)

  exec_info = await contract.read_array(idx=15).call() 
  assert exec_info.result == (1,)
  
