%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func important_contract() -> (addr: felt):
end

@storage_var
func stored_value() -> (addr: felt):
end

@constructor
func constructor{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    addr: felt,
    value: felt
):
    important_contract.write(addr)
    stored_value.write(value)
    return ()
end

@view
func read_values{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}() -> (addr: felt, value: felt):
    alloc_locals
    let (local addr) = important_contract.read()
    let (local value) = stored_value.read()
    return (addr=addr, value=value)
end