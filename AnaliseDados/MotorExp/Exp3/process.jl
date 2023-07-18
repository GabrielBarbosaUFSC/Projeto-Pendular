filename = "M2.csv"
filepath = joinpath(@__DIR__, filename)

using CSV
using DataFrames
using Plots; plotly()

dataframe = CSV.read(filepath, DataFrame)
pwm = dataframe[:,2] #de mA para Ampere
i = @.  dataframe[:,3]/1e3  - 8.7e-3

plot(pwm, i, seriestype=:scatter)
