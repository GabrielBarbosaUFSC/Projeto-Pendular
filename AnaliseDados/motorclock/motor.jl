using Plots; plotly()
using Noise
τr = 1e-1

function motor_iter(ypast, u, Δt)
    return ypast*τr/(τr+Δt) + Δt*u/(τr+Δt)
end

ts = 5e-3
len = Int(trunc(10/ts))
time = range(0,10, len)

voltage = @. sin(2*pi*time)

motor_res = zeros(len)
motor_res[1] = 0
for i in eachindex(voltage)
    if i != 1
        motor_res[i] = motor_iter(motor_res[i-1], voltage[i], ts)
    end
end

plot(time, [voltage motor_res])

τm = 0.8e-1

r_mod_ω = @. abs(motor_res)
n_mod_ω = add_gauss(r_mod_ω, 0.05)

ω = zeros(len)
ω1 = zeros(len)
ω2 = zeros(len)
f_mod_ω = zeros(len)

for i in eachindex(ω)
    if i != 1
        
        f_mod_ω[i] =  (τm/10)/(τm/10 + ts)*f_mod_ω[i-1] +  (ts)/(τm/10 + ts)*n_mod_ω[i-1]
        
        ω1[i] = (τm)/(τm + ts)*ω1[i-1] + (ts)/(τm + ts)*abs(voltage[i-1])
        ω2[i] = abs((τm)/(τm + ts)*ω1[i-1] - (ts)/(τm + ts)*abs(voltage[i-1]))

        d1 = abs( f_mod_ω[i] - ω1[i])
        d2 = abs( f_mod_ω[i] - ω2[i])
    
        if d1 < d2
            ω[i] = n_mod_ω[i]*sign(voltage[i-1])
        else d2 < d1
            ω[i] = -n_mod_ω[i]*sign(voltage[i-1])
        end 

    end
end

begin
    p1 = plot(time, [voltage motor_res ω n_mod_ω], label =["u" "w real" "w calc" "n_mod_ω"])
    p2 = plot(time, [ω ω1 ω2 f_mod_ω], label =["w calc" "w1" "w2" "f_mod_ω"])
    plot(p1, p2, layout=(2, 1))   
end
