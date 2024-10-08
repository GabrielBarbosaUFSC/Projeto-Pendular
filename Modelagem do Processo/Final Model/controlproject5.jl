using ControlSystems
using Plots; plotly()

θz0 = 0
θp0 = -1235.7262476675755
θp1 = -647.1134087815102
θp2 = 6.700833957274487
θp3 = -6.505057463635203
θk = -238900.20928917004

θp = [θp0, θp1, θp2, θp3]
Hθ = tf(zpk([θz0], θp, θk))
Hθ_delay = Hθ*delay(1e-3)

setPlotScale("dB")
bodeplot(Hθ, label = ["G_Hθ" "P_Hθ"])

Hdθ = c2d(Hθ, 10e-3)

Hdθ_delay = c2d(Hθ_delay, 10e-3)

2pi/200




# Φz0 = 7.632741006069605
# Φz1 = -7.632741032008387
# Φp0 = -1235.7262476675755
# Φp1 = -647.1134087815102
# Φp2 = 6.700833957274487
# Φp3 = -6.505057463635203
# Φp4 = 0
# Φk = 710880.5964456222

# Φz = [Φz0, Φz1]
# Φp = [Φp0, Φp1, Φp2, Φp3, Φp4]
# HΦ = zpk(Φz, Φp, Φk)

# dΦz = [Φz0, Φz1]
# dΦp = [Φp0, Φp1, Φp2, Φp3]
# HdΦ = zpk(dΦz, dΦp, Φk)
# pzmap(HdΦ)
# HddΦ =  c2d(HdΦ, 1e-3)
# pzmap(HddΦ)
# HddΦ = tf(HddΦ)





# Hd_θ = tf(c2d(Hθ, 1e-3))

# Hd_dΦ = tf(c2d(HdΦ, 1e-3))