filename = "motor.csv"
filepath = joinpath(@__DIR__, filename)
using CSV
using DataFrames
using Plots; plotly()

df = CSV.read(filepath, DataFrame)
dtime = df[:,3]*1e-6 
maxtime = 5e-3;

begin
    speed_zeros = zeros(0)
    dtime_speed = zeros(0)
    
    dt = 0
    for i in eachindex(dtime[:,1])
        dt = dtime[i]
        while dt > maxtime
            append!(speed_zeros, 0)
            append!(dtime_speed, maxtime)
            dt = dt - maxtime
        end

        append!(speed_zeros, 1/dtime[i])
        append!(dtime_speed, dt)
    end       
end

speed_zeros
dtime_speed

function filter_iter(X, i, y, y2k, time_, dt, wc, swc)
    time_[i] = time_[i-1] + dt[i]
    a = 1/(swc*dt[i]*dt[i]) + 1.414/(wc*dt[i]) + 1;
    b = (-1/swc)*(1/(dt[i]*dt[i]) + 1/(dt[i-1]*dt[i])) - 1.414/(wc*dt[i]);
    c = 1/(swc*dt[i]*dt[i-1]);

    Y = X/a - b/a*y - c/a*y2k;

    return Y;
end

function calc_filter(wc, dt, x)
    time_ = zeros(length(dt))
    swc = wc*wc
    y = zeros(length(time_))

    for i in eachindex(time_)
        if i > 2
            y[i] = filter_iter(x[i], i, y[i-1], y[i-2], time_, dt, wc, swc)
        end
    end
    
    return y, time_
end

y_filtered, time_ = calc_filter(1000, dtime_speed, speed_zeros)
y_filtered
time_

plot(time_, [speed_zeros y_filtered])

using FastTransforms

n = length(speed_zeros)
ω = collect(0:n-1)
c = complex(rand(n));
nufft1(c, time_)