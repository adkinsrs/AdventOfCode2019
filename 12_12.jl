#!/usr/bin/env julia

"""
https://adventofcode.com/2019/day/12
"""

using Combinatorics

mutable struct Point
    x::Int
    y::Int
    z::Int
end

# Though Point and Velocity share the same properties, it feels more logical to split them
mutable struct Velocity
    x::Int
    y::Int
    z::Int
end

function add!(point::Point, velo::Velocity)
    """Update positional coordinates based on velocity"""
    point.x += velo.x
    point.y += velo.y
    point.z += velo.z
end

function kinetic_energy(moon)
    return abs(moon.x) + abs(moon.y) + abs(moon.z)

end

function match_previous_state(states, moon_positions, moon_velocities)
    # Since objects in previous states are different object IDs, a simple "if state in states" will not work
    match = true

    # Break up the "states" tuples into their individual parts
    prev_moon_positions = map(x -> x[1], states)
    prev_moon_velocities = map(x -> x[2], states)
    matching_indexes = collect(1:length(prev_moon_positions))   # Keeps track of all indexes where state continues to match across criteria
    for i in 1:length(moon_positions)
        # Position and velocity for each individual moon.  Serialize the x,y,z coords into a list.
        moon_pos = to_array(moon_positions[i])
        moon_vel = to_array(moon_velocities[i])
        ith_moon_pos= map(moons -> to_array(moons[i]), prev_moon_positions)
        ith_moon_vel = map(moons -> to_array(moons[i]), prev_moon_velocities)

        # Find all indexes for the ith moon where the coordinates match the current state
        # If number of potential index matches ever hits zero, then the state is unique
        pos_matches = findall(pos -> pos == moon_pos, ith_moon_pos)
        vel_matches = findall(vel -> vel == moon_vel, ith_moon_vel)
        intersect!(matching_indexes, pos_matches, vel_matches)
        length(matching_indexes) > 0 || return false
    end
    # If all 4 moons end have matching positions and velocities with a previous state,
    # there should be a single matching index
    return match
end

function parse_coordinates(line)
    m = match(r"x=(-?\d+), y=(-?\d+), z=(-?\d+)", line)
    x = parse(Int, m.captures[1])
    y = parse(Int, m.captures[2])
    z = parse(Int, m.captures[3])
    return Point(x, y, z)
end

function potential_energy(moon)
    return abs(moon.x) + abs(moon.y) + abs(moon.z)
end

function to_array(point::Point)
    return [point.x, point.y, point.z]
end

function to_array(velo::Velocity)
    return [velo.x, velo.y, velo.z]
end

function total_energy(position, velocity)
    return potential_energy(position) * kinetic_energy(velocity)
end

function update_positions!(moon_positions, moon_velocities)
    """For each moon, velocity is added to position to give new 3D position."""
    for i in 1:length(moon_positions)
        add!(moon_positions[i], moon_velocities[i])
    end
end

function update_velocities!(moon_velocities, moon_positions)
    """ Apply gravity to each pair of moons to adjust their 3D velocity."""

    # Each pair of moons gets pulled closer to each other for each axis
    # The smaller coordinate is incremented by 1, and the larger decremented by 1
    for pair in combinations(1:length(moon_velocities), 2)
        moon1_idx = pair[1]
        moon2_idx = pair[2]
        # For each comparison, if both coords are equal no adjustment is needed
        if moon_positions[moon1_idx].x > moon_positions[moon2_idx].x
            moon_velocities[moon1_idx].x -= 1
            moon_velocities[moon2_idx].x += 1
        elseif moon_positions[moon2_idx].x > moon_positions[moon1_idx].x
            moon_velocities[moon2_idx].x -= 1
            moon_velocities[moon1_idx].x += 1
        end
        if moon_positions[moon1_idx].y > moon_positions[moon2_idx].y
            moon_velocities[moon1_idx].y -= 1
            moon_velocities[moon2_idx].y += 1
        elseif moon_positions[moon2_idx].y > moon_positions[moon1_idx].y
            moon_velocities[moon2_idx].y -= 1
            moon_velocities[moon1_idx].y += 1
        end
        if moon_positions[moon1_idx].z > moon_positions[moon2_idx].z
            moon_velocities[moon1_idx].z -= 1
            moon_velocities[moon2_idx].z += 1
        elseif moon_positions[moon2_idx].z > moon_positions[moon1_idx].z
            moon_velocities[moon2_idx].z -= 1
            moon_velocities[moon1_idx].z += 1
        end
    end
end

function main1()
    # Getting curl 400 error so downloading file beforehand
    #input_file = download("https://adventofcode.com/2019/day/1/input")
    input_file = joinpath(pwd(), "files", "12_12_input.txt")
    lines = readlines(open(input_file, "r"))
    lines = map(x -> chomp(x), lines)

    # Initial moon positions and velocities
    moon_positions = Point[]
    moon_velocities = Velocity[]
    [push!(moon_positions, parse_coordinates(line)) for line in lines]
    [push!(moon_velocities, Velocity(0,0,0)) for line in lines]

    t = 0
    while t < 1000
        # Update velocity by applying gravity
        update_velocities!(moon_velocities, moon_positions)
        # Update position by applying velocity
        update_positions!(moon_positions, moon_velocities)
        t += 1
    end

    println("Part 1 Answer:")
    total_system_energy = sum(i -> total_energy(moon_positions[i], moon_velocities[i]), 1:length(moon_positions))
    @show total_system_energy
end

function main2()
    input_file = joinpath(pwd(), "files", "12_12_input.txt")
    lines = readlines(open(input_file, "r"))
    lines = map(x -> chomp(x), lines)

    # i cheated and lookat at the Advent of Code subreddit for a hint
    # The cycle for each moon's axis can be independently determined
    # The least common multiple of all these cycles is the answer
    least_common_multiple = zeros(Int,4)

    # Initial moon positions and velocities
    moon_positions = Point[]
    moon_velocities = Velocity[]
    [push!(moon_positions, parse_coordinates(line)) for line in lines]
    [push!(moon_velocities, Velocity(0,0,0)) for line in lines]

    # Need to deepcopy as 'copy' will copy reference pointers beyond the first depth
    init_positions = deepcopy(moon_positions)
    # Initial velocity is always (0,0,0)

    t = 0
    while true
        t += 1
        # Update velocity by applying gravity
        update_velocities!(moon_velocities, moon_positions)
        # Update position by applying velocity
        update_positions!(moon_positions, moon_velocities)

        # Compare moon positions until cycle has been found
        for i in 1:length(moon_positions)
            # cycle has been found for this moon
            if least_common_multiple[i] > 0
                continue
            end
            if to_array(moon_positions[i]) == to_array(init_positions[i]) && to_array(moon_velocities[i]) == [0,0,0]
                least_common_multiple[i] = t
            end
        end

        # Exit from loop once all four moons have had their cycles computed
        if !any(x -> x == 0, least_common_multiple)
            break
        end
    end
    @show least_common_multiple

    answer = reduce(lcm, least_common_multiple)

    println("Part 2 Answer:")
    @show answer
end

# What is the total energy in the system after simulating the moons given in your scan for 1000 steps?
main1()
# How many steps does it take to reach the first state that exactly matches a previous state?
main2()