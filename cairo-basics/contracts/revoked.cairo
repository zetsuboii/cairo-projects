func main():
    let x = [ap]
    [ap] = 1; ap++
    [ap] = 2; ap++

    %{
        print('x=', ids.x)
        print(memory.keys)
    %}

    [ap] = x; ap++
    jmp rel -1  # Jump to the previous instruction.
end