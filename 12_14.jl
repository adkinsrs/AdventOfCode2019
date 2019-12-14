#!/usr/bin/env julia

"""
https://adventofcode.com/2019/day/14
"""

function amount_to_increase(created, consumed )
    """ Determine amount to increase product requirements by for a reactant."""
    return max(created, consumed)
end

function calculate_requirements!(requirements, reactions, product)
    """Recursively calculate the number required to make FUEL for each reactant."""
    product == "ORE" && return
    # Create intermediate requirements dictionary for current product
    reactants = map(x -> x.reactant, reactions[product]["inputs"])

    [requirements[input.reactant] += amount_to_increase(reactions[input]["quantity"], input.quantity) for input in reactions[product]["inputs"]]
    @show product, reactions[product]["quantity"], reactions[product]["inputs"]

    [calculate_requirements!(requirements, reactions, input.reactant) for input in reactions[product]["inputs"]]
    @show requirements
    @show ""

    #product_requirements = Dict( input => zero(Int) for input in reactants)
    #[product_requirements[input.reactant] = input.quantity for input in reactions[product]["inputs"]]

    #for reactant in collect(keys(product_requirements))
    #    if reactant != "ORE"
    #        inner_requirements = calculate_requirements!(product_requirements, reactions, reactant)
    #        @show product, inner_requirements
    #    end
    #end
    # How much product will be produced in the reaction
    #product_requirements[product] = reactions[product]["quantity"]

    #return product_requirements
end

function parse_reactants(reactant_string)
    """Parse a string of reactants."""
    reactants = split(reactant_string, ", ")
    inputs = []
    for r in reactants
        quantity, reactant = split(r, " ")
        push!(inputs, (reactant=reactant, quantity=parse(Int,quantity)))
    end
    return inputs
end

function main1()
    input_file = joinpath(pwd(), "input.txt")
    input_file = joinpath(pwd(), "testinput.txt")

    lines = readlines(open(input_file, "r"))
    lines = map(l -> chomp(l), lines)
    # Determined via a test that all outputs are unique (num lines = num unique chemicals)
    reactants = map(x -> split(x, " => ")[1], lines)
    products = map(x -> split(x, " => ")[2], lines)
    quantities = map(x -> parse(Int, split(x, " ")[1]), products)
    chems = map(x -> split(x, " ")[2], products)

    # Break reactant_string into quantities and inputs
    inputs = map(r_str -> parse_reactants(r_str), reactants)

    # Store everything into a dictionary
    reactions = Dict( chems[i] => Dict("quantity" => quantities[i], "inputs" => inputs[i]) for i in 1:length(chems))

    # Keep track of chemical requirements to make FUEL
    requirements = Dict( chem => zero(Int) for chem in chems)
    requirements["ORE"] = 0 # ORE is not in list of products
    curr_chem = "FUEL"
    calculate_requirements!(requirements, reactions, curr_chem)
    #@show requirements
    println("Part 1 Answer:")
    @show requirements["ORE"]
end

function main2()
    nothing
end

# Given the list of reactions in your puzzle input, what is the minimum amount of ORE required to produce exactly 1 FUEL?
main1()
main2()