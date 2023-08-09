function main
    clear all
    clc

    teta0 = pi/2;
    teta1 = 0;
    phi1 = 0;
    
    

    x0 = [teta1 teta0 phi1];
    tspan = [0 5];
    options = odeset('Abstol', 1e-3);
    [t y] = ode45(@edos, tspan, x0, options);
    plot(t, y)
    legend('teta1', 'teta0', 'phi1')
    subplot(3,1,1);
    plot(t, y(:,1), t, y(:,3))
    title('Velocidade Angular')

    subplot(3,1,2);
    plot(t, y(:,2), t, y(:,4))
    title('Posi��o Angular')
    
    subplot(3,1,3);
    plot(t, y(:,5))
    title('Energia')
end

function dxdt = edos(t, x)
    g = 9.80665;      % m/s^2
    rw = 0.035;       % m
    mb = 0.919;       % Kg
    mw = 0.046;       % Kg
    l = 0.062468307;  % m
    Iw = 2*2.8061902; % Kg.m^2
    Ib = 0.004068013; % kg.m^2
    kv = 0.0064877;
    
    a = Ib+mb*l^2;
    b = mb*rw*l;
    c = mb*g*l;
    d = mb*rw^2+mw*rw^2+Iw;
    
    teta1 = x(1);
    teta0 = x(2);
    phi1 = x(3);
        
    dx = zeros(3);
    dx(1) = (1/(a - (b^2 *(cos(teta0))^2)/d ))*(c*sin(teta0)-(b^2*teta1^2*sin(teta0)*cos(teta0))/(d) -2*kv*(1+(b*cos(teta0)/d))*(teta1-phi1));
    dx(2) = teta1;
    dx(3) = (1/d)*(b*teta1^2*sin(teta0) - b*dx(1)*cos(teta0) + 2*kv(teta1-phi1));

    dxdt = [
        dx(1);
        dx(2);
        dx(3);
    ];
end
    