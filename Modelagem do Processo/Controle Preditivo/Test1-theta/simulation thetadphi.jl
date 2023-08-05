include("GPC.jl")
using Plots; plotly()

function simulation()
    len = Int(trunc(time/ts))

    K1θ, MG_Y_freeθ, MGΔu_freeθ, K1dΦ, MG_Y_freedΦ, MGΔu_freedΦ = get_matrix_θdΦ(Nθ, NdΦ, N2, Nu, λθ, λdΦ)

    t = zeros(len)
    x = zeros(len, 5)
    Vn = zeros(len)
    vecfθ = zeros(len)
    vecfdΦ = zeros(len)

    dθ0 = 0
    θ0 = pi/18
    dΦ0 = 0
    Φ0 = 0
    I0 = 0
    
    x[1,:] = [dθ0, θ0, dΦ0, Φ0, I0]
    
    pastΔu = zeros(4, 1)

    θ = θ0*ones(4, 1)
    dΦ = dΦ0*ones(5, 1)

    Vn1 = 0.0
    
    for i in range(2, 5)
        x[i,:] = x[1,:]
    end

    fθ = 0
    fdΦ = 0
    for i in range(6, len)
        if i%100 == 0
            for i in 3:-1:2
                θ[i+1] = θ[i] 
            end
            θ[1] = x[i-1,2]

            for i in 4:-1:2
                dΦ[i+1] = dΦ[i]
            end
            dΦ[1] = x[i-1,3]

            fθ = MG_Y_freeθ*θ + MGΔu_freeθ*pastΔu[1:2]
            fdΦ = MG_Y_freedΦ*dΦ + MGΔu_freedΦ*pastΔu
            
            Δu = sum(@. K1θ*fθ) + sum(@. K1dΦ*fdΦ) 
            #println(Δu)

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
        vecfdΦ[i] = fdΦ[end]
        vecfθ[i] = fθ[end]
        Vn[i] = Vn1
        t[i] = (i-1)*ts
        x[i,:] = iter(x[i-1,:], Vn[i])
    end  

    plotθ = plot(t, 180/pi*(x[:,2]), label="Θ")
    plotu = plot(t, x[:,5], label="tm")
    plotdθdΦ = plot(t, [x[:,1], x[:,3]], label=["dΘ" "dΦ"])   
    plotVn = plot(t, Vn, label = "Vn")
    plotfθ = plot(t, vecfθ, label = "fθ")
    plotfdΦ = plot(t, vecfdΦ, label = "fdΦ")

    plot(plotθ, plotVn, plotdθdΦ, plotu, plotfθ, plotfdΦ, layout = (6, 1), size = (1080, 720))
    
end

#Ganhos Relativos: λθ + λΦ + λΔu = 1
time = 1
Nθ = 1
NdΦ = 7
N2 = 10
Nu = 10
λθ = 0.5
λdΦ = 0.3


simulation()
