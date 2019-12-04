#!/usr/bin/env julia

"""
I don't feel like copy/pasting the whole set of instructions here, since it makes the code feel bloated.
Instead of I will just link to the puzzle's URL, like so:

https://adventofcode.com/2019/day/3
"""

function calc_manhattan_distance(point)
    origin_x = 0
    origin_y = 0
    distance = abs(origin_x - point.x) + abs(origin_y - point.y)
    return distance
end

function calc_min_manhattan_distance(intersections)
    # 'min' processes arguments, 'minimum' processes in iterative function
    return minimum(map(x -> calc_manhattan_distance(x), intersections))
end

function calc_num_steps(coords1, coords2, x, y, ind1, ind2)
    # 'x' and 'y' are the coordinates of the intersection found
    # ind1 is the last coord-1 position index before the intersection
    # ind2 is the same index for coord-2 array
    if ind1==5 && ind2==4
    @show x
    @show y
    @show coords1[ind1-1]
    @show coords2[ind2-1]
    @show coords1[ind1]
    @show coords2[ind2]
    end

    total_x = coords1[1].x
    total_y = coords1[1].y
    total_u = coords2[1].x
    total_v = coords2[1].y

    for i in 1:ind1-1
        x1 = coords1[i].x
        x2 = coords1[i+1].x
        y1 = coords1[i].y
        y2 = coords1[i+1].y

        # Could have parsed the directions array instead of getting the 'delta' of coordinate points
        # but would still have needed to coordinate point before the intersection
        total_x += abs(x2 - x1)
        total_y += abs(y2 - y1)
    end

    total_x += abs(x - coords1[ind1].x)
    total_y += abs(y - coords1[ind1].y)

    for j in 1:ind2-1
        u1 = coords2[j].x
        u2 = coords2[j+1].x
        v1 = coords2[j].y
        v2 = coords2[j+1].y

        total_u += abs(u2 - u1)
        total_v += abs(v2 - v1)
    end

    total_u += abs(x - coords2[ind2].x)
    total_v += abs(y - coords2[ind2].y)

    total_steps = total_u + total_v + total_x + total_y
    return total_steps
end

function create_coordinates_from_directions(directions)
    coords = [(x=0, y=0)]
    for dir in directions
        if dir[1] == 'U'
            push!(coords, move_up(coords[end], dir))
        elseif dir[1] == 'D'
            push!(coords, move_down(coords[end], dir))
        elseif dir[1] == 'L'
            push!(coords, move_left(coords[end], dir))
        else    # is R
            push!(coords, move_right(coords[end], dir))
        end
    end
    return coords
end

function find_intersections(coords1, coords2)
    intersection_points = NamedTuple{(:x, :y),Tuple{Int,Int}}[]
    for i in 1:length(coords1)-1, j in 1:length(coords2)-1
        # Collect two sets of coords for each set
        x1 = min(coords1[i].x, coords1[i+1].x)
        x2 = max(coords1[i].x, coords1[i+1].x)
        y1 = min(coords1[i].y, coords1[i+1].y)
        y2 = max(coords1[i].y, coords1[i+1].y)

        u1 = min(coords2[j].x, coords2[j+1].x)
        u2 = max(coords2[j].x, coords2[j+1].x)
        v1 = min(coords2[j].y, coords2[j+1].y)
        v2 = max(coords2[j].y, coords2[j+1].y)

        # After every movement, one axis will be unchanged
        # For an intersection, the other coord set's opposite axis will be unchanged
        if x1 == x2
            # Movement of coordinate 1 was vertical
            # ...so coordinate 2 needs to be horizontal
            if v1 == v2
                if u1 <= x1 <= u2 && y1 <= v1 <= y2
                    push!(intersection_points, (x=x1, y=v1))
                end
            end
        elseif y1 == y2
            # Movement of coordinate 1 was horizontal
            # ...so coordinate 2 needs to be vertical
            if u1 == u2
                if v1 <= y1 <= v2 && x1 <= u1 <= x2
                    push!(intersection_points, (x=u1, y=y1))
                end
            end
        end

    end
    return intersection_points
end

