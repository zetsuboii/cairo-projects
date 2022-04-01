# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func balance() -> (res: felt):
end

# View function to get balance
@view
func get_balance {
    syscall_ptr: felt*,         # Looks similar to output_ptr
    pedersen_ptr: HashBuiltin*, # Used for hashing
    range_check_ptr
}() -> (
    value: felt
):
    # Read value from storage
    let (value) = balance.read()
    return (value)
end

# Function to increase the balance by 1
@external
func increase_balance {
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}() -> ():
    let (current_bal) = balance.read()
    balance.write(current_bal + 1)
    return ()
end