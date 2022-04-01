# iostream eq.
%builtins output

# cout eq.
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.alloc import alloc

# felt is an integer type which is used when we don't specift a type
# value of a felt is between -2**252 & +2**252
# if there's an underflow/overflow value rounds up to the other end
func array_sum(arr: felt*, size) -> (sum):
    # If size is 0 return 0
    if size == 0:
        return (sum = 0)
    # Close if statements with "end"
    end

    # Calculate sum recursively
    # Main reason is that loops are not possible with Cairo
    let (sum_of_rest) = array_sum(arr=arr + 1, size=size - 1)
    
    # [] is the dereference operator which returns arr[0]
    return (sum = [arr] + sum_of_rest)

# Close functions with end
end

# Cannot call functions as part of other expressions (foo(bar()))

func array_prod(arr: felt*, size) -> (prod):
    if size == 0:
        return (prod = 1)
    end

    let (prod_of_rest) = array_prod(arr=arr + 2, size=size-2)
    return (prod = [arr] * prod_of_rest) 
end

# assert <expr> = <val_expr> does
# - the assertion if <expr> is set
# - make an assignment if <expr> is not set before

func main{output_ptr : felt*}():
    const ARRAY_SIZE = 3

    # alloc allocates space for ptr, size is evaluated at compile time
    # A function call returns a Return object which then we'll need to unpack
    let (ptr) = alloc()

    assert [ptr] = 9
    assert [ptr+1] = 16
    assert [ptr+2] = 25 

    let (sum) = array_prod(arr=ptr, size=ARRAY_SIZE)
    serialize_word(sum)

    return ()
end