g = 9.81;
rw = 0.035;
mb = 0.6;
mw = 0.2;
l = 0.10;
Iw = 1/2*mw*rw^2;
Ib = Iw*mb/mw;
kv = 0.005;

dt2 = l^2*mb^2*rw^2 - (Ib + mb*l^2)*(Iw + mb*rw^2 + mw*rw^2);
at2t0 = -g*l*mb*(Iw + mb*rw^2 + mw*rw^2);
at2t1 = l*mb*rw*kv + (Iw + mb*rw^2 + mw*rw^2)*kv;
at2p0 = 0;
at2p1 = -l*mb*rw*kv - (Iw + mb*rw^2 + mw*rw^2)*kv;
bt2 = l*mb*rw + Iw + mb*rw^2 + mw*rw^2;

dp2 = Iw + mb*rw^2 + mw*rw^2 - (mb^2*rw^2*l^2)/(Ib + mb*l^2);
ap2t0 = (-g*l^2*mb^2*rw^2)/(Ib + mb*l^2);
ap2t1 = kv + (mb*l*rw*kv)/(Ib+mb*l^2);
ap2p0 = 0;
ap2p1 = -kv - (mb*l*rw*kv)/(Ib + mb*l^2);
bp2 = 1 + (mb*l*rw)/(Ib+mb*l^2);

A = [ at2t1/dt2 at2t0/dt2 at2p1/dt2 at2p0/dt2;
        1           0       0           0;
      ap2t1/dp2 ap2t0/dp2 ap2p1/dp2 ap2p0/dp2;
        0           0       1           0      ];

B = [ bt2/dt2; 0; bp2/dp2; 0 ];


ts  = 1/200;
I = eye(4);
C = inv(I - ts*A);
D = C*(ts*B); 

x = [0; 0.1; 0; 0];
u = 0;

t = 0:ts:2;
y = zeros(4, size(t, 2));
u = zeros(size(t, 2));

kp = 4;

for i = 1:size(t, 2)
    y(:,i) = x;
    teta0 = y(2,i);
    u(i) = kp*teta0;
    x = C*x + D*u(i); 
end


teta1 = y(1,:);
teta0 = y(2,:);
phi1 = y(3,:);
phi0 = y(4,:);

subplot(3,1,1)
plot(t, teta1, t, phi1);
title('vel ang');
legend('theta','phi');

subplot(3,1,2)
plot(t, teta0, t, phi0);
title('ang');
legend('theta','phi');

subplot(3,1,3)
plot(t, u);
title('controle');