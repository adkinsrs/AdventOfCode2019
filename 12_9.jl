#!/usr/bin/env julia

"""
https://adventofcode.com/2019/day/9
"""

# Since it's a local module, it must be found with 'include' first
include("Common.jl")
using .Common

# Builds off of the intcode compiler from Day 7
function main1()
    input_file = joinpath(pwd(), "files", "12_7_input.txt")
    input = read(open(input_file, "r"), String)
    intcode = chomp(input)

    # TESTCODE
    intcode = "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"

    str_positions = split(intcode, ",")
    positions = map(x -> parse(Int, x), str_positions)
    orig_positions = copy(positions)

    INITIAL_INPUT = 1
    output = process_intcode(positions, Int[INITIAL_INPUT])

    println("Part 1 Answer:")
    @show output
end

function main2()
    nothing
end

# What BOOST keycode does it produce?
main1()
main2()