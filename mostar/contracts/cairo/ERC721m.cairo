%lang starknet

# ERC721 Mostar
# An ERC721 asset that is reflective on its L1 counterpart

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_caller_address
from starkware.starknet.common.messages import send_message_to_l1

from starkware.cairo.common.uint256 import Uint256, uint256_check
from starkware.cairo.common.math import assert_nn_le

from openzeppelin.introspection.ERC165 import ERC165_supports_interface
from openzeppelin.token.erc721.library import (
  ERC721_name,
  ERC721_symbol,
  ERC721_balanceOf,
  ERC721_ownerOf,
  ERC721_getApproved,
  ERC721_isApprovedForAll,
  ERC721_tokenURI,
  
  ERC721_initializer,
  ERC721_approve, 
  ERC721_setApprovalForAll, 
  ERC721_transferFrom,
  ERC721_safeTransferFrom,
  ERC721_mint,
  ERC721_burn,
  ERC721_only_token_owner,
  ERC721_setTokenURI
)

# Optional - Type of message we're sending
# keccak256(send_back_to_l1(Uint256))[:4] = 0x15f1c585 = 368166277
const MESSAGE_SEND_BACK = 368166277

#	███████╗████████╗ ██████╗ ██████╗  █████╗  ██████╗ ███████╗
#	██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██╔══██╗██╔════╝ ██╔════╝
#	███████╗   ██║   ██║   ██║██████╔╝███████║██║  ███╗█████╗  
#	╚════██║   ██║   ██║   ██║██╔══██╗██╔══██║██║   ██║██╔══╝  
#	███████║   ██║   ╚██████╔╝██║  ██║██║  ██║╚██████╔╝███████╗
#	╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝

@storage_var
func l1_address() -> (addr: felt):
end

@storage_var
func l1_manager() -> (addr: felt):
end

@storage_var
func custom_uri(token_id: Uint256, idx: felt) -> (uri_part: felt):
end

@storage_var
func custom_uri_len(token_id: Uint256) -> (len: felt):
end

#	 ██████╗███╗   ██╗███████╗████████╗ ██████╗ ██████╗ 
#	██╔════╝████╗  ██║██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗
#	██║     ██╔██╗ ██║███████╗   ██║   ██║   ██║██████╔╝
#	██║     ██║╚██╗██║╚════██║   ██║   ██║   ██║██╔══██╗
#	╚██████╗██║ ╚████║███████║   ██║   ╚██████╔╝██║  ██║
#	 ╚═════╝╚═╝  ╚═══╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝

# Sets the L1 contract that'll initialize the contract
@constructor
func constructor{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}(l1_manager_address: felt):
  l1_manager.write(l1_manager_address)
  return ()
end

#	██╗   ██╗██╗███████╗██╗    ██╗
#	██║   ██║██║██╔════╝██║    ██║
#	██║   ██║██║█████╗  ██║ █╗ ██║
#	╚██╗ ██╔╝██║██╔══╝  ██║███╗██║
#	 ╚████╔╝ ██║███████╗╚███╔███╔╝
#	  ╚═══╝  ╚═╝╚══════╝ ╚══╝╚══╝ 
#   These function will be mere aliases

@view
func name{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}() -> (name: felt):
  return ERC721_name()
end

@view
func symbol{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}() -> (symbol:felt):
  return ERC721_symbol()
end

@view
func balanceOf{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}(owner: felt) -> (balance: Uint256):
  return ERC721_balanceOf(owner)
end

@view
func ownerOf{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}(token_id: Uint256) -> (owner: felt):
  return ERC721_ownerOf(token_id)
end

@view
func getApproved{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}(token_id: Uint256) -> (approved: felt):
  return ERC721_getApproved(token_id)
end

@view
func isApprovedForAll{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}(owner: felt, operator: felt) -> (is_approved: felt):
  return ERC721_isApprovedForAll(owner, operator)
end

@view
func tokenURI{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}(token_id: Uint256) -> (token_uri: felt):
  return ERC721_tokenURI(token_id)
end

@view
func supportsInterface{
  syscall_ptr : felt*,
  pedersen_ptr : HashBuiltin*,
  range_check_ptr
}(interfaceId: felt) -> (success: felt):
  let (success) = ERC165_supports_interface(interfaceId)
  return (success)
end

# Returns address of the original asset on L1
@view
func get_l1_address{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}() -> (l1_address: felt):
  return l1_address.read()
end

#	███████╗██╗  ██╗████████╗███████╗██████╗ ███╗   ██╗ █████╗ ██╗     
#	██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝██╔══██╗████╗  ██║██╔══██╗██║     
#	█████╗   ╚███╔╝    ██║   █████╗  ██████╔╝██╔██╗ ██║███████║██║     
#	██╔══╝   ██╔██╗    ██║   ██╔══╝  ██╔══██╗██║╚██╗██║██╔══██║██║     
#	███████╗██╔╝ ██╗   ██║   ███████╗██║  ██║██║ ╚████║██║  ██║███████╗
#	╚══════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝

@external
func approve{
  pedersen_ptr: HashBuiltin*, 
  syscall_ptr: felt*, 
  range_check_ptr
}(to: felt, tokenId: Uint256):
  ERC721_approve(to, tokenId)
  return ()
end

@external
func setApprovalForAll{
  syscall_ptr: felt*, 
  pedersen_ptr: HashBuiltin*, 
  range_check_ptr
}(operator: felt, approved: felt):
  ERC721_setApprovalForAll(operator, approved)
  return ()
end

@external
func transferFrom{
  pedersen_ptr: HashBuiltin*, 
  syscall_ptr: felt*, 
  range_check_ptr
}(
  from_: felt, 
  to: felt, 
  tokenId: Uint256
):
  ERC721_transferFrom(from_, to, tokenId)
  return ()
