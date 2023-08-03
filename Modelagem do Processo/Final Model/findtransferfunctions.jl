begin
    τm = 540e-6
    kt = 0.65377
    kω = 0.7816
    kv = 0.0064877
    re = 6.05

    g = 9.80665
    rw = 0.035
    mb = 0.919
    mw = 0.046
    l = 0.062468307
    Iw = 2.8061902e-5
    Ib = 0.0040680128000000005
end

using Symbolics

@variables s

D1 = (2*kt/re)*(1/(τm*s+1))
D2 = - (2*kt*kω/re)*(s/(τm*s+1))
D3 = (2*kt*kω/re)*(s/(τm*s+1))

a1 = Ib + mb*l^2
c0 = mb*rw*l
a2 = mb*g*l
b1 = mb*rw^2 + mw*rw^2 + Iw

F1 = a1*s^2 + kv*s - a2
F2 = c0*s^2 - kv*s

G1 = c0*s^2 - kv*s 
G2 = b1*s^2 + kv*s 

E1 = a2 - (a1 + c0)*s^2
E2 = (b1+c0)*s^2

Hn = simplify(E2/E1)

H1 = G1
H1 = H1 + G2/Hn
H1 = H1 - D2
H1 = H1 - D3/Hn
H1 = simplify(H1)

H2 = H1*Hn
H2 = simplify(H2)

Hθ = simplify(D1/H1, expand=true)
HΦ = simplify(D1/H2, expand = true)

using Latexify
latexify(Hθ)
latexify(HΦ)


