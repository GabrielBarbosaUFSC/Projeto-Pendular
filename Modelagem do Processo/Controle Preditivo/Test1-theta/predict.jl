using LaurentPolynomials
using LinearAlgebra
z = Pol(:z)

function diophantine(Ã, n)
    dividend = z^0
    Ej = []
    Fjzj = []
    last_ej = Pol(0)
    for i in range(1,n)
        gain1 = -valuation(Ã)
        if (-valuation(dividend)) > gain1
            gain1 = -valuation(dividend)
        end
        a = Ã*z^gain1
        div = dividend*z^gain1
        
        gain2 = 0
        if degree(a) > degree(div)
            gain2 = degree(a) - degree(div)
        end 
        div = div*z^gain2

        ej, fj = divrem(div, a)

        ej, fj = ej*z^(-gain2), fj*z^(-gain2)

        fj = fj*z^(-gain1)
        ej = last_ej + ej
        push!(Ej, ej)
        push!(Fjzj, fj)
        dividend = fj
        last_ej = ej
    end
    for i in eachindex(Fjzj)
        Fjzj[i] = Fjzj[i]*z^(i)
    end
    return Ej, Fjzj
end
function get_last_dependency(Fj)
    min = valuation(Fj[1])
    for i in eachindex(Fj)
        if valuation(Fj[i]) < min
            min = valuation(Fj[i])
        end
    end
    return min
end
function get_first_dependency(Fj)
    max = degree(Fj[1])
    for i in eachindex(Fj)
        if degree(Fj[i]) > max
            max = degree(Fj[i])
        end
    end
    return max
end
function get_G_Y(Fj)
    first_y = get_first_dependency(Fj)
    last_y = get_last_dependency(Fj)
    colums_G_Y = first_y-last_y+1
    rows_G_Y = length(Fj)
    
    G_Y = zeros(rows_G_Y, colums_G_Y)
    for i in range(1, rows_G_Y)
        for j in range(1, colums_G_Y)
            G_Y[i, j] = Fj[i][first_y-j+1]
        end
    end
    return G_Y, first_y, last_y
end
function get_G_Δu(B, Ej)
    EjB = []
    for i in eachindex(Ej)
        push!(EjB, Ej[i]*B*z^(i-1)) # [Ej*B*z^(0)*Δu(k), Ej*B*z^(1)*Δu(k), Ej*B*z^(2)*Δu(k)]
    end

    first_u = valuation(EjB[end])
    last_u = degree(EjB[end]) 

    colums_G_Δu = last_u - first_u + 1
    rows_G_Δu = length(EjB)
    
    G_Δu = zeros(rows_G_Δu, colums_G_Δu)
    for i in range(1, rows_G_Δu)
        Eji = EjB[i]
        for j in range(1, colums_G_Δu)
            order = j-1 + first_u
            G_Δu[i, j] = Eji[order]
        end
    end

    return G_Δu, first_u, last_u
end
function get_K1(G1, λ1, G2, λ2, λu)
    Nu = length(G1[1,:])
    N1 = length(G1[:,1])
    N2 = length(G2[:,1])

    G1t = transpose(G1)
    Q1 = λ1*Matrix(I, N1, N1)

    G2t = transpose(G2)
    Q2 = λ2*Matrix(I, N2, N2)

    QΔu = λu*Matrix(I, Nu, Nu)

    A = G1t*Q1*G1 + G2t*Q2*G2 + QΔu
    iA = inv(A)

    K1 = -iA*G1t*Q1
    K2 = -iA*G2t*Q2
    return K1[1,:], K2[1,:]
end

function triangle_matrix(N, Nu)
    H = zeros(N, Nu)
    for i in eachindex(H[:,1])
        for j in eachindex(H[1,:])
            if i >= j
                H[i,j] = 1
            end
        end
    end 
    return H
end

function get_K1_u(G1, λ1, λΔu, λu)
    # G1 = [0.5 0; 0.75 0.5; 0.85 0.75]
    # λ1 = 0.5
    # λΔu =0.3
    # λu = 0.2

    Nu = length(G1[1,:])
    N = length(G1[:,1])

    #H = triangle_matrix(N, Nu)
    H = ones(1, Nu)
    Ht = transpose(H)
    Qu = λu

    G1t = transpose(G1)
    Q1 = λ1*Matrix(I, N, N)

    QΔu = λΔu*Matrix(I, Nu, Nu)

    A = G1t*Q1*G1 + Ht*Qu*H + QΔu
    iA = inv(A)

    Ku = -iA*Ht*Qu

    K1 = -iA*G1t*Q1
    return Ku[1], K1[1,:]
end

function get_matrixGain(Num, Den, N2)
    Ã = (1 - z^(-1))*Den
    B = Num*z
    Ej, Fj = diophantine(Ã, N2)
    MG_Y, firsty, lasty = get_G_Y(Fj)
    MG_Δu, firstu, lastu = get_G_Δu(B, Ej)
    return MG_Y, firsty, lasty, MG_Δu, firstu, lastu
end


