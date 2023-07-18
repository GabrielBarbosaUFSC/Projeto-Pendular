filename = "motor.csv"
filepath = joinpath(@__DIR__, filename)


using PyCall
using CSV
using DataFrames
using Plots; plotly()
@pyimport nufft as nufft_fortran


df = CSV.read(filepath, DataFrame)
dtime = df[:,3] 

speed = @. 1/(df[:,3]*1e-6)
maxtime = 3000;

speed_zeros = zeros(0)
dtime_speed = zeros(0)

dt = 0
for i in eachindex(dtime[:,1])
    dt += dtime[i]
    while dt > maxtime
        append!(speed_zeros, 0)
        append!(dtime_speed, maxtime)
        dt = dt - 3000
    end
    if dt > 600
        append!(speed_zeros, 1/(dt*1e-6))
        append!(dtime_speed, dt)
        dt = 0
    end
end

speed_zeros
dtime_speed

time_ = zeros(10889)
for i in eachindex(time_)
    if i != 1
        time_[i] = time_[i-1]+dtime_speed[i]
    end
end

time_


plot(time_, speed_zeros)


for i in eachindex(speed)
    if i >= 5415
        speed[i] = speed[i]*(-1)
    end
end

speed

time = zeros(10890)
for i in eachindex(time)
    if i != 1
        time[i] = time[i-1] + dtime_speed[i]*1e-6
    end
end


#dt = (df[:,3]*1e-6)

dt = dtime_speed*1e-6
wc = 500
swc = wc*wc
function filter_iter(X, i, y, y2k)
    time[i] = time[i-1] + dt[i]
    a = 1/(swc*dt[i]*dt[i]) + 1.414/(wc*dt[i]) + 1;
    b = (-1/swc)*(1/(dt[i]*dt[i]) + 1/(dt[i-1]*dt[i])) - 1.414/(wc*dt[i]);
    c = 1/(swc*dt[i]*dt[i-1]);

    Y = X/a - b/a*y - c/a*y2k;

    return Y;
end

speed_filtered = zeros(10890)
y = zeros(10890)

for i in eachindex(time)
    if i > 2
        y[i] = filter_iter(speed_zeros[i], i, y[i-1], y[i-2])
    end
end

plot(time, [speed_zeros, y], size = (720, 480))