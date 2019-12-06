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

    """
    #test string
    test = "COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L"
    lines = split(test, "\n")
    # end test
    """

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

    total_dists = zero(Int)
    for v in vertices(orbits)
        geodesic_dist = gdistances(orbits, v)
        # If source vertex cannot traverse to destination vertex, 
        # then result distance is maximum Int64 number.  Remove these
        good_dists = filter(x -> x < typemax(Int64), geodesic_dist)
        # Only want the longest traversal
        total_dists += maximum(good_dists)
    end

    println("Part 1 Answer:")
    @show total_dists
end

"""
What is the minimum number of orbital transfers required to move 
from the object YOU are orbiting to the object SAN is orbiting?
(Between the objects they are orbiting - not between YOU and SAN.)
"""
function main2()
    nothing
end

main1()
main2()