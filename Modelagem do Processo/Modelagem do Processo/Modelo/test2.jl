using Plots; plotly()
using LinearAlgebra
ts = 1e-3
time = 10

g = 9.81
rw = 0.035
mb = 1
mw = 0.1
l = 0.1
Iw = 1/2*mw*rw^2
Ib = 5*Iw
kv = 0.005
 
α = Ib + mb*l^2
β = mb*rw^2 + mw*rw^2 + Iw
γ = mb*rw*l
ϵ = mb*g*l

function iter(x)
    dθ =    x[1]   #dΘ(t)
    θ =     x[2]    #Θ(t)
    dΦ =    x[3]   #dΦ(t)
    Φ =     x[4]    #Φ(t)

    a11 = α
    a12 = γ*cos(θ)
    a21 = γ*cos(θ)
    a22 = β
    A = [a11 a12; a21 a22] 
    
    u = 2*sin(θ)

    b1 = ϵ*sin(θ) - kv*dθ + kv*dΦ -u
    b2 = γ*dθ^2*sin(θ) + kv*dθ - kv*dΦ + u
    b = [b1; b2]

    x_f = A\b

    d2θ = x_f[1]
    d2Φ = x_f[2]

    # detd2Φ = β - γ^2*cos(θ)*2/α
    # p1d2Φ = u + kv*(dθ - dΦ) + γ*dθ^2*sin(θ)
    # p2d2Φ = (-γ*cos(θ)/α)*(-u - kv*(dθ - dΦ) + ϵ*sin(θ))
    # d2Φ = (p1d2Φ + p2d2Φ)/detd2Φ

    # detd2θ = α - γ^2*cos(θ)*2/β
    # p1d2θ = -u - kv*(dθ - dΦ) + ϵ*sin(θ)
    # p2d2θ = (-γ*cos(θ)/β)*(u + kv*(dθ-dΦ)+γ*dθ^2*sin(θ))
    # d2θ = (p1d2θ + p2d2θ)/detd2θ

    C = [d2θ; dθ; d2Φ; dΦ]
    #show(x)
    #show(C.*ts)
    return x + C.*ts, u
end

t = zeros(Int(time/ts))
x = zeros(Int(time/ts), 4)
u = zeros(Int(time/ts))


x[1,:] = [0 0.1 0 0]
#show(x)

for i in range(2, Int(time/ts))
    t[i] = (i-1)*ts
    x[i,:], u[i] = iter(x[i-1,:])
end

begin
    p1 = plot(t, [x[:,2], u])
    p2 = plot(t, x[:,4])
    p3 = plot(t, [x[:,1], x[:,3]])   
    plot(p1, p2, p3, layout = (3, 1))
end

 
#plot(t, [x[:,2],x[:,4]])