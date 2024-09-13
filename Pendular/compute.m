rw = 3.5e-2;
mb = 9.19e-1;
mw = 4.6e-2;
Ib = 4.068e-3;
Iw = 5.612e-5;
kv = 6.488e-3;
g = 9.801;
l = 6.247e-2;
kt = 6.538e-1; 
kw = 7.816e-1;
R = 6.05;

detA = @(x) 1./( (Ib+mb*l^2)*(mb*rw^2 + mw*rw^2 + Iw) - (mb*rw*l*cos(x)).^2);
iA11 = @(x) detA(x).*(mb*rw^2 + mw*rw^2 + Iw);
iA12 = @(x) detA(x).*(-mb*rw*l*cos(x)); 
iA21 = iA12;
iA22 = @(x) detA(x)*(Ib+mb*l^2);


d2theta_k_V = @(x) 2*(iA12(x)-iA11(x))*(kt/R);
d2theta_k_dphi_dtheta = @(x) 2*kv*(iA12(x)-iA11(x))+2*kt*kw/R*(iA12(x)-iA11(x));
d2theta_k_sin_theta =  @(x) iA11(x)*mb*g*l.*sin(x);
d2theta_k_dtheta2 = @(x) iA12(x)*mb*rw*l.*sin(x);


d2phi_k_V = @(x) 2*(iA22(x)-iA21(x))*(kt/R);
d2phi_k_dphi_dtheta = @(x) 2*kv*(iA22(x)-iA21(x))+2*kt*kw/R*(iA22(x)-iA21(x));
d2phi_k_sin_theta =  @(x) iA21(x)*mb*g*l.*sin(x);
d2phi_k_dtheta2 = @(x) iA22(x)*mb*rw*l.*sin(x);

angle = linspace(0, 90, 1000)';
x = angle/180*pi;

k1 = d2theta_k_V(x);
k2 = d2theta_k_dphi_dtheta(x);
k3 =  d2theta_k_sin_theta(x);
k4 = d2theta_k_dtheta2(x);

k5 = d2phi_k_V(x);
k6 = d2phi_k_dphi_dtheta(x);
k7 = d2phi_k_sin_theta(x);
k8 = d2phi_k_dtheta2(x);



close all
figure 
subplot(2,2,1);
plot(angle, [k1 k5], LineWidth=2)
grid on
legend("Vtheta", "Vphi")

subplot(2,2,2);
plot(angle, [k2 k6], LineWidth=2)
grid on 
legend("dphitheta", "dphiphi")

subplot(2,2,3);
plot(angle, [k3 k7], LineWidth=2)
grid on
legend("sintehta", "sinphi")

subplot(2,2,4);
plot(angle, [k4 k8], LineWidth=2)
grid on
legend("d2sintheta", "d2sinphi")



% viA11 = detA(x).*iA11;
% viA12 = detA(x).*iA12(x);
% viA21 = detA(x).*iA21(x);
% viA22 = detA(x).*iA22;
% 
% close all
% figure 
% plot(angle, [viA11 viA12 viA21 viA22], LineWidth=2)
% grid on


%e11 = (viA11(1) - viA11(end))/(viA11(1))
%e12 = (viA12(1) - viA12(end))/(viA12(1))
%e21 = (viA21(1) - viA21(end))/(viA21(1))
% %e22 = (viA22(1) - viA22(end))/(viA22(1))
% 
% a11 = viA11(end);
% a12 = viA21(end);







