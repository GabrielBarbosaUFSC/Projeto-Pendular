clear
G_theta_V = zpk(0, [-6.5029, +6.6986, -431.89], -129.0146);

%Adicionando dois integrados (seguimento de referencia para planta derivativa)
%Calcelando o polo lento da planta.
C = zpk([-6.5029], [0 0], -1);

pd = -30 + 30*1i; %Ts = 200ms 

phase_sis = - phase(pd - 0) ... %Controlador Prévio (com os cancelamentos) 
            - phase(pd - 6.6986) - phase(pd + 431.89);% ... %Planta (com os cancelamentos)    
            %- pi; %Klr maior que zero 
z = real(pd) - imag(pd)/tan(-phase_sis);

C1 = C*zpk(z, [], 1);
C2 = C1*206;
rlocus(G_theta_V*C2)
