using CSV
using DataFrames
using Plots
using LsqFit

function get_data(path)
    filepath = joinpath(@__DIR__, path)
    dataframe = CSV.read(filepath, DataFrame)
    Vdc = dataframe[:,1]
    Id = dataframe[:,2]/1e3
    return Vdc, Id
end

Vdc1, Id1 = get_data("M1.csv")
Vdc2, Id2 = get_data("M2.csv")
Vdc3, Id3 = get_data("M3.csv")

begin
    plot([Vdc1 Vdc2 Vdc3], [Id1 Id2 Id3], seriestype=:scatter)
    title!("Motor Desligado: Vdc x Current")    
end

#Using M1 e M2

Vdc = vcat(Vdc1, Vdc2)
Id = vcat(Id1, Id2)

begin
    plot(Vdc, Id, seriestype=:scatter)
    title!("Motor M1 e M2: Vdc x Id")
end


Idfit(Vdc, p) = @. p[1]*Vdc + p[2]
p0 = [0.1, 0]
pfit = curve_fit(Idfit, Vdc, Id, p0).param

Vdcfitted = range(12, 17, 300)
Idfitted = [Idfit(Vdci, pfit) for Vdci in Vdcfitted]

begin
    plot(Vdcfitted, Idfitted)
    plot!(Vdc, Id, seriestype=:scatter)
    title!("Motor M1 e M2 Fit: Vdc x Id")
end

#Id da tensão nominal das baterias
Idf = Idfit(14.8, pfit)
#Idf = 8.572mA

