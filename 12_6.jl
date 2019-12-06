#!/usr/bin/env julia

"""
https://adventofcode.com/2019/day/6
"""

# SIDENOTE: Is it cheap for me to use a package to do this puzzle? 
# Maybe not... I am learning about graph theory some, and there is no sense in reinventing the wheel
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
    
    # Initialize graph (directed)
    orbits = SimpleDiGraph(length(all_bodies))

    for line in lines
        larger, smaller = split(line, ")")
        small_index = findfirst(x -> x == smaller, all_bodies)
        large_index = findfirst(x -> x == larger, all_bodies)

        add_edge!(orbits, small_index, large_index) # Small orbits large
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
    input_file = joinpath(pwd(), "files", "12_6_input.txt")
    lines = readlines(open(input_file, "r"))

    lines = map(x -> chomp(x), lines)
    # Split larger and smaller bodies into their own array.
    # Can now take smaller bodies as a node label for the graphs
    smaller = map(x -> split(x, ")")[2], lines)
    larger = map(x -> split(x, ")")[1], lines)
    all_bodies = union(smaller, larger)
    
    # Initialize graph (undirected)
    orbits = SimpleGraph(length(all_bodies))

    YOU_index = zero(Int)
    SAN_index = zero(Int)

    for line in lines
        larger, smaller = split(line, ")")
        small_index = findfirst(x -> x == smaller, all_bodies)
        large_index = findfirst(x -> x == larger, all_bodies)

        # Keep these for later
        if smaller == "YOU"
            YOU_index = small_index
        elseif smaller == "SAN"
            SAN_index = small_index
        end

        add_edge!(orbits, small_index, large_index)
    end    

    # YOU and SAN only orbit a single body so start with that larger body
    YOU_neighbor = neighbors(orbits, YOU_index)[1]
    SAN_neighbor = neighbors(orbits, SAN_index)[1]

    edges = a_star(orbits, YOU_neighbor, SAN_neighbor)

    println("Part 2 Answer:")
    @show length(edges)
end

main1()
main2()