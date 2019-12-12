#!/usr/bin/env julia

"""
https://adventofcode.com/2019/day/2
"""

function init_positions!(positions, noun=12, verb=2)
    # Julia is 1-indexed so these are slightly different than the instructions
    positions[2] = noun   # Noun
    positions[3] = verb    # Verg
end

function resolve_opcode_1!(positions, window)
    # Windows 2, 3, and 4 are memory address positions
    total = positions[window[2]+1] + positions[window[3]+1]
    positions[window[4]+1] = total
end

function resolve_opcode_2!(positions, window)
    total = positions[window[2]+1] * positions[window[3]+1]
    positions[window[4]+1] = total
end

function resolve_opcode_99(positions)
    return positions[1]
end

function main1()
    input_file = joinpath(pwd(), "files", "12_2_input.txt")
    intcode = open(input_file, "r") do ifh
        read(ifh, String)
    end

    #intcode = "1,9,10,3,2,3,11,0,99,30,40,50"  # Test string
    intcode = strip(intcode)
    str_positions = split(intcode, ",")
    positions = map(x -> parse(Int, x), str_positions)

    init_positions!(positions)

    final_position = length(positions) - 3
    for i in 1:4:final_position
        window = positions[i:i+3]
        if window[1] == 1
            resolve_opcode_1!(positions, window)
        elseif window[1] == 2
            resolve_opcode_2!(positions, window)
        elseif window[1] == 99
            println("Part 1 Answer:")
            @show resolve_opcode_99(positions)
            return
        end
    end

    # In case we never have opcode 99
    println("Part 1 Answer:")
    @show positions[1]
end

function main2()
    input_file = joinpath(pwd(), "files", "12_2_input.txt")
    intcode = open(input_file, "r") do ifh
        read(ifh, String)
    end

    intcode = strip(intcode)
    str_positions = split(intcode, ",")
    positions = map(x -> parse(Int, x), str_positions)
    orig_positions = copy(positions)

    DESIRED_OUTPUT = 19690720
    final_position = length(positions) - 3

    # Compute output over range of nouns and verbs until the combination
    # that gives the desired output is come across
    for noun in 0:99, verb in 0:99
        init_positions!(positions, noun, verb)
        output = zero(Int)
        for i in 1:4:final_position
            window = positions[i:i+3]
            if window[1] == 1
                resolve_opcode_1!(positions, window)
            elseif window[1] == 2
                resolve_opcode_2!(positions, window)
            elseif window[1] == 99
                output = resolve_opcode_99(positions)
                break
            end
        end
        if output == DESIRED_OUTPUT
            println("Part 2 Answer:")
            @show (100 * noun + verb)
            exit()
        end
        positions = copy(orig_positions)
    end

    # In case we don't find it...
    println("Didn't find the combination :-(")

end

main1()
main2()