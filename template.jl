#!/usr/bin/env julia

# Since it's a local module, it must be found with 'include' first
include("Intcode.jl")
using .Intcode

function main1()
    input_file = joinpath(pwd(), "files", "12_1_input.txt")
    lines = readlines(open(input_file, "r"))
    println("Part 1 Answer:")
end

function main2()
    nothing
end

main1()
main2()