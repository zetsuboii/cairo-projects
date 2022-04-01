import os
import pytest
from starkware.starknet.testing.starknet import Starknet

CONTRACT_A = os.path.join('contracts', 'interA.cairo')
CONTRACT_B = os.path.join('contracts', 'interB.cairo')

@pytest.mark.asyncio
async def test_interaction():
  starknet = await Starknet.empty()
  contract_b = await starknet.deploy(CONTRACT_B, constructor_calldata=[66])
  
  print("b_address", contract_b.contract_address)
  
  contract_a = await starknet.deploy(CONTRACT_A, constructor_calldata=[
    contract_b.contract_address,
    65
  ])

  print("a_address", contract_a.contract_address)

  # TODO: Read default value for a_addr
  # TODO: Read owner

  # try:
  #   await contract_a.write_b(100).invoke()
  # except:
  #   print("Unauth call errored successfully")
  
  # Set a_address
  await contract_b.set_a( contract_a.contract_address ).invoke()

  exec_info = await contract_b.read_a().call()
  (a_address, ) = exec_info.result
  
  assert a_address == contract_a.contract_address

  exec_info = await contract_a.read_b().call()
  assert exec_info.result == (66, )

  await contract_a.write_b(9).invoke()

  exec_info = await contract_a.read_b().call()
  assert exec_info.result == (75, )

