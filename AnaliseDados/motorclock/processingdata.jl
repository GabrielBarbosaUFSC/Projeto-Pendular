filename = "motor.csv"
filepath = joinpath(@__DIR__, filename)

using CSV
using DataFrames
using Plots; plotly()

df = CSV.read(filepath, DataFrame)

speed = @. 1/(df[:,3]*1e-6)

time = zeros(10873)
for i in eachindex(time)
    if i != 1
        time[i] = time[i-1] + df[i-1, 3]*1e-6
    end
end

dt = (df[:,3]*1e-6)
wc = 250
swc = wc*wc
function filter_iter(X, i, y, y2k)
    time[i] = time[i-1] + dt[i]
    a = 1/(swc*dt[i]*dt[i]) + 1.414/(wc*dt[i]) + 1;
    b = (-1/swc)*(1/(dt[i]*dt[i]) + 1/(dt[i-1]*dt[i])) - 1.414/(wc*dt[i]);
    c = 1/(swc*dt[i]*dt[i-1]);

    Y = X/a - b/a*y - c/a*y2k;

    return Y;
end

speed_filtered = zeros(10873)
y = zeros(10873)
for i in eachindex(time)
    if i > 2
        y[i] = filter_iter(speed[i], i, y[i-1], y[i-2])
    end
end

plot(time, [speed, y], size = (1080, 720))