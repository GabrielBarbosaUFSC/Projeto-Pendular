include("GPC.jl")
using Plots#; plotly()
using Noise

function shift_values(array, new)
    for i in length(array)-1:-1:1
        array[i+1] = array[i]
    end
    array[1] = new
    return array
end

function simulation()
    len = Int(trunc(time/ts))

    K1θ, MG_Y_freeθ, MGΔu_freeθ, K1dΦ, MG_Y_freedΦ, MGΔu_freedΦ = get_matrix_θdΦ(Nθ, NdΦ, N2, Nu, λθ, λdΦ)

    t = zeros(len)
    x = zeros(len, 5)
    Vn = zeros(len)
    vecfθ = zeros(len)
    vecfdΦ = zeros(len)

    #noise = add_gauss(zeros(len), 0.001)

    dθ0 = 0
    θ0 = pi/9
    dΦ0 = 0
    Φ0 = 0
    I0 = 0
    
    x[1,:] = [dθ0, θ0, dΦ0, Φ0, I0]
    
    pastΔu = zeros(3, 1)

    θ = θ0*ones(5, 1)
    dΦ = dΦ0*ones(5, 1)
    pastx = x[1,:]
    Vn1 = 0.0
    
    for i in range(2, 5)
        x[i,:] = x[1,:]
    end

    fθ = 0
    fdΦ = 0
    for i in range(6, len)
        if i%100 == 0
            θ = shift_values(θ, x[i-1,2])
            dΦ = shift_values(dΦ, x[i-1,3])

            fθ = MG_Y_freeθ*θ + MGΔu_freeθ*pastΔu

            fdΦ = MG_Y_freedΦ*dΦ + MGΔu_freedΦ*pastΔu 
            
            Δu = sum(@. K1θ*fθ) + sum(@. K1dΦ*fdΦ) 
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
        vecfdΦ[i] = fdΦ[end]
        vecfθ[i] = fθ[end]
        Vn[i] = Vn1
        t[i] = (i-1)*ts
        x[i,:] = iter(pastx, Vn[i])
        pastx = x[i,:]
        x[i, 2] = x[i,2] #+ noise[i] 
    end  

    plotθ = plot(t, 180/pi*(x[:,2]), label="Θ")
    plotu = plot(t, x[:,5], label="tm")
    #plotdθdΦ = plot(t, [vecfdΦ x[:,3]], label=["fdΦ" "dΦ"])   
    plotdθdΦ = plot(t, [x[:,1], x[:,3]], label=["dΘ" "dΦ"])   
    plotVn = plot(t, Vn, label = "Vn")
    plotfθ = plot(t, 180/pi*vecfθ, label = "fθ")
    plotfdΦ = plot(t, vecfdΦ, label = "fdΦ")

    plot(plotθ, plotVn, plotdθdΦ, plotu, plotfθ, plotfdΦ, layout = (6, 1), size = (1080, 720))
    
end

#Ganhos Relativos: λθ + λΦ + λΔu = 1
#ts = 1ms
begin
    time = 10
    Nθ = 1
    NdΦ = 9
    N2 = 20
    Nu = 20
    λθ = 0.8
    λdΦ = 0.0

    simulation()
end
