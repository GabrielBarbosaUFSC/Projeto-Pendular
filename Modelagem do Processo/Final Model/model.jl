begin
    τm = 540e-6
    kt = 0.65377
    kω = 0.7816
    kv = 0.0064877
    re = 6.05

    g = 9.81
    rw = 0.035
    mb = 1
    mw = 0.07
    l = 0.06
    Iw = 1/2*mw*rw^2
    Ib = 5*Iw
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
G1 = b1*s^2 + kv*s 
G2 = c0*s^2 - kv*s 

E1 = a2 - (a1 + c0)*s^2
E2 = (b1+c0)*s^2

H1 = simplify(G1 + G2*E1/E2 - D2 - D3*E1/E2)
H2 = simplify(G1*E2/E1 + G2 - D2*E2/E1 - D3)

Hθ = expand(simplify(D1/H1))
HΦ = expand(simplify(D1/H2))

using Latexify
latexify(Hθ)
latexify(HΦ)



using ControlSystems
using Plots; plotly()
a2θ = 5.2076e-6*0.00054
a1θ = 5.2076e-6
a0θ = 0
b3θ = -1.9423e-7
b2θ = 1.6133e-5
b1θ = 1.6381e-5
b0θ = -0.00084468

a0Φ = 0.2079876862710744
a1Φ = 0.00011231335058638018
a5Φ = 2.224563643568957e-8
a4Φ = 4.119562302905476e-5 
a3Φ = - 3.161317424124794e-6
a2Φ = - 0.005854291526157026

b8Φ = 1.6669923010871491e-13
b7Φ = + 6.169157417244477e-10
b6Φ = 5.462656680200895e-7
b5Φ = - 4.541785315422744e-5
b4Φ = - 8.488904430595186e-5
b3Φ = + 0.005599766797097389
b2Φ = + 0.00327373639496521
b1Φ = - 0.16880668504917176



Hmaθ = tf([a2θ, a1θ, a0θ],[b2θ, b2θ, b1θ, b0θ])
HmaΦ = tf([a5Φ, a4Φ, a3Φ, a2Φ, a1Φ, a0Φ], [b8Φ, b7Φ, b6Φ, b5Φ, b4Φ, b3Φ, b2Φ, b1Φ, 0])

function cancel_pole_zero(H)
    z, p, k = zpkdata(H)
    zeros_ = z[1]
    poles_ = p[1]
    zer_map = ones(length(zeros_))
    pol_map = ones(length(poles_))
    
    for i_z in eachindex(zeros_)
        for i_p in eachindex(poles_)
            if abs(zeros_[i_z] - poles_[i_p]) < 1e-3
                if (zer_map[i_z] == 1) && (pol_map[i_p] == 1)
                    zer_map[i_z] = 0
                    pol_map[i_p] = 0
                end
            end 
        end
    end
    print(pol_map)
    
    H = tf([k[1]],[1])
    for i_z in eachindex(zeros_)
        if zer_map[i_z] == 1
            H = H*tf([1, -zeros_[i_z]], [1])
        end
    end
    for i_p in eachindex(poles_)
        if pol_map[i_p] == 1
            H = H*tf([1], [1, -poles_[i_p]])
        end
    end
    return H   
end

Hmaθf = cancel_pole_zero(Hmaθ)
HmaΦf = cancel_pole_zero(HmaΦ)

#pzmap(Hmaθ)
pzmap(Hmaθf)
pzmap(HmaΦf)
# pzmap(H)
# bodeplot(Hmaθ)