using DataFrames
using CSV
using Plots; plotly()
using Polynomials 
using  CurveFit

function getdata(file)
    filepath = joinpath(@__DIR__, file)
    return CSV.read(filepath, DataFrame)
end

d36_1 = getdata("data\\36_1.csv")
d36_2 = getdata("data\\36_2.csv")
d36_3 = getdata("data\\36_3.csv")
d35_1 = getdata("data\\35_1.csv")
d35_2 = getdata("data\\35_2.csv")
d35_3 = getdata("data\\35_3.csv")
d34_1 = getdata("data\\34_1.csv")
d34_2 = getdata("data\\34_2.csv")
d34_3 = getdata("data\\34_3.csv")

io_pwm = [d36_1[:, "PWM"] d36_2[:, "PWM"] d36_3[:, "PWM"] d35_1[:, "PWM"] d35_2[:, "PWM"] d35_3[:, "PWM"] d34_1[:, "PWM"] d34_2[:, "PWM"] d34_3[:, "PWM"]]
io_adc = [d36_1[:, "ADC"] d36_2[:, "ADC"] d36_3[:, "ADC"] d35_1[:, "ADC"] d35_2[:, "ADC"] d35_3[:, "ADC"] d34_1[:, "ADC"] d34_2[:, "ADC"] d34_3[:, "ADC"]]
labels = ["IO36(1)" "IO36(2)" "IO36(3)"  "IO35(1)" "IO35(2)" "IO35(3)" "IO34(1)" "IO34(2)" "IO34(3)"]

volts = @. io_pwm*3.3/4095.0

ref = @.volts[:,1] * 4095/3.3

plot(volts, [io_adc ref], label = labels)


tofitadc = d34_1[100:720, "ADC"]
tofitvolts = volts[100:720, 1]

plot([d34_1[:, "ADC"], tofitadc], [volts[:, 1], tofitvolts])


fit_ = curve_fit(Polynomial, tofitadc, tofitvolts, 4)
plot(tofitadc, [tofitvolts, fit_.(tofitadc)] )

#pa = fit(ArnoldiFit, d34_1[:, "ADC"], volts[:, 1], 10)
#q = Polynomial(as)