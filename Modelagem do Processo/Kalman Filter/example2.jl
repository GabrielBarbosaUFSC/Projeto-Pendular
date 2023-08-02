using Plots; plotly()
using Noise

ts = 5
A = [1 ts; 0 1]
function predict(x_n1_n1)
    return A*x_n1_n1    
end

α = 0.2
β = 0.3
function update(x_n_n1, zn)
    x = α*(zn - x_n_n1[1])
    dx = β/ts*(zn - x_n_n1[1])
    return x_n_n1 + [x, dx]
end

v = 0.1 
function pos(t)
    return t*v
end

time = 0:5:1000
realpos = [pos(i) for i in time]
measurements = add_gauss(realpos, 10)

x_ = zeros(length(time), 2)

x = [0, 0]

for i in eachindex(time)
    x_n_n1 = predict(x)
    zn = measurements[i]
    x = update(x_n_n1, zn)
    x_[i,:] = x
end

v_ = v*ones(length(time))

begin
    p1 = plot(time, [x_[:,1], measurements, realpos])
    p2 = plot(time, [v_, x_[:,2]])
    
    layout = (2,1)
    plot(p1, p2, layout = (2,1))    
end
