#!/usr/bin/env julia

"""
https://adventofcode.com/2019/day/5

"""

POSITION_MODE = 0   # Parameter is a memory address
IMMEDIATE_MODE = 1  # Parameters is the value itself

function determine_values(positions, window, modes)
    values = Int[]
    for i in 1:length(window)
        if modes[i] == POSITION_MODE
            push!(values, positions[window[i]+1])
        else
            # Immediate mode pushes value directly
            push!(values, window[i])
        end
    end
    return values
end

function normalize_modes!(modes, window)
    # If modes array is smaller than the windows, add the implied 0 modes
    while length(modes) < length(window)
        push!(modes, POSITION_MODE)
    end
end

function resolve_opcode_1!(positions, window, modes)
    values = determine_values(positions, window, modes)
    # Windows 2, 3, and 4 are memory address positions
    total = values[1] + values[2]
    positions[window[3]+1] = total
end

function resolve_opcode_2!(positions, window, modes)
    values = determine_values(positions, window, modes)
    total = values[1] * values[2]
    positions[window[3]+1] = total
end

function resolve_opcode_3!(positions, window, modes, input)
    # parameters that write to a position will never be in "immediate mode"
    positions[window[1]+1] = input
end

function resolve_opcode_4(positions, window, modes)
    values = determine_values(positions, window, modes)
    return values[1]
end

function resolve_opcode_5(positions, window, modes, idx)
    values = determine_values(positions, window, modes)
    # Since Julia is 1-based indexing, need to increment index by 1 if it references an address
    # If returning original index, increment over the window so "opcode does nothing"
    return (iszero(values[1]) ? idx+3 : values[2]+1)
end

function resolve_opcode_6(positions, window, modes, idx)
    values = determine_values(positions, window, modes)
    return (iszero(values[1]) ? values[2]+1 : idx+3)
end

function resolve_opcode_7(positions, window, modes)
    values = determine_values(positions, window, modes)
    positions[window[3]+1] = (values[1] < values[2] ? 1 : 0)
end

function resolve_opcode_8(positions, window, modes)
    values = determine_values(positions, window, modes)
    @show (window, values)
    positions[window[3]+1] = (values[1] == values[2] ? 1 : 0)
end

function resolve_opcode_99(positions)
    return positions[1]
end

function main1()
    input_file = joinpath(pwd(), "files", "12_5_input.txt")
    input = read(open(input_file, "r"), String)
    intcode = chomp(input)

    str_positions = split(intcode, ",")
    positions = map(x -> parse(Int, x), str_positions)

    INITIAL_INPUT = 1
    stored_value = INITIAL_INPUT

    i = 1
    while i <= length(positions)
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
    println("Part 1 Answer (should not have gotten here):")
    @show positions[1]
end

function main2()
    input_file = joinpath(pwd(), "files", "12_5_input.txt")
    input = read(open(input_file, "r"), String)
    intcode = chomp(input)

    # TEST COMMANDS
    # Output should be 999
    #intcode = "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"
    #stored_value = 7  # For test, input is gathered on first instruction

    # Output should be 1 for non-zero input, 0 for zero input
    #intcode = "3,3,1105,-1,9,1101,0,0,12,4,12,99,1"
    #stored_value = 1

    str_positions = split(intcode, ",")
    positions = map(x -> parse(Int, x), str_positions)

    INITIAL_INPUT = 5
    stored_value = INITIAL_INPUT
    i = 1
    while i <= length(positions)
        # First param is instructions
        instructions = positions[i]
        # Last two digits in the instructions code is the opcode
        opcode = mod(instructions, 100)
        # Divide to remove the opcode, the store individual digits right-to-left in array
        modes = digits(div(instructions, 100))

        #@show (i, instructions, stored_value)
        #@show positions

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
        elseif opcode == 5
            try
                window = positions[i+1:i+2]
            catch BoundsError
                error("Whoops! Program went to far.  Opcode 5 or 6 should not be this close to the end.")
            end
            normalize_modes!(modes, window)
            i = resolve_opcode_5(positions, window, modes, i)
        elseif opcode == 6
            try
                window = positions[i+1:i+2]
            catch BoundsError
                error("Whoops! Program went to far.  Opcode 5 or 6 should not be this close to the end.")
            end
            normalize_modes!(modes, window)
            i = resolve_opcode_6(positions, window, modes, i)
        elseif opcode == 7
            try
                window = positions[i+1:i+3]
            catch BoundsError
                error("Whoops! Program went to far.  Opcode 7 or 8 should not be this close to the end.")
            end
            normalize_modes!(modes, window)
            resolve_opcode_7(positions, window, modes)
            i += 4
        elseif opcode == 8
            try
                window = positions[i+1:i+3]
            catch BoundsError
                error("Whoops! Program went to far.  Opcode 7 or 8 should not be this close to the end.")
            end
            normalize_modes!(modes, window)
            resolve_opcode_8(positions, window, modes)
            i += 4
        elseif opcode == 99
            println("Part 2 Answer:")
            @show stored_value
            return
        end
    end

    # In case we never have opcode 99
    println("Part 2 Answer (should not have gotten here):")
    @show positions[1]
end

main1()
main2()