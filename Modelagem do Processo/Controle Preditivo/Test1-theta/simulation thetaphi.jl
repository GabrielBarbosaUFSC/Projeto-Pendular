include("GPC.jl")
using Plots; plotly()

function simulation()
    len = Int(trunc(time/ts))

    K1θ, MG_Y_freeθ, MGΔu_freeθ, K1Φ, MG_Y_freeΦ, MGΔu_freeΦ = get_matrix_θΦ(N1, N2, Nu, λθ, λΦ)

    t = zeros(len)
    x = zeros(len, 5)
    Vn = zeros(len)
    
    dθ0 = 0
    θ0 = pi/18
    dΦ0 = 0
    Φ0 = 0
    I0 = 0
    
    x[1,:] = [dθ0, θ0, dΦ0, Φ0, I0]
    
    pastΔu = zeros(3, 1)
    θ = θ0*ones(4, 1)
    Φ = Φ0*ones(5, 1)
    Vn1 = 0.0
    
    for i in range(2, 4)
        x[i,:] = x[1,:]
    end

    for i in range(6, len)
        if i%100 == 0
            for i in 3:-1:2
                θ[i+1] = θ[i] 
            end
            θ[1] = x[i-1,2]

            for i in 4:-1:2
                Φ[i+1] = Φ[i]
            end
            Φ[1] = x[i-1,4]


            fθ = MG_Y_freeθ*θ + MGΔu_freeθ*pastΔu[1:2]
            fΦ = MG_Y_freeΦ*Φ + MGΔu_freeΦ*pastΔu
            
            Δu = sum(@. K1θ*fθ) + sum(@. K1Φ*fΦ) 
            println(Δu)

            pastΔu[3] = pastΔu[2]
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
    plotΦ = plot(t, 180/pi*(x[:,4]), label="Φ")
    plotu = plot(t, x[:,5], label="tm")
    plotdθdΦ = plot(t, [x[:,1], x[:,3]], label=["dΘ" "dΦ"])   
    plotVn = plot(t, Vn, label = "Vn")
    plot(plotθ, plotΦ, plotVn, plotdθdΦ, plotu, layout = (5, 1))
    #plot(p1, p2, p3, p4, layout = (4, 1))
end

#Ganhos Relativos: λθ + λΦ + λΔu = 1
time = 2
N1 = 10
N2 = 15
Nu = 15
λθ = 0.7
λΦ = 0

simulation()
