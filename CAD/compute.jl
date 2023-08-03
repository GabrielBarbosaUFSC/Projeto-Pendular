#Baixo

pesototal = 0
pesototal += 2*124
pesototal += 45*4
pesototal += 1.31*43 + 31*0.6 + 10*0.6923
pesototal += 2*27 + 2*3 + 36 + 2*30 + 2*37 + 63 + 10 + 19 + 5 + 3 + 5 

re = pesototal/917

dm = 919 - pesototal

V = 533209.08 #mm^3

ρi = dm/V

di = 0.00013905802204268529 #g/mm^3

begin
    v =  38785.474
    m =  37
    nm = m + di*v  
end

Ib = 0.0040680128000000005
mb = 0.919
l = 0.062468307
r_w = 0.035
g = 9.80665
m_w = 0.046
I_w = 2.8061902e-5
kv = 0.0064877
mb*l^2
a1  = Ib+mb*l^2
c0 = mb*r_w*l
a2 = mb*g*l
b1 = mb*r_w^2 + m_w*r_w^2 + I_w
