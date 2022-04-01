import os
import pytest
from starkware.starknet.testing.starknet import Starknet

async def contract_factory(file):
    starknet = await Starknet.empty()
    contract = await starknet.deploy(file)
    return starknet, contract

CONTRACT_FILE = os.path.join('contracts', 'array_args.cairo')

@pytest.mark.asyncio
async def test_read_array():
  _starknet, contract = await contract_factory(CONTRACT_FILE)

  await contract.assign([1,5]).invoke()

  exec_info = await contract.read(1).call()  
  assert exec_info.result == (5,)

  
