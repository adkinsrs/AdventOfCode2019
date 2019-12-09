#!/usr/bin/env julia

"""
https://adventofcode.com/2019/day/7
"""

# So I finished part 1 and was working on part 2, but forgot to add my files before I did a Git commit.
# Now I'm rewriting this whole thing. :-(

using Combinatorics

mutable struct Amplifier
    positions::Array{Int}
    phase::Int
    curr_idx::Int
    inputs::Array{Int}
end

Amplifier(positions::Array{Int}, phase::Int) = Amplifier(positions, phase, 1, Int[phase])

POSITION_MODE = 0   # Parameter is a memory address
IMMEDIATE_MODE = 1  # Parameters is the value itself

function determine_values(positions, window, modes)
    values = Int[]
    for i in 1:length(window)
        if modes[i] == POSITION_MODE
            push!(values, positions[window[i]+1])
        else
            # Immediate mode pushes value directly
            push!(values, window[i])
        end
    end
    return values
end

function normalize_modes!(modes, window)
    # If modes array is smaller than the windows, add the implied 0 modes
    while length(modes) < length(window)
        push!(modes, POSITION_MODE)
    end
end

function process_intcode(amp::Amplifier; save4=false)
    return process_intcode(amp.positions, amp.inputs, amp.curr_idx; save4=save4)
end

function process_intcode(positions, inputs, curr_idx=1; save4=false)
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
            normalize_modes!(modes, window)
            resolve_opcode_1!(positions, window, modes)
            curr_idx += 4
        elseif opcode == 2
            try
                window = positions[curr_idx+1:curr_idx+3]
            catch BoundsError
                error("Whoops! Program went to far.  Opcode 1 or 2 should not be this close to the end.")
            end
            normalize_modes!(modes, window)
            resolve_opcode_2!(positions, window, modes)
            curr_idx += 4
        elseif opcode == 3
            window = positions[curr_idx+1]
            normalize_modes!(modes, window)
            stored_value = popfirst!(inputs)
            resolve_opcode_3!(positions, window, modes, stored_value)
            curr_idx += 2
        elseif opcode == 4
            window = positions[curr_idx+1]
            normalize_modes!(modes, window)
            stored_value = resolve_opcode_4(positions, window, modes)
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
            normalize_modes!(modes, window)
            curr_idx = resolve_opcode_5(positions, window, modes, curr_idx)
        elseif opcode == 6
            try
                window = positions[curr_idx+1:curr_idx+2]
            catch BoundsError
                error("Whoops! Program went to far.  Opcode 5 or 6 should not be this close to the end.")
            end
            normalize_modes!(modes, window)
            curr_idx = resolve_opcode_6(positions, window, modes, curr_idx)
        elseif opcode == 7
            try
                window = positions[curr_idx+1:curr_idx+3]
            catch BoundsError
                error("Whoops! Program went to far.  Opcode 7 or 8 should not be this close to the end.")
            end
            normalize_modes!(modes, window)
            resolve_opcode_7(positions, window, modes)
            curr_idx += 4
        elseif opcode == 8
            try
                window = positions[curr_idx+1:curr_idx+3]
            catch BoundsError
                error("Whoops! Program went to far.  Opcode 7 or 8 should not be this close to the end.")
            end
            normalize_modes!(modes, window)
            resolve_opcode_8(positions, window, modes)
            curr_idx += 4
        elseif opcode == 99
            # "save4" indicates to return values from opcode 4 instead of opcode 99
            if save4
                return "done", curr_idx
            end
            return popfirst!(inputs)
        end
    end
end

function resolve_opcode_1!(positions, window, modes)
    values = determine_values(positions, window, modes)
    # Windows 2, 3, and 4 are memory address positions
    total = values[1] + values[2]
    positions[window[3]+1] = total
end

function resolve_opcode_2!(positions, window, modes)
    values = determine_values(positions, window, modes)
    total = values[1] * values[2]
    positions[window[3]+1] = total
end

function resolve_opcode_3!(positions, window, modes, input)
    # parameters that write to a position will never be in "immediate mode"
    positions[window[1]+1] = input
end

function resolve_opcode_4(positions, window, modes)
    values = determine_values(positions, window, modes)
    return values[1]
end

function resolve_opcode_5(positions, window, modes, idx)
    values = determine_values(positions, window, modes)
    # Since Julia is 1-based indexing, need to increment index by 1 if it references an address
    # If returning original index, increment over the window so "opcode does nothing"
    return (iszero(values[1]) ? idx+3 : values[2]+1)
end

function resolve_opcode_6(positions, window, modes, idx)
    values = determine_values(positions, window, modes)
    return (iszero(values[1]) ? values[2]+1 : idx+3)
end

function resolve_opcode_7(positions, window, modes)
    values = determine_values(positions, window, modes)
    positions[window[3]+1] = (values[1] < values[2] ? 1 : 0)
end

function resolve_opcode_8(positions, window, modes)
    values = determine_values(positions, window, modes)
    positions[window[3]+1] = (values[1] == values[2] ? 1 : 0)
end

function resolve_opcode_99(positions)
    return positions[1]
end

function main1()
    input_file = joinpath(pwd(), "files", "12_7_input.txt")
    input = read(open(input_file, "r"), String)
    intcode = chomp(input)

    str_positions = split(intcode, ",")
    positions = map(x -> parse(Int, x), str_positions)
    orig_positions = copy(positions)

    INITIAL_INPUT = 0
    max_output_signal = 0

    phase_signals = 0:4

    # For each permutation of phase signals, create an amplifier system
    # Pass output from previous amp to next amp and output signal value at end
    for phase_perm in permutations(phase_signals)
        stored_value = INITIAL_INPUT
        amps = [Amplifier(orig_positions, sig) for sig in phase_perm]
        for amp in amps
            push!(amp.inputs, stored_value)
            stored_value = process_intcode(amp)
        end
        max_output_signal = max(max_output_signal, stored_value)
    end

    println("Part 1 Answer:")
    @show max_output_signal
end

function main2()
    input_file = joinpath(pwd(), "files", "12_7_input.txt")
    input = read(open(input_file, "r"), String)
    intcode = chomp(input)

    # TEST code
    #intcode = "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5"
    # END test code

    str_positions = split(intcode, ",")
    positions = map(x -> parse(Int, x), str_positions)
    orig_positions = copy(positions)

    INITIAL_INPUT = 0
    max_output_signal = 0

    phase_signals = 5:9

    # For each permutation of phase signals, create an amplifier system
    # Pass output from previous amp to next amp and output signal value at end
    for phase_perm in permutations(phase_signals)
        stored_value = INITIAL_INPUT
        amps = [Amplifier(copy(orig_positions), sig) for sig in phase_perm]
        final_amp = amps[end]
        for amp in Iterators.cycle(amps)
            push!(amp.inputs, stored_value)
            # Keep last stored value when we hit "done"
            last_stored = stored_value
            (stored_value, curr_idx) = process_intcode(amp; save4=true)
            # If opcode 99, get input from final amp and go to next permutation
            if stored_value == "done"
                # The last stored value will be passed to the final amp
                stored_value = last_stored
                break
            end
            # Update this particular amplifier
            # amp.positions is updated in 'process_intcode' by reference

            amp.curr_idx = curr_idx
        end
        max_output_signal = max(max_output_signal, stored_value)
    end

    println("Part 2 Answer:")
    @show max_output_signal
end

# What is the highest signal that can be sent to the thrusters?
main1()
# What is the highest signal that can be sent to the thrusters? (feedback loop)
main2()

