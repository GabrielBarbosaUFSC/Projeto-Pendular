using CSV
using DataFrames
using Plots
using LsqFit

function get_data(path)
    filepath = joinpath(@__DIR__, path)
    dataframe = CSV.read(filepath, DataFrame)
    pwm = dataframe[:,2]
    i = dataframe[:,3]/1e3 #de mA para Ampere
    return pwm, i
end

pwm1, i1 = get_data("M1.csv")
pwm2, i2 = get_data("M2.csv")
pwm3, i3 = get_data("M3.csv")

begin
    plot([pwm1 pwm2 pwm3], [i1 i2 i3], seriestype=:scatter)
    title!("Motor travado: PWM x Current")    
end

#---Processing
#Getting M1 e M2
#Non Using PWM Range [-10, 10]
V = 14.8
V1 = vcat(pwm1[1:9], pwm2[1:9])
V2 = vcat(pwm1[13:21], pwm2[13:21])
V1 = @. V1*V/100
V2 = @. V2*V/100

I1 = vcat(i1[1:9], i2[1:9])
I2 = vcat(i1[13:21], i2[13:21])
I1 = @.I1 - sign(I1)*8.572e-3
I2 = @.I2 - sign(I2)*8.572e-3

begin
    plot([V1 V2], [I1, I2], seriestype=:scatter)
    title!("Motor travado: Veq x Current")    
end


function fitting(I, Vdc)
    Veq(If, p) = @. p[1]*If + p[2]
    p0 = [0.1, 0]
    pf = curve_fit(Veq, I, Vdc, p0).param
    
    Ifit = range(-2.5, 2.5, 300)
    Vdcfit = [Veq(i, pf) for i in Ifit]
    
    
    p = plot(Ifit, Vdcfit)
    plot!(I, Vdc, seriestype=:scatter)
    title!("Motor M1 e M2 Fit: Id x Vdc")
    
    return pf, p
end

pf1, p1  =fitting(I1, V1)
pf2, p2 = fitting(I2, V2)

re = (pf1[1] + pf2[1])/2
v0 = (-pf1[2] + pf2[2])/2
plot(p1)
plot(p2)

