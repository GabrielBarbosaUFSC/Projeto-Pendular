using ControlSystems
using Plots; plotly()

begin
    τm = 540e-6
    kt = 0.65377
    kω = 0.7816
    kv = 0.0064877
    re = 6.05

    g = 9.80665
    rw = 0.035
    mb = 0.919
    mw = 2*0.023
    l = 0.062468307
    Iw = 2*2.8061902e-5
    Ib = 0.0040680128000000005
end

D1 = tf([2*kt/re],[τm, 1])
D2 = tf([2*kt*kω/re, 0], [τm, 1])
D3 = tf([-2*kt*kω/re, 0], [τm, 1])

a1 = Ib + mb*l^2
c0 = mb*rw*l
a2 = mb*g*l
b1 = mb*rw^2 + mw*rw^2 + Iw

F1 = tf([a1, 2kv, -a2],[1])
F2 = tf([c0, -2kv, 0],[1])
G1 = tf([c0, -2kv, 0], [1])
G2 = tf([b1, 2kv, 0], [1])

E1 = tf([-a1-c0, 0, a2], [1])
E2 = tf([b1+c0, 0, 0], [1])

Hn = E2/E1

H1 = G1 + G2/Hn - D2 - D3/Hn
Hθ = D1/H1

H2 = G1*Hn + G2 - D2*Hn - D3
HΦ = D1/H2

pzmap(HΦ)
HdΦ = HΦ*tf([1,0],[1])
z,p, k = zpkdata(HdΦ)
z
p
k
H


θz0 = 0
θp0 = -1235.7262476675755
θp1 = -647.1134087815102
θp2 = 6.700833957274487
θp3 = -6.505057463635203
θk = -238900.20928917004

θp = [θp0, θp1, θp2, θp3]
Hθ = zpk([θz0], θp, θk)


dΦz0 = 7.632741006069605
dΦz1 = -7.632741032008387
dΦp0 = -1235.7262476675755
dΦp1 = -647.1134087815102
dΦp2 = 6.700833957274487
dΦp3 = -6.505057463635203
dΦk = 710880.5964456222

dΦz = [dΦz0, dΦz1]
dΦp = [dΦp0, dΦp1, dΦp2, dΦp3]
HdΦ = tf(zpk(dΦz, dΦp, dΦk))
bodeplot(HdΦ)

HddΦ = c2d(HdΦ, 1e-3)

setPlotScale("dB")
bodeplot(HddΦ)