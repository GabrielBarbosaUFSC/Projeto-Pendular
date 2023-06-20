filename = "pwm_speed_motor3_0506.csv"
filepath = joinpath(@__DIR__, filename)

using CSV
using DataFrames
using Plots; plotly()

df = CSV.read(filepath, DataFrame)

voltage_input = @. 17 - 17*df[:,3]/4095
time = @. df[:,1]/1e6
speed = @. df[:, 2]

time[112]
time[247]

time_ = time[112:247]
volt_ = voltage_input[112:247]
speed_ = speed[112:247]
#plot(df[:,1], [df[:,2] voltage_input])
plot(time_, [volt_ speed_])

