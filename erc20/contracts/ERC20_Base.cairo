%lang starknet

# ? Why Signature Builtin is used
from starkware.cairo.common.cairo_builtins import HashBuiltin # , SignatureBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import (
    Uint256, uint256_add, uint256_sub, uint256_le, uint256_lt, uint256_check
)

################################################################
########################### STORAGE ############################
################################################################

@storage_var
func ERC20_name_() -> (name: felt):
end

@storage_var
func ERC20_symbol_() -> (symbol: felt):
end

@storage_var
func ERC20_decimals_() -> (decimals: felt):
end

@storage_var
func ERC20_total_supply() -> (totalSupply: Uint256):
end

@storage_var
func ERC20_balances(account: felt) -> (balance: Uint256):
end

@storage_var
func ERC20_allowances(owner: felt, spender: felt) -> (allowance: Uint256):
end

################################################################
######################### CONSTRUCTOR ##########################
################################################################

# Initializing like upgradeables
func ERC20_initializer{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    name: felt,
    symbol: felt,
    initial_supply: Uint256,
    recipient:felt
):
    ERC20_name_.write(name)
    ERC20_symbol_.write(symbol)
    ERC20_decimals_.write(10)
    ERC20_total_supply.write(initial_supply)
    return()
end

################################################################
############################ VIEWS #############################
################################################################

func ERC20_name{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}() -> (name: felt):
    alloc_locals
    let (local name) = ERC20_name_.read()
    return (name)
end

func ERC20_symbol{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}() -> (symbol: felt):
    alloc_locals
    let (local symbol) = ERC20_symbol_.read()
    return (symbol)
end

func ERC20_decimals{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}() -> (decimals: felt):
    alloc_locals
    let (local decimals) = ERC20_decimals_.read()
    return (decimals)
end

func ERC20_totalSupply{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}() -> (total_supply: Uint256):
    alloc_locals
    let (local total_supply) = ERC20_total_supply.read()
    return (total_supply)
end

func ERC20_balanceOf{
    syscall_ptr: felt*, 
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    account: felt
) -> (
    balance: Uint256
):
    alloc_locals
    let (local balance) = ERC20_balances.read(account)
    return (balance)
end

func ERC20_allowance{
    syscall_ptr: felt*, 
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    owner: felt,
    spender: felt
) -> (
    allowance: Uint256
):
    alloc_locals
    let (local allowance) = ERC20_allowances.read(owner, spender)
    return (allowance)
end

################################################################
########################## EXTERNAL ############################
################################################################

func ERC20_transfer{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(recipient: felt, amount: Uint256):
    let (caller) = get_caller_address()
    _transfer(caller, recipient, amount)
    return ()
end

func ERC20_transferFrom{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    sender: felt,
    recipient: felt,
    amount: Uint256
):
    alloc_locals

    # Check allowance
    let (local caller) = get_caller_address()
    let (local before_allowance: Uint256) = ERC20_allowances.read(sender, caller)
    let (enough_balance) = uint256_le(amount, before_allowance)
    assert_not_zero(enough_balance)

    _transfer(sender, recipient, amount)

    # Update allowance
    let (after_allowance) = uint256_sub(before_allowance, amount)
    ERC20_allowances.write(sender, caller, after_allowance)

    return ()
end

func ERC20_approve{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    spender: felt,
    amount: Uint256
):
    alloc_locals
    assert_not_zero(spender)
    uint256_check(amount)

    # Update allowance
    let (caller) = get_caller_address()
    ERC20_allowances.write(caller, spender, amount)

    return ()
end

func ERC20_increaseAllowance{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    spender: felt,
    amount: Uint256
):
    alloc_locals
    assert_not_zero(spender)
    uint256_check(amount)

    # Read allowance
    let (caller) = get_caller_address()
    let (before_allowance: Uint256) = ERC20_allowances.read(caller, spender)
    
    # Update allowance
    let (local after_allowance: Uint256, is_overflow) = uint256_add(before_allowance, amount)
    assert is_overflow = 0
    ERC20_allowances.write(caller, spender, after_allowance)

    return ()
end

func ERC20_decreaseAllowance{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    spender: felt,
    amount: Uint256
):
    alloc_locals
    assert_not_zero(spender)
    uint256_check(amount)

    # Read allowance
    let (caller) = get_caller_address()
    let (before_allowance: Uint256) = ERC20_allowances.read(caller, spender)
    
    # Update allowance
    let (local after_allowance: Uint256) = uint256_sub(before_allowance, amount)
    ERC20_allowances.write(caller, spender, after_allowance)

    return ()
end

func ERC20_mint{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(recipient: felt, amount: Uint256):
    alloc_locals
    assert_not_zero(recipient)
    uint256_check(amount)

    # Add to balance
    let (before_balance: Uint256) = ERC20_balances.read(recipient)
    let (after_balance, _: Uint256) = uint256_add(before_balance, amount)
    ERC20_balances.write(recipient, after_balance)

    # Add to supply
    let (before_supply: Uint256) = ERC20_total_supply.read()
    let (after_supply: Uint256, is_overflow) = uint256_add(before_supply, amount)
    # Check if new supply is in bounds
    assert (is_overflow) = 0
    
    ERC20_total_supply.write(after_supply)
    return ()
end

func ERC20_burn{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(account:felt, amount: Uint256):
    alloc_locals
    assert_not_zero(account)
    uint256_check(amount)

    # Check balance
    let (local before_balance: Uint256) = ERC20_balances.read(account)
    let (enough_balance) = uint256_le(amount, before_balance)
    assert_not_zero(enough_balance)

    # Update balance
    let (after_balance: Uint256) = uint256_sub(before_balance, amount)
    ERC20_balances.write(account, after_balance)

    # Update supply
    let (local before_supply: Uint256) = ERC20_total_supply.read()
    let (after_supply: Uint256) = uint256_sub(before_supply, amount)
    ERC20_total_supply.write(after_supply)

    return ()
end

################################################################
########################## INTERNAL ############################
################################################################

func _transfer{
  syscall_ptr: felt*,
  pedersen_ptr: HashBuiltin*,
  range_check_ptr
}(
    sender: felt,
    recipient: felt,
    amount: Uint256
):
    alloc_locals
    assert_not_zero(sender)
    assert_not_zero(recipient)
    uint256_check(amount)

    let (local sender_balance: Uint256) = ERC20_balances.read(sender)

    let (enough_balance) = uint256_le(amount, sender_balance)
    assert_not_zero(enough_balance)

    # Subtract from sender balance
    let (sender_after: Uint256) = uint256_sub(sender_balance, amount)
    ERC20_balances.write(sender, sender_after)

    # Add to receiver balance
    let (local recipient_balance: Uint256) = ERC20_balances.read(recipient)
    # Addition also returns carry, but this won't overflow
    let (recipient_after, _: Uint256) = uint256_add(recipient_balance, amount)
    ERC20_balances.write(recipient, recipient_after)

    return ()
end