include("predict.jl")
using LinearAlgebra

Nθ = 10
NΦ = 10
Nu = 5

#Ganhos Relativos: λθ + λΦ + λΔu = 1
λθ = 0.6
λΦ = 0.3
λΔu = 1 - λθ - λΦ

#Normalização das variáveis 
θ_bound = pi/6          # 30°
Φ_bound = 10            #10 rad
Δu_bound = 16.8 - 3.7   #Vbatmax - V0

#Ganhos Usados na função custo
Gθ = λθ/Nθ/θ_bound
GΦ = λΦ/NΦ/Φ_bound
GΔu = λΔu/Nu/Δu_bound

Num = 0.5z^(-1)
Den = 1 - 0.5z^(-1)

Ã = (1 - z^(-1))*Den
B = Num*z
Ej, Fj = diophantine(Ã, 3)
G_Y, firsty, lasty = get_G_Y(Fj)
G_Δu, firstu, lastu = get_G_Δu(B, Ej)


G_Δu

len = length(G_Δu[:,1])
G_Δu_t = transpose(G_Δu)
Iθ = Gθ*Matrix(I, len, len)
IΔu = GΔu*Matrix(I, len, len)

A = G_Δu_t*G_Δu*Iθ + IΔu
iA = inv(A)

Q = iA*G_Δu_t*Iθ
G_Y