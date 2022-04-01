# each builtin is assigned a predefined memory place
# you use those memory places when you interact with a builtin

func hash2primitive(hash_ptr, x, y) -> (hash_ptr, z):
    x = [hash_ptr]
    y = [hash_ptr + 1]

    return (hash_ptr=hash_ptr + 3, z=[hash_ptr + 2])
end

# Builtins has syntactic sugars to help write these statements

from starkware.cairo.common.cairo_builtins import HashBuiltin

func hash2less_primitive(hash_ptr: HashBuiltin*, x, y) -> (hash_ptr, z):
    let hash = hash_ptr # copy the reference
    hash.x = x
    hash.y = y
    # (?) As soon as x and y are assigned hash_ptr+2 is assigned the right value
    
    return (hash_ptr=hash_ptr + HashBuiltin.SIZE, z=hash.result)
    # return (hash_ptr=hash_ptr + 3, z=[hash_ptr + 2])
end

# This way you have to pass hash_ptr to everywhere you go, even though you don't increment it
# (?) Don't understand why it is incremented though

func hash2{hash_ptr: HashBuiltin*}(x,y) -> (z):
    let hash = hash_ptr
    # (?) Why let here?
    # (?) let binds reference, this way we can re-bind the hash_ptr to what we want
    let hash_ptr = hash_ptr + HashBuiltin.SIZE

    # Same as result = hash(x,y)
    hash.x = x
    hash.y = y

    return (z=hash.result)
end
