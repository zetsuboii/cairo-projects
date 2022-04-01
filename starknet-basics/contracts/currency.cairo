%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

# No notion of currency

# Holds wallet balances
@storage_var
func wallet_balance(user: felt) -> (balance: felt):
end

# Increases user balance
@external
func register_currency{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    user: felt,
    register_amount: felt
) -> ():
    alloc_locals
    let(local balance) = wallet_balance.read(user)
    wallet_balance.write(user, balance + register_amount)
    return ()
end

@external
func move_currency{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    sender_user: felt,
    receiver_user: felt,
    amount: felt
) -> ():
    alloc_locals
    let (local sender_balance) = wallet_balance.read(sender_user)
    let (local receiver_balance) = wallet_balance.read(receiver_user)
    wallet_balance.write(sender_user, sender_balance - amount)
    wallet_balance.write(receiver_user, receiver_balance + amount)
    return ()
end

@view
func check_wallet{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    user: felt
) -> (
    balance: felt
):
    alloc_locals
    let (local user_balance) = wallet_balance.read(user)
    return (balance = user_balance)
end