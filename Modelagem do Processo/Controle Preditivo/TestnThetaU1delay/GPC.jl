include("predict.jl")
using LinearAlgebra
using Printf
using Latexify

function get_matrix_θ(N1, N2, Nu, λθ, λu, λΔu)
    # N1 = 1
    # N2 = 8
    # Nu = 1

    # λθ = 0.5
    # λΔu = 0.3
    # λu = 0.2
    #N1, N2, Nu, λθ, λu, λΔu = 1, 4, 2, 0.3, 0.4, 0.2
    #λΔu = 1 - λθ - λu
    θ_bound = pi/12  #1° 
    Δu_bound = 4    #
    u_bound = 1     #

    Gainθ = λθ/(N2-N1+1)/θ_bound^2
    Gainu = λu/u_bound^2
    GainΔu = λΔu/Nu/Δu_bound^2


    @printf "\nN1 = %d" N1
    @printf "\nN2 = %d" N2
    @printf "\nNu = %d" Nu
    @printf "\n Gainθ = %.4f" Gainθ
    @printf "\n Gainu = %.4f" Gainu
    @printf "\n GainΔu = %.4f" GainΔu


    #ts = 10ms
   
    Numθ = ( -0.0022885069917117917z^3 + 0.0015904058880837901z^2 + 0.0006976931945916441z + 4.079090360793572e-7)z^(-5)
    Denθ = (1.0z^4 - 2.007876236602047z^3 + 1.0050730397564838z^2 - 0.0015548225118057796z + 6.664713969501098e-9)z^(-4)

    MG_Yθ, firstyθ, lastyθ, MG_Δuθ, firstuθ, lastuθ = get_matrixGain(Numθ, Denθ, N2)
    
    # println("MG_Yθ:")
    # println(latexify(MG_Yθ; fmt=FancyNumberFormatter(3)))
    
    # println("\nMG_Δufθ:")
    # println(latexify(MG_Δuθ[:,1:4]; fmt=FancyNumberFormatter(3)))
    
    # println("\nG")
    # println(latexify(MG_Δuθ[:,5:end]; fmt=FancyNumberFormatter(3)))


    # firstyθ
    # lastyθ
    # firstuθ
    # lastuθ
    # @printf "\nlastuθ = %d" lastuθ 
    # @printf "\nfirstuθ = %d" firstuθ

    
    MG_Δuθ

    MG_Y_freeθ= MG_Yθ[N1:N2,:]
    MGΔu_freeθ = MG_Δuθ[N1:N2,1:4]
    
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
    
    MGΔu_forcedθ = MG_Δuθexp[N1:N2,5:5+Nu-1]

    M = ones(1, Nu)
    
    K1θ, K1u, Kfullθ, Kfullu  = get_K1(MGΔu_forcedθ, Gainθ, M, Gainu, GainΔu, true)
    return K1θ, MG_Y_freeθ, MGΔu_freeθ, K1u, Kfullθ, Kfullu, MGΔu_forcedθ
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