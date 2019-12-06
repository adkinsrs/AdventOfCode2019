#!/usr/bin/env julia

function main1()
    # Getting curl 400 error so downloading file beforehand
    #input_file = download("https://adventofcode.com/2019/day/1/input")
    input_file = joinpath(pwd(), "files", "12_1_input.txt")
    lines = readlines(open(input_file, "r"))
    println("Part 1 Answer:")
end

function main2()
    nothing
end

main1()
main2()