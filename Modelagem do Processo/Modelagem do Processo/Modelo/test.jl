using DifferentialEquations
using Plots; plotly()
using LinearAlgebra

begin
    g = 9.81
    rw = 0.035
    mb = 1
    mw = 0.5
    l = 0.1
    Iw = 1/2*mw*rw^2
    Ib = 10*Iw
    kv = 1

    α = Ib + mb*l^2
    β = mb*rw^2 + mw*rw^2 + Iw
    γ = mb*rw*l
    ϵ = mb*g*l
end

function dxdt(x, p, t)
    #Pega os estados para cada instatnte t
    dθ  =   x[1]   #dΘ(t)
    θ   =   x[2]    #Θ(t)
    dΦ  =   x[3]   #dΦ(t)
    Φ   =   x[4]    #Φ(t)
    Δem =   x[5]  #ΔEm(t)

    #resolve o problema Ax = b; sendo x o vetor [d2θ, d2Φ]; conforme o  sistema encontrado
    a11 = α
    a12 = γ*cos(θ)
    a21 = γ*cos(θ)
    a22 = β
    A = [a11 a12; a21 a22] 
    
    b1 = ϵ*sin(θ) - kv*dθ + kv*dΦ
    b2 = γ*dθ^2*sin(θ) + kv*dθ - kv*dΦ
    b = [b1; b2]

    x_f = A\b

    d2θ = x_f[1]
    d2Φ = x_f[2]

    #Calcula a energia pela derivada temporal da equação de energia usada no lagrangeano
    dem = α*dθ*d2θ + β*dΦ*d2Φ - ϵ*dθ*sin(θ) + γ*(d2Φ*dθ*cos(θ) + dΦ*d2θ*cos(θ) - dΦ*dθ^2*sin(θ))

    return [d2θ, dθ, d2Φ, dΦ, dem]
end 


x0 = [0, 0.1, 0, 0, 0]
tspan = (0.0, 10)
prob = ODEProblem(dxdt, x0, tspan)
sol  = solve(prob, AutoTsit5(Rosenbrock23()), reltol = 1e-10, abstol = 1e-10)

show(sol.t)
begin 
    p1 = plot(sol.t, sol[5,:], label="ΔEm")
    # xlims!((0,5))
    # ylims!((-5,5))
    p2 = plot(sol.t, sol[2,:], label="θ")
    p3 = plot(sol.t, sol[4,:], label="Φ")
    p4 = plot(sol.t, sol[1,:], label="dθ")
    p5 = plot(sol.t, sol[3,:], label="dΦ")

    plot(p1, p2,p3, p4, p5, layout=(5,1), size = (720, 480))
end