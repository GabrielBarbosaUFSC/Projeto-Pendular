using Plots; plotly()

dt = randn(30)
dt = @. (300 + 100*dt)*1e-6

for i in eachindex(dt)
    if dt[i] <= 0
        println(i)
    end
end

begin
    t = zeros(length(dt))
    for i in eachindex(dt)
        if i != 1
            t[i] = t[i-1] + dt[i]
        else
            t[i] = dt[1]
        end
    end    
end
t
λ = -500

ω = zeros(length(dt))
for i in eachindex(dt)
    if i == 1
        ω[i] = exp(λ*t[1])
    else
        ω[i] = 1/dt[i]/λ*(exp(λ*(t[i-1] + dt[i])) - exp(λ*t[i-1]))
    end
end

ω
y = @. exp(λ*t)

plot(t, [y, ω])