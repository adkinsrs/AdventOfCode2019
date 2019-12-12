#!/usr/bin/env julia

"""
https://adventofcode.com/2019/day/9
"""

# Since it's a local module, it must be found with 'include' first
include("Intcode.jl")
using .Intcode

# Builds off of the intcode compiler from Day 7
function main1()
    input_file = joinpath(pwd(), "files", "12_9_input.txt")
    input = read(open(input_file, "r"), String)
    intcode = chomp(input)

    # TESTCODE
    #intcode = "1102,34915192,34915192,7,4,7,99,0"
    #intcode = "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"

    str_positions = split(intcode, ",")
    positions = map(x -> parse(Int, x), str_positions)

    #ic = IntcodeComputer(copy(positions))  # TESTCODE

    INITIAL_INPUT = 1
    ic = IntcodeComputer(copy(positions), INITIAL_INPUT)
    while ic.curr_idx > 0
        (output, index, relative_base) = process_intcode(ic)
        update_computer!(ic, index, output, relative_base)
        @show ic.input
    end
    #(output, index, relative_base) = process_intcode(positions, INITIAL_INPUT)

    println("Part 1 Answer:")
    @show ic.input
end

function main2()
    input_file = joinpath(pwd(), "files", "12_9_input.txt")
    input = read(open(input_file, "r"), String)
    intcode = chomp(input)

    # TESTCODE
    #intcode = "1102,34915192,34915192,7,4,7,99,0"

    str_positions = split(intcode, ",")
    positions = map(x -> parse(Int, x), str_positions)
    orig_positions = copy(positions)

    INITIAL_INPUT = 2
    #output = process_intcode(positions, nothing) # Test code takes no input
    ic = IntcodeComputer(copy(positions), INITIAL_INPUT)
    while ic.curr_idx > 0
        (output, index, relative_base) = process_intcode(ic)
        update_computer!(ic, index, output, relative_base)
        @show ic.input
    end

    println("Part 1 Answer:")
    @show ic.input
end

# What BOOST keycode does it produce?
main1()
# What are the coordinates of the distress signal?
main2()