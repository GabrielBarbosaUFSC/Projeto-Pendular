using ControlSystems
using Plots; plotly()

#(3.972827622739898e-7(s^3) - 2.31384277994817e-5s) / (5.78917830058632e-7(s^3) + 0.00013537489841313412(s^2) - 0.003375980795919445 - 2.310093037125913e-5s - 1.3290167935882173e-6(s^4))
a0θ = 0
a1θ = 2.279340119435931e-6
a2θ = 0

b0θ = 0.00033256402574613996
b1θ = 2.2767175819038683e-6
b2θ = - 7.625553066001966e-6
b3θ = - 1.7962251849678757e-8

Hmaθ = tf([a2θ, a1θ, a0θ],[b3θ, b2θ, b1θ, b0θ])
plot(pzmap(Hmaθ, title ="theta"))
zθ, pθ, kθ = zpkdata(Hmaθ)
zθ
pθ
kθ



#(0.00012233337541804406(s^2) - 0.007124905088696374) / (3.239787127354705e-7(s^4) + 0.00013752940871047362(s^3) - 0.005996585697281254s - 4.10330262617667e-5(s^2))a0Φ = 1.2832316353076082e-6 
a1Φ = 0
a2Φ= - 2.202642566003433e-8
a3Φ = 0

b0Φ= 0
b1Φ= 1.0800156075959698e-6
b2Φ= 7.39373573863731e-9
b3Φ= - 2.4764303082258486e-8
b4Φ= - 5.833316547602505e-11

HmaΦ = tf([a3Φ, a2Φ, a1Φ, a0Φ], [b4Φ, b3Φ, b2Φ, b1Φ, b0Φ])
pzmap(HmaΦ, title ="phi")
zΦ, pΦ, kΦ = zpkdata(HmaΦ)
zΦ
pΦ
kΦ

#(0.0032475418986550007(s^2)) / (0.5629838321913844 - 0.009663509834366105(s^2))a0Hn = 0
a1Hn = 0
a2Hn = 0.0032475418986550007
b0Hn =0.5629838321913844
b1Hn =0
b2Hn =- 0.009663509834366105

Hn = tf([a2Hn, a1Hn, a0Hn],[b2Hn, b1Hn, b0Hn])
pzmap(Hn)
zHn, pHn, kHn = zpkdata(Hn)
zHn
pHn
kHn





HmadΦ = HmaΦ * tf([1, 0], [1])
HddΦ = c2d(HmadΦ, 20e-3)



setPlotScale("dB")
bodeplot(Hmaθ)
bodeplot(HmaΦ)

Hdθ = c2d(Hmaθ, 20e-3)
HdΦ = c2d(HmaΦ, 20e-3)

dY = tf([1, -1],[1, 0], 20e-3)


HddΦ = HdΦ*dY


#-0.005286550699417969z^2 + 0.004616222333472475z + 0.0006703283659455013
#--------------------------------------------------------------------------
#1.0z^3 - 2.022214670021557z^2 + 1.005503039109366z - 0.0008094941026986402

#Sample Time: 0.02 (seconds)