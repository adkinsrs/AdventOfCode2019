#!/usr/bin/env julia

"""
https://adventofcode.com/2019/day/1
"""

function calculate_fuel_required(mass)
    return calculate_fuel_required(parse(Int, mass))
end

function calculate_fuel_required(mass::Int)
    fuel =  floor(mass / 3) - 2
    if fuel < 0
        fuel = 0
    end
    return fuel
end

function calculate_fuel_required2(mass)
    return calculate_fuel_required2(parse(Int, mass))
end

function calculate_fuel_required2(mass)
    total_module_fuel = Int[]
    # Calculate original fuel requirements
    push!(total_module_fuel, calculate_fuel_required(mass))
    # Calculate iterative fuel requirements
    while total_module_fuel[end] > 0
        push!(total_module_fuel, calculate_fuel_required(total_module_fuel[end]))
    end
    return sum(total_module_fuel)
end

function main1()
    # Getting curl 400 error so downloading file beforehand
    #input_file = download("https://adventofcode.com/2019/day/1/input")
    input_file = joinpath(pwd(), "files", "12_1_input.txt")
    total_fuel = zero(Int)
    open(input_file, "r") do ifh
        lines = [strip(line) for line in eachline(ifh)]
        total_fuel = sum(calculate_fuel_required, lines)
    end
    println("Part 1 Answer:")
    @show Int(total_fuel)
end

function main2()
    input_file = joinpath(pwd(), "files", "12_1_input.txt")
    total_fuel = zero(Int)
    open(input_file, "r") do ifh
        lines = [strip(line) for line in eachline(ifh)]
        total_fuel = sum(calculate_fuel_required2, lines)
    end
    println("Part 2 Answer:")
    @show Int(total_fuel)
end

main1()
main2()