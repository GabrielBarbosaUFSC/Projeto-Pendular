filename = "pwm_speed_motor3_0506.csv"
filepath = joinpath(@__DIR__, filename)

using CSV
using DataFrames
using Plots; plotly()

df = CSV.read(filepath, DataFrame)

voltage_input = @. 17 - 17*df[:,3]/4095

plot(df[:,1], [df[:,2] voltage_input])

