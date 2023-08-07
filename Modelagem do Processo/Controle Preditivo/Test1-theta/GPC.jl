include("predict.jl")
using LinearAlgebra

function get_matrix(Nθ, Nu, λθ, λu)
    #Nθ = 10
    #Nu = 10

    #Ganhos Relativos: λθ + λΔu = 1
    #λθ = 0.55
    #λu = 0.25
    λΔu = 1 - λθ - λu

    #Normalização das variáveis 
    θ_bound = pi/9          # 20°
    Δu_bound = 3   #Vbatmax - V0
    u_bound = 6             #6V 

    #Ganhos Usados na função custo
    Gainθ = λθ/Nθ/θ_bound
    GainΔu = λΔu/Nu/Δu_bound
    Gainu = λu/u_bound

    #ts = 20ms
    Num = -0.005286550699417969z^-1 + 0.004616222333472475z^-2 + 0.0006703283659455013z^-3
    Den = 1.0 - 2.022214670021557z^-1 + 1.005503039109366z^-2 - 0.0008094941026986402z^-3

    Ã = (1 - z^(-1))*Den
    B = Num*z
    Ej, Fj = diophantine(Ã, Nθ)

    MG_Y, firsty, lasty = get_G_Y(Fj)

   # MG_Y # (y(k), y(k-1), y(k-2), y(k-3))

    MG_Y

    MG_Δu, firstu, lastu = get_G_Δu(B, Ej)
    MG_Δu
    
    MGΔu_free = MG_Δu[:,1:2]  # *Δu(k-2), Δu(k-1)
    
    MGΔu_Nu = MG_Δu[:,3:2+Nu]

    K1u, K1w = get_K1_u(MGΔu_Nu, Gainθ, GainΔu, Gainu)

    #f = MG_Y*[y(0), y(-1), y(-2)...] + MGΔu_free*[Δu(k-1)....] 
    #lei de controle: Δu(k) = K1u*u(k-1) + K1w*(f-r)

    return MG_Y, MGΔu_free, K1u, K1w
end

function get_matrix_θΦ(N1, N2, Nu, λθ, λΦ)
    #N1, N2, Nu, λθ, λΦ = 1, 4, 2, 0.3, 0.4
    λΔu = 1 - λθ - λΦ
    θ_bound = pi/9  #20°
    Φ_bound = 10    #20 rad 
    Δu_bound = 3    #3V

    Gainθ = λθ/(N2-N1+1)/θ_bound
    GainΦ = λΦ/(N2-N1+1)/Φ_bound
    GainΔu = λΔu/Nu/Δu_bound

    Numθ = -0.005286550699417969z^-1 + 0.004616222333472475z^-2 + 0.0006703283659455013z^-3
    Denθ = 1.0 - 2.022214670021557z^-1 + 1.005503039109366z^-2 - 0.0008094941026986402z^-3
    MG_Yθ, firstyθ, lastyθ, MG_Δuθ, firstuθ, lastuθ = get_matrixGain(Numθ, Denθ, N2)
    firstyθ
    lastyθ
    firstuθ
    lastuθ

    MG_Y_freeθ= MG_Yθ[N1:N2,:]
    MGΔu_freeθ = MG_Δuθ[N1:N2,1:2]
    MGΔu_forcedθ = MG_Δuθ[N1:N2,3:3+Nu-1]

    
    NumΦ = (0.015816538553838022z^3 - 0.029991235604570843z^2 + 0.011747148593551304z + 0.002011190364814053)z^-4
    DenΦ = (1.0z^4 - 3.0222146700215564z^3 + 3.0277177091309224z^2 - 1.0063125332120644z + 0.00080949410269864)z^-4
    MG_YΦ, firstyΦ, lastyΦ, MG_ΔuΦ, firstuΦ, lastuΦ = get_matrixGain(NumΦ, DenΦ, N2)
    firstyΦ
    lastyΦ
    MG_Yθ
    firstuΦ
    lastuΦ
    
    MG_Y_freeΦ= MG_YΦ[N1:N2,:]
    MGΔu_freeΦ = MG_ΔuΦ[N1:N2, 1:3]
    MGΔu_forcedΦ = MG_ΔuΦ[N1:N2, 4:4+Nu-1]

    K1θ, K1Φ = get_K1(MGΔu_forcedθ, Gainθ, MGΔu_forcedΦ, GainΦ, GainΔu)
    return K1θ, MG_Y_freeθ, MGΔu_freeθ, K1Φ, MG_Y_freeΦ, MGΔu_freeΦ
