import os
from sys import exc_info
import pytest
from starkware.starknet.testing.starknet import Starknet

async def contract_factory(file, constructor_calldata=None):
  starknet = await Starknet.empty()
  
  contract = None
  if constructor_calldata == None:
    contract = await starknet.deploy(file)
  else:
    contract = await starknet.deploy(file, constructor_calldata=constructor_calldata)
  return starknet, contract

CONTRACT_FILE = os.path.join('contracts', 'constr.cairo')

@pytest.mark.asyncio
async def test_values():
  ADDRESS = 12345
  VALUE = 11111 

  _starknet, contract = await contract_factory(CONTRACT_FILE, 
    constructor_calldata=[ADDRESS, VALUE])

  exec_info = await contract.read_values().call()
  assert exec_info.result == (ADDRESS, VALUE, )