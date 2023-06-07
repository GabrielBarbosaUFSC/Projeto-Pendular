function main
    clear all
    clc
    teta0 = pi/2;
    teta1 = 0;
    phi0 = 0;
    phi1 = 0;
    em0 = 0;
    
    x0 = [teta1 teta0 phi1 phi0 em0];
    tspan = [0 5];
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
    mb = 0.6;
    mw = 0.2;
    l = 0.10;
    Iw = 1/2*mw*rw^2;
    Ib = Iw*mb/mw;
    
    alpha = Ib+mb*l^2;
    beta = mb*rw^2+mw*rw^2+Iw;
    gamma = rw*l;
    eps = mb*g*l;
    
    teta1 = x(1);
    teta0 = x(2);
    phi1 = x(3);
    phi0 = x(4);
        
    dxdt = [
        (1/(alpha - gamma^2/beta*(cos(teta0))^2 ))*(eps*sin(teta0)-(gamma^2*teta1^2*sin(teta0)*cos(teta0))/(beta));
        teta1;
        (1/(beta - gamma^2*(cos(teta0)^2)/alpha))*(gamma*teta1^2*sin(teta0)-gamma*eps*sin(teta0)*cos(teta0)/alpha);
        phi1;
        0;
    ];
end
    