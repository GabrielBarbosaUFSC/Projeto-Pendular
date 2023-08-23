include("predict.jl")
using LinearAlgebra
using Printf

function get_matrix_θ(N1θ, N1dΦ, N2, Nu, λθ, λdΦ, λΔu)
    # N1θ = 2
    # N1dΦ = 4
    # N2 = 4
    # Nu = 2
    # λθ = 0.5
    # λdΦ = 0.5
    # λΔu = 0.5
    #λΔu = 1 - λθ - λu
    θ_bound = pi/12  #1° 
    dΦ_bound = 1 #1 rad/s
    Δu_bound = 4    #     #

    Gainθ = λθ/(N2-N1θ+1)/θ_bound^2
    GaindΦ = λdΦ/dΦ_bound^2
    GainΔu = λΔu/Nu/Δu_bound^2

    #ts = 10ms
   
    Numθ = ( -0.0022885069917117917z^3 + 0.0015904058880837901z^2 + 0.0006976931945916441z + 4.079090360793572e-7)z^(-5)
    Denθ = (1.0z^4 - 2.007876236602047z^3 + 1.0050730397564838z^2 - 0.0015548225118057796z + 6.664713969501098e-9)z^(-4)

    MG_Yθ, firstyθ, lastyθ, MG_Δuθ, firstuθ, lastuθ = get_matrixGain(Numθ, Denθ, N2)
    firstyθ
    lastyθ
    firstuθ
    lastuθ
    @printf "\nlastuθ = %d" lastuθ 
    @printf "\nfirstuθ = %d" firstuθ 
    MG_Δuθ

    MG_Y_freeθ= MG_Yθ[N1θ:N2,:]
    MGΔu_freeθ = MG_Δuθ[N1θ:N2,1:4]
    
    MG_Δuθ
    MG_Δuθexp = zeros(N2, -firstuθ +Nu)
    
    j = length(MG_Δuθ)
    if j > length(MG_Δuθexp)
        j = length(MG_Δuθexp)
    end
    
    for i in range(1,j)
        MG_Δuθexp[i] = MG_Δuθ[i]
    end
    MG_Δuθexp
    
    MGΔu_forcedθ = MG_Δuθexp[N1θ:N2,5:5+Nu-1]


    NumdΦ = (0.8870322147307497z^3 - 1.7780748068734575z^2 + 0.8843574938775228z + 0.0015070804459076978)z^(-5)
    DendΦ = (1.0z^4 - 2.007876236602047z^3 + 1.0050730397564838z^2 - 0.0015548225118057796z + 6.664713969501098e-9)z^(-4)

    MG_YdΦ, firstydΦ, lastydΦ, MG_ΔudΦ, firstudΦ, lastudΦ = get_matrixGain(NumdΦ, DendΦ, N2)
    firstydΦ
    lastydΦ
    firstudΦ
    lastudΦ
    @printf "\nlastudΦ = %d" lastudΦ 
    @printf "\nfirstudΦ = %d" firstudΦ 
    MG_ΔudΦ

    MG_Y_freedΦ= MG_YdΦ[N1dΦ:N2,:]
    MGΔu_freedΦ = MG_ΔudΦ[N1dΦ:N2,1:4]
    
    MG_ΔudΦ
    MG_ΔudΦexp = zeros(N2, -firstudΦ +Nu)

    j = length(MG_ΔudΦ)
    if j > length(MG_ΔudΦexp)
        j = length(MG_ΔudΦexp)
    end
    
    for i in range(1,j)
        MG_ΔudΦexp[i] = MG_ΔudΦ[i]
    end
    MG_ΔudΦexp

    MGΔu_forceddΦ = MG_ΔudΦexp[N1dΦ:N2,5:5+Nu-1]
    
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

ts = 10e-5
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