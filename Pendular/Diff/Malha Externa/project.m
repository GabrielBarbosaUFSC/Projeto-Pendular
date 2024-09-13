clear;
G22 = zpk([-7.631, 7.631], [0 -30+30i -30-30i], -1.9542e6/365.3);

%Adicionando dois integrados (seguimento de referencia)
C = zpk([-30+30i -30-30i], [0 -15 -15], 1);

pd = -1.2 + 1.2*1i; %Ts = 2.5s 

phase_sis = - phase(pd - 0) ... %Controlador Prévio (com os cancelamentos) 
            - phase(pd + 30+30i) - phase(pd + 30-30i) - phase(pd - 0) + phase(pd - 7.631) + phase(pd + 7.631) ;% ... %Planta (com os cancelamentos)    
            %- pi; %Klr maior que zero 
z = real(pd) - imag(pd)/tan(-phase_sis);

C1 = C*zpk(z, [], 1);
C2 = C1*0.00166;
rlocus(G22*C2)

%MF = G22*C2/(1+G22*C2);
%pzmap(MF)
%step(MF)