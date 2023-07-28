using LaurentPolynomials
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
            G_Y[i, j] = Fj[i][-j+1]
        end
    end
    return G_Y, first_y, last_y
end
function get_G_Δu(B, Ej)
    EjB = []
    for i in eachindex(Ej)
        push!(EjB, Ej[i]*B*z^(i-1))
    end

    first_u = valuation(EjB[end])
    last_u = degree(EjB[end]) 

    colums_G_Δu = last_u- first_u + 1
    rows_G_Δu = length(EjB)
    
    G_Δu = zeros(rows_G_Δu, colums_G_Δu)
    for i in range(1, rows_G_Δu)
        for j in range(1, colums_G_Δu)
            G_Δu[i, j] = EjB[i][j-1]
        end
    end
    return G_Δu, first_u, last_u
end
function get_K1(G1, λ1, G2, λ2, λu)
    lenu = length(G1[1,:])
    len1 = length(G1[:,1])
    len2 = length(G2[:,1])
    G1t = transpose(G1)
    G2t = transpose(G2)
    I1 = λ1*Matrix(I, len1, len1)
    I2 = λ2*Matrix(I, len2, len2)
    Iu = λu*Matrix(I, lenu, lenu)
    A = G1t*I1*G1 + G2t*I2*G2 + Iu
    iA = inv(A)
    K1 = iA*G1t*I1
    K2 = iA*G2t*I2
    return K1[1,:], K2[1,:]
end


