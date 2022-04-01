%lang starknet

from starkware.cairo.common.alloc import alloc

# (?) As this is a pure function, no need for syscall_ptr
@view
func read_array{
    range_check_ptr
} (idx: felt) -> (value: felt):

    let (felt_array: felt*) = alloc() 

    assert [felt_array] = 3 
    assert [felt_array + 1] = 6 
    assert [felt_array + 2] = 9 
    assert [felt_array + 3] = 12
    assert [felt_array + 15] = 1

    return (value=felt_array[idx]) 
end