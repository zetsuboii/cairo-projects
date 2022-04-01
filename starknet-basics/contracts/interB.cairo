%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
# msg.sender
from starkware.starknet.common.syscalls import get_caller_address

@storage_var
func b_value() -> (val: felt):
end

@storage_var
func a_addr() -> (addr: felt):
end

@storage_var
func owner() -> (addr: felt):
end

@constructor
func constructor{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    _b_value: felt,
):
    let (caller) = get_caller_address()
    owner.write(caller)
    b_value.write(_b_value)
    return ()
end

@view
func read_value{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
) -> (
    value: felt
):
    let (value) = b_value.read()
    return (value)
end

@view
func read_a{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
) -> (
    a: felt
):
    let (value) = a_addr.read()
    return (value)
end

@external
func set_a{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    new_a: felt
):
    alloc_locals
    let (local caller) = get_caller_address()
    let (_owner) = owner.read()
    assert caller = _owner

    a_addr.write(new_a)
    return ()
end

@external
func increment{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    n: felt
):
    alloc_locals
    let (local caller) = get_caller_address()
    let (a_address) = a_addr.read()

    assert caller = a_address

    let (prev_b) = b_value.read()
    b_value.write(prev_b + n)
    return ()
end