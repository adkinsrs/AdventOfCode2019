#!/usr/bin/env julia

"""
https://adventofcode.com/2019/day/5

"""

POSITION_MODE = 0
IMMEDIATE_MODE = 1

function init_positions!(positions, noun=12, verb=2)
    # Julia is 1-indexed so these are slightly different than the instructions
    positions[2] = noun   # Noun
    positions[3] = verb    # Verb
end

function normalize_modes!(modes, window)
    # If modes array is smaller than the windows, add the implied 0 modes
    while length(modes) < length(window)
        push!(modes, POSITION_MODE)
    end
end

function resolve_opcode_1!(positions, window, modes)
    values = Int[]
    for i in 1:length(window)
        if modes[i] == POSITION_MODE
            push!(values, positions[window[i]+1])
        else
            # Immediate mode pushes value directly
            push!(values, window[i])
        end
    end
    # Windows 2, 3, and 4 are memory address positions
    total = values[1] + values[2]
    positions[window[3]+1] = total
end

function resolve_opcode_2!(positions, window, modes)
    values = Int[]
    for i in 1:length(window)
        if modes[i] == POSITION_MODE
            push!(values, positions[window[i]+1])
        else
            push!(values, window[i])
        end
    end
    total = values[1] * values[2]
    positions[window[3]+1] = total
end

function resolve_opcode_3!(positions, window, modes, input)
    positions[window[1]+1] = input
end

function resolve_opcode_4(positions, window, modes)
    return positions[window[1]+1]
end

function resolve_opcode_99(positions)
    return positions[1]
end

function main1()
    input_file = joinpath(pwd(), "files", "12_5_input.txt")
    input = read(open(input_file, "r"), String)
    intcode = chomp(input)
    #intcode = "1,9,10,3,2,3,11,0,99,30,40,50"  # Test string
    str_positions = split(intcode, ",")
    positions = map(x -> parse(Int, x), str_positions)

    #init_positions!(positions)
    INITIAL_INPUT = 1
    stored_value = INITIAL_INPUT

    i = 1
    while i < length(positions)-1
        # First param is instructions
        instructions = positions[i]
        # Last two digits in the instructions code is the opcode
        opcode = mod(instructions, 100)
        # Divide to remove the opcode, the store individual digits right-to-left in array
        modes = digits(div(instructions, 100))

        # Handle the various opcodes
        if opcode == 1
            try
                window = positions[i+1:i+3]
            catch BoundsError
                error("Whoops! Program went to far.  Opcode 1 or 2 should not be this close to the end.")
            end
            normalize_modes!(modes, window)
            resolve_opcode_1!(positions, window, modes)
            i += 4
        elseif opcode == 2
            try
                window = positions[i+1:i+3]
            catch BoundsError
                error("Whoops! Program went to far.  Opcode 1 or 2 should not be this close to the end.")
            end
            normalize_modes!(modes, window)
            resolve_opcode_2!(positions, window, modes)
            i += 4
        elseif opcode == 3
            window = positions[i+1]
            normalize_modes!(modes, window)
            resolve_opcode_3!(positions, window, modes, stored_value)
            i += 2
        elseif opcode == 4
            window = positions[i+1]
            normalize_modes!(modes, window)
            stored_value = resolve_opcode_4(positions, window, modes)
            i += 2
        elseif opcode == 99
            println("Part 1 Answer:")
            @show stored_value
            return
        end
    end

    # In case we never have opcode 99
    println("Part 1 Answer:")
    @show positions[1]
end

function main2()
    nothing
end

main1()
main2()