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



#	██╗      ██╗    ██╗  ██╗ █████╗ ███╗   ██╗██████╗ ██╗     ███████╗██████╗ 
#	██║     ███║    ██║  ██║██╔══██╗████╗  ██║██╔══██╗██║     ██╔════╝██╔══██╗
#	██║     ╚██║    ███████║███████║██╔██╗ ██║██║  ██║██║     █████╗  ██████╔╝
#	██║      ██║    ██╔══██║██╔══██║██║╚██╗██║██║  ██║██║     ██╔══╝  ██╔══██╗
#	███████╗ ██║    ██║  ██║██║  ██║██║ ╚████║██████╔╝███████╗███████╗██║  ██║
#	╚══════╝ ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝

# Initializes the asset with relavant info
@l1_handler
func initialize{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}(from_address: felt, name: felt, symbol: felt):
    return ()
end