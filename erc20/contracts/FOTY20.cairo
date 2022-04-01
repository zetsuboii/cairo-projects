%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_caller_address
from contracts.ERC20_Base import (
    ERC20_initializer,
    ERC20_name,
    ERC20_symbol,
    ERC20_decimals,
    ERC20_totalSupply,
    ERC20_balanceOf,
    ERC20_allowance,
    ERC20_increaseAllowance,
    ERC20_decreaseAllowance,
    ERC20_approve,
    ERC20_transfer,
    ERC20_transferFrom,
    ERC20_burn
)

################################################################
######################### CONSTRUCTOR ##########################
################################################################

@constructor
func constructor{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}():
    const initial_supply = 1000000000000000
    let (caller) = get_caller_address()
    ERC20_initializer(
        'FOTY',                     # Name 
        'FOTY',                     # Symbol
        Uint256(0, initial_supply), # Total supply
        caller                      # Receiver of initial mint
    )
    return ()
end

################################################################
############################ VIEWS #############################
################################################################

@view
func name{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}() -> (name: felt):
    return ERC20_name()
end

@view
func symbol{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}() -> (symbol: felt):
    return ERC20_symbol()
end

@view
func decimals{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}() -> (decimals: felt):
    return ERC20_decimals()
end

@view
func totalSupply{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}() -> (total_supply: Uint256):
    return ERC20_totalSupply()
end

@view
func balanceOf{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(account: felt) -> (balance: Uint256):
    return ERC20_balanceOf(account)
end

@view
func allowance{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(owner: felt, spender: felt) -> (allowance: Uint256):
    return ERC20_allowance(owner, spender)
end

################################################################
########################## EXTERNALS ###########################
################################################################

@external
func transfer{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    recipient: felt,
    amount: Uint256
):
    ERC20_transfer(recipient, amount)
    return ()
end