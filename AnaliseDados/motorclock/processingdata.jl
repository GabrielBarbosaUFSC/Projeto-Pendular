filename = "motor.csv"
filepath = joinpath(@__DIR__, filename)

using CSV
using DataFrames
using Plots; plotly()

df = CSV.read(filepath, DataFrame)