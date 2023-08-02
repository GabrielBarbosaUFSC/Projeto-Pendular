using ControlSystems

ts = 1
Hcdx = tf([1, -1],[1], 1) 
Hdx = c2d(Hcdx, 1)