end

@external
func safeTransferFrom{
  pedersen_ptr: HashBuiltin*, 
  syscall_ptr: felt*, 
  range_check_ptr
}(
  from_: felt, 
  to: felt, 
  tokenId: Uint256,
  data_len: felt, 
  data: felt*
):
  ERC721_safeTransferFrom(from_, to, tokenId, data_len, data)
  return ()
end

# Sends asset back to L1
# It is done by burning the ERC721 asset and sending a message to L1
@external
func send_back_to_l1{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}(token_id: Uint256):
  alloc_locals
  uint256_check(token_id)

  # Check if caller owns the token
  let (local caller: felt) = get_caller_address()
  let (local token_owner: felt) = ERC721_ownerOf(token_id)
  with_attr error_msg("Caller doesn't own the asset"):
    assert caller = token_owner
  end

  # Burn the asset
  ERC721_burn(token_id)

  # Call L1
  let (local manager_addr: felt) = l1_manager.read()
  let (local token_addr: felt) = l1_address.read()
  let (message_payload: felt*) = alloc()
  assert message_payload[0] = MESSAGE_SEND_BACK
  assert message_payload[1] = token_addr
  assert message_payload[2] = token_id.low
  assert message_payload[3] = token_id.high
  
  send_message_to_l1(
    to_address=manager_addr,
    payload_size=4,
    payload=message_payload
  )
  return ()
end

#	██╗      ██╗    ██╗  ██╗ █████╗ ███╗   ██╗██████╗ ██╗     ███████╗██████╗ 
#	██║     ███║    ██║  ██║██╔══██╗████╗  ██║██╔══██╗██║     ██╔════╝██╔══██╗
#	██║     ╚██║    ███████║███████║██╔██╗ ██║██║  ██║██║     █████╗  ██████╔╝
#	██║      ██║    ██╔══██║██╔══██║██║╚██╗██║██║  ██║██║     ██╔══╝  ██╔══██╗
#	███████╗ ██║    ██║  ██║██║  ██║██║ ╚████║██████╔╝███████╗███████╗██║  ██║
#	╚══════╝ ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝

# Initializes the asset with relavant info
# SELECTOR: 215307247182100370520050591091822763712463273430149262739280891880522753123
@l1_handler
func initialize{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}(from_address: felt, name: felt, symbol: felt):
  only_manager(from_address)

  ERC721_initializer(name=name, symbol=symbol)
  return ()
end

# Can be used if token URI is smaller than 32
@l1_handler
func register_simple{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}(
  from_address: felt, 
  owner: felt,
  l2addr: felt,
  token_id_low: felt, 
  token_id_high: felt,
  token_uri: felt
):
  only_manager(from_address)

  # Construct the token ID and mint token
  let token_id: Uint256 = Uint256(low=token_id_low, high=token_id_high) 
  uint256_check(token_id) # Check if received token ID is valid 

  ERC721_mint(to=l2addr, token_id=token_id)
  ERC721_setTokenURI(token_id=token_id, token_uri=token_uri)
  return ()
end

# Registers a token id for the owner of that token
# We cannot assume URI length on L1, this method decodes input in a way that
# both complies Cairo ERC721 and L1 ERC721. In this case URI on Cairo is not
# guaranteed to make sense (It'll only work if length is < 32)
# * This will mint a new ERC721 asset on L2 side
# * It shouldn't be possible to directly pass uint256 L1->L2, because of 
# that I'll be passing low and high order bits seperately
# SELECTOR: 453167574301948615256927179001098538682611778866623857597439531518333154691
@l1_handler
@raw_input
func register{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}(
  selector: felt,
  calldata_size: felt,
  calldata: felt*
):
  alloc_locals

  with_attr error_msg("Invalid selector"):
    assert selector = 453167574301948615256927179001098538682611778866623857597439531518333154691
  end

  # from_address   0 
  # l2addr         1
  # token_id_low   2 
  # token_id_high  3
  # token_uri_len  4
  # token_uri      variant

  only_manager(calldata[0])

  # Construct the token ID and mint token
  let token_id: Uint256 = Uint256(low=calldata[2], high=calldata[3]) 
  uint256_check(token_id) # Check if received token ID is valid 

  ERC721_mint(to=calldata[1], token_id=token_id)

  # I'll set the first index of token URI as ERC721's token URI, and save rest
  # as custom URI. This will help both  
  ERC721_setTokenURI(token_id=token_id, token_uri=calldata[5])

  custom_uri_len.write(token_id, calldata[4])

  # Save all of the URI to the custom storage
  save_token_uri(token_id, calldata, 5, calldata_size)
  return ()
end

func save_token_uri{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}(
  token_id: Uint256, 
  uri: felt*, 
  idx: felt,
  len: felt
):
  custom_uri.write(token_id, idx, uri[idx])
  
  if idx == (len-1):
    return ()
  else:
    return save_token_uri(token_id, uri, idx+1, len)
  end
end


#	██╗███╗   ██╗████████╗███████╗██████╗ ███╗   ██╗ █████╗ ██╗     
#	██║████╗  ██║╚══██╔══╝██╔════╝██╔══██╗████╗  ██║██╔══██╗██║     
#	██║██╔██╗ ██║   ██║   █████╗  ██████╔╝██╔██╗ ██║███████║██║     
#	██║██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗██║╚██╗██║██╔══██║██║     
#	██║██║ ╚████║   ██║   ███████╗██║  ██║██║ ╚████║██║  ██║███████╗
#	╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝

# Asserts if the caller is manager address specified in constructor
func only_manager{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}(caller: felt):
  let (manager) = l1_manager.read()
  with_attr error_msg("Only manager contract can call this function"):
    assert manager = caller
  end
  return ()
end