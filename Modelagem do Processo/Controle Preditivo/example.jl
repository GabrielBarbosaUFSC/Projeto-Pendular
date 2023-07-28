using ControlSystems
include("predict.jl")
using LinearAlgebra

H1 = tf([1],[1, 0, 0])
H1d = c2d(H1, 1)
H2 = tf([1], [1, 0])
H2d = c2d(H2, 1)

Np = 15
Nv = 15
Nu = 5

λp = 0.4
λv = 0.1
λΔu = 1- λp - λv

pmax = 120
vmax = 20 
Δumax = 2

Gp = λp/Np/pmax
Gv = λv/Nv/vmax
GΔu = λΔu/Nu/Δumax

pNum = 0.5z^-1 + 0.5z^-2
pDen = 1 - 2z^-1 + 1z^-2
vNum = z^-1
vDen= 1 - z^-1

pÃ = (1-z^-1)*pDen
vÃ = (1-z^-1)*vDen

pB = pNum*z
vB = vNum*z

pEj, pFj = diophantine(pÃ, Np)
pGy, pfirsty, plasty = get_G_Y(pFj)
pGu, pfirstu, plastu = get_G_Δu(pB, pEj)
pGu
pGuf = pGu[:,1]
pGu_ = pGu[:,2:4]
pGy

vEj, vFj = diophantine(vÃ, Nv)
vGy, vfirsty, vlasty = get_G_Y(vFj)
vGu, vfirstu, vlastu = get_G_Δu(vB, vEj)
vGu_ = vGu[:, 1:3]
vGy

pK1, vK1 = get_K1(pGu_, Gp, vGu_, Gv, GΔu)

pK1
vK2

function get_u(K1, Gy, Guf, y, Δu, r)
    f = @. Guf*Δu
    f += Gy*y
    w = r - f
    return @.K1*w
end



vGuf = zeros(5)

p_ = zeros(3)
v_ = zeros(2)
Δu = zeros(1)
pr = 100*ones(Np)
vr = zeros(Nv)

time = 0:1:300
p = zeros(length(time))
v = zeros(length(time))
u = zeros(length(time))

for i in range(3, 301)
    p[i] = 2p[i-1] - p[i-2] + 0.5u[i-1] + 0.5u[i-2]
    v[i] = v[i-1] + u[i-1]

    p_ = reverse(p[i-2:i])
    v_ = reverse(v[i-1:i])
    Δu_ = sum(get_u(pK1, pGy, pGuf, p_, Δu, pr) + get_u(vK1, vGy, vGuf, v_, Δu, vr))
    Δu[1] = Δu_
    u[i] = u[i-1]+Δu[1]
end

using Plots; plotly()

plot(time, [p, v, u])