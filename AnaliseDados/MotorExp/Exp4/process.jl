using CSV
using DataFrames
using Plots#; plotly()
using LsqFit


function get_data(path)
    #path = "M1.csv"
    filepath = joinpath(@__DIR__, path)
    dataframe = CSV.read(filepath, DataFrame)
    pwm = dataframe[:,2]
    i = dataframe[:,3]/1e3 #de mA para Ampere
    ω = @.  dataframe[:,4]/60*2*pi
    return pwm, ω, i
end

pwm1, ω1, i1 = get_data("M1.csv")
pwm2, ω2, i2 = get_data("M2.csv")
pwm3, ω3, i3 = get_data("M3.csv")

begin
    plot([ω1 ω2 ω3], [i1 i2 i3], seriestype=:scatter)
    title!("Sem carga: Speed x Current")    
end

begin
    plot([pwm1 pwm2 pwm3], [i1 i2 i3], seriestype=:scatter)
    title!("Sem carga: PWM x Current")    
end

begin
    plot([pwm1 pwm2 pwm3], [ω1 ω2 ω3], seriestype=:scatter)
    title!("Sem carga: PWM x Speed")    
end

#--------------------------------------------------
#For motor M1 and M2

PWM = vcat(pwm1, pwm2)
ω = vcat(ω1, ω2)
I = vcat(i1, i2)
I =@. I - sign(I)*8.572e-3
V = 14.8

Veq = zeros(length(PWM))
for i in eachindex(Veq)
    V_ = V*PWM[i]/100
    if PWM[i] > 0
        if V_ > 3.44
            Veq[i] = V_ - 3.47
        end
    elseif PWM[i] < 0
        if V_ < -3.49
            Veq[i] = V_ + 3.47
        end
    else
        Veq[i] = 0
    end
end

Veq1 = []
I1 = []
ω1 = []
Veq2 = []
I2 = []
ω2 = []

for i in eachindex(Veq)
    if Veq[i] > 0
        append!(Veq1, Veq[i])
        append!(I1, I[i])
        append!(ω1, ω[i])
    elseif Veq[i] < 0
        append!(Veq2, Veq[i])
        append!(I2, I[i])
        append!(ω2, ω[i])
    end
end

begin
    plot([Veq1 Veq2], [I1 I2], seriestype=:scatter)
    title!("Sem carga: Veq x Current")    
end

begin
    plot([Veq1 Veq2], [ω1 ω2], seriestype=:scatter)
    title!("Sem carga: Veq x Speed")    
end

begin
    plot([I1 I2], [ω1 ω2], seriestype=:scatter)
    title!("Sem carga: Current x Speed")    
end

#calc kt/kv

ω_fit(If, p) = @. p[1]*If + p[2]
p0 = [0.1, 0]
pf1 = curve_fit(ω_fit, I1, ω1, p0).param
pf2 = curve_fit(ω_fit, I2, ω2, p0).param
ktkv = (pf1[1]+pf2[1])/2

Ifitted1 = range(0, 0.120, 300)
ω_fitted1 = [ω_fit(i, pf1) for i in Ifitted1]
Ifitted2 = range(-0.120, 0, 300)
ω_fitted2 = [ω_fit(i, pf2) for i in Ifitted2]

    
begin
    plot([Ifitted1 Ifitted2], [ω_fitted1 ω_fitted2])
    plot!([I1 I2], [ω1 ω2], seriestype=:scatter)
    title!("Current x Speed")    
end

# kt/kv = 100.77

R = 6.05

function calc_kω(Veq, ω, I)
    Veq_ω = @. Veq/ω
    I_ω = @. I/ω
    
    Veq_ω_fit(I_ω, p) = @. R*I_ω + p[1]
    p0 = [1.0]
    return curve_fit(Veq_ω_fit, I_ω, Veq_ω, p0).param        
end

kω1 = calc_kω(Veq1, ω1, I1)
kω2 = calc_kω(Veq2, ω2, I2)

kω = (kω1+kω2)/2
#kω = 0.7826

#from datasheet
kt = (12*9.80665*1e-2)/1.8
kv = kt/ktkv