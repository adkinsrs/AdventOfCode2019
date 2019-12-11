# Functions related to the intcode computer

module Intcode
export process_intcode

POSITION_MODE = 0   # Parameter is a memory address
# Read - value = mem[pos]
# Write - mem[pos] = values
IMMEDIATE_MODE = 1  # Parameters is the value itself
# Read - value = pos
# Write - NA
RELATIVE_MODE = 2   # Parameter's memory address is adjusted based on a stored relative base
# Read - value = mem[pos + base]
# Write - mem[pos + base] = value

function determine_values(positions, window, modes, relative_base)
    """Returns list of values, depending on mode for the particular parameter."""
    normalize_modes!(modes, window)
    values = Int[]
    for i in 1:length(window)
        if modes[i] == POSITION_MODE
            grow_memory!(positions, window[i]+1)
            push!(values, positions[window[i]+1])
        elseif modes[i] == RELATIVE_MODE
            relative_position = window[i] + relative_base
            grow_memory!(positions, relative_position+1)
            push!(values, positions[relative_position+1])
        else
            # Immediate mode pushes value directly
            push!(values, window[i])
        end
    end
    return values
end

function determine_write_position(index, mode, relative_base)
    """Determine index to write to, between position mode and relative mode."""
    if mode == RELATIVE_MODE
        return index + relative_base
    end
    return index
end

function grow_memory!(positions, index)
    """If current index is out of bounds, grow memory addresses."""
    if index > length(positions)
        num_to_grow  = index - length(positions)
        for i in 1:num_to_grow
            push!(positions, zero(Int))
        end
    end
end

function normalize_modes!(modes, window)
    """If modes array is smaller than the windows, add the implied 0 modes."""
    while length(modes) < length(window)
        push!(modes, POSITION_MODE)
    end
end

function process_intcode(positions, input, curr_idx=1; return4=false)
    """Loop through intcode instructions, resolving any opcodes encountered."""
    #TODO: eventually use the OffsetArrays package to 0-index the positions array to be accurate with
    # memory address positions read in from the intcode
    relative_base = 0
    while curr_idx <= length(positions)
        # First param is instructions
        instructions = positions[curr_idx]
        # Last two digits in the instructions code is the opcode
        opcode = mod(instructions, 100)
        # Divide to remove the opcode, the store individual digits right-to-left in array
        modes = digits(div(instructions, 100))

        @show positions[curr_idx:curr_idx+3]

        # Handle the various opcodes
        if opcode == 1
            try
                window = positions[curr_idx+1:curr_idx+3]
            catch BoundsError
                error("Whoops! Program went to far.  Opcode 1 or 2 should not be this close to the end.")
            end
            opcode_1!(positions, window, modes, relative_base)
            curr_idx += 4
        elseif opcode == 2
            try
                window = positions[curr_idx+1:curr_idx+3]
            catch BoundsError
                error("Whoops! Program went to far.  Opcode 1 or 2 should not be this close to the end.")
            end
            opcode_2!(positions, window, modes, relative_base)
            curr_idx += 4
        elseif opcode == 3
            window = positions[curr_idx+1]
            opcode_3!(positions, window, modes, relative_base, input)
            curr_idx += 2
        elseif opcode == 4
            window = positions[curr_idx+1]
            input = opcode_4(positions, window, modes, relative_base)
            curr_idx += 2
            return4 && return (input, curr_idx)
        elseif opcode == 5
            try
                window = positions[curr_idx+1:curr_idx+2]
            catch BoundsError
                error("Whoops! Program went to far.  Opcode 5 or 6 should not be this close to the end.")
            end
            curr_idx = opcode_5(positions, window, modes, relative_base, curr_idx)
        elseif opcode == 6
            try
                window = positions[curr_idx+1:curr_idx+2]
            catch BoundsError
                error("Whoops! Program went to far.  Opcode 5 or 6 should not be this close to the end.")
            end
            curr_idx = opcode_6(positions, window, modes, relative_base, curr_idx)
        elseif opcode == 7
            try
                window = positions[curr_idx+1:curr_idx+3]
            catch BoundsError
                error("Whoops! Program went to far.  Opcode 7 or 8 should not be this close to the end.")
            end
            opcode_7(positions, window, modes, relative_base)
            curr_idx += 4
        elseif opcode == 8
            try
                window = positions[curr_idx+1:curr_idx+3]
            catch BoundsError
                error("Whoops! Program went to far.  Opcode 7 or 8 should not be this close to the end.")
            end
            opcode_8(positions, window, modes, relative_base)
            curr_idx += 4
        elseif opcode == 9
            try
                window = positions[curr_idx+1]
            catch BoundsError
                error("Whoops! Program went to far.  Opcode 9 should not be this close to the end.")
            end
            relative_base = opcode_9(positions, window, modes, relative_base)
            curr_idx += 2
        elseif opcode == 99
            return input, curr_idx
            #return opcode_99(positions)
        end
    end
