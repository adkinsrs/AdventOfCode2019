# The purpose of this module is to house reusable code pieces.  If I performed a process many times in the past, there is a good chance it will be included here

module Common
export process_intcode

POSITION_MODE = 0   # Parameter is a memory address
IMMEDIATE_MODE = 1  # Parameters is the value itself
RELATIVE_MODE = 2   # Parameter's memory address is adjusted based on a stored relative base

function determine_values(positions, window, modes, relative_base)
    """Returns list of values, depending on mode for the particular parameter."""
    normalize_modes!(modes, window)
    values = Int[]
    for i in 1:length(window)
        if modes[i] == POSITION_MODE
            push!(values, positions[window[i]+1])
        elseif modes[i] == RELATIVE_MODE
            relative_position = window[i] + relative_base
            push!(values, positions[relative_position+1])
        else
            # Immediate mode pushes value directly
            push!(values, window[i])
        end
    end
    return values
end

function normalize_modes!(modes, window)
    """If modes array is smaller than the windows, add the implied 0 modes."""
    while length(modes) < length(window)
        push!(modes, POSITION_MODE)
    end
end

function process_intcode(positions, inputs, curr_idx=1; save4=false)
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
            stored_value = popfirst!(inputs)
            opcode_3!(positions, window, modes, relative_base, stored_value)
            curr_idx += 2
        elseif opcode == 4
            window = positions[curr_idx+1]
            stored_value = opcode_4(positions, window, modes, relative_base)
            curr_idx += 2
            # "save4" indicates to return values from opcode 4 instead of opcode 99
            if save4
                return stored_value, curr_idx
            end
            push!(inputs, stored_value)
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
            window = positions[curr_idx+1]
            relative_base = opcode_9(positions, window, modes, relative_base)
            curr_idx += 2
        elseif opcode == 99
            # "save4" indicates to return values from opcode 4 instead of opcode 99
            if save4
                return "done", curr_idx
            end
            return popfirst!(inputs)
        end
    end
end

function opcode_1!(positions, window, modes, relative_base)
    """Add first two parameters, write result to third."""
    values = determine_values(positions, window, modes, relative_base)
    # Windows 2, 3, and 4 are memory address positions
    total = values[1] + values[2]
    positions[window[3]+1] = total
end

function opcode_2!(positions, window, modes, relative_base)
    """Multiply first two parameters, write result to third."""
    values = determine_values(positions, window, modes, relative_base)
    total = values[1] * values[2]
    positions[window[3]+1] = total
end

function opcode_3!(positions, window, modes, relative_base, input)
    """Write input parameter to first intcode parameter read."""
    # parameters that write to a position will never be in "immediate mode"
    positions[window[1]+1] = input
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
    """Write 1 if first parameter is less than second, otherwise write zero."""
    values = determine_values(positions, window, modes, relative_base)
    positions[window[3]+1] = (values[1] < values[2] ? 1 : 0)
end

function opcode_8(positions, window, modes, relative_base)
    """Write 1 if first parameter is equal to second, otherwise write zero."""
    values = determine_values(positions, window, modes, relative_base)
    positions[window[3]+1] = (values[1] == values[2] ? 1 : 0)
end

function opcode_9(positions, window, modes, relative_base)
    """Adjusts relative base by the value of the first parameter."""
    return relative_base + values[1]
end

function opcode_99(positions)
    """Halt program."""
    return positions[1]
end

end