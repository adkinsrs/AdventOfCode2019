#!/usr/bin/env julia

"""
https://adventofcode.com/2019/day/10
"""

EMPTY_POSITION = '.'
ASTEROID = '#'

NEGX_NEGY = 1
NEGX_POSY = 2
POSX_NEGY = 3
POSX_POSY = 4

struct Point
    x::Int   # left is 0
    y::Int   # top is 0
    asteroid::Bool # true if asteroid is present
end

function calculate_slope(x::Int, y::Int)::Float32
    return y / x
end

function is_asteroid(char::Char)
    return char == ASTEROID
end

function is_asteroid(position::Point)
    return position.asteroid
end

function main1()
    # Getting curl 400 error so downloading file beforehand
    #input_file = download("https://adventofcode.com/2019/day/10/input")
    input_file = joinpath(pwd(), "files", "12_10_input.txt")
    #input_file = joinpath(pwd(), "files", "12_10_test1.txt")    # TEST_CODE
    lines = readlines(open(input_file, "r"))
    lines = map(x -> chomp(x), lines)

    width = length(lines[1])
    height = length(lines)
    # Initialize grid with asteroids
    grid =  [Point(col, row, is_asteroid(lines[row+1][col+1])) for row in 0:height-1, col in 0:width-1]

    max_asteroids_seen = 0

    # The monitoring station must be built on an existing asteroid
    asteroid_positions = filter(x -> is_asteroid(x), grid)
    for pos in asteroid_positions
        #@show pos.x, pos.y
        pos_offset_x = (width-1) - pos.x
        pos_offset_y = (height-1) - pos.y
        neg_offset_x = copysign(pos.x, -1)
        neg_offset_y = copysign(pos.y, -1)
        slopes = Dict{Float32, Set{Int}}()  # keep track of slopes where an asteroid was visible, and quadrants where asteroid was
        asteroids_seen = Point[]
        for x in neg_offset_x:pos_offset_x, y in neg_offset_y:pos_offset_y
            # Skip current position
            x == 0 && y == 0 && continue
            # Get true coordinates of the position we are looking at
            true_x = x + pos.x
            true_y = y + pos.y
            # Only consider positions with asteroids
            is_asteroid(grid[true_y+1, true_x+1]) || continue

            # Create a slope dict key if not present
            slope = calculate_slope(x, y)
            get!(slopes, slope, Set{Int}())

            # Two asteroids can be in the same line from the current asteroid, but in different directions
            # x and y coordinates at 0 will be considered positive integers
            if x < 0
                if y < 0
                    push!(slopes[slope], NEGX_NEGY)
                else
                    push!(slopes[slope], NEGX_POSY)
                end
            else
                if y < 0
                    push!(slopes[slope], POSX_NEGY)
                else
                    push!(slopes[slope], POSX_POSY)
                end
            end
        end
        #@show slopes
        visible_asteroids = sum(length(slopes[slope]) for slope in keys(slopes))
        max_asteroids_seen = max(max_asteroids_seen, visible_asteroids)
    end

    println("Part 1 Answer:")
    @show max_asteroids_seen
end

function main2()
    nothing
end

# Find the best location for a new monitoring station.
# How many other asteroids can be detected from that location?
main1()
main2()