using CSV
using DataFrames
using Plots; plotly()
using Statistics

function get_data(path)
    #path = "M1.csv"
    filepath = joinpath(@__DIR__, path)
    dataframe = CSV.read(filepath, DataFrame)
    n = dataframe[:,1]
    time = dataframe[:,2]/1e6
    theta = dataframe[:,3]
    dUθ = dataframe[:,4]
    dUu = dataframe[:,5]
    du = dataframe[:,6]
    U = dataframe[:,7]
    Vbat = dataframe[:,8]
    PWM = dataframe[:,9]

    return n, time, theta, dUθ, dUu, U, Vbat, PWM
end

n, time, theta, dUθ, dUu, U, Vbat, PWM = get_data("data.csv")

dtime = zeros(length(n)-1)
for i in range(2,200)
    dtime[i-1] = time[i] - time[i-1]
end

plot(time, [180*theta/pi, PWM])
plot(time, U)
plot(time, PWM)