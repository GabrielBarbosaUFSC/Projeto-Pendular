include("Gain_GPC.jl")
using CSV
using DataFrames
using Plots; plotly()
using Statistics

function get_data(path)
    filepath = joinpath(@__DIR__, path)
    dataframe = CSV.read(filepath, DataFrame)
    i = dataframe[:,1]
    time = dataframe[:,2]/1e6
    y0 = dataframe[:,3]
    y1 = dataframe[:,4]
    y2 = dataframe[:,5]
    y3 = dataframe[:,6]
    y4 = dataframe[:,7]
    du1 = dataframe[:,8]
    du2 = dataframe[:,9]
    du3 = dataframe[:,10]
    du4 = dataframe[:,11]
    U1 = dataframe[:,12]
    du = dataframe[:,13]
    return i,time,y0,y1,y2,y3,y4,du1,du2,du3,du4,U1,du
end

i,time,y0,y1,y2,y3,y4,du1,du2,du3,du4,U1,du = get_data("controldata.csv")

y = [y0 y1 y2 y3 y4]
Δu = [du1 du2 du3 du4]

ducalc = zeros(length(y[:,1]))
free = zeros(length(y[:,1]), 3)
for i in eachindex(ducalc)
    free[i,:] = f_theta*y[i,:] + f_du*Δu[i,:]
    du_ = sum(@. free[i,:]*K1_theta) + K1_u[1]*(-U1[i])
    ducalc[i] = du_
end
free

function add_phase(phase)
    phased_free = zeros(length(y[:, 1]))
    for i in range(1, length(phased_free)-phase)
        phased_free[i+phase] = free[i,phase-1]
    end   
    return phased_free
end


f2 = add_phase(2)
f3 = add_phase(3)
f4 = add_phase(4)

plot(time, [y0 f2])
plot(time, [y0 f3])
plot(time, [y0 f4])


plot(time, [y0 phased_free])
plot(time, du)