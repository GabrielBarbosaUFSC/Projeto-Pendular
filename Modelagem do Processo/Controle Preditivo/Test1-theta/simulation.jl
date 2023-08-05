include("GPC.jl")
using Plots; plotly()

#Ganhos Relativos: λθ + λΔu + λu= 1
Nθ = 10
Nu = 10
λθ = 0.3
λu = 0.5

MG_Y, MGΔu_free, K1u, K1w = get_matrix(Nθ, Nu, λθ, λu)

time = 2
len = Int(trunc(time/ts))

function simulation()
    t = zeros(len)
    x = zeros(len, 5)
    Vn = zeros(len)
    
    dθ0 = 0
    θ0 = pi/40
    dΦ0 = 0
    Φ0 = 0
    I0 = 0
    
    x[1,:] = [dθ0, θ0, dΦ0, Φ0, I0]
    
    pastΔu = [0.0, 0.0]
    y = θ0*ones(4, 1)
    Vn1 = 0.0
    
    for i in range(2, 4)
        x[i,:] = x[1,:]
    end
    for i in range(5, len)
        if i%100 == 0
            for i in 3:-1:2
                y[i+1] = y[i] 
            end
            y[1] = x[i-1,2]

            f = MG_Y*y + MGΔu_free*pastΔu
            print(f[end])
            print(" ")
            Δu = sum(@. K1w*f) + K1u*Vn1
            println(Δu)
            pastΔu[2] = pastΔu[1]
            pastΔu[1] = Δu

            Vn1 = Vn1 + Δu

            if Vn1 > 15
               Vn1 = 15
            elseif  Vn1 < -15
               Vn1 = -15
            end

        end
    
        Vn[i] = Vn1
        t[i] = (i-1)*ts
        x[i,:] = iter(x[i-1,:], Vn[i])
    end  

    plotθ = plot(t, 180/pi*(x[:,2]), label="Θ")
    plotu = plot(t, x[:,5], label="tm")
    plotdθdΦ = plot(t, [x[:,1], x[:,3]], label=["dΘ" "dΦ"])   
    plotVn = plot(t, Vn, label = "Vn")
    plot(plotθ, plotVn, plotdθdΦ, plotu, layout = (4, 1))
    #plot(p1, p2, p3, p4, layout = (4, 1))
end

simulation()
