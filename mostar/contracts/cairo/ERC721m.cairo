%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
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

# Sends asset back to L1
# It is done by burning the ERC721 asset and sending a message to L1
@external
func send_back_to_l1{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}(token_id):
  # TODO
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

  # TODO
  return ()
end

# Registers a token id for the owner of that token
# * This will mint a new ERC721 asset on L2 side
# * It shouldn't be possible to directly pass uint256 L1->L2, because of 
# that I'll be passing low and high order bits seperately
# SELECTOR: 453167574301948615256927179001098538682611778866623857597439531518333154691
@l1_handler
func register{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}(
  from_address: felt, 
  owner: felt, 
  token_id_low: felt, 
  token_id_high: felt
):
  only_manager(from_address)

  # TODO
  return ()
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