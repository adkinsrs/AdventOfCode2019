#!/usr/bin/env julia

"""
Puzzle at https://adventofcode.com/2019/day/4
"""

PUZZLE_INPUT="108457-562041"

function main1()
    str_inputs = split(PUZZLE_INPUT, "-")
    inputs = map(x -> parse(Int, x), str_inputs)
    ranges = inputs[1]:inputs[end]
    num_passwords = zero(Int)
    for i in ranges
        str_number = string(i)
        length(str_number) == 6 || continue
        # Test for at least 1 set of adjacent digits
        adjacent_numbers = false
        for j in 1:5
            if str_number[j] == str_number[j+1]
                adjacent_numbers = true
                break
            end
        end
        adjacent_numbers || continue
        # Digits never decrease from left-to-right
        decrease = false
        for j in 1:5
            if str_number[j] > str_number[j+1]
                decrease = true
                break
            end
        end
        decrease && continue
        num_passwords += 1
        
    end
    println("Part 1 Answer:")
    @show num_passwords
end

function main2()
    str_inputs = split(PUZZLE_INPUT, "-")
    inputs = map(x -> parse(Int, x), str_inputs)
    ranges = inputs[1]:inputs[end]
    num_passwords = zero(Int)
    for i in ranges
        str_number = string(i)
        length(str_number) == 6 || continue
        # Test for at least 1 set of adjacent digits but as a run of 2
        adjacent_numbers = false
        for j in 1:5
            total_adjacent_nums = zero(Int)
            if str_number[j] == str_number[j+1]
                # Look behind to check for a run of 3
                if j > 1
                    str_number[j-1] == str_number[j] && continue
                end

                # Now look ahead
                if j+1 < length(str_number)
                    str_number[j+1] == str_number[j+2] && continue
                end
                
                # If lookbehind and lookahead pass then this has to be a run of 2
                adjacent_numbers = true
                break
            end
        end
        adjacent_numbers || continue
        # Digits never decrease from left-to-right
        decrease = false
        for j in 1:5
            if str_number[j] > str_number[j+1]
                decrease = true
                break
            end
        end
        decrease && continue
        num_passwords += 1
        
    end
    println("Part 2 Answer:")
    @show num_passwords
end

main1()
main2()