end

function opcode_1!(positions, window, modes, relative_base)
    """Add first two parameters, write result to third."""
    values = determine_values(positions, window, modes, relative_base)
    write_index = determine_write_position(window[3], modes[3], relative_base)
    # Windows 2, 3, and 4 are memory address positions
    total = values[1] + values[2]
    grow_memory!(positions, write_index+1)
    positions[write_index+1] = total
end

function opcode_2!(positions, window, modes, relative_base)
    """Multiply first two parameters, write result to third."""
    values = determine_values(positions, window, modes, relative_base)
    write_index = determine_write_position(window[3], modes[3], relative_base)
    total = values[1] * values[2]
    grow_memory!(positions, write_index+1)
    positions[write_index+1] = total
end

function opcode_3!(positions, window, modes, relative_base, input)
    """Write input parameter to first intcode parameter read."""
    # parameters that write to a position will never be in "immediate mode"
    write_index = determine_write_position(window[1], modes[1], relative_base)
    grow_memory!(positions, write_index+1)
    positions[write_index+1] = input
end

function opcode_4(positions, window, modes, relative_base)
    """Return first intcode parameter."""
    values = determine_values(positions, window, modes, relative_base)
    return values[1]
end

function opcode_5(positions, window, modes, relative_base, idx)
    """Jump index to second parameter's position if first parameter is not zero."""
    values = determine_values(positions, window, modes, relative_base)
    # Since Julia is 1-based indexing, need to increment index by 1 if it references an address
    # If returning original index, increment over the window so "opcode does nothing"
    return (iszero(values[1]) ? idx+3 : values[2]+1)
end

function opcode_6(positions, window, modes, relative_base, idx)
    """Jump index to second parameter's position if first parameter is zero."""
    values = determine_values(positions, window, modes, relative_base)
    return (iszero(values[1]) ? values[2]+1 : idx+3)
end

function opcode_7(positions, window, modes, relative_base)
    """Write 1 to third parameter if first parameter is less than second, otherwise write zero."""
    values = determine_values(positions, window, modes, relative_base)
    write_index = determine_write_position(window[3], modes[3], relative_base)
    grow_memory!(positions, write_index+1)
    positions[write_index+1] = (values[1] < values[2] ? 1 : 0)
end

function opcode_8(positions, window, modes, relative_base)
    """Write 1 to third parameter if first parameter is equal to second, otherwise write zero."""
    values = determine_values(positions, window, modes, relative_base)
    write_index = determine_write_position(window[3], modes[3], relative_base)
    grow_memory!(positions, write_index+1)
    positions[write_index+1] = (values[1] == values[2] ? 1 : 0)
end

function opcode_9(positions, window, modes, relative_base)
    """Adjusts relative base by the value of the first parameter."""
    values = determine_values(positions, window, modes, relative_base)
    return relative_base + values[1]
end

function opcode_99(positions)
    """Halt program."""
    return positions[1]
end

end