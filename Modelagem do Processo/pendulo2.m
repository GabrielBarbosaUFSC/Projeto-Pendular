function main
    clear all
    clc
    teta0 = pi/18;
    teta1 = 0;
    phi0 = 0;
    phi1 = 0;
    em0 = 0.5*9.81*0.1*cos(teta0);
    
    x0 = [teta1 teta0 phi1 phi0 em0];
    tspan = [0 20];
    options = odeset('Abstol', 1e-3);
    [t y] = ode45(@edos, tspan, x0, options);
    plot(t, y)
    legend('teta1', 'teta0', 'phi1', 'phi0')
    subplot(3,1,1);
    plot(t, y(:,1), t, y(:,3))
    title('Velocidade Angular')

    subplot(3,1,2);
    plot(t, y(:,2), t, y(:,4))
    title('Posição Angular')
    
    subplot(3,1,3);
    plot(t, y(:,5))
    title('Energia')
end

function dxdt = edos(t, x)
    g = 9.81;
    rw = 0.035;
    mb = 0.5;
    mw = 0.200;
    l = 0.10;
    kv = 0.005*0;
    Iw = 1/2*mw*rw^2;
    Ib = 1/3*mb*(2*l)^2 + mb*l^2;
    mu = 0.75*0;
    
    teta1 = x(1);
    teta0 = x(2);
    phi1 = x(3);
    phi0 = x(4);
    
    Tteta = mb*g*l*sin(teta0);
    Tphi = 0;
    
    Kb = mb*rw^2*phi1^2/2 + Ib*teta1^2/2;
    Ub = mb*g*l*cos(teta0);
    Kw = mw*rw^2*phi1^2/2 + Iw*phi1^2/2;
    
    dEm = (Kb + Ub + Kw) - x(5);
    
    dxdt = [
        Tteta/(Ib);
        teta1;
        Tphi/((mb+mw)*rw^2+Iw);
        phi1;
        dEm;
    ];
end
    