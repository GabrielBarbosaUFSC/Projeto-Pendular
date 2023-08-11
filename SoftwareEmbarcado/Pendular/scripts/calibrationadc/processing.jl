using DataFrames
using CSV
using Plots; plotly()
using Polynomials 
using CurveFit

function getdata(file)
    filepath = joinpath(@__DIR__, file)
    return CSV.read(filepath, DataFrame)
end

data = getdata("data.csv")
pwm = data[:, "PWM"]
adc = data[:, "ADC"]
volts = @. pwm*3.3/4095.0
ref = @. volts*4095/3.3

labels = ["ADC" "REF"]

plot(pwm, [adc ref], label = labels)

#plot(volts, [io_adc ref], label = labels)
tofitadc = adc[90:765]
tofitvolts = volts[90:765]

fit_ = curve_fit(Polynomial, tofitadc, tofitvolts, 4)
plot(tofitadc, [tofitvolts, fit_.(tofitadc)] )

#pa = fit(ArnoldiFit, d34_1[:, "ADC"], volts[:, 1], 10)
#q = Polynomial(as)