using ControlSystems
using Plots; plotly()

#Hθ = (2.240118904371009e-6s + 1.2096642083603447e-9(s^2)) / (0.0003296903510129275 + 2.3842147066937706e-6s - 2.118824713472991e-8(s^3) - 7.542063642402484e-6(s^2))
a0θ = 0
a1θ = 2.240118904371009e-6
a2θ = 1.2096642083603447e-9

b0θ = 0.0003296903510129275
b1θ = + 2.3842147066937706e-6
b2θ = - 7.542063642402484e-6
b3θ = - 2.118824713472991e-8

# HΦ (extenso)= (3.463884599452048e-6 + 1.870497683704115e-9s - 3.210673509268558e-11(s^3) - 5.945691683830636e-8(s^2)) /
# (2.915906951759964e-6s + 2.1532675791893786e-8(s^2) - 1.9355628536484204e-10(s^4) - 6.682678812398916e-8(s^3))

#HΦ (Hθ/Hn)= (1.2832316353076084e-6 - 2.2026425660034335e-8(s^2)) / (1.0800156075959698e-6s - 2.476031046495962e-8(s^3))


a0Φ = 1.2832316353076084e-6 
a1Φ = 0
a2Φ= - 2.2026425660034335e-8
a3Φ = 0

b0Φ= 0
b1Φ= 1.0800156075959698e-6
b2Φ= 0
b3Φ= - 2.476031046495962e-8
b4Φ= 0

#Hn (θ/ϕ) = (0.0032194799966550006(s^2)) / (0.5629838321913844 - 0.009663509834366105(s^2))
a0Hn = 0
a1Hn = 0
a2Hn = 0.0032194799966550006
b0Hn =0.5629838321913844
b1Hn =0
b2Hn =- 0.009663509834366105


Hmaθ = tf([a2θ, a1θ, a0θ],[b3θ, b2θ, b1θ, b0θ])
plot(pzmap(Hmaθ, title ="theta"))
zθ, pθ, kθ = zpkdata(Hmaθ)
zθ
pθ
kθ

HmaΦ = tf([a3Φ, a2Φ, a1Φ, a0Φ], [b4Φ, b3Φ, b2Φ, b1Φ, b0Φ])
pzmap(HmaΦ, title ="phi")
zΦ, pΦ, kΦ = zpkdata(HmaΦ)
zΦ
pΦ
kΦ

HmadΦ = HmaΦ * tf([1, 0], [1])
HddΦ = c2d(HmadΦ, 20e-3)


# pzmap(HmadΦ, title ="dphi")
# zdΦ, pdΦ, kdΦ = zpkdata(HmadΦ)
# zdΦ
# pdΦ
# kdΦ

# #Teste 
# zfdΦ = [-1851.8518518518529 + 0.0im, 7.632740809573139 + 0.0im, -7.63274080957315 + 0.0im]
# pfdΦ = [-356.14833115897164 + 0.0im, 6.707173065847311 + 0.0im, -6.513895406331542 + 0.0im]
# kfdΦ = 0.17136375221535402

# HfmadΦ = zpk(zfdΦ, pfdΦ, kfdΦ)
# pzmap(HfmadΦ, title ="fdphi")
# setPlotScale("dB")
# bodeplot(HfmadΦ)
# res = step(HfmadΦ, 20)
# plot(res)


Hn = tf([a2Hn, a1Hn, a0Hn],[b2Hn, b1Hn, b0Hn])
pzmap(Hn)
zHn, pHn, kHn = zpkdata(Hn)
zHn
pHn
kHn

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