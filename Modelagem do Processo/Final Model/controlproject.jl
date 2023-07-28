using ControlSystems
using Plots; plotly()


#hθ0 = (2.5778044423376556e-6s + 1.392014398862334e-9(s^2)) / (2.5804699883620745e-6s + 5.2582774790868915e-6(s^2) - 0.00033019541708711493)
a0θ = 0
a1θ = 2.5778044423376556e-6
a2θ = 1.392014398862334e-9

b0θ = - 0.00033019541708711493
b1θ = 2.5804699883620745e-6
b2θ = + 5.2582774790868915e-6

#hΦ0 = (1.517295694759944e-6 + 8.193396751703698e-10s - 8.232895160271418e-12(s^3) - 1.5246102148650774e-8(s^2)) 
#       / (8.911975663556971e-9(s^2) + 1.8160118558711465e-8(s^3) - 1.1403711473374875e-6s)
a0Φ =1.517295694759944e-6
a1Φ = 8.193396751703698e-10
a2Φ= - 1.5246102148650774e-8
a3Φ = - 8.232895160271418e-12

b0Φ= 0
b1Φ= - 1.1403711473374875e-6
b2Φ= 8.911975663556971e-9
b3Φ= 1.8160118558711465e-8


#Hn Hθ/Hϕ = (0.0034536250000000005(s^2)) / (0.5886 - 0.005914375(s^2))
a0Hn = 0
a1Hn = 0
a2Hn = 0.0034536250000000005
b0Hn =0.5886
b1Hn =0
b2Hn =- 0.005914375


Hmaθ = tf([a2θ, a1θ, a0θ],[b2θ, b1θ, b0θ])
plot(pzmap(Hmaθ, title ="theta"))
zθ, pθ, kθ = zpkdata(Hmaθ)
zθ
pθ
kθ

HmaΦ = tf([a3Φ, a2Φ, a1Φ, a0Φ], [b3Φ, b2Φ, b1Φ, b0Φ])
pzmap(HmaΦ, title ="phi")
zΦ, pΦ, kΦ = zpkdata(HmaΦ)
zΦ
pΦ
kΦ

Hn = tf([a2Hn, a1Hn, a0Hn],[b2Hn, b1Hn, b0Hn])
pzmap(Hn)
zHn, pHn, kHn = zpkdata(Hn)
zHn
pHn
kHn


setPlotScale("dB")
bodeplot(Hmaθ)

Hdθ = c2d(Hmaθ, 1e-3)
bodeplot(Hdθ)

# function cancel_pole_zero(H)
#     z, p, k = zpkdata(H)
#     zeros_ = z[1]
#     poles_ = p[1]
#     zer_map = ones(length(zeros_))
#     pol_map = ones(length(poles_))
    
#     for i_z in eachindex(zeros_)
#         for i_p in eachindex(poles_)
#             if abs(zeros_[i_z] - poles_[i_p]) < 1e-3
#                 if (zer_map[i_z] == 1) && (pol_map[i_p] == 1)
#                     zer_map[i_z] = 0
#                     pol_map[i_p] = 0
#                 end
#             end 
#         end
#     end
#     print(pol_map)
    
#     H = tf([k[1]],[1])
#     for i_z in eachindex(zeros_)
#         if zer_map[i_z] == 1
#             H = H*tf([1, -zeros_[i_z]], [1])
#         end
#     end
#     for i_p in eachindex(poles_)
#         if pol_map[i_p] == 1
#             H = H*tf([1], [1, -poles_[i_p]])
#         end
#     end
#     return H   
# end

# Hmaθf = cancel_pole_zero(Hmaθ)
# HmaΦf = cancel_pole_zero(HmaΦ)

# #pzmap(Hmaθ)
# pzmap(Hmaθf)
# pzmap(HmaΦf)
# # pzmap(H)
# # bodeplot(Hmaθ)