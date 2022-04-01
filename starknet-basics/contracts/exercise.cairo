func main():
    [ap] = 100; ap++
    [ap] = 23; ap++
    [ap] = 45; ap++
    [ap] = 67; ap++
    [ap] = [ap-2] * [fp]; ap++
    [ap] = [ap-4] * [fp]; ap++
    [ap] = [ap-5] * [fp]; ap++
    [ap] = [fp] * [fp]; ap++
    [ap] = [ap-1] * [fp]; ap++
    ret
end