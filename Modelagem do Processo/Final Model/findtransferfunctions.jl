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


using Symbolics

@variables s

using ControlSystems

D1 = (2*kt/re)*(1/(τm*s+1))
D2 = +(2*kt*kω/re)*(s/(τm*s+1))
D3 = -(2*kt*kω/re)*(s/(τm*s+1))

a1 = Ib + mb*l^2
c0 = mb*rw*l
a2 = mb*g*l
b1 = mb*rw^2 + mw*rw^2 + Iw

F1 = a1*s^2 + 2kv*s - a2
F2 = c0*s^2 - 2kv*s

G1 = c0*s^2 - 2kv*s 
G2 = b1*s^2 + 2kv*s 



E1 = a2 - (a1 + c0)*s^2


E2 = (b1+c0)*s^2

Hn = simplify(E2/E1)


# hD1 = tf([- 1.196582949484607e-5,  - 0.00012538790550483395 , + 0.0006971140568823185, 0.007304940416216089], [0.0032475418986550007, 0])
# z,p,k = zpkdata(hD1)
# k
# z
# p

G2Hn = simplify(G2/Hn)
D3Hn = simplify(D3/Hn)

H1_ = simplify(G1 + G2Hn)
H1__ = simplify(-D2-D3Hn)
H1 = simplify(H1_ + H1__)

Hθ = simplify(D1/H1, expand=true)
HΦ = simplify(Hθ/Hn, expand=true)


# G1Hn = simplify(G1*Hn, expand =true)
# D2Hn = simplify(D2*Hn, expand =true)
# H2_ = simplify(G1Hn + G2, expand =true)
# H2__ = simplify(-D2Hn-D3, expand =true)
# H2 = simplify(H2_ + H2__, expand =true)

# HΦ = simplify(D1/H2, expand=true)
# Hθ = simplify(HΦ*Hn, expand=true)


using Latexify
latexify(Hθ)
latexify(HΦ)


