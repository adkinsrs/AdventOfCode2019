#!/usr/bin/env julia

"""
https://adventofcode.com/2019/day/11
"""

# Since it's a local module, it must be found with 'include' first
include("Intcode.jl")
using .Intcode

# colors to paint the panels
BLACK = 0
WHITE = 1

# Which direction to rotate the robot
TURN_LEFT = 0
TURN_RIGHT = 1

UP = 1
RIGHT = 2
DOWN = 3
LEFT = 4

mutable struct Point
    x::Int   # left is 0
    y::Int   # top is 0
end

function direction_after_turn(curr_direction, turn)
    """After turning the robot, return new direction robot is facing."""
    curr_direction == UP && turn == TURN_LEFT && return LEFT
    curr_direction == UP && turn == TURN_RIGHT && return RIGHT
    curr_direction == RIGHT && turn == TURN_LEFT && return UP
    curr_direction == RIGHT && turn == TURN_RIGHT && return DOWN
    curr_direction == DOWN && turn == TURN_LEFT && return RIGHT
    curr_direction == DOWN && turn == TURN_RIGHT && return LEFT
    curr_direction == LEFT && turn == TURN_LEFT && return DOWN
    curr_direction == LEFT && turn == TURN_RIGHT && return UP
end

function move(panel::String, direction)
    """Move a space in the given direction.  Create new Point."""
    point = string_to_point(panel)
    x = point.x
    y = point.y
    if direction == UP
        return Point(x, y+1)
    elseif direction == RIGHT
        return Point(x+1, y)
    elseif direction == DOWN
        return Point(x, y-1)
    elseif direction == LEFT
        return Point(x-1, y)
    else
        error("Invalid move direction")
    end
end

function point_to_string(point::Point)
    return string(point.x, "_", point.y)
end

function string_to_point(panel_string::String)
    coords = split(panel_string, "_")
    int_coords = map(x -> parse(Int, x), coords)
    x = int_coords[1]
    y = int_coords[2]
    return Point(x, y)
end

function main1()
    input_file = joinpath(pwd(), "files", "12_11_input.txt")
    input = read(open(input_file, "r"), String)
    intcode = chomp(input)
    str_positions = split(intcode, ",")
    positions = map(x -> parse(Int, x), str_positions)
    orig_positions = copy(positions)

    panels = Dict{String, Int}()
    # Having issues with points creating duplicate keys due to separate object ids
    starting_point = Point(0,0)
    current_panel = point_to_string(starting_point)
    panels[current_panel] = BLACK      # All panels, initially black.
    panels_painted = Set{String}()  # Keep track of coordinates seen

    intcode_idx = 1
    current_direction = UP
    steps = 0
    # Two outputs
    # 1) color to paint current panel
    # 2) which direction to turn robot (always move forward 1-space afterwards)
    #while intcode_idx != -1
    while steps < 20
        panel_color = panels[current_panel]
        # Determine what color to paint the panel
        panels[current_panel], intcode_idx = process_intcode(positions, panel_color, intcode_idx, return4=true)
        @show panels[current_panel], intcode_idx
        # Store how many panels have been painted over at least once
        push!(panels_painted, current_panel)

        # Determine which direction to rotate the robot in
        turn_direction, intcode_idx = process_intcode(positions, panel_color, intcode_idx; return4=true)
        # Move the robot based on the current direction its facing
        current_direction = direction_after_turn(current_direction, turn_direction)
        @show turn_direction, intcode_idx, current_direction
        current_point = move(current_panel, current_direction)
        current_panel = point_to_string(current_point)
        @show current_panel
        get!(panels, current_panel, BLACK)  # Return new point or assign it to black
        steps +=1
        @show ""
    end
    @show panels

    println("Part 1 Answer:")
    @show length(collect(panels_painted))
end

function main2()
    nothing
end

# Build a new emergency hull painting robot and run the Intcode program on it.
# How many panels does it paint at least once?
main1()
main2()