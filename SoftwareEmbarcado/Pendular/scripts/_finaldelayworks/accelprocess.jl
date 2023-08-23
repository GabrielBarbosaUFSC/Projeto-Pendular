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
    raw_accel = dataframe[:,3]
    raw_gyro = dataframe[:,4]
    kalman_accel = dataframe[:,5]
    return n, time, raw_accel, raw_gyro, kalman_accel
end

n, time, raw_theta, raw_gyro, kalman_theta= get_data("accel.csv")

dtime = zeros(length(n)-1)
for i in range(2,length(n))
    dtime[i-1] = time[i] - time[i-1]
end

mean(dtime)

plot(dtime)

mean(kalman_theta)
plot(time, [180/pi*raw_theta 180/pi*kalman_theta])

begin
    p1 = plot(time, [180/pi*raw_theta 180/pi*kalman_theta])
    p2 = plot(time, raw_gyro)
    p3 = plot(time, [180/pi*kalman_theta raw_gyro])
    plot(p1, p2, p3, layout=(3,1), size=(720,480))  
end

plot(time, [])
plot(time, [theta_predict 180/pi*raw_theta])

