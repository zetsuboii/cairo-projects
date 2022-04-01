%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func persistent_state() -> (res: felt):
end

@external
func use_variable{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}() -> ():
    alloc_locals

    # Both let & tempvar are revocable
    # References can be redefined
    let my_reference = 50
    let my_reference = 51

    # Tempvars also can be redefined
    tempvar my_tempvar = 2 * my_reference
    tempvar my_tempvar = 3 * my_reference

    # Both are non-revocable
    const my_const = 60
    local my_local = 70

    persistent_state.write(60)
    persistent_state.write(80)

    let (my_reference_2) = persistent_state.read()
    let (local my_local_2) = persistent_state.read()

    # If my_local_2 was reference this would count as a reassignment
    assert my_local_2 = 80
    return ()
end


