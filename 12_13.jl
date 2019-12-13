#!/usr/bin/env julia

# Since it's a local module, it must be found with 'include' first
include("Intcode.jl")
using .Intcode

# Tile IDs
EMPTY = 0   # No game object appears at the position
WALL = 1    # Indestructable barriers
BLOCK = 2   # Can be broken by the ball
H_PADDLE = 3    # Horizontal paddle tile. Indestructable.
BALL = 4    # Moves diagonally and bounces off objects

function draw_board!(grid)
    """Draw a colorized game board.  I just did this for fun."""
    height = size(grid)[1]
    width = size(grid)[2]
    for i in 1:height
        row = join(grid[i,1:width], "")
        # color the individual characters to view the message
        for char in row
            # For some reason, I need to explicitly use the number instead of the constant
            char == '0' && printstyled(".", color=:black)
            char == '1' && printstyled("#", bold=true, color=:red)
            char == '2' && printstyled("*", bold=true, color=:blue)
            char == '3' && printstyled("_", bold=true, color=:green)
            char == '4' && printstyled("o", bold=true, color=:white)
        end
        print("\n")
    end
    print("\n")
end

function draw_tile(ic, input=nothing)
    """Run the intcode computer three times to get the x, y, and id of the new tile."""
    tile_array = Int[]
    for i in 1:3
        output, intcode_idx, relative_base = process_intcode(ic)
        # Update computer with current state
        update_computer!(ic, intcode_idx, input, relative_base)
        # Caught halt signal in middle of creating tuple
        if intcode_idx == -1
            return nothing
        end
        push!(tile_array, output)
    end
    # Return a NamedTuple
    # Since julia is 1-indexed, increment coords by 1 to make easier to store on grid
    return (x = tile_array[1]+1, y = tile_array[2]+1, id = tile_array[3])
end

function grow_grid(grid, tile)
    """Extend the grid with empty tiles if necessary."""
    if tile.x > size(grid)[2]
        # Grow horizontally
        num_to_grow  = tile.x - size(grid)[2]
        grid = hcat(grid, zeros(Int, (size(grid)[1], num_to_grow)))
    end
    if tile.y > size(grid)[1]
        # grow vertically
        num_to_grow = tile.y - size(grid)[1]
        grid = vcat(grid, zeros(Int, (num_to_grow, size(grid)[2])))
    end

    # 'hcat' and 'vcat' do not have inplace functions
    return grid
end

function move_joystick!(grid)
        # Determine input for next go-round based on which way the joystick was moved
        input = 0
        paddle_position = findfirst(x -> x==H_PADDLE, grid) # Only need x position
        paddle_position == nothing && return 0
        paddle_y = paddle_position[1]
        paddle_x = paddle_position[2]
        ball_position = findfirst(x -> x==BALL, grid)
        ball_position == nothing && return 0
        ball_y = paddle_position[1]
        ball_x = paddle_position[2]
        if paddle_x > ball_x
            input = -1  # Need to move to the left
        elseif paddle_x < ball_x
            input = 1   # Need to move paddle to the right
        end
        # Move the paddle
        grid[paddle_y, paddle_x] = EMPTY
        grid[paddle_y, paddle_x+input] = H_PADDLE
        return input
end

function update_grid!(grid, ic::IntcodeComputer, current_score=0)
    while ic.curr_idx != -1
        # A little reddit help... move paddle during drawing to have it align with the bal
        initial_input = move_joystick!(grid)
        tile = draw_tile(ic, initial_input)
        # This will occur if intcode halted in middle of creating 3-part tuple
        if ic.curr_idx == -1
            break
        end

        # Periodically update score
        if tile.x == 0 && tile.y == 1
            current_score = tile.id
            continue
        end

        # Grow if tile coordinate is beyond the current grid
        grid = grow_grid(grid, tile)

        # Do not replace indestructable objects
        grid[tile.y, tile.x] in [WALL, H_PADDLE] && continue
        
        grid[tile.y, tile.x] = tile.id
    end
    return grid, current_score
end

function main1()
    input_file = joinpath(pwd(), "input.txt")
    input = read(open(input_file, "r"), String)
    intcode = chomp(input)
    str_positions = split(intcode, ",")
    positions = map(x -> parse(Int, x), str_positions)

    # Initialize empty grid
    grid = zeros(Int, (1,1))
    ic = IntcodeComputer(copy(positions))
    grid, current_score = update_grid!(grid, ic)

    #@show grid
    println("Part 1 Answer:")
    num_blocks = count(x -> x==BLOCK, grid)
    @show num_blocks
end

function main2()
    # LETS PLAY SOME BREAKOUT!
    input_file = joinpath(pwd(), "input.txt")
    input = read(open(input_file, "r"), String)
    intcode = chomp(input)
    str_positions = split(intcode, ",")
    positions = map(x -> parse(Int, x), str_positions)

    # Insert some quarters   
    num_quarters = 2
    positions[1] = num_quarters

    # Initialize grid
    current_score = 0   # Score updated when tile is x=-1,y=0 (add 1 for julia indexing)

    grid = zeros(Int, (1,1))
    ic = IntcodeComputer(copy(positions))
    grid, current_score = update_grid!(grid, ic, current_score)

    draw_board!(grid)

    num_blocks = count(x -> x==BLOCK, grid)

    # Keep playing until all the blocks are removed
    while num_blocks > 0
        update_computer!(ic)
        grid, current_score = update_grid!(grid, ic, current_score)

        # Update how many blocks are left
        num_blocks = count(x -> x==BLOCK, grid)
        #draw_board!(grid)
        #@show num_blocks
        #@show current_score
    end

    println("Part 2 answer:")
    @show current_score
end

# Start the game. How many block tiles are on the screen when the game exits?
main1()
# Beat the game by breaking all the blocks. What is your score after the last block is broken?
main2()