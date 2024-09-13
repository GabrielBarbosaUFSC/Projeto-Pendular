clear;
load Ax0.mat
load bx0.mat
a1 = Ax0(1, 1); 
a2 = Ax0(1, 2);
a3 = Ax0(1, 3);
a4 = bx0(1);
b1 = Ax0(3, 1);
b2 = Ax0(3, 2);
b3 = Ax0(3, 3);
b4 = bx0(3);

%syms s
%den_theta = (s-b3)*(s^2-a1*s-a2) - a3*b1*s - a3*b2;
%num_theta = a4*s - a4*b3 + a3*b4;
%poles_theta = double(root(den_theta, s));
%zeros_theta = double(root(num_theta, s));
%den_phi =  (s-b3)*(s^2-a1*s-a2) - a3*b1*s - a3*b2;
%num_phi = b4*(s^2-a1*s-a2) + a4*(b1*s + b2);
%poles_phi = double(root(den_phi, s));
%zeros_phi = double(root(num_phi, s));


%Assumindo tsMF de 100ms (pd = -30), o polo em -431.89 é desprezível.
%Assim, considera-se a seguinte função (DEPOIS VERIFIQUE A INFLUENCIA DA FASE)
%G = zpk(0, [-6.5029, -431.89, +6.6986], a4);
G_theta_V = zpk(0, [-6.5029, +6.6986, -431.89], a4);


%Assumindo tsMf > 1s, o polo em -431.89 é desprezível. 
%Assim, considera-se a seguinte função(DEPOIS VERIFIQUE A INFLUENCIA DA FASE)
%Gphi_ = zpk([7.6306, -7.6306], [-6.5029, -431.89, +6.6986], b4);
G_phi_V =  zpk([7.6306, -7.6306], [-6.5029, +6.6986, -431.89], b4);


C1 = zpk([-6.5029 -24.71], [0 0], -206);
F1 = zpk([], -24.71, 24.71);


T2 = zpk((F1*C1*G_phi_V)/(1 + C1*G_theta_V));
G22 = zpk([-7.631, 7.631], [0 -30+30i -30-30i], -1.9542e6/365.3);
C2 = zpk([-30+30i -30-30i -1.211], [0 -15 -15], -0.00166*0.001*0);

rlocus(G22*C2)

%T1 = zpk((C1*F1 - 1)*G_phi_V);
%G2 = zpk([-7.63, 7.63], [0 0 6.7], -383.9*(5084*6.511)/(6.50*431.89))

%bode(T1, T2)



%rlocus(G2*C2)

%rlocus(C1*G_theta_V)
%bode(G1, G)
%step((F1*(C1*G_theta_V)/(1 + C1*G_theta_V)))

%Malha Externa
%G2 = zpk(-b2/b1, b3, b1);% b1);
%G22 = zpk([],b3, b4);

%Cff = zpk([], +b2/b1, b4/b1);
%Cff2 = tf([16.32 9.273], [1 5]);

%Gphi = G2 + G22*C1*(F1 - 1);    

%Gphi_2 = zpk(-6.688, 0, 257.4);
%C2 = zpk(-1, [0 -15], 0.019*0.164*15);
%F2 = tf(1, [1 1]);

%figure
%bode(tf(1, [5 7.07 1]))
%rlocus(Gphi_2*C2)

%figure
%step(C2*G2/(C2*G2 + 1))
%rlocus(G2*C2)

