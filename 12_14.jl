#!/usr/bin/env julia

"""
https://adventofcode.com/2019/day/14
"""

function parse_reactants(reactant_string)
    """Parse a string of reactants."""
    reactants = split(reactant_string, ", ")
    inputs = []
    for r in reactants
        quantity, reactant = split(r, " ")
        push!(inputs, (reactant=reactant, quantity=quantity))
    end
    return inputs
end

function main1()
    input_file = joinpath(pwd(), "input.txt")
    lines = readlines(open(input_file, "r"))
    lines = map(l -> chomp(l), lines)
    # Determined via a test that all outputs are unique (num lines = num unique chemicals)
    reactants = map(x -> split(x, " => ")[1], lines)
    products = map(x -> split(x, " => ")[2], lines)
    quantities = map(x -> split(x, " ")[1], products)
    chems = map(x -> split(x, " ")[2], products)

    # Break reactant_string into quantities and inputs
    inputs = map(r_str -> parse_reactants(r_str), reactants)

    # Store everything into a dictionary
    reactions = Dict( chems[i] => Dict("quantity" => quantities[i], "inputs" => inputs[i]) for i in 1:length(chems))

    num_ore = 0
    curr_chem = "FUEL"

    for input in reactions[curr_chem]["inputs"]
        @show reactions[input.reactant]["inputs"] 
    end


    println("Part 1 Answer:")
end

function main2()
    nothing
end

# Given the list of reactions in your puzzle input, what is the minimum amount of ORE required to produce exactly 1 FUEL?
main1()
main2()