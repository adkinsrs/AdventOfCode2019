#!/usr/bin/env julia

"""
https://adventofcode.com/2019/day/8
"""

using DelimitedFiles

PIXEL_WIDTH = 25
PIXEL_HEIGHT = 6

function main1()
    input_file = joinpath(pwd(), "files", "12_8_input.txt")
    input = chomp(read(open(input_file, "r"), String))

    str_array = split(input, "")
    int_array = map(x -> parse(Int, x), str_array)

    layer_length = PIXEL_HEIGHT * PIXEL_WIDTH

    # Keep track of layer with fewest zeroes
    fewest_zeros = Inf
    # Store number of ones and twos in layer with fewest_zeroes
    num_ones = 0
    num_twos = 0
    for i in 1:layer_length:length(int_array)
        layer_idx = i+layer_length-1
        layer = int_array[i:layer_idx]
        zeroes = count(x->x==0, layer)
        if zeroes < fewest_zeros
            fewest_zeros = zeroes
            num_ones = count(x->x==1, layer)
            num_twos = count(x->x==2, layer)
        end
    end

    println("Part 1 Answer:")
    @show num_ones * num_twos
end

function main2()
    input_file = joinpath(pwd(), "files", "12_8_input.txt")
    input = chomp(read(open(input_file, "r"), String))

    str_array = split(input, "")
    int_array = map(x -> parse(Int, x), str_array)

    layer_length = PIXEL_HEIGHT * PIXEL_WIDTH

    # Currently visible bits.  Start with transparent nodes first which will gradually be replaced
    visible_layer = fill(2, (PIXEL_HEIGHT, PIXEL_WIDTH))

    # naturally read front to back
    for i in 1:layer_length:length(int_array)
        layer_idx = i+layer_length-1
        layer = int_array[i:layer_idx]
        for j in 1:length(layer)
            # If layer is a 0 and 1, and a transparent bit is still present in the visible layer, replace
            if layer[j] < 2 && visible_layer[j] == 2
                visible_layer[j] = layer[j]
            end
        end
    end

    println("Part 2 Answer:")
    for i in 1:PIXEL_WIDTH:length(visible_layer)
        row_idx = i+PIXEL_WIDTH-1
        row = join(visible_layer[i:row_idx], "")
        # color the individual characters to view the message
        for char in row
            char == '0' && printstyled(char, color=:black)
            char == '1' && printstyled(char, bold=true, color=:white)
        end
        print("\n")        
    end
end

# To make sure the image wasn't corrupted during transmission, the Elves would like you to find the layer that contains the fewest 0 digits. 
# On that layer, what is the number of 1 digits multiplied by the number of 2 digits?
main1()
# What message is produced after decoding your image?
main2()