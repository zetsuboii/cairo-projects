"""contract.cairo test file."""
import os
import pytest
import asyncio
from timeit import default_timer as timer
from starkware.starknet.testing.starknet import Starknet
from utils import uint, str_to_felt, Signer

# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "mock", "MockERC721M.cairo")

REGISTER_SELECTOR = \
  453167574301948615256927179001098538682611778866623857597439531518333154691

l1_manager_signer = Signer(111)
l2_owner_signer = Signer(222)
token_id = uint(3735928559)


@pytest.fixture(scope='module')
def event_loop():
  return asyncio.new_event_loop()

# Deploys the contract
@pytest.fixture(scope='module')
async def factory():
  start = timer()
  starknet = await Starknet.empty()

  start = timer()
  mostar = await starknet.deploy(
    source=CONTRACT_FILE, constructor_calldata=[l1_manager_signer.public_key]
  )
  print(f"ERC721M deploy: {timer() - start} secs")

  return starknet, mostar


@pytest.mark.asyncio
async def test_constructor(factory):
  """Tests if constructor sets l1_manager as intended"""
  _, mostar = factory

  start = timer()
  l1_manager_call = await mostar.get_l1_manager().call()
  assert l1_manager_call.result == (l1_manager_signer.public_key, )
  print(f"ERC721M.get_l1_manager(): {timer() - start} secs")


@pytest.mark.asyncio
async def test_initialize(factory):
  """Test if initialization sets l1_address as intended"""
  _, mostar = factory

  start = timer()
  await mostar.initialize(
    from_address=l1_manager_signer.public_key,
    name=str_to_felt("Dummy NFT"),
    symbol=str_to_felt("DNFT"),
  ).invoke()
  print(f"ERC721M.initialize(): {timer() - start} secs")

  start = timer()
  name_call = await mostar.name().call()
  assert name_call.result == (str_to_felt("Dummy NFT"), )
  print(f"ERC721M.name(): {timer() - start} secs")

  symbol_call = await mostar.symbol().call()
  assert symbol_call.result == (str_to_felt("DNFT"), )

@pytest.mark.asyncio
async def test_register_uri(factory):
  """Tests if register function sets the uri as intended"""
  _, mostar = factory

  await mostar.initialize(
    from_address=l1_manager_signer.public_key,
    name=str_to_felt("Dummy NFT"),
    symbol=str_to_felt("DNFT"),
  ).invoke()

  await mostar.register(
    selector=REGISTER_SELECTOR,
    cdata=[
      l1_manager_signer.public_key,
      l2_owner_signer.public_key,
      token_id[0],
      token_id[1],
      2,
      str_to_felt("URI 1"),
      str_to_felt("URI 2")
    ]
  ).invoke()

  customuri_call = await mostar.get_custom_uri_v2(
    token_id=token_id,
  ).call()
  
  assert customuri_call.result == (
    str_to_felt("URI 1"),
    str_to_felt("URI 2"),)

  owner_call = await mostar.ownerOf(token_id=token_id).call()
  assert owner_call.result == (l2_owner_signer.public_key, )

  balance_call = await mostar.balanceOf(owner=l2_owner_signer.public_key).call()
  assert balance_call.result == (uint(1), )

  uri_call = await mostar.tokenURI(token_id=token_id).call()
  assert uri_call.result == (str_to_felt("URI 1"), )
