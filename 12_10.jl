#!/usr/bin/env julia

"""
https://adventofcode.com/2019/day/10
"""

EMPTY_POSITION = '.'
ASTEROID = '#'

# Start up and go clockwise
POSX_POSY = 1
POSX_NEGY = 2
NEGX_NEGY = 3
NEGX_POSY = 4

# Arranged so they can be rotated over
QUADRANTS = Int[POSX_POSY, POSX_NEGY, NEGX_NEGY, NEGX_POSY]

struct Point
    x::Int   # left is 0
    y::Int   # top is 0
    asteroid::Bool # true if asteroid is present
end

function calculate_slope(x::Int, y::Int)
    return y / x
end

function get_quadrant(x::Int, y::Int)
    if x < 0
        if y < 0
            return NEGX_NEGY
        end
        return NEGX_POSY
    end

    if y < 0
        return POSX_NEGY
    end
    return POSX_POSY
end

function is_asteroid(char::Char)
    return char == ASTEROID
end

function is_asteroid(position::Point)
    return position.asteroid
end

function manhattan_distance(point, origin_x=0, origin_y=0)
    distance = abs(origin_x - point.x) + abs(origin_y - point.y)
    return distance
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
    monitoring_location = Point(-1, -1, false)  # dummy coordinate
    # The monitoring station must be built on an existing asteroid
    asteroid_positions = filter(x -> is_asteroid(x), grid)
    for pos in asteroid_positions
        #@show pos.x, pos.y
        pos_offset_x = (width-1) - pos.x
        pos_offset_y = (height-1) - pos.y
        neg_offset_x = copysign(pos.x, -1)
        neg_offset_y = copysign(pos.y, -1)
        slopes = Dict()  # keep track of slopes where an asteroid was visible, and quadrants where asteroid was
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
                if y <= 0
                    push!(slopes[slope], NEGX_NEGY) # want to ensure (-0 y-axis) goes to quadrant 3 to avoid potential logic issues later
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
        if visible_asteroids > max_asteroids_seen
            max_asteroids_seen = visible_asteroids
            monitoring_location = pos
        end
    end

    println("Part 1 Answer:")
    @show max_asteroids_seen
    println("Location of monitoring station")
    @show monitoring_location
    return monitoring_location  # Return the location of the station to use in Part 2
end

function main2(monitoring_location::Point)
    input_file = joinpath(pwd(), "files", "12_10_input.txt")
    #input_file = joinpath(pwd(), "files", "12_10_test1.txt")    # TEST_CODE
    lines = readlines(open(input_file, "r"))
    lines = map(x -> chomp(x), lines)

    width = length(lines[1])
    height = length(lines)
    # Initialize grid with asteroids
    grid =  [Point(col, row, is_asteroid(lines[row+1][col+1])) for row in 0:height-1, col in 0:width-1]
    # The monitoring station must be built on an existing asteroid
    asteroid_positions = filter(x -> is_asteroid(x), grid)

    asteroid_info = Dict()
    slopes = Set()

    # Look at positions relative to our monitoring station (new origin point)
    for pos in asteroid_positions
        relative_x = monitoring_location.x - pos.x
        relative_y = monitoring_location.y - pos.y
        # skip position of monitoring station
        relative_x == 0 && relative_y == 0 && continue

        slope = calculate_slope(relative_x, relative_y)
        if slope == -Inf
            slope = Inf
        end

        # Add slope to set of slopes, which will be cycled over as the laser moves
        push!(slopes, slope)
        distance = manhattan_distance(monitoring_location, relative_x, relative_y)
        quadrant = get_quadrant(relative_x, relative_y)

        asteroid_info[pos] = Dict("slope" => slope, "distance" => distance, "quadrant" => quadrant)
    end

    # In order to rotate clockwise, slope goes from Inf to 0 to -Inf to -0 to repeat
    sorted_slopes = sort(collect(slopes), rev=true)
    splice!(sorted_slopes, findfirst(x->x==-0.0, sorted_slopes))    # Do not want a -0.0 and 0.0 in the array
    pop!(sorted_slopes) # Turned all -Inf into +Inf

    num_asteroids_destroyed = 0
    last_asteroid = 0
    quadrants = circshift(QUADRANTS, 1)    # Rotate away from front so first iteration will start with quadrant 1 (pos-X, pos-Y)
    for slope in Iterators.cycle(sorted_slopes)
        quadrant = quadrants[1]
        @show slope, quadrant

        # slope is current laser's path. Get all asteroids in that path
        asteroids_in_path = collect(filter(x -> asteroid_info[x]["quadrant"] == quadrant && asteroid_info[x]["slope"] == slope, keys(asteroid_info)))
        length(asteroids_in_path) > 0 || continue

        sort!(asteroids_in_path, by=x->asteroid_info[x]["distance"])
        last_asteroid = popfirst!(asteroids_in_path)

        num_asteroids_destroyed +=1
        pop!(asteroid_info, last_asteroid)
        @show slope
        @show last_asteroid
        @show num_asteroids_destroyed
        if num_asteroids_destroyed == 200
            break
        end
        if slope == 0.0 || slope == Inf
            quadrants = circshift(quadrants, -1)   # Rotate everything up an index
        end
    end

    println("Part 2 answer:")
    @show (last_asteroid.x * 100) + last_asteroid.y
end

# Find the best location for a new monitoring station.
# How many other asteroids can be detected from that location?
monitoring_location = main1()
# Win the bet by determining which asteroid that will be;
# what do you get if you multiply its X coordinate by 100 and then add its Y coordinate?
main2(monitoring_location)