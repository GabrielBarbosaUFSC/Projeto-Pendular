function main
    clear all
    clc
    teta0 = pi/18;
    teta1 = 0;
    phi1 = 0;
    phi0 = 0;
    em0 = 0;
    
    x0 = [teta1 teta0 phi1 phi0 em0];
    tspan = [0 10];
    options = odeset('Abstol', 1e-6);
    [t y] = ode45(@edos, tspan, x0, options);
    plot(t, y)
    legend('teta1', 'teta0', 'phi1', 'phi0')
    subplot(3,1,1);
    plot(t, y(:,1), t, y(:,3))
    title('Velocidade Angular')

    subplot(3,1,2);
    plot(t, y(:,2), t, y(:,4))
    title('Posicao Angular')
    
    subplot(3,1,3);
    plot(t, y(:,5))
    title('Energia')
end

function dxdt = edos(t, x)
    teta1 = x(1);
    teta0 = x(2);
    phi1 = x(3);
    phi0 = x(4);

    g = 9.81;
    rw = 0.035;
    mb = 0.6;
    mw = 0.2;
    l = 0.10;
    Iw = 1/2*mw*rw^2;
    Ib = Iw*mb/mw;
    kv = 0;

    alpha = Ib+mb*l^2;
    beta = mb*rw^2 + mw*rw^2 + Iw;
    gamma = mb*rw*l;
    epsi = mb*g*l;

    u = 0;

    a_k = gamma*cos(teta0);
    b_k = kv*teta1 - kv*phi1 + u;
    c_k = -epsi*sin(teta0);
    d_k = -gamma*phi1^2*sin(teta0);

  
    phi2 = 1/(beta - a_k^2/alpha) * (b_k-d_k+ a_k*b_k/alpha+ a_k*c_k/alpha);
    teta2 = (-1/alpha)*(a_k*phi2 + b_k + c_k);

    KbR = Ib*teta1^2/2 + mb*l^2*teta1^2/2;
    KbT = mb*rw^2*phi1^2/2+ mb*rw*l*teta1*phi1*cos(teta0);
    Ub = mb*g*l*cos(teta0);
    KwT = mw*rw^2*phi1^2/2;
    KwR = Iw*phi1^2/2;
    Em = KbR+KbT+Ub+KwT+KwR;

    dxdt = [
        teta2;
        teta1;
        phi2;
        phi1;
        Em;
    ];
end



