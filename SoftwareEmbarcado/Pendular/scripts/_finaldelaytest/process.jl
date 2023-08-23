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
    computetime  = dataframe[:,10]
    sensortime = dataframe[:,11]

    return n, time, theta, dUθ, dUu, U, Vbat, PWM, computetime, sensortime
end

n, time, theta, dUθ, dUu, U, Vbat, PWM, computetime, sensortime = get_data("data.csv")

dtime = zeros(length(n)-1)
for i in range(2,500)
    dtime[i-1] = time[i] - time[i-1]
end

plot(dtime)

mean(sensortime)
plot(sensortime)

plot(time, [180*theta/pi])
plot(time, [180*theta/pi, PWM, U])

plot(computetime)

plot(time, U)
plot(time, PWM)