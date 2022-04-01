%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func stored_mapping(x:felt) -> (y:felt):
end

@view
func read{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    key: felt
) -> (
    value: felt
):
    let (res) = stored_mapping.read(key)
    return(value = res)
end

@external
func assign{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}(
    assign_arr_len: felt,
    assign_arr: felt*
):
    assert assign_arr_len = 2
    let first = assign_arr[0]
    let second = assign_arr[1]

    stored_mapping.write(first, second)
    return ()
end