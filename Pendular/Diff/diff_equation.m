clear
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

syms detA(theta)
    detA(theta) = 1/( (Ib+mb*l^2)*(mb*rw^2 + mw*rw^2 + Iw) - (mb*rw*l*cos(theta))^2);

syms iA11(theta) iA12(theta) iA21(theta) iA22(theta)
    iA11(theta) = detA(theta)*(mb*rw^2 + mw*rw^2 + Iw);
    iA12(theta) = detA(theta)*(-mb*rw*l*cos(theta)); 
    iA21(theta) = detA(theta)*(-mb*rw*l*cos(theta));
    iA22(theta) = detA(theta)*(Ib+mb*l^2);

syms theta_k_V(theta) theta_k_dtheta_dphi(theta) theta_k_sin_theta(theta) theta_k_d2theta_sin(theta, dtheta)
    theta_k_V(theta)                    = (iA12(theta)-iA11(theta))*(2*kt/R);
    theta_k_dtheta_dphi(theta)          = (iA12(theta)-iA11(theta))*(2*kv + 2*kt*kw/R);
    theta_k_sin_theta(theta)            = iA11(theta)*mb*g*l*sin(theta);
    theta_k_d2theta_sin(theta, dtheta)  = iA12(theta)*mb*rw*l*(dtheta^2)*sin(theta);

syms d2theta(theta, dtheta, dphi, V)
    d2theta(theta, dtheta, dphi, V) = ... 
        theta_k_V(theta)*V + ...
        theta_k_dtheta_dphi(theta)*(dtheta-dphi) + ...
        theta_k_sin_theta(theta) + ...
        theta_k_d2theta_sin(theta, dtheta);

syms phi_k_V(theta) phi_k_dtheta_dphi(theta) phi_k_sin_theta(theta) phi_k_d2theta_sin(theta, dtheta)
    phi_k_V(theta)                    = (iA22(theta)-iA21(theta))*(2*kt/R);
    phi_k_dtheta_dphi(theta)          = (iA22(theta)-iA21(theta))*(2*kv + 2*kt*kw/R);
    phi_k_sin_theta(theta)            = iA21(theta)*mb*g*l*sin(theta);
    phi_k_d2theta_sin(theta, dtheta)  = iA22(theta)*mb*rw*l*(dtheta^2)*sin(theta);

syms d2phi(theta, dtheta, dphi, V)
    d2phi(theta, dtheta, dphi, V) = ... 
        phi_k_V(theta)*V + ...
        phi_k_dtheta_dphi(theta)*(dtheta-dphi) + ...
        phi_k_sin_theta(theta) + ...
        phi_k_d2theta_sin(theta, dtheta);

theta0 = 0;
dtheta0 = 0;
dphi0 = 0;
V0 = 0;

A = [ 
    diff(d2theta, dtheta) diff(d2theta, theta) diff(d2theta, dphi);
    1 0 0;
    diff(d2phi, dtheta) diff(d2phi, theta) diff(d2phi, dphi)
    ];

Ax0 = double(A(theta0, dtheta0, dphi0, V0));

b = [
     diff(d2theta, V);
     0;
     diff(d2phi, V);
     ];
bx0 = double(b(theta0, dtheta0, dphi0, V0));


