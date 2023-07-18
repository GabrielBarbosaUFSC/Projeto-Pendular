using Plots; plotly()
using Noise

wc = 100
swc = wc*wc

dt =  broadcast(abs, add_gauss(1e-3 * ones(10000), 1e-3)) 
plot(dt)
time = zeros(10000)

function filter_iter(X, i, y, y2k)
    time[i] = time[i-1] + dt[i]
    a = 1/(swc*dt[i]*dt[i]) + 1.414/(wc*dt[i]) + 1;
    b = (-1/swc)*(1/(dt[i]*dt[i]) + 1/(dt[i-1]*dt[i])) - 1.414/(wc*dt[i]);
    c = 1/(swc*dt[i]*dt[i-1]);
    Y = X/a - b/a*y - c/a*y2k;
    return Y;
end

x = add_gauss(1*ones(10000), 0.1)
y = zeros(10000)

for i in eachindex(y)
    if i > 2
        y[i] = filter_iter(x[i], i, y[i-1], y[i-2])
    end
end

plot(time, [x y])