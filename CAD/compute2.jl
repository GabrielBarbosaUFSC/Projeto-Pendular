using CSV
using DataFrames
using Plots

function get_data(path)
    filepath = joinpath(@__DIR__, path)
    dataframe = CSV.read(filepath, DataFrame)
    comp = dataframe[:,1]
    qnt = dataframe[:,2]
    massa = dataframe[:,3]
    vol = dataframe[:,4]
    n_massa = dataframe[:,5]

    return comp, qnt, massa, vol, n_massa
end

comp, qnt, massa, vol, n_massa = get_data("weight.csv")

eq_mass = @. qnt*massa 
t_mas = sum(eq_mass)

cor_mass = @.qnt*n_massa
t_n_mas = sum(cor_mass)

t_vol = 533209.08
real_mass = 919
ρ = (real_mass-t_mas)/t_vol


cor2_mass = @. massa + vol*ρ
sum(@. cor2_mass * qnt)

print(cor2_mass)


function gmm2_to_kgm2(gmm2)
    G_kg = 1/1000
    G_m = (1/1000)^2
    return G_kg*G_m*gmm2
end

Ib = gmm2_to_kgm2(4068012.8)
Iw = gmm2_to_kgm2(2*14030.951)