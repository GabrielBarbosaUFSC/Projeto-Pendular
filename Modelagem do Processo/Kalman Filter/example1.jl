using Plots; plotly()
using Noise
#Função Predição
#Como o dinâmica do modelo é estática, não se soupõe que a barra muda seu peso com o tempo
# x_n_n1 = x_n1_n1
function predict(x_n1_n1)
    return x_n1_n1
end

#Função Update
function update(n, x_n_n1, z_n)
    return x_n_n1 + (1/n)*(z_n - x_n_n1)
end

n = 1:100

real = 1000*ones(length(n))
measurements =  add_gauss(real, 200)
x = zeros(length(n))
x_n1_n1 = 0
for i in eachindex(measurements)
    x_n_n1 = predict(x_n1_n1)
    zn = measurements[i]
    x_n1_n1 = update(i, x_n_n1, zn)
    x[i] = x_n1_n1
end

plot(n, [real, measurements, x])