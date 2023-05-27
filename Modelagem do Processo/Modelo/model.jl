using DifferentialEquations
using Plots; plotly()
using  LinearAlgebra

#Def Coeffs
begin
    ts = 1e-6

    g = 9.81
    rw = 0.035
    mb = 1
    mw = 0.5
    l = 0.1
    Iw = 1/2*mw*rw^2
    Ib = 10*Iw
    kv = 0.5

    α = Ib + mb*l^2
    β = mb*rw^2 + mw*rw^2 + Iw
    γ = mb*rw*l
    ϵ = mb*g*l   
end

function sys_iteration(pX, u)
    dθ  =   pX[1]   #dθ(k-1)
    θ   =   pX[2]   # θ(k-1)
    dΦ  =   pX[3]   #dΦ(k-1)
    Φ   =   pX[4]   # Φ(k-1)
    ΔEm =   pX[5]   #ΔEm(k-1)

    a11 = α
    a12 = γ*cos(θ)
    a21 = γ*cos(θ)
    a22 = β

    b1 = ϵ*sin(θ) - kv*dθ + kv*dΦ - u
    b2 = γ*dθ^2*sin(θ) + kv*dθ - kv*dΦ + u

    d2X = [a11 a12; a21 a22]\[b1, b2]
    d2θ, d2Φ = d2X[1], d2X[2]


    dem = α*dθ*d2θ + β*dΦ*d2Φ - ϵ*dθ*sin(θ) + γ*(d2Φ*dθ*cos(θ) + dΦ*d2θ*cos(θ) - dΦ*dθ^2*sin(θ))
    return pX + ts.*[d2θ, dθ, d2Φ, dΦ, dem]
end

time = 10
t = zeros(Int(time/ts))
x = zeros(Int(time/ts), 5)
u = zeros(Int(time/ts))

#def initial conditions
begin
    dθ0 = 0 
    θ0  = 0.1
    dΦ0 = 0
    Φ0  = 0
    x[1,:] = [dθ0 θ0 dΦ0 Φ0 0]
end

#iteration
for i in range(2, Int(time/ts))
    t[i] = ts*(i-1)
    x[i,:] = sys_iteration(x[i-1,:], 0) 
end

#Plots
begin
    dθ  = x[:,1]
    θ   = x[:,2]
    dΦ  = x[:,3]
    Φ   = x[:,4]
    ΔEm = x[:,5]

    p1 = plot(t, [θ, u], label=["θ" "u"])
    p2 = plot(t, Φ, label = "Φ")
    p3 = plot(t, [dθ, dΦ], label=["dθ" "dΦ"])
    p4 = plot(t, ΔEm, label = "ΔEm") 

    plot(p1, p2, p3, p4, layout = (2, 2), size=(720, 480))
end