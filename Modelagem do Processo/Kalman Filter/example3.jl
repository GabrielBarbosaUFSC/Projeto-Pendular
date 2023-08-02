using Plots; plotly()
using Noise

function predict(x_n1_n1, variance)
    return x_n1_n1, variance
end

#Função Update
function update(x_n_n1, variance_x, z_n, variance_z)
    K = (variance_x)/(variance_x + variance_z)
    x_n_n = x_n_n1 + K*(z_n - x_n_n1)
    variance = (1-K)*variance_x
    return x_n_n, variance
end

measurements = [48.54, 47.11, 55.01, 55.15, 49.89, 40.85, 46.72, 50.05, 51.27, 49.95]
plot(measurements)

x = 60
variance = 15^2
zvariance = 5^2

x_ = zeros(length(measurements))
for i in eachindex(measurements)
    x_n_n1, variance_ = predict(x, variance)
    x_n_n, variance_n = update(x_n_n1, variance_, measurements[i], zvariance)
    x = x_n_n
    variance = variance_n
    print(x_n_n)
    print("  ")
    println(variance)
end