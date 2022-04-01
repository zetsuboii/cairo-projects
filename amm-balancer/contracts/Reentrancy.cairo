%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

#////////////////////////////////////////////////#
#                   CONSTANTS                    #
#////////////////////////////////////////////////#

const _NOT_ENTERED = 0
const _ENTERED = 1


#////////////////////////////////////////////////#
#                    STORAGE                     #
#////////////////////////////////////////////////#

@storage_var
func Reentrancy_status() -> (status: felt):
end


#////////////////////////////////////////////////#
#                   FUNCTIONS                    #
#////////////////////////////////////////////////#

# Called before function starts
func Reentrancy_start{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}():
    alloc_locals
    # Assert if function is not entered
    let (local status) = Reentrancy_status.read()

    with_attr error_message("ERR_REENTRY"):
        assert status = _NOT_ENTERED
    end

    # Update status
    Reentrancy_status.write(_ENTERED)
    return ()
end

# Called after function ends
func Reentrancy_end{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
}():
    Reentrancy_status.write(_NOT_ENTERED)
    return ()
end