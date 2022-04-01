%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

@contract_interface
namespace contract_B:
    func increment(n: felt):
    end

    func read_value() -> (n: felt):
    end
end

@storage_var
func b_address() -> (addr: felt):
end

@storage_var
func a_value() -> (val: felt):
end

@constructor
func constructor{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    _b_address: felt, 
    _a_value: felt
):
    b_address.write(value=_b_address)
    a_value.write(value=_a_value)
    return ()
end

@view
func read_b{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}() -> (b_value: felt):
    let (b_addr) = b_address.read()
    # Read from B contract
    let (b_value) = contract_B.read_value(b_addr)
    return (b_value)
end

@external
func write_b{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    incr_amt: felt
):
    alloc_locals
    let (b_addr) = b_address.read()
    # Write to contract
    contract_B.increment(b_addr, n=incr_amt)
    return ()
end
