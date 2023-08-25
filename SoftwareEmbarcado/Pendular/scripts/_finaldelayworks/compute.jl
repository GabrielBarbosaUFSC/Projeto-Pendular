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

i,time,y0,y1,y2,y3,y4,du1,du2,du3,du4,U1,du = get_data("lambdad0.csv")

y = [y0 y1 y2 y3 y4]
Δu = [du1 du2 du3 du4]

ducalc = zeros(length(y[:,1]), 6)
hat_y = zeros(length(y[:,1]), 6)
free = zeros(length(y[:,1]), 6)

for i in eachindex(ducalc[:,1])
    free[i, :] = f_theta*y[i,:] + f_du*Δu[i,:]
    ducalc[i, :] = K1fulltheta*free[i, :] + K1fullu*(-U1[i])
    hat_y[i,:] = free[i,:] + G*ducalc[i,:]   
end


function add_phase(phase)
    phased_free = zeros(length(y[:, 1]))
    for i in range(1, length(phased_free)-phase)
        phased_free[i+phase] = hat_y[i,phase-1]
    end   
    return phased_free
end

begin
    f2 = add_phase(2)
    f3 = add_phase(3)
    f4 = add_phase(4)
    
    
    p1 = plot(time, [180/pi*y0 180/pi*f2], label = ["θ" "yf1"])
    ylabel!(p1, "θ[°]")
    p2 = plot(time, [180/pi*y0 180/pi*f3], label = ["θ" "yf3"])
    ylabel!(p2, "θ[°]")
    p3 = plot(time, [180/pi*y0 180/pi*f4], label = ["θ" "yf4"])
    xlabel!(p3, "Tempo [s]")
    ylabel!(p3, "θ[°]")

    plot(p1, p2, p3, layout = (3,1), size=(1080, 720))  
    
end

begin
    f2 = add_phase(2)
    f3 = add_phase(3)
    f4 = add_phase(4)
    f5 = add_phase(5)
    f6 = add_phase(6)
    f7 = add_phase(7)    
    

    p1 = plot(time, [180/pi*y0 180/pi*f2], label = ["θ" "yf2"])
    ylabel!(p1, "θ[°]")
    p2 = plot(time, [180/pi*y0 180/pi*f3], label = ["θ" "yf3"])
    ylabel!(p2, "θ[°]")
    p3 = plot(time, [180/pi*y0 180/pi*f4], label = ["θ" "yf4"])
    ylabel!(p3, "θ[°]")
    p4 = plot(time, [180/pi*y0 180/pi*f5], label = ["θ" "yf5"])
    ylabel!(p4, "θ[°]")
    p5 = plot(time, [180/pi*y0 180/pi*f6], label = ["θ" "yf6"])
    ylabel!(p5, "θ[°]")
    p6 = plot(time, [180/pi*y0 180/pi*f7], label = ["θ" "yf7"])
    ylabel!(p6, "θ[°]")

    xlabel!(p6, "Tempo [s]")
    
    plot(p1, p2, p3, p4, p5, p6, layout = (6,1), size=(1080, 1440))  
    
end


