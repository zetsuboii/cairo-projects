%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2 # ??
from starkware.cairo.common.math import (
    assert_le, 
    assert_nn_le, 
    unsigned_div_rem 
)
from starkware.starknet.common.syscalls import get_caller_address

# Maximum amount of each token ???
const BALANCE_UPPER_BOUND = 2**64

const TOKEN_TYPE_A = 1
const TOKEN_TYPE_B = 2

# Ensure users' balance < pool's balance ???
const POOL_UPPER_BOUND = 2**30
const ACCOUNT_BALANCE_BOUND = 1073741 # 2**30 // 1000

@storage_var
func account_balance(account_id: felt, token_type: felt) -> (balance: felt):
end

@storage_var
func pool_balance(token_type: felt) -> (balance: felt):
end

func modify_account_balance{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    account_id: felt,
    token_type: felt,
    amount: felt
):
    # Read balance
    let (current_balance) = account_balance.read(account_id, token_type)
    tempvar new_balance = current_balance + amount
    # Assert if new balance doesn't exceed max balance
    assert_nn_le(new_balance, BALANCE_UPPER_BOUND - 1)
    # Write balance
    account_balance.write(account_id, token_type, amount)
    return ()
end

# Returns an account's balance for given token
@view
func get_account_token_balance{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    account_id: felt, 
    token_type: felt
) -> (
    balance: felt
):
    return account_balance.read(account_id, token_type)
end

# Sets pool's token balance
func set_pool_token_balance{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    token_type: felt,
    balance: felt
):
    # Assert pool balance is less than upper bound
    assert_nn_le(balance, BALANCE_UPPER_BOUND - 1)
    pool_balance.write(token_type, balance)
    return ()
end

# Return pool's token balance
@view
func get_pool_token_balance{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(token_type: felt)->(balance: felt):
    return pool_balance.read(token_type)
end

func revoke_x(x: felt)->():
    x = 5
    return ()
end

# Swaps tokens between given account and pool
func do_swap{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    account_id: felt,
    token_from: felt,
    token_to: felt,
    amount_from: felt
)->(
    amount_to: felt
):
    # Get pool balance
    let (amm_from_balance) = pool_balance.read(token_from)
    let (amm_to_balance) = pool_balance.read(token_to)

    # Calculate swap amount !!! Uniswap style
    let (amount_to, _) = unsigned_div_rem(
        amm_to_balance * amount_from, 
        amm_from_balance + amount_from    
    )

    # Update token_from balances
    modify_account_balance(account_id, token_from, amount_from)
    set_pool_token_balance(token_from, amm_from_balance + amount_from)

    # Update token_to balances
    modify_account_balance(account_id, token_to, amount_to)
    set_pool_token_balance(token_to, amm_to_balance - amount_to)
    return (amount_to)
end

func get_opposite_token(token_type: felt) -> (t: felt):
    if token_type == TOKEN_TYPE_A:
        return (TOKEN_TYPE_B)
    else:
        return (TOKEN_TYPE_A)
    end
end

@external
func swap{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    token_from: felt,
    amount_from: felt
)->(
    amount_to: felt
):
    assert (token_from - TOKEN_TYPE_A) * (token_from - TOKEN_TYPE_B) = 0
    # Check amount_from is valid
    assert_nn_le(amount_from, BALANCE_UPPER_BOUND - 1)
    # Check if user has enough funds
    let (caller) = get_caller_address()
    let (from_balance) = account_balance.read(caller, token_from)
    assert_le(amount_from, from_balance)

    let (token_to) = get_opposite_token(token_from)
    let (amount_to) = do_swap(
        caller,
        token_from,
        token_to,
        amount_from
    )

    return (amount_to)
end

@external
func add_demo_tokens{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    account_id: felt,
    token_a_amount: felt,
    token_b_amount: felt
):
    assert_nn_le(token_a_amount, BALANCE_UPPER_BOUND - 1)
    assert_nn_le(token_b_amount, BALANCE_UPPER_BOUND - 1)

    modify_account_balance(account_id, TOKEN_TYPE_A, token_a_amount)
    modify_account_balance(account_id, TOKEN_TYPE_B, token_b_amount)
    return ()
end

@external
func init_pool{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    token_a_amount: felt,
    token_b_amount: felt
):
    assert_nn_le(token_a_amount, BALANCE_UPPER_BOUND - 1)
    assert_nn_le(token_b_amount, BALANCE_UPPER_BOUND - 1)

    set_pool_token_balance(TOKEN_TYPE_A, token_a_amount)
    set_pool_token_balance(TOKEN_TYPE_B, token_b_amount)
    return ()
end