function find_min_num_steps_to_intersections(coords1, coords2)
    min_num_steps = Inf # Start at Infinty

    for i in 1:length(coords1)-1, j in 1:length(coords2)-1
        # Collect two sets of coords for each set
        x1 = min(coords1[i].x, coords1[i+1].x)
        x2 = max(coords1[i].x, coords1[i+1].x)
        y1 = min(coords1[i].y, coords1[i+1].y)
        y2 = max(coords1[i].y, coords1[i+1].y)

        u1 = min(coords2[j].x, coords2[j+1].x)
        u2 = max(coords2[j].x, coords2[j+1].x)
        v1 = min(coords2[j].y, coords2[j+1].y)
        v2 = max(coords2[j].y, coords2[j+1].y)


        # After every movement, one axis will be unchanged
        # For an intersection, the other coord set's opposite axis will be unchanged
        if x1 == x2
            # Movement of coordinate 1 was vertical
            # ...so coordinate 2 needs to be horizontal
            if v1 == v2
                if u1 <= x1 <= u2 && y1 <= v1 <= y2
                    num_steps = calc_num_steps(coords1, coords2, x1, v1, i, j)
                    min_num_steps = min(min_num_steps, num_steps)
                end
            end
        elseif y1 == y2
            # Movement of coordinate 1 was horizontal
            # ...so coordinate 2 needs to be vertical
            if u1 == u2
                if v1 <= y1 <= v2 && x1 <= u1 <= x2
                    num_steps = calc_num_steps(coords1, coords2, u1, y1, i, j)
                    min_num_steps = min(min_num_steps, num_steps)
                end
            end
        end

    end
    return min_num_steps
end

function move_down(coordinate, dir)
    num_steps = parse(Int, dir[2:end])
    return (x=coordinate.x, y=coordinate.y - num_steps)
end

function move_left(coordinate, dir)
    num_steps = parse(Int, dir[2:end])
    return (x=coordinate.x - num_steps, y=coordinate.y)
end

function move_right(coordinate, dir)
    num_steps = parse(Int, dir[2:end])
    return (x=coordinate.x + num_steps, y=coordinate.y)
end

function move_up(coordinate, dir)
    num_steps = parse(Int, dir[2:end])
    return (x=coordinate.x, y=coordinate.y + num_steps)
end

function parse_line(line)
    line = chomp(line)  # Knew julia had 'strip' but didn't know it had 'chomp' as well :-)
    return split(line, ",")
end

function main1()
    input_file = joinpath(pwd(), "files", "12_3_input.txt")
    lines = readlines(open(input_file, "r"))
    directions1 = parse_line(lines[1])
    directions2 = parse_line(lines[2])

    # Test cases
    #directions1 = parse_line("R75,D30,R83,U83,L12,D49,R71,U7,L72")
    #directions2 = parse_line("U62,R66,U55,R34,D71,R55,D58,R83")

    # Array of named tuples
    # Coordinates will be based on current position after processing a direction
    coords1 = create_coordinates_from_directions(directions1)
    coords2 = create_coordinates_from_directions(directions2)

    intersection_points = find_intersections(coords1, coords2)

    min_distance = calc_min_manhattan_distance(intersection_points)

    println("Part 1 answer:")
    @show min_distance
end

function main2()
    input_file = joinpath(pwd(), "files", "12_3_input.txt")
    lines = readlines(open(input_file, "r"))
    directions1 = parse_line(lines[1])
    directions2 = parse_line(lines[2])

    # Test cases
    #directions1 = parse_line("R75,D30,R83,U83,L12,D49,R71,U7,L72")
    #directions2 = parse_line("U62,R66,U55,R34,D71,R55,D58,R83")
    #directions1 = parse_line("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51")
    #directions2 = parse_line("U98,R91,D20,R16,D67,R40,U7,R15,U6,R7")

    # Array of named tuples
    # Coordinates will be based on current position after processing a direction
    coords1 = create_coordinates_from_directions(directions1)
    coords2 = create_coordinates_from_directions(directions2)

    min_num_steps = find_min_num_steps_to_intersections(coords1, coords2)

    println("Part 2 answer:")
    @show min_num_steps
end

main1()
main2()