end

function get_matrix_θdΦ(Nθ, NdΦ, N2, Nu, λθ, λdΦ)
    #Nθ, NdΦ, N2, Nu, λθ, λdΦ = 1, 1, 4, 2, 0.3, 0.4
    λΔu = 1 - λθ - λdΦ
    θ_bound = pi/36  #5°
    dΦ_bound = 20    #5 rad/s 
    Δu_bound = 4    #3V

    Gainθ = λθ/(N2-Nθ+1)/θ_bound
    GaindΦ = λdΦ/(N2-NdΦ+1)/dΦ_bound
    GainΔu = λΔu/Nu/Δu_bound

    
    Numθ = (-2.5518240522015003e-5z^3 - 3.9977949724726136e-5z^2 + 5.552779253929561e-5z + 9.968397707445544e-6)*z^-4
    Denθ = (1.0z^4 - 2.8144178969338807z^3 + 2.7809051333513173z^2 - 1.1186891788559257z + 0.1521872086753235)*z^-4
    MG_Yθ, firstyθ, lastyθ, MG_Δuθ, firstuθ, lastuθ = get_matrixGain(Numθ, Denθ, N2)
    firstyθ
    lastyθ
    firstuθ
    lastuθ

    MG_Y_freeθ= MG_Yθ[Nθ:N2,:]
    MGΔu_freeθ = MG_Δuθ[Nθ:N2,1:3]
    MGΔu_forcedθ = MG_Δuθ[Nθ:N2,4:4+Nu-1]

    
    NumdΦ = (0.19591417797414887z^3 - 0.2872669541548613z^2 - 0.013237554224906335z + 0.10457282433264564)*z^-4
    DendΦ = (1.0z^4 - 2.8144178969338807z^3 + 2.7809051333513173z^2 - 1.1186891788559257z + 0.1521872086753235)*z^-4
    MG_YdΦ, firstydΦ, lastydΦ, MG_ΔudΦ, firstudΦ, lastudΦ = get_matrixGain(NumdΦ, DendΦ, N2)
    firstydΦ
    lastydΦ
    
    MG_YdΦ
    firstudΦ
    lastudΦ
    MG_ΔudΦ

    MG_Y_freedΦ= MG_YdΦ[NdΦ:N2,:]
    MGΔu_freedΦ = MG_ΔudΦ[NdΦ:N2, 1:3]
    MGΔu_forceddΦ = MG_ΔudΦ[NdΦ:N2, 4:4+Nu-1]

    K1θ, K1dΦ = get_K1(MGΔu_forcedθ, Gainθ, MGΔu_forceddΦ, GaindΦ, GainΔu)
    return K1θ, MG_Y_freeθ, MGΔu_freeθ, K1dΦ, MG_Y_freedΦ, MGΔu_freedΦ
end


begin
    τm = 540e-6
    kt = 0.65377
    kω = 0.7816
    kv = 0.0064877
    re = 6.05

    g = 9.80665
    rw = 0.035
    mb = 0.919
    mw = 0.046
    l = 0.062468307
    Iw = 2.8061902e-5
    Ib = 0.0040680128000000005

    a1 = Ib+mb*l^2
    c0 = mb*rw*l
    a2 = mb*g*l
    b1 = mb*rw^2 + mw*rw^2 + Iw
end

ts = 1.0e-5
function iter(x, Vn)    
    #println(Vn)
    dθ = x[1]
    θ = x[2]
    dΦ = x[3]
    Φ = x[4]
    u = x[5]
    
    A = [a1 c0*cos(θ); c0*cos(θ) b1]
    b1_ = -u + a2*sin(θ) -2kv*dθ + 2kv*dΦ
    b2_ = u + c0*(dθ^2)*sin(θ)+ 2kv*dθ-2kv*dΦ
    b = [b1_;b2_]
    
    x_f = A\b 
    
    d2θ = x_f[1]
    d2Φ = x_f[2]
    du = 0 # 
    x[5] = (τm)/(τm+ts)*x[5] + (ts)/(τm+ts)*(2*kt/re*(Vn + kω*dθ - kω*dΦ)) 
    #print(x[5])
    C = [d2θ; dθ; d2Φ; dΦ; du]
    
    return x + C.*ts    
end