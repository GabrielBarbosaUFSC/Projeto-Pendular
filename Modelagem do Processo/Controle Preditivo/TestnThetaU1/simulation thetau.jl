include("GPC.jl")
include("savematrix.jl")
using Plots; plotly()
using Noise
using CSV, Tables

function simulation()
    len = Int(trunc(time/ts))

    K1θ, MG_Y_freeθ, MGΔu_freeθ, K1u = get_matrix_θ(N1, N2, Nu, λθ, λu, λΔu)
    labels = ["f_du", "f_theta", "K1_theta", "K1_u"]
    matrix = [MGΔu_freeθ, MG_Y_freeθ, K1θ, K1u]

    save_matrix_to_array_c(matrix, labels, "Gain_GPC")
    t = zeros(len)
    x = zeros(len, 5)
    Vn = zeros(len)
    vecfθ = zeros(len)

    noise = add_gauss(zeros(len), 0.01)

    dθ0 = 0
    dΦ0 = 0
    Φ0 = 0
    I0 = 0
    
    x[1,:] = [dθ0, θ0, dΦ0, Φ0, I0]
    
    pastΔu = zeros(3, 1)

    θ = θ0*ones(5, 1)
    #dΦ = dΦ0*ones(5, 1)
    pastx = x[1,:]
    Vn1 = 0.0
    
    for i in range(2, 5)
        x[i,:] = x[1,:]
    end

    fθ = 0
    for i in range(6, len)
        if i%100 == 0
            newθ = x[i-1,2]

            θ = shift_values(θ, newθ)

            fθ = MG_Y_freeθ*θ + MGΔu_freeθ*pastΔu
            
            Δu = sum(@. K1θ*fθ) + K1u[1]*(-Vn1)



            pastΔu = shift_values(pastΔu, Δu)

            Vn1 = Vn1 + Δu

            if Vn1 > Vsat
               Vn1 = Vsat
            elseif  Vn1 < -Vsat
               Vn1 = -Vsat
            end

        end
        #vecfdΦ[i] = fdΦ[end]
        vecfθ[i] = fθ[end]
        Vn[i] = Vn1
        t[i] = (i-1)*ts
        x[i,:] = iter(pastx, Vn[i])
        pastx = x[i,:]
        x[i, 2] = x[i,2] + noise[i] 
    end  

    plotθ = plot(t, [180/pi*(x[:,2])], label="Θ")
    yaxis!(plotθ, "θ[°]" )
    title!(plotθ, "N1 = 1; N2 = 15; Nu = 15; θi = 10°")
    
    plotu = plot(t, x[:,5], label="tm")
    yaxis!(plotu, "Torque [Nm]")
    #plotdθdΦ = plot(t, [vecfdΦ x[:,3]], label=["fdΦ" "dΦ"])   
    plotdθdΦ = plot(t, [x[:,1], x[:,3]], label=["dΘ" "dΦ"])   
    yaxis!(plotdθdΦ, "Velocidade [rad/s]")
    plotVn = plot(t, Vn, label = "Vn")
    yaxis!(plotVn, "Tensão [V]")

    plotfθ = plot(t, 180/pi*vecfθ, label = "fθ")
    yaxis!(plotfθ, "free θ[°]")
    #plotfdΦ = plot(t, vecfdΦ, label = "fdΦ")

    plot(plotθ, plotVn, plotdθdΦ, plotu, plotfθ, layout = (5, 1), size = (1080, 720))
    
end

#ts = 10ms
begin
    Vsat = 9
    θ0 = pi/18
    time = 10
    N1 = 1
    N2 = 8
    Nu = 8

    λθ = 0.35
    λΔu = 0.5
    λu = 0.2

    simulation()
end