# Functions related to the intcode computer

module Intcode
export process_intcode, IntcodeComputer, update_computer!

# Computer that processes intcode strings and stores key information inside
mutable struct IntcodeComputer
    positions::Array{Int}   # Current state of the intcode string
    curr_idx::Int   # Current index for next read position
    input  # Currently stored input (or output from last stored value).  Can also be 'nothing'
    relative_base::Int  # Current relative base modifier
end

IntcodeComputer(positions::Array{Int}) = IntcodeComputer(positions, 1, nothing, 0)
IntcodeComputer(positions::Array{Int}, input) = IntcodeComputer(positions, 1, input, 0)

function update_computer!(ic::IntcodeComputer, curr_idx=1, input=nothing, relative_base=0)
    """Update the state of the current computer."""
    ic.curr_idx = curr_idx
    ic.input = input
    ic.relative_base = relative_base
end

POSITION_MODE = 0   # Parameter is a memory address
# Read - value = mem[pos]
# Write - mem[pos] = values
IMMEDIATE_MODE = 1  # Parameters is the value itself
# Read - value = pos
# Write - NA
RELATIVE_MODE = 2   # Parameter's memory address is adjusted based on a stored relative base
# Read - value = mem[pos + base]
# Write - mem[pos + base] = value

function determine_read_value(positions, parameter::Int, mode::Int, relative_base::Int)
    """Returns list of values, depending on mode for the particular parameter."""
    if mode == POSITION_MODE
        grow_memory!(positions, parameter+1)
        return positions[parameter+1]
    elseif mode == RELATIVE_MODE
        relative_position = parameter + relative_base
        grow_memory!(positions, relative_position+1)
        return positions[relative_position+1]
    elseif mode == IMMEDIATE_MODE
        return parameter
    end
    error("Invalid mode found in reading!")
end

function determine_write_index(index::Int, mode::Int, relative_base::Int)
    """Determine index to write to, between position mode and relative mode."""
    if mode == RELATIVE_MODE
        return index + relative_base
    elseif mode == POSITION_MODE
        return index
    end

    if mode == IMMEDIATE_MODE
        error("Cannot use Immediate Mode for writing to a memory address")
    end
    error("Invalid mode found in writing!")
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

function process_intcode(ic::IntcodeComputer)
    return process_intcode(ic.positions, ic.input, ic.curr_idx, ic.relative_base)
end

function process_intcode(positions, input=nothing, curr_idx=1, relative_base=0)
    """Loop through intcode instructions, resolving any opcodes encountered."""
    #TODO: eventually use the OffsetArrays package to 0-index the positions array to be accurate with
    # memory address positions read in from the intcode
    while curr_idx <= length(positions)
        # First param is instructions
        instructions = positions[curr_idx]
        # Last two digits in the instructions code is the opcode
        opcode = mod(instructions, 100)
        # Divide to remove the opcode, the store individual digits right-to-left in array
        modes = digits(div(instructions, 100))

        #@show curr_idx, relative_base, input, instructions
        #@show positions

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
            return (input, curr_idx, relative_base)
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
            return (input, -1, -1)
            #return opcode_99(positions)
        end
    end
    error("Read past the intcode string!")
end

function opcode_1!(positions, window, modes, relative_base)
    """Add first two parameters, write result to third."""
    normalize_modes!(modes, window)
    value1 = determine_read_value(positions, window[1], modes[1], relative_base)
    value2 = determine_read_value(positions, window[2], modes[2], relative_base)
    write_index = determine_write_index(window[3], modes[3], relative_base)
    # Windows 2, 3, and 4 are memory address positions
    total = value1 + value2
    grow_memory!(positions, write_index+1)
    positions[write_index+1] = total
end

function opcode_2!(positions, window, modes, relative_base)
    """Multiply first two parameters, write result to third."""
    normalize_modes!(modes, window)
    value1 = determine_read_value(positions, window[1], modes[1], relative_base)
    value2 = determine_read_value(positions, window[2], modes[2], relative_base)
    write_index = determine_write_index(window[3], modes[3], relative_base)
    total = value1 * value2
    grow_memory!(positions, write_index+1)
    positions[write_index+1] = total
end

function opcode_3!(positions, window, modes, relative_base, input)
    """Write input parameter to first intcode parameter read."""
    # parameters that write to a position will never be in "immediate mode"
    normalize_modes!(modes, window)
    write_index = determine_write_index(window[1], modes[1], relative_base)
    grow_memory!(positions, write_index+1)
    positions[write_index+1] = input
end

function opcode_4(positions, window, modes, relative_base)
    """Return first intcode parameter."""
    normalize_modes!(modes, window)
    value = determine_read_value(positions, window[1], modes[1], relative_base)
    return value
end

function opcode_5(positions, window, modes, relative_base, idx)
    """Jump index to second parameter's position if first parameter is not zero."""
    normalize_modes!(modes, window)
    value1 = determine_read_value(positions, window[1], modes[1], relative_base)
    value2 = determine_read_value(positions, window[2], modes[2], relative_base)
    # If returning original index, increment over the window so "opcode does nothing"
    return (iszero(value1) ? idx+3 : value2+1)
end

function opcode_6(positions, window, modes, relative_base, idx)
    """Jump index to second parameter's position if first parameter is zero."""
    normalize_modes!(modes, window)
    value1 = determine_read_value(positions, window[1], modes[1], relative_base)
    value2 = determine_read_value(positions, window[2], modes[2], relative_base)
    return (iszero(value1) ? value2+1 : idx+3)
end

function opcode_7(positions, window, modes, relative_base)
    """Write 1 to third parameter if first parameter is less than second, otherwise write zero."""
    normalize_modes!(modes, window)
    value1 = determine_read_value(positions, window[1], modes[1], relative_base)
    value2 = determine_read_value(positions, window[2], modes[2], relative_base)
    write_index = determine_write_index(window[3], modes[3], relative_base)
    grow_memory!(positions, write_index+1)
    positions[write_index+1] = (value1 < value2 ? 1 : 0)
end

function opcode_8(positions, window, modes, relative_base)
    """Write 1 to third parameter if first parameter is equal to second, otherwise write zero."""
    normalize_modes!(modes, window)
    value1 = determine_read_value(positions, window[1], modes[1], relative_base)
    value2 = determine_read_value(positions, window[2], modes[2], relative_base)
    write_index = determine_write_index(window[3], modes[3], relative_base)
    grow_memory!(positions, write_index+1)
    positions[write_index+1] = (value1 == value2 ? 1 : 0)
end

function opcode_9(positions, window, modes, relative_base)
    """Adjusts relative base by the value of the first parameter."""
    normalize_modes!(modes, window)
    value = determine_read_value(positions, window[1], modes[1], relative_base)
    return relative_base + value
end

function opcode_99(positions)
    """Halt program."""
    ### NOT USED ANYMORE
    return positions[1]
end

end