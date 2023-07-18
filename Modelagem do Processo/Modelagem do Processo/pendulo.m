function main
    clear all
    clc
    teta0 = pi/18;
    teta1 = 0;
    phi0  = 0;
    phi1  = 0;
    
    x0 = [teta1 teta0 phi1 phi0];
    tspan = [0 5];
    options = odeset('Abstol', 1e-3);
    [t y] = ode45(@edos, tspan, x0, options);
    %plot(t, y(:, 1), t, y(:, 3))
    plot(t, y)
    %legend('teta1', 'phi1')
    legend('teta1', 'teta0', 'phi1', 'phi0')
    
    
    subplot(2,1,1);
    plot(t, y(:,1), t, y(:,3))
    title('Velocidade Angular')

    subplot(2,1,2);
    plot(t, y(:,2), t, y(:,4))
    title('Posição Angular')
    
end

function dxdt = edos(t, x)
    g = 9.81;
    r = 0.05;
    mb = 0.3;
    mw = 0.2;
    a = 0.1;
    k = 0.005*0;
    Iw = 1/2*mw*r^2;
    Ib = 1/3*mb*(2*a)^2;
    mu = 0.75; 
        
    teta1 = x(1);
    teta0 = x(2);
    phi1 = x(3);
    phi0 = x(4);
    
    kp = 0.8*0;
    u = kp*sin(teta0);
    
    Tteta = k*phi1 - k*teta1 + mb*g*a*sin(teta0) - u;
    
    Tf = k*teta1 - k*phi1 + u;
    Ta = sign(phi1)*mu*(mb*cos(teta0)^2+mw)*r;
    
    
    
    Tphi = 0;
    if abs(phi1) > 0.001
        Tphi = Tf - Ta;
    elseif abs(Tf) > abs(Ta)
        Tphi = sign(Tf)*(abs(Tf) - abs(Ta));
    else 
        Tphi = 0;
    end
    Tphi = -mb*g*cos(teta0)*sin(teta0)*r;
        
    Em = mb*r^2*phi1^2/2 + Ib*teta1^2/2 + mw*r^2*phi1^2/2 + Iw*phi1^2/2+ mb*g*a*cos(teta0)
    
    dxdt = [
        Tteta/(Ib + mb*a^2);
        teta1;
        Tphi/(Iw + mb*r^2);
        phi1
    ];
end
