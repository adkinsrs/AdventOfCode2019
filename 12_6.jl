#!/usr/bin/env julia

"""
https://adventofcode.com/2019/day/6
"""

using LightGraphs

"""
What is the total number of direct and indirect orbits in your map data?

"""
function main1()
    input_file = joinpath(pwd(), "files", "12_6_input.txt")
    lines = readlines(open(input_file, "r"))
    lines = map(x -> chomp(x), lines)
    # Split larger and smaller bodies into their own array.
    # Can now take smaller bodies as a node label for the graphs
    smaller = map(x -> split(x, ")")[2], lines)
    larger = map(x -> split(x, ")")[1], lines)
    all_bodies = union(smaller, larger)
    
    # Initialize graph
    orbits = SimpleDiGraph(length(all_bodies))

    for line in lines
        larger, smaller = split(line, ")")
        small_index = findfirst(x -> x == smaller, all_bodies)
        large_index = findfirst(x -> x == larger, all_bodies)

        add_edge!(orbits, small_index, large_index)
    end

    

    println("Part 1 Answer:")
end

function main2()
    nothing
end

main1()
main2()