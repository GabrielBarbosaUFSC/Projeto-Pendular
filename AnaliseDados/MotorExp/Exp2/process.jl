using CSV
using DataFrames
using Plots
using LsqFit

function get_data(path)
    filepath = joinpath(@__DIR__, path)
    dataframe = CSV.read(filepath, DataFrame)
    Vdc = dataframe[:,1]
    R = dataframe[:, 2]
    I = dataframe[:,3]/1e3
    τ = dataframe[:, 4]/1e6
    rt = dataframe[:, 5]/1e6
    return Vdc, R, I, τ, rt
end

Vdc1, R1, I1, τ1, rt1 = get_data("M1.csv")
Vdc2, R2, I2, τ2, rt2 = get_data("M2.csv")
Vdc3, R3, I3, τ3, rt3 = get_data("M3.csv")

begin
    plot([Vdc1 Vdc2 Vdc3], [I1 I2 I3], seriestype=:scatter)
    title!("Motor travado: Vdc x Current")    
end

begin
    plot([Vdc1 Vdc2 Vdc3], [τ1 τ2 τ3], seriestype=:scatter)
    title!("Motor travado: Vdc x τ medido")    
end

begin
    plot([Vdc1 Vdc2 Vdc3], [rt1 rt2 rt3], seriestype=:scatter)
    title!("Motor travado: Vdc x rt medido")    
end

#------------------------------------------------------------------
#Using M1 e M2
Vdc = vcat(Vdc1, Vdc2)
I = vcat(I1, I2) 
I = @. I - sign(I)*8.572e-3 #Diminui Id calculado 

begin
    plot(Vdc, I, seriestype=:scatter)
    title!("Motor travado: Vdc x rt medido")    
end

R = 1.008
Vfit(If, p) = @. (p[1] + R)*If + p[2]
p0 = [0.1, 0]
pf = curve_fit(Vfit, I, Vdc, p0).param
re = pf[1]+R
Ifit = range(0, 2.5, 300)
Vdcfit = [Vfit(i, pf) for i in Ifit]

begin
    plot(Ifit, Vdcfit)
    plot!(I, Vdc, seriestype=:scatter)
    title!("Motor M1 e M2 Fit: Id x Vdc")
end

#re = 7.17 Ohm
#--------------------------------------------------
#Supondo τ = 400us
τ_estimado = 400e-6
L = τ_estimado*(re)

#from other experiments
re_ = 6.05
τ_calc = L/re_

#L = 3.